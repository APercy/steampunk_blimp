function steampunk_blimp.testDamage(self, velocity, position)
    if self._last_accell == nil then return end
    local p = position --self.object:get_pos()
    local collision = false
    local low_node_pos = -2.5
    if self._last_vel == nil then return end
    --lets calculate the vertical speed, to avoid the bug on colliding on floor with hard lag
    if math.abs(velocity.y - self._last_vel.y) > 2 then
		local noded = airutils.nodeatpos(airutils.pos_shift(p,{y=low_node_pos}))
	    if (noded and noded.drawtype ~= 'airlike') then
		    collision = true
	    else
            self.object:set_velocity(self._last_vel)
            --self.object:set_acceleration(self._last_accell)
            self.object:set_velocity(vector.add(velocity, vector.multiply(self._last_accell, self.dtime/8)))
        end
    end
    local impact = math.abs(steampunk_blimp.get_hipotenuse_value(velocity, self._last_vel))
    if impact > 2 then
        if self.colinfo then
            collision = self.colinfo.collides
            --core.chat_send_all(impact)
        end
    end

    if collision then
        --self.object:set_velocity({x=0,y=0,z=0})
        local damage = impact -- / 2
        self.hp = self.hp - damage
        if self.hp < steampunk_blimp.min_hp then self.hp = steampunk_blimp.min_hp end
        core.sound_play("steampunk_blimp_collision", {
            --to_player = self.driver_name,
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 1.0,
        }, true)
        if damage > 5 then
            self._power_lever = 0
        end

        if self.driver_name then
            local player_name = self.driver_name

            local player = core.get_player_by_name(player_name)
            if player then
		        if player:get_hp() > 0 then
			        player:set_hp(player:get_hp()-(damage/2))
		        end
            end
            if self._passenger ~= nil then
                local passenger = core.get_player_by_name(self._passenger)
                if passenger then
		            if passenger:get_hp() > 0 then
			            passenger:set_hp(passenger:get_hp()-(damage/2))
		            end
                end
            end
        end

    end
    airutils.setText(self, self._vehicle_name)
end

