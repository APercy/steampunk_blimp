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
        collisionbox = {-2, -2, -2, 2, 0, 2},
	    pointable=false,
	    visual = "mesh",
	    mesh = "steampunk_blimp_stand_base.b3d",
        textures = {"steampunk_blimp_alpha.png",},
	},
    dist_moved = 0,

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
        collisionbox = {-4, -2.5, -4, 4, 9, 4}, --{-1,0,-1, 1,0.3,1},
        --selectionbox = {-0.6,0.6,-0.6, 0.6,1,0.6},
        visual = "mesh",
        backface_culling = false,
        mesh = "steampunk_blimp.b3d",
        textures = steampunk_blimp.textures_copy(),
    },
    textures = {},
    driver_name = nil,
    sound_handle = nil,
    static_save = true,
    infotext = "A nice blimp",
    lastvelocity = vector.new(),
    hp = 50,
    color = "blue",
    color2 = "white",
    logo = "steampunk_blimp_alpha_logo.png",
    timeout = 0;
    buoyancy = 0.15,
    max_hp = 50,
    anchored = true,
    physics = steampunk_blimp.physics,
    hull_integrity = nil,
    owner = "",
    time_total = 0,
    _shared_owners = {},
    _engine_running = false,
    _power_lever = 0,
    _last_applied_power = 0,
    _at_control = false,
    _rudder_angle = 0,
    _baloon_buoyancy = 0,
    _show_hud = true,
    _energy = 1.0,--0.001,
    _water_level = 1.0,
    _boiler_pressure = 1.0, --min 155 max 310
    _is_going_up = false, --to tell the boiler to lose pressure
    _passengers = {}, --passengers list
    _passengers_base = {}, --obj id
    _passengers_base_pos = steampunk_blimp.copy_vector({}),
    _passenger_is_sit = {}, -- 0, 1, 2, 3 or 4 ==> stand, 0, 90, 180, 270 --the sit rotation
    _passengers_locked = false,
    _disconnection_check_time = 0,
    _inv = nil,
    _inv_id = "",
    _ship_name = "",
    _name_color = 0,
    _name_hor_aligment = 3.0,
    item = "steampunk_blimp:blimp",

    get_staticdata = function(self) -- unloaded/unloads ... is now saved
        return minetest.serialize({
            stored_baloon_buoyancy = self._baloon_buoyancy,
            stored_energy = self._energy,
            stored_water_level = self._water_level,
            stored_boiler_pressure = self._boiler_pressure,
            stored_owner = self.owner,
            stored_shared_owners = self._shared_owners,
            stored_hp = self.hp,
            stored_color = self.color,
            stored_color2 = self.color2,
            stored_logo = self.logo,
            stored_anchor = self.anchored,
            stored_hull_integrity = self.hull_integrity,
            stored_item = self.item,
            stored_inv_id = self._inv_id,
            stored_passengers = self._passengers, --passengers list
            stored_passengers_locked = self._passengers_locked,
            stored_ship_name = self._ship_name,
            remove = self._remove or false,
        })
    end,

	on_deactivate = function(self)
        if self._remove ~= true then
            airutils.save_inventory(self)
        end
        if self.sound_handle then minetest.sound_stop(self.sound_handle) end
        if self.sound_handle_pistons then minetest.sound_stop(self.sound_handle_pistons) end
	end,

    on_activate = function(self, staticdata, dtime_s)
        --minetest.chat_send_all('passengers: '.. dump(self._passengers))
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}

            self._baloon_buoyancy = data.stored_baloon_buoyancy or 0
            self._energy = data.stored_energy or 0
            self._water_level = data.stored_water_level or 0
            self._boiler_pressure = data.stored_boiler_pressure or 0
            self.owner = data.stored_owner or ""
            self._shared_owners = data.stored_shared_owners or {}
            self.hp = 50 --data.stored_hp or 50
            self.color = data.stored_color or "blue"
            self.color2 = data.stored_color2 or "white"
            self.logo = data.stored_logo or "steampunk_blimp_alpha_logo.png"
            self.anchored = data.stored_anchor or false
            self.buoyancy = data.stored_buoyancy or 0.15
            self.hull_integrity = data.stored_hull_integrity
            self.item = data.stored_item
            self._passengers = data.stored_passengers or steampunk_blimp.copy_vector({[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil, [6]=nil, [7]=nil})
            self._passengers_locked = data.stored_passengers_locked
            self._ship_name = data.stored_ship_name
            self._remove = data.remove or false
            if self._remove ~= true then
                self._inv_id = data.stored_inv_id
            end
            --minetest.debug("loaded: ", self._energy)
            local properties = self.object:get_properties()
            properties.infotext = data.stored_owner .. " nice blimp"
            self.object:set_properties(properties)

            if self._remove == true then
                airutils.destroy_inventory(self)
                self.object:remove()
                return
            end
        end

        local colstr = steampunk_blimp.colors[self.color]
        if not colstr then
            colstr = "blue"
            self.color = colstr
        end
        steampunk_blimp.paint(self, self.color)
        steampunk_blimp.paint2(self, self.color2)
        local pos = self.object:get_pos()

        local fire=minetest.add_entity(pos,'steampunk_blimp:fire')
        fire:set_attach(self.object,'',{x=0.0,y=0.0,z=0.0},{x=0,y=0,z=0})
	    self.fire = fire

        --passengers positions
        self._passenger_is_sit = steampunk_blimp.copy_vector({})
        self._passengers_base = steampunk_blimp.copy_vector({})
        self._passengers_base_pos = steampunk_blimp.copy_vector({})
        for i = 1,steampunk_blimp.max_seats,1
        do
            self._passenger_is_sit[i] = 0
            self._passengers_base_pos[i] = steampunk_blimp.copy_vector(steampunk_blimp.passenger_pos[i])
            self._passengers_base[i]=minetest.add_entity(pos,'steampunk_blimp:stand_base')
            self._passengers_base[i]:set_attach(self.object,'',self._passengers_base_pos[i],{x=0,y=0,z=0})
        end

        --animation load - stoped
        self.object:set_animation({x = 1, y = 47}, 0, 0, true)

        self.object:set_bone_position("low_rudder_a", {x=0,y=0,z=-40}, {x=-5.35,y=0,z=0})

        self.object:set_armor_groups({immortal=1})

        airutils.actfunc(self, staticdata, dtime_s)

        self.object:set_armor_groups({immortal=1})

        if self._remove ~= true then
		    local inv = minetest.get_inventory({type = "detached", name = self._inv_id})
		    -- if the game was closed the inventories have to be made anew, instead of just reattached
		    if not inv then
                airutils.create_inventory(self, steampunk_blimp.trunk_slots)
		    else
		        self.inv = inv
            end
        end

        steampunk_blimp.engine_step(self, 0)
    end,

    on_step = function(self,dtime,colinfo)
	    self.dtime = math.min(dtime,0.2)
	    self.colinfo = colinfo
	    self.height = airutils.get_box_height(self)

    --  physics comes first
	    local vel = self.object:get_velocity()

	    if colinfo then
		    self.isonground = colinfo.touching_ground
	    else
		    if self.lastvelocity.y==0 and vel.y==0 then
			    self.isonground = true
		    else
			    self.isonground = false
		    end
	    end

	    self:physics()

	    if self.logic then
		    self:logic()
	    end

	    self.lastvelocity = self.object:get_velocity()
	    self.time_total=self.time_total+self.dtime
    end,
    logic = function(self)

        local accel_y = self.object:get_acceleration().y
        local rotation = self.object:get_rotation()
        local yaw = rotation.y
        local curr_pos = self.object:get_pos()
        local newyaw
        local newpitch

        local hull_direction = minetest.yaw_to_dir(yaw)
        local nhdir = {x=hull_direction.z,y=0,z=-hull_direction.x}        -- lateral unit vector
        local velocity = self.object:get_velocity()
        local wind_speed = airutils.get_wind(curr_pos, 0.15)

        local longit_speed = steampunk_blimp.dot(velocity,hull_direction)
        self._longit_speed = longit_speed --for anchor verify
        local relative_longit_speed = longit_speed
        if steampunk_blimp.wind_enabled then
            relative_longit_speed = steampunk_blimp.dot(vector.add(velocity, wind_speed), hull_direction)
        end
        self._relative_longit_speed = relative_longit_speed

        local longit_drag = vector.multiply(hull_direction,relative_longit_speed*
                relative_longit_speed*LONGIT_DRAG_FACTOR*-1*steampunk_blimp.sign(relative_longit_speed))
        local later_speed = steampunk_blimp.dot(velocity,nhdir)
        local later_drag = vector.multiply(nhdir,later_speed*later_speed*
                LATER_DRAG_FACTOR*-1*steampunk_blimp.sign(later_speed))
        local accel = vector.add(longit_drag,later_drag)

        self._last_pos = curr_pos
        self.object:move_to(curr_pos)

        if self.owner == "" then return end

        --fire
        if self.fire then
            if self._engine_running == true then
                self.fire:set_properties({textures={steampunk_blimp.fire_tex},glow=15})
            else
                self.fire:set_properties({textures={"steampunk_blimp_alpha.png"},glow=0})
            end
        end

        --detect collision
        steampunk_blimp.testDamage(self, velocity, curr_pos)

        accel = steampunk_blimp.control(self, self.dtime, hull_direction, relative_longit_speed, accel) or velocity

        --get disconnected players
        steampunk_blimp.rescueConnectionFailedPassengers(self)

        local turn_rate = math.rad(18)
        newyaw = yaw + self.dtime*(1 - 1 / (math.abs(relative_longit_speed) + 1)) *
            self._rudder_angle / 30 * turn_rate * steampunk_blimp.sign(relative_longit_speed)

        steampunk_blimp.engine_step(self, accel)

        --roll adjust
        ---------------------------------
        local sdir = minetest.yaw_to_dir(newyaw)
        local snormal = {x=sdir.z,y=0,z=-sdir.x}    -- rightside, dot is negative
        local prsr = steampunk_blimp.dot(snormal,nhdir)
        local rollfactor = -15
        local newroll = 0
        if self._last_roll ~= nil then newroll = self._last_roll end
        --oscilation when stoped
        if relative_longit_speed == 0 then
            local time_correction = (self.dtime/steampunk_blimp.ideal_step)
            --stoped
            if self._roll_state == nil then
                self._roll_state = math.floor(math.random(-1,1))
                if self._roll_state == 0 then self._roll_state = 1 end
                self._last_roll = newroll
            end
            if math.deg(newroll) >= 1 and self._roll_state == 1 then
                self._roll_state = -1
                steampunk_blimp.play_rope_sound(self);
            end
            if math.deg(newroll) <= -1 and self._roll_state == -1 then
                self._roll_state = 1
                steampunk_blimp.play_rope_sound(self);
            end
            local roll_factor = (self._roll_state * 0.005) * time_correction
            self._last_roll = self._last_roll + math.rad(roll_factor)
        else
            --in movement
            self._roll_state = nil
            newroll = (prsr*math.rad(rollfactor))*later_speed
            if self._last_roll ~= nil then
                if math.sign(newroll) ~= math.sign(self._last_roll) then
                    steampunk_blimp.play_rope_sound(self)
                end
            end
            self._last_roll = newroll
        end
        --minetest.chat_send_all('newroll: '.. newroll)
        ---------------------------------
        -- end roll

        if steampunk_blimp.wind_enabled then
            --local wind_yaw = minetest.dir_to_yaw(wind_speed)
            --minetest.chat_send_all("x: "..wind_speed.x.. " - z: "..wind_speed.z.." - yaw: "..math.deg(wind_yaw).. " - orig: "..wind_yaw)

            if self.anchored == false and self.isonground == false then
                accel = vector.add(accel, wind_speed)
            else
                accel = vector.new()
            end
        end
        accel.y = accel_y

        newpitch =  velocity.y * math.rad(1.5) * (relative_longit_speed/3)
        --self.object:set_acceleration(accel)
        self.object:add_velocity(vector.multiply(accel,self.dtime))
        self.object:set_rotation({x=newpitch,y=newyaw,z=newroll})

        local compass_angle = newyaw
        local rem_obj = self.object:get_attach()
        if rem_obj then
            compass_angle = rem_obj:get_rotation().y
        end

        self.object:set_bone_position("low_rudder", {x=0,y=0,z=0}, {x=0,y=self._rudder_angle,z=0})
        self.object:set_bone_position("rudder", {x=0,y=97,z=-148}, {x=0,y=self._rudder_angle,z=0})
        self.object:set_bone_position("timao", {x=0,y=27,z=-25}, {x=0,y=0,z=self._rudder_angle*8})
        self.object:set_bone_position("compass_axis", {x=0,y=30.2,z=-21.243}, {x=0, y=(math.deg(compass_angle)), z=0})

        --saves last velocy for collision detection (abrupt stop)
        self._last_vel = self.object:get_velocity()
        self._last_accell = accel

        steampunk_blimp.move_persons(self)
    end,

    on_punch = function(self, puncher, ttime, toolcaps, dir, damage)
        if not puncher or not puncher:is_player() then
            return
        end
        local is_admin
        is_admin = minetest.check_player_privs(puncher, {server=true})
		local name = puncher:get_player_name()
        if self.owner == nil then
            self.owner = name
        end

        local is_attached = steampunk_blimp.checkAttach(self, puncher)

        local itmstck=puncher:get_wielded_item()
        local item_name = ""
        if itmstck then item_name = itmstck:get_name() end
        --minetest.chat_send_all(item_name)

        if is_attached == true then
            --refuel
            if steampunk_blimp.load_fuel(self, puncher) then return end
            if steampunk_blimp.load_water(self, puncher) then return end
        end

        if self.owner and self.owner ~= name and self.owner ~= "" then
            if is_admin == false then return end
        end

        if self.driver_name and self.driver_name ~= name then
            -- do not allow other players to remove the object while there is a driver
            return
        end

        -- deal with painting or destroying
        if itmstck then
            local find_str = 'dye:'
            local _,indx = item_name:find(find_str)
            if indx then

                --lets paint!!!!
                local color = nil
                if not airutils.is_repixture then
                    color = item_name:sub(indx+1)
                end
                local colstr = steampunk_blimp.colors[color]
                --minetest.chat_send_all(color ..' '.. dump(colstr))
                if colstr and (name == self.owner or minetest.check_player_privs(puncher, {protection_bypass=true})) then
                    local ctrl = puncher:get_player_control()
                    if ctrl.aux1 then
                        steampunk_blimp.paint2(self, colstr)
                    else
                        steampunk_blimp.paint(self, colstr)
                    end
                    itmstck:set_count(itmstck:get_count()-1)
                    puncher:set_wielded_item(itmstck)
                end
                -- end painting
            end
        end

        if is_attached == false then
            local has_passengers = false
            for i = steampunk_blimp.max_seats,1,-1
            do
                if self._passengers[i] ~= nil then
                    has_passengers = true
                    break
                end
            end


            if not has_passengers and toolcaps and toolcaps.damage_groups and
                    toolcaps.groupcaps and (toolcaps.groupcaps.choppy or toolcaps.groupcaps.axey_dig) then

                local is_empty = true

                --airutils.make_sound(self,'hit')
                if is_empty == true then
                    self.hp = self.hp - 10
                    minetest.sound_play("steampunk_blimp_collision", {
                        object = self.object,
                        max_hear_distance = 5,
                        gain = 1.0,
                        fade = 0.0,
                        pitch = 1.0,
                    })
                end
            end

            if self.hp <= 0 then
                steampunk_blimp.destroy(self, false)
            end

        end

    end,

    on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end

        local name = clicker:get_player_name()

        if self.owner == "" then
            self.owner = name
        end

        --minetest.chat_send_all('passengers: '.. dump(self._passengers))
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
                for i = steampunk_blimp.max_seats,1,-1
                do
                    if self._passengers[i] ~= nil then
                        local old_player = minetest.get_player_by_name(self._passengers[i])
                        if not old_player then self._passengers[i] = nil end
                    end
                end
                --attach normal passenger
                --if self._door_closed == false then
                    steampunk_blimp.attach_pax(self, clicker)
                --end
            end
        end

    end,
})
