--
-- constants
--
local LONGIT_DRAG_FACTOR = 0.13*0.13
local LATER_DRAG_FACTOR = 2.0

--
-- entity
--

minetest.register_entity('steampunk_blimp:fire',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
    glow = 0,
	visual = "mesh",
	mesh = "steampunk_blimp_light.b3d",
    textures = {
            "steampunk_blimp_alpha.png",
        },
	},

    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

--
-- seat pivot
--
minetest.register_entity('steampunk_blimp:stand_base',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "steampunk_blimp_stand_base.b3d",
    textures = {"steampunk_blimp_alpha.png",},
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

minetest.register_entity("steampunk_blimp:blimp", {
    initial_properties = {
        physical = true,
        collide_with_objects = true, --true,
        collisionbox = {-4, -2.5, -4, 4, 10, 4}, --{-1,0,-1, 1,0.3,1},
        --selectionbox = {-0.6,0.6,-0.6, 0.6,1,0.6},
        visual = "mesh",
        backface_culling = false,
        mesh = "steampunk_blimp.b3d",
        textures = {
            steampunk_blimp.black_texture, --alimentacao balao
            "default_wood.png", --asa
            steampunk_blimp.canvas_texture, --asa
            steampunk_blimp.canvas_texture, --balao
            "wool_white.png", --faixas brancas nariz
            "wool_blue.png", --faixas azuis nariz
            steampunk_blimp.metal_texture, --pontas do balão
            steampunk_blimp.black_texture, --caldeira
            steampunk_blimp.forno_texture, --caldeira
            "default_junglewood.png", --casco
            steampunk_blimp.canvas_texture, --leme
            "default_junglewood.png", --leme
            steampunk_blimp.wood_texture, --timao
            "default_ladder_wood.png", --escada
            "default_wood.png", --mureta
            steampunk_blimp.wood_texture, --mureta
            steampunk_blimp.black_texture, --nacele rotores
            steampunk_blimp.wood_texture, --quilha
            "default_wood.png", --rotores
            steampunk_blimp.rotor_texture, --"steampunk_blimp_rotor.png", --rotores
            steampunk_blimp.black_texture, --suportes rotores
            "default_junglewood.png", --suporte timao
            "steampunk_blimp_rope.png", --cordas
            "wool_blue.png", --det azul
            "wool_white.png", --det branco
            steampunk_blimp.wood_texture, --fixacao cordas
            --"steampunk_blimp_metal.png",
            --"steampunk_blimp_red.png",
        },
    },
    textures = {},
    driver_name = nil,
    sound_handle = nil,
    static_save = true,
    infotext = "A nice blimp",
    lastvelocity = vector.new(),
    hp = 50,
    color = "#000000",
    timeout = 0;
    buoyancy = 0.15,
    max_hp = 50,
    anchored = false,
    physics = steampunk_blimp.physics,
    hull_integrity = nil,
    owner = "",
    _shared_owners = {},
    _engine_running = false,
    _power_lever = 0,
    _last_applied_power = 0,
    _at_control = false,
    _rudder_angle = 0,
    _baloon_buoyancy = 0,
    _show_hud = true,
    _energy = 1.0,--0.001,
    _passengers = {[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil,}, --passengers list
    _inv = nil,
    _inv_id = "",
    item = "steampunk_blimp:blimp",

    get_staticdata = function(self) -- unloaded/unloads ... is now saved
        return minetest.serialize({
            stored_baloon_buoyancy = self._baloon_buoyancy,
            stored_energy = self._energy,
            stored_owner = self.owner,
            stored_shared_owners = self._shared_owners,
            stored_hp = self.hp,
            stored_color = self.color,
            stored_anchor = self.anchored,
            stored_hull_integrity = self.hull_integrity,
            stored_item = self.item,
            stored_inv_id = self._inv_id,
            --stored_passengers = self._passengers, --passengers list
        })
    end,

	on_deactivate = function(self)
        airutils.save_inventory(self)
	end,

    on_activate = function(self, staticdata, dtime_s)
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self._baloon_buoyancy = data.stored_baloon_buoyancy
            self._energy = data.stored_energy
            self.owner = data.stored_owner
            self._shared_owners = data.stored_shared_owners
            self.hp = data.stored_hp
            self.color = data.stored_color
            self.anchored = data.stored_anchor
            self.buoyancy = data.stored_buoyancy
            self.surface_level = data.stored_surface_level
            self.hull_integrity = data.stored_hull_integrity
            self.item = data.stored_item
            self._inv_id = data.stored_inv_id
            --self._passengers = data.stored_passengers
            --minetest.debug("loaded: ", self._energy)
            local properties = self.object:get_properties()
            properties.infotext = data.stored_owner .. " nice blimp"
            self.object:set_properties(properties)
        end

        steampunk_blimp.paint(self, self.color)
        local pos = self.object:get_pos()

        local fire=minetest.add_entity(pos,'steampunk_blimp:fire')
        fire:set_attach(self.object,'',{x=0.0,y=0.0,z=0.0},{x=0,y=0,z=0})
	    self.fire = fire

        self._passengers_base = {[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil} --obj id
        self._passengers_base_pos = {
                [1]=steampunk_blimp.passenger_pos[1],
                [2]=steampunk_blimp.passenger_pos[2],
                [3]=steampunk_blimp.passenger_pos[3],
                [4]=steampunk_blimp.passenger_pos[4],
                [5]=steampunk_blimp.passenger_pos[5],} --curr pos
        self._passengers = {[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil,} --passenger names

        self._passengers_base[1]=minetest.add_entity(pos,'steampunk_blimp:stand_base')
        self._passengers_base[1]:set_attach(self.object,'',self._passengers_base_pos[1],{x=0,y=0,z=0})

        self._passengers_base[2]=minetest.add_entity(pos,'steampunk_blimp:stand_base')
        self._passengers_base[2]:set_attach(self.object,'',self._passengers_base_pos[2],{x=0,y=0,z=0})

        self._passengers_base[3]=minetest.add_entity(pos,'steampunk_blimp:stand_base')
        self._passengers_base[3]:set_attach(self.object,'',self._passengers_base_pos[3],{x=0,y=0,z=0})

        self._passengers_base[4]=minetest.add_entity(pos,'steampunk_blimp:stand_base')
        self._passengers_base[4]:set_attach(self.object,'',self._passengers_base_pos[4],{x=0,y=0,z=0})

        self._passengers_base[5]=minetest.add_entity(pos,'steampunk_blimp:stand_base')
        self._passengers_base[5]:set_attach(self.object,'',self._passengers_base_pos[5],{x=0,y=0,z=0})

        --animation load - stoped
        self.object:set_animation({x = 1, y = 47}, 0, 0, true)

        self.object:set_bone_position("low_rudder_a", {x=0,y=0,z=-40}, {x=-5.35,y=0,z=0})

        self.object:set_armor_groups({immortal=1})

        mobkit.actfunc(self, staticdata, dtime_s)

        self.object:set_armor_groups({immortal=1})        

		local inv = minetest.get_inventory({type = "detached", name = self._inv_id})
		-- if the game was closed the inventories have to be made anew, instead of just reattached
		if not inv then
            airutils.create_inventory(self, steampunk_blimp.trunk_slots)
		else
		    self.inv = inv
        end

    end,

    on_step = function(self, dtime)
        mobkit.stepfunc(self, dtime)
        
        local accel_y = self.object:get_acceleration().y
        local rotation = self.object:get_rotation()
        local yaw = rotation.y
        local newyaw=yaw
        local pitch = rotation.x
        local newpitch = pitch
        local roll = rotation.z

        local hull_direction = minetest.yaw_to_dir(yaw)
        local nhdir = {x=hull_direction.z,y=0,z=-hull_direction.x}        -- lateral unit vector
        local velocity = self.object:get_velocity()

        local longit_speed = steampunk_blimp.dot(velocity,hull_direction)
        self._longit_speed = longit_speed --for anchor verify
        local longit_drag = vector.multiply(hull_direction,longit_speed*
                longit_speed*LONGIT_DRAG_FACTOR*-1*steampunk_blimp.sign(longit_speed))
        local later_speed = steampunk_blimp.dot(velocity,nhdir)
        local later_drag = vector.multiply(nhdir,later_speed*later_speed*
                LATER_DRAG_FACTOR*-1*steampunk_blimp.sign(later_speed))
        local accel = vector.add(longit_drag,later_drag)

        local vel = self.object:get_velocity()
        local curr_pos = self.object:get_pos()
        self._last_pos = curr_pos
        self.object:move_to(curr_pos)

        --minetest.chat_send_all(self._energy)
        steampunk_blimp.engine_set_sound_and_animation(self)


        local is_attached = false
        local player = nil
        if self.driver_name then
            player = minetest.get_player_by_name(self.driver_name)
            
            if player then
                is_attached = steampunk_blimp.checkAttach(self, player)
            end
        end

        --fire
        if self._engine_running == true then
            self.fire:set_properties({textures={"default_furnace_fire_fg.png"},glow=15})
        else
            self.fire:set_properties({textures={"steampunk_blimp_alpha.png"},glow=0})
        end

        --detect collision
        if self.last_vel ~= nil then
            local impact = steampunk_blimp.get_hipotenuse_value(vel, self.last_vel)
            if impact > 1 then
                minetest.sound_play("steampunk_blimp_collision", {
                    --to_player = self.driver_name,
                    pos = curr_pos,
                    max_hear_distance = 15,
                    gain = 1.0,
                    fade = 0.0,
                    pitch = 1.0,
                })
                --[[if self.hull_integrity then
                    self.hull_integrity = self.hull_integrity - impact
                    if (self.hull_integrity <= 0) then
                        steampunk_blimp.destroy(self, true)
                        return
                    end
                end]]--
            end
        end
        
        accel = steampunk_blimp.control(self, dtime, hull_direction, longit_speed, accel) or vel

        --[[if is_attached then
            --control
        else
            -- for some engine lag the player can be detached from the blimp, so lets set him attached again
            local can_stop = true
            if self.owner and self.driver_name then
                -- attach the driver again
                if player then
                    steampunk_blimp.attach(self, player)
                    can_stop = false
                end
            end

            if can_stop then
                --detach player
                if self.sound_handle ~= nil then
                    minetest.sound_stop(self.sound_handle)
                    self.sound_handle = nil
                end
            end
        end]]--

        local turn_rate = math.rad(18)
        newyaw = yaw + self.dtime*(1 - 1 / (math.abs(longit_speed) + 1)) *
            self._rudder_angle / 30 * turn_rate * steampunk_blimp.sign(longit_speed)

        -- calculate energy consumption --
        ----------------------------------
        if self._energy > 0 and self._engine_running then
            local zero_reference = vector.new()
            local acceleration = steampunk_blimp.get_hipotenuse_value(accel, zero_reference)
            local consumed_power = acceleration/steampunk_blimp.FUEL_CONSUMPTION
            --self._energy = self._energy - consumed_power;

            local energy_indicator_angle = steampunk_blimp.get_pointer_angle(self._energy, steampunk_blimp.MAX_FUEL)
        end
        if self._energy <= 0 then
            self._engine_running = false
            if self.sound_handle then minetest.sound_stop(self.sound_handle) end
            self.object:set_animation_frame_speed(0)
        end
        ----------------------------
        -- end energy consumption --
        
        --roll adjust
        ---------------------------------
        local sdir = minetest.yaw_to_dir(newyaw)
        local snormal = {x=sdir.z,y=0,z=-sdir.x}    -- rightside, dot is negative
        local prsr = steampunk_blimp.dot(snormal,nhdir)
        local rollfactor = -15
        local newroll = 0
        if self._last_roll ~= nil then newroll = self._last_roll end
        --oscilation when stoped
        if longit_speed == 0 then
            local time_correction = (self.dtime/steampunk_blimp.ideal_step)
            --stoped
            if self._roll_state == nil then
                self._roll_state = math.floor(math.random(-1,1))
                if self._roll_state == 0 then self._roll_state = 1 end
                self._last_roll = newroll
            end
            if math.abs(math.deg(newroll)) >= 1 then
                if self._roll_state == 1 then self._roll_state = -1 elseif self._roll_state == -1 then self._roll_state = 1 end
            end
            local roll_factor = (self._roll_state * 0.005) * time_correction
            self._last_roll = self._last_roll + math.rad(roll_factor)
        else
            --in movement
            self._roll_state = nil
            newroll = (prsr*math.rad(rollfactor))*later_speed
            self._last_roll = newroll
        end
        --minetest.chat_send_all('newroll: '.. newroll)
        ---------------------------------
        -- end roll

        accel.y = accel_y -- + bob
        newpitch = velocity.y * math.rad(1.5)
        self.object:set_acceleration(accel)
        self.object:set_rotation({x=newpitch,y=newyaw,z=newroll})

        self.object:set_bone_position("low_rudder", {x=0,y=0,z=0}, {x=0,y=self._rudder_angle,z=0})
        self.object:set_bone_position("rudder", {x=0,y=97,z=-148}, {x=0,y=self._rudder_angle,z=0})
        self.object:set_bone_position("timao", {x=0,y=27,z=-25}, {x=0,y=0,z=self._rudder_angle*8})

        --saves last velocy for collision detection (abrupt stop)
        self.last_vel = self.object:get_velocity()

        steampunk_blimp.move_persons(self)
    end,

    on_punch = function(self, puncher, ttime, toolcaps, dir, damage)
        if not puncher or not puncher:is_player() then
            return
        end
        local is_admin = false
        is_admin = minetest.check_player_privs(puncher, {server=true})
		local name = puncher:get_player_name()
        if self.owner and self.owner ~= name and self.owner ~= "" then
            if is_admin == false then return end
        end
        if self.owner == nil then
            self.owner = name
        end
            
        if self.driver_name and self.driver_name ~= name then
            -- do not allow other players to remove the object while there is a driver
            return
        end
        
        local is_attached = steampunk_blimp.checkAttach(self, puncher)

        local itmstck=puncher:get_wielded_item()
        local item_name = ""
        if itmstck then item_name = itmstck:get_name() end

        if is_attached == true then
            --refuel
            steampunk_blimp.load_fuel(self, puncher)
            self._engine_running = true
        end

        if is_attached == false then

            -- deal with painting or destroying
            if itmstck then
                local _,indx = item_name:find('dye:')
                if indx then

                    --lets paint!!!!
                    local color = item_name:sub(indx+1)
                    local colstr = steampunk_blimp.colors[color]
                    --minetest.chat_send_all(color ..' '.. dump(colstr))
                    if colstr then
                        steampunk_blimp.paint(self, colstr)
                        itmstck:set_count(itmstck:get_count()-1)
                        puncher:set_wielded_item(itmstck)
                    end
                    -- end painting

                else -- deal damage
                    if not self.driver_name and toolcaps and toolcaps.damage_groups and
                            toolcaps.damage_groups.fleshy then
                        --mobkit.hurt(self,toolcaps.damage_groups.fleshy - 1)
                        --mobkit.make_sound(self,'hit')
                        self.hp = self.hp - 10
                        minetest.sound_play("collision", {
                            object = self.object,
                            max_hear_distance = 5,
                            gain = 1.0,
                            fade = 0.0,
                            pitch = 1.0,
                        })
                    end
                end
            end

            if self.hp <= 0 then
                steampunk_blimp.destroy(self, false)
            end

        end
        
    end,

    on_rightclick = function(self, clicker)
        local message = ""
		if not clicker or not clicker:is_player() then
			return
		end

        local name = clicker:get_player_name()

        if self.owner == "" then
            self.owner = name
        end

        local touching_ground, liquid_below = airutils.check_node_below(self.object, 2.5)
        local is_on_ground = self.isinliquid or touching_ground or liquid_below
        local is_under_water = airutils.check_is_under_water(self.object)

        --minetest.chat_send_all('name '.. dump(name) .. ' - pilot: ' .. dump(self.driver_name) .. ' - pax: ' .. dump(copilot_name))
        --=========================
        --  form to pilot
        --=========================
        local is_attached = false
        local seat = clicker:get_attach()
        if seat then
            local plane = seat:get_attach()
            if plane == self.object then is_attached = true end
        end
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
            is_attached = steampunk_blimp.check_passenger_is_attached(self, name)

            if is_attached then
                local can_bypass = minetest.check_player_privs(clicker, {protection_bypass=true})
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
                    if self.driver_name ~= nil then
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
                --attach normal passenger
                --if self._door_closed == false then
                    steampunk_blimp.attach_pax(self, clicker)
                --end
            end
        end

    end,
})