local function do_attach(self, player, slot)
    if slot == 0 then return end
    if self._passengers[slot] == nil then
        local name = player:get_player_name()
        --core.chat_send_all(self.driver_name)
        self._passengers[slot] = name
        player:set_attach(self._passengers_base[slot], "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
        
        if airutils.is_mcl then
            mcl_player.player_attached[name] = true
        elseif airutils.is_repixture then
            rp_player.player_attached[name] = true
        else
            player_api.player_attached[name] = true
        end
    end
end

function steampunk_blimp.check_passenger_is_attached(self, name)
    local is_attached = false
    if is_attached == false then
        for i = steampunk_blimp.max_seats,1,-1
        do
            if self._passengers[i] == name then
                is_attached = true
                break
            end
        end
    end
    return is_attached
end

--this method checks each 1 second for a disconected player who comes back
function steampunk_blimp.rescueConnectionFailedPassengers(self)
    self._disconnection_check_time = self._disconnection_check_time + self.dtime
    if self._disconnection_check_time > 1 then
        --core.chat_send_all(dump(self._passengers))
        self._disconnection_check_time = 0
        for i = steampunk_blimp.max_seats,1,-1
        do
            if self._passengers[i] then
                local player = core.get_player_by_name(self._passengers[i])
                if player then --we have a player!
                    local is_attached = nil
                    if airutils.is_mcl then
                        is_attached = mcl_player.player_attached[self._passengers[i]]
                    elseif airutils.is_repixture then
                        is_attached = rp_player.player_attached[self._passengers[i]]
                    else
                        is_attached = player_api.player_attached[self._passengers[i]]
                    end

                    if is_attached == nil then --but isn't attached?
                        --core.chat_send_all("okay")
		                if player:get_hp() > 0 then
                            self._passengers[i] = nil --clear the slot first
                            do_attach(self, player, i) --attach
		                end
                    end
                end
            end
        end
    end
end

-- attach passenger
function steampunk_blimp.attach_pax(self, player, slot)
    slot = slot or 0

    --verify if is locked to non-owners
    if self._passengers_locked == true then
        local name = player:get_player_name()
        local can_bypass = core.check_player_privs(player, {protection_bypass=true})
        local is_shared = false
        if name == self.owner or can_bypass then is_shared = true end
        for k, v in pairs(self._shared_owners) do
            if v == name then
                is_shared = true
                break
            end
        end
        if is_shared == false then
            core.chat_send_player(name,core.colorize('#ff0000', " >>> This blimp is currently locked for non-owners"))
            return
        end
    end


    if slot > 0 then
        do_attach(self, player, slot)
        return
    end
    --core.chat_send_all(dump(self._passengers))

    --now yes, lets attach the player
    --randomize the seat
    local t = {1,2,3,4,5,6,7}
    for i = 1, #t*2 do
        local a = math.random(#t)
        local b = math.random(#t)
        t[a],t[b] = t[b],t[a]
    end

    --core.chat_send_all(dump(t))

    for k,v in ipairs(t) do
        local i = t[k] or 0
        if self._passengers[i] == nil then
            do_attach(self, player, i)
            --core.chat_send_all(i)
            break
        end
    end
end

function steampunk_blimp.dettach_pax(self, player, side)
    side = side or "r"
    if player then
        local name = player:get_player_name() --self._passenger
        if self.driver_name == name then
            self.driver_name = nil
            self._at_control = false
        end

        steampunk_blimp.remove_hud(player)

        -- passenger clicked the object => driver gets off the vehicle
        for i = steampunk_blimp.max_seats,1,-1
        do
            if self._passengers[i] == name then
                self._passengers[i] = nil
                self._passengers_base_pos[i] = steampunk_blimp.copy_vector(steampunk_blimp.passenger_pos[i])
                --break
            end
        end

        -- detach the player
        player:set_detach()
        if airutils.is_mcl then
            mcl_player.player_attached[name] = nil
            mcl_player.player_set_animation(player, "stand", 30)
        elseif airutils.is_repixture then
            rp_player.player_attached[name] = nil
            rp_player.player_set_animation(player, "stand", 30)
        else
            player_api.player_attached[name] = nil
            player_api.set_animation(player, "stand")
        end

        -- move player down
        core.after(0.1, function(pos)
            local rotation = self.object:get_rotation()
            local direction = rotation.y

            if side == "l" then
                direction = direction - math.rad(180)
            end

            local move = 5
            pos.x = pos.x + move * math.cos(direction)
            pos.z = pos.z + move * math.sin(direction)
            if self.isinliquid then
                pos.y = pos.y + 1
            else
                pos.y = pos.y - 2.5
            end
            player:set_pos(pos)
        end, player:get_pos())
    end
end

function steampunk_blimp.textures_copy()
    local tablecopy = {}
    for k, v in pairs(steampunk_blimp.textures) do
      tablecopy[k] = v
    end
    return tablecopy
end

--this function needs an urgent refactory to be independent, but not today :(
local function paint(self, write_prefix)
    write_prefix = write_prefix or false

    local l_textures = steampunk_blimp.textures_copy()
    for _, texture in ipairs(l_textures) do
        local indx = texture:find(steampunk_blimp.color1_texture)
        if indx then
            if not airutils.is_repixture then
                l_textures[_] = "wool_".. self.color..".png"
            else
                l_textures[_] = "rp_default_reed_block_side.png^[colorize:"..airutils.colors[self.color]
            end
        end
        indx = texture:find(steampunk_blimp.color2_texture)
        if indx then
            if not airutils.is_repixture then
                l_textures[_] = "wool_".. self.color2..".png"
            else
                l_textures[_] = "rp_default_reed_block_side.png^[colorize:"..airutils.colors[self.color2]
            end
        end

        indx = texture:find('steampunk_blimp_alpha_logo.png')
        if indx then
            l_textures[_] = self.logo
        end
        if airutils._use_signs_api and write_prefix == true then
            indx = texture:find('airutils_name_canvas.png')
            if indx then
                l_textures[_] = "airutils_name_canvas.png^"..airutils.convert_text_to_texture(self._ship_name, self._name_color or 0, self._name_hor_aligment or 0.8)
            end
        end
    end
    self.object:set_properties({textures=l_textures})
end

function steampunk_blimp.set_logo(self, texture_name)
    if texture_name == "" or texture_name == nil then
        self.logo = "steampunk_blimp_alpha_logo.png"
    elseif texture_name then
        self.logo = texture_name
    end
    paint(self)
end

--painting
function steampunk_blimp.paint(self, colstr)
    if colstr then
        self.color = colstr
        paint(self)
    end
end
function steampunk_blimp.paint2(self, colstr)
    if colstr then
        self.color2 = colstr
        paint(self,true)
    end
end

--remove blimp objects
function steampunk_blimp.remove_blimp(self)
    if self._engine_running == true then
        steampunk_blimp.start_furnace(self)
    end
    if self._boiler_pressure > 0 then
        minetest.sound_play({name = "default_cool_lava"},
            {object = self.object, gain = 1.0,
                pitch = 1.0,
                max_hear_distance = 32,
                loop = false,}, true)
    end
    self._boiler_pressure = 0

    if self.sound_handle then
        core.sound_stop(self.sound_handle)
        self.sound_handle = nil
    end

    for i = steampunk_blimp.max_seats,1,-1 
    do
        if self._passengers_base[i] then self._passengers_base[i]:remove() end
    end

    local obj_children = self.object:get_children()
    for _, child in ipairs(obj_children) do
        child:remove()
    end

    airutils.destroy_inventory(self)
    self.inv = nil
    self._inv_id = nil
    
    self.object:remove()
end

function steampunk_blimp.get_blimp_back(self, player, overload)
    if not player then return end
    local remove_it = self._remove or false --for efemeral blimp
    local pos = self.object:get_pos()
    local lua_ent = self.object:get_luaentity()
    local staticdata = lua_ent:get_staticdata(self)
    --local player = core.get_player_by_name(self.owner)

    steampunk_blimp.remove_blimp(self)

    if remove_it == false then
        pos.y=pos.y+2

        local stack = ItemStack(self.item)
        local stack_meta = stack:get_meta()
        stack_meta:set_string("staticdata", staticdata)

        if player then
            local inv = player:get_inventory()
            if inv then
                if inv:room_for_item("main", stack) then
                    inv:add_item("main", stack)
                else
                    core.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5}, stack)
                end
            end
        else
            core.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5}, stack)
        end
    end
end

-- destroy the boat
function steampunk_blimp.destroy(self, overload)
    local remove_it = self._remove or false --for efemeral blimp
    local pos = self.object:get_pos()
    local lua_ent = self.object:get_luaentity()
    local staticdata = lua_ent:get_staticdata(self)
    local player = core.get_player_by_name(self.owner)

    steampunk_blimp.remove_blimp(self)

    if remove_it == false then
        pos.y=pos.y+2
        for i=1,7 do
            core.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:steel_ingot')
        end

        for i=1,7 do
            core.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:mese_crystal')
        end

        core.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'steampunk_blimp:boat')
        core.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:diamond')
    end
end

--returns 0 for old, 1 for new
function steampunk_blimp.detect_player_api(player)
    local player_proterties = player:get_properties()
    local mesh = "character.b3d"
    if player_proterties.mesh == mesh then
        local models = player_api.registered_models
        local character = models[mesh]
        if character then
            if character.animations.sit.eye_height then
                return 1
            else
                return 0
            end
        end
    end

    return 0
end

function steampunk_blimp.checkAttach(self, player)
    local retVal = false
    if player then
        local player_attach = player:get_attach()
        if player_attach then
            for i = steampunk_blimp.max_seats,1,-1
            do
                if player_attach == self._passengers_base[i] then
                    retVal = true
                    break
                end
            end
        end
    end
    return retVal
end

function steampunk_blimp.clamp(value, min, max)
    local retVal = value
    if value < min then retVal = min end
    if value > max then retVal = max end
    --core.chat_send_all(value .. " - " ..retVal)
    return retVal
end

function steampunk_blimp.reclamp(value, min, max)
    local retVal = value
    local mid = (max-min)/2
    if value > min and value <= (min+mid) then retVal = min end
    if value < max and value > (max-mid) then retVal = max end
    --core.chat_send_all(value .. " - return: " ..retVal .. " - mid: " .. mid)
    return retVal
end

function steampunk_blimp.engineSoundPlay(self)
    --sound
    if self.sound_handle then core.sound_stop(self.sound_handle) end
    if self.sound_handle_pistons then core.sound_stop(self.sound_handle_pistons) end
    if self.object then
        local furnace_sound = "default_furnace_active"
        if steampunk_blimp.furnace_sound then
            self.sound_handle = core.sound_play({name = steampunk_blimp.furnace_sound.name},
                {object = self.object, gain = steampunk_blimp.furnace_sound.gain,
                    max_hear_distance = 5,
                    loop = true,})
        end

        self.sound_handle_pistons = core.sound_play({name = steampunk_blimp.piston_sound.name},--"default_item_smoke"},
            {object = self.object, gain = steampunk_blimp.piston_sound.gain,
                pitch = steampunk_blimp.piston_sound.pitch+((math.abs(self._power_lever)/100)/2),
                max_hear_distance = 32,
                loop = true,})
    end
end

function steampunk_blimp.engine_set_sound_and_animation(self)
    if self._last_applied_power ~= self._power_lever then
        --core.chat_send_all('test2')
        self._last_applied_power = self._power_lever
        self.object:set_animation_frame_speed(steampunk_blimp.iddle_rotation + (self._power_lever))
        if self._last_sound_update == nil then self._last_sound_update = self._power_lever end
        if math.abs(self._last_sound_update - self._power_lever) > 5 then
            self._last_sound_update = self._power_lever
            steampunk_blimp.engineSoundPlay(self)
        end
    end
    if self._engine_running == false then
        if self.sound_handle then
            core.sound_stop(self.sound_handle)
            self.sound_handle = nil
            --self.object:set_animation_frame_speed(0)
        end
    end
end


function steampunk_blimp.start_furnace(self)
    if self._engine_running then
	    self._engine_running = false
        -- sound and animation
        if self.sound_handle then
            core.sound_stop(self.sound_handle)
            self.sound_handle = nil
        end
    elseif self._engine_running == false and self._energy > 0 then
	    self._engine_running = true
        -- sound
        if self.sound_handle then core.sound_stop(self.sound_handle) end
        if self.object then
            local furnace_sound = "default_furnace_active"
            if airutils.is_mcl then furnace_sound = "fire_fire" end

            if steampunk_blimp.furnace_sound then
                self.sound_handle = core.sound_play({name = steampunk_blimp.furnace_sound.name},
                    {object = self.object, gain = steampunk_blimp.furnace_sound.gain,
                        max_hear_distance = 5,
                        loop = true,})
            end
        end
    end
end

function steampunk_blimp.copy_vector(original_vector)
    local tablecopy = {}
    for k, v in pairs(original_vector) do
      tablecopy[k] = v
    end
    return tablecopy
end

function steampunk_blimp.play_rope_sound(self)
    core.sound_play({name = "steampunk_blimp_rope"},
                {object = self.object, gain = 1,
                    max_hear_distance = 5,
                    ephemeral = true,})
end

function steampunk_blimp.table_copy(table_here)
    local tablecopy = {}
    for k, v in pairs(table_here) do
      tablecopy[k] = v
    end
    return tablecopy
end

function steampunk_blimp.pitch_by_accel(self, accel, hull_direction)
    local longit_accel = steampunk_blimp.dot(accel,hull_direction)
    local pitch_to_add = math.rad(3)*longit_accel
    if self._pitch_accel_accumulator == nil then self._pitch_accel_accumulator = 0 end
    self._pitch_accel_accumulator = self._pitch_accel_accumulator + pitch_to_add --accumulate
    if self._pitch_last_error == nil then self._pitch_last_error = 0 end
    --airutils.pid_controller(current_value, setpoint, last_error, d_time, kp, ki, kd, integrative)
    local kp = 25
    local ki = 0.001
    local kd = 0.05
    local output, last_error = airutils.pid_controller(self._pitch_accel_accumulator, 0.0, self._pitch_last_error, self.dtime, kp, ki, kd)
    self._pitch_last_error = last_error
    if output == output then --detect nan
        self._pitch_accel_accumulator = self._pitch_accel_accumulator + (output*self.dtime)
    else
        self._pitch_accel_accumulator = 0
    end

    return self._pitch_accel_accumulator
end

function steampunk_blimp.right_click_helm(self, clicker)
    local message = ""
	if not clicker or not clicker:is_player() then
		return
	end

    local name = clicker:get_player_name()
    local ship_self = nil

    local is_attached = false
    local seat = clicker:get_attach()
    if seat then
        ship_attach = seat:get_attach()
        if ship_attach then
            ship_self = ship_attach:get_luaentity()
            is_attached = true
        end
    end

    if is_attached then
        --minetest.chat_send_all('passengers: '.. dump(ship_self._passengers))
        --=========================
        --  form to pilot
        --=========================
        if ship_self.owner == "" then
            ship_self.owner = name
        end
        local can_bypass = minetest.check_player_privs(clicker, {protection_bypass=true})
        if ship_self.driver_name ~= nil and ship_self.driver_name ~= "" then
            --shows pilot formspec
            if name == ship_self.driver_name then
                steampunk_blimp.pilot_formspec(name)
                return
            end
            --lets take the control by force
            if name == ship_self.owner or can_bypass then
                --require the pilot position now
                steampunk_blimp.owner_formspec(name)
                return
            end
        else
            --check if is on owner list
            local is_shared = false
            if name == ship_self.owner or can_bypass then is_shared = true end
            for k, v in pairs(ship_self._shared_owners) do
                if v == name then
                    is_shared = true
                    break
                end
            end
            --normal user
            if is_shared == false then
                steampunk_blimp.pax_formspec(name)
            else
                --owners
                steampunk_blimp.pilot_formspec(name)
            end
        end
    end
end

local function clear_passengers(self)
    for i = steampunk_blimp.max_seats,1,-1
    do
        if self._passengers[i] ~= nil then
            local old_player = core.get_player_by_name(self._passengers[i])
            if not old_player then self._passengers[i] = nil end
        end
    end
end

function steampunk_blimp.right_click(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end

    local name = clicker:get_player_name()

    if self.owner == "" then
        self.owner = name
    end

    --core.chat_send_all('passengers: '.. dump(self._passengers))
    --=========================
    --  form to pilot
    --=========================
    local is_attached = false
    local seat = clicker:get_attach()
    if seat then
        local plane = seat:get_attach()
        if plane == self.object then is_attached = true end
    end

    --check error after being shot for any other mod
    if is_attached == false then
        for i = steampunk_blimp.max_seats,1,-1
        do
            if self._passengers[i] == name then
                self._passengers[i] = nil --clear the wrong information
                break
            end
        end
    end

    --shows pilot formspec
    if name == self.driver_name then
        if is_attached then
            steampunk_blimp.pilot_formspec(name)
        else
            self.driver_name = nil
        end
    --=========================
    --  attach passenger
    --=========================
    else
        local pass_is_attached = steampunk_blimp.check_passenger_is_attached(self, name)

        if pass_is_attached then
            local can_bypass = core.check_player_privs(clicker, {protection_bypass=true})
            if clicker:get_player_control().aux1 == true then --lets see the inventory
                local is_shared = false
                if name == self.owner or can_bypass then is_shared = true end
                for k, v in pairs(self._shared_owners) do
                    if v == name then
                        is_shared = true
                        break
                    end
                end
                if is_shared then
                    airutils.show_vehicle_trunk_formspec(self, clicker, steampunk_blimp.trunk_slots)
                end
            else
                if self.driver_name ~= nil and self.driver_name ~= "" then
                    --lets take the control by force
                    if name == self.owner or can_bypass then
                        --require the pilot position now
                        steampunk_blimp.owner_formspec(name)
                    else
                        steampunk_blimp.pax_formspec(name)
                    end
                else
                    --check if is on owner list
                    local is_shared = false
                    if name == self.owner or can_bypass then is_shared = true end
                    for k, v in pairs(self._shared_owners) do
                        if v == name then
                            is_shared = true
                            break
                        end
                    end
                    --normal user
                    if is_shared == false then
                        steampunk_blimp.pax_formspec(name)
                    else
                        --owners
                        steampunk_blimp.pilot_formspec(name)
                    end
                end
            end
        else
            --first lets clean the boat slots
            --note that when it happens, the "rescue" function will lost the historic
            clear_passengers(self)

            --attach normal passenger
            --if self._door_closed == false then
                steampunk_blimp.attach_pax(self, clicker)
            --end
        end
    end

end

function steampunk_blimp.right_click_hull(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end

    local name = clicker:get_player_name()

    local is_attached = false
    local airship = self.object:get_attach()
    airship_ent = airship:get_luaentity()
    if airship_ent then
        local pass_is_attached = steampunk_blimp.check_passenger_is_attached(airship_ent, name)

        if not pass_is_attached then
            local itmstck=clicker:get_wielded_item()
	        if itmstck then
                local item_name = ""
                if itmstck then item_name = itmstck:get_name() end
                --remove
                if (item_name == "airutils:repair_tool" or item_name == "keys:skeleton_key" or item_name == "default:skeleton_key") and
                    airship_ent._engine_running == false and (airship_ent.owner == name or core.check_player_privs(clicker, {protection_bypass=true})) then
                    local has_passengers = false
                    for i = steampunk_blimp.max_seats,1,-1
                    do
                        if airship_ent._passengers[i] ~= nil then
                            has_passengers = true
                            break
                        end
                    end

                    if not has_passengers then
                        steampunk_blimp.get_blimp_back(airship_ent, clicker, false)
                        return
                    end
                    return
                end
            end

            --first lets clean the boat slots
            --note that when it happens, the "rescue" function will lost the historic
            clear_passengers(airship_ent)
            steampunk_blimp.attach_pax(airship_ent, clicker)
            ---------------------------------------------
        end
    end
end

function steampunk_blimp.right_click_cannon(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end

    local name = clicker:get_player_name()

    local is_attached = false
    local airship = self.object:get_attach()
    airship_ent = airship:get_luaentity()
    if airship_ent then
        local pass_is_attached = steampunk_blimp.check_passenger_is_attached(airship_ent, name)

        if pass_is_attached then
            local side = "r"
            if self.object == airship_ent._cannon_l_interactor then
                side = "l"
            end
                
            steampunk_blimp.prepare_cannon_formspec(self, name, side)
        end
    end
end
