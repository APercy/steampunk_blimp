--
-- constants
--
local LONGIT_DRAG_FACTOR = 0.13*0.13
local LATER_DRAG_FACTOR = 2.0

local function damage_vehicle(self, toolcaps, ttime, damage, min_damage_value)
    damage = damage or 0
    if (not toolcaps) then
        return
    end
    
    local value = toolcaps.damage_groups.fleshy or 0
    if (toolcaps.damage_groups.vehicle) then
        value = toolcaps.damage_groups.vehicle
    end
    damage = damage + value
    if damage < min_damage_value then
        steampunk_blimp.setText(self, self._vehicle_name)
        return
    end
    damage = damage / 10
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

    steampunk_blimp.setText(self, self._vehicle_name)
end

--
-- entity
--

core.register_entity('steampunk_blimp:fire',{
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
	    self.sdata = core.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
        self.object:set_armor_groups({immortal=1})
    end,

    get_staticdata=function(self)
      self.sdata.remove=true
      return core.serialize(self.sdata)
    end,

})

local default_wood_texture = "default_wood.png"
if airutils.is_repixture then
    default_wood_texture = "default_wood_oak.png"
end

core.register_entity('steampunk_blimp:wings',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
    glow = 0,
	visual = "mesh",
    backface_culling = false,
	mesh = "steampunk_blimp_wings.b3d",
    textures = {
            default_wood_texture, --asa
            steampunk_blimp.canvas_texture, --asa
        },
	},

    on_activate = function(self,std)
	    self.sdata = core.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
        self.object:set_armor_groups({immortal=1})
    end,

    get_staticdata=function(self)
      self.sdata.remove=true
      return core.serialize(self.sdata)
    end,

})

core.register_entity('steampunk_blimp:cannons',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
    glow = 0,
	visual = "mesh",
    backface_culling = false,
	mesh = "steampunk_blimp_cannons.b3d",
    textures = {
            "steampunk_blimp_cannon.png", --canhão
            default_wood_texture, --canhão
        },
	},

    on_activate = function(self,std)
	    self.sdata = core.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
        self.object:set_armor_groups({immortal=1})
    end,

    get_staticdata=function(self)
      self.sdata.remove=true
      return core.serialize(self.sdata)
    end,

})


--
-- seat pivot
--
core.register_entity('steampunk_blimp:stand_base',{
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
	    self.sdata = core.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
        self.object:set_armor_groups({immortal=1})
    end,

    get_staticdata=function(self)
      self.sdata.remove=true
      return core.serialize(self.sdata)
    end,
})

core.register_entity('steampunk_blimp:cannon_mouth',{
    initial_properties = {
	    physical = false,
	    collide_with_objects=true,
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	    pointable=false,
	    visual = "mesh",
	    mesh = "steampunk_blimp_stand_base.b3d",
        textures = {"steampunk_blimp_alpha.png",},
	},
    dist_moved = 0,

    on_activate = function(self,std)
	    self.sdata = core.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
        self.object:set_armor_groups({immortal=1})
    end,

    get_staticdata=function(self)
      self.sdata.remove=true
      return core.serialize(self.sdata)
    end,
})

core.register_entity('steampunk_blimp:cannon_interactor',{
    initial_properties = {
	    physical = false,
	    collide_with_objects=true,
        collisionbox = {-0.8, -0.8, -0.8, 0.8, 0.8, 0.8},
	    pointable=true,
	    visual = "mesh",
	    mesh = "steampunk_blimp_stand_base.b3d",
        textures = {"steampunk_blimp_alpha.png",},
	},
    dist_moved = 0,

    on_activate = function(self,std)
	    self.sdata = core.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
        self.object:set_armor_groups({immortal=1})
    end,

    get_staticdata=function(self)
      self.sdata.remove=true
      return core.serialize(self.sdata)
    end,

    on_rightclick = steampunk_blimp.right_click_cannon,
})

core.register_entity('steampunk_blimp:helm_interactor',{
    initial_properties = {
	    physical = false,
	    collide_with_objects=false,
        collisionbox = {-0.3, -0.3, -0.3, 0.3, 1, 0.3},
	    pointable=true,
	    visual = "mesh",
	    mesh = "steampunk_blimp_stand_base.b3d",
        textures = {"steampunk_blimp_alpha.png",},
	},
    dist_moved = 0,

    on_activate = function(self,std)
	    self.sdata = core.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
        self.object:set_armor_groups({immortal=1})
    end,

    get_staticdata=function(self)
      self.sdata.remove=true
      return core.serialize(self.sdata)
    end,

    on_punch = function(self, puncher, ttime, toolcaps, dir, damage)
        --minetest.chat_send_all("punch")
        if not puncher or not puncher:is_player() then
            return
        end
    end,

    on_rightclick = steampunk_blimp.right_click_helm,
})

core.register_entity('steampunk_blimp:hull_interactor',{
    initial_properties = {
	    physical = false,
	    collide_with_objects=false,
        collisionbox = {-3, -2.5, -3, 3, 0, 3},
	    pointable=true,
	    visual = "mesh",
	    mesh = "steampunk_blimp_stand_base.b3d",
        textures = {"steampunk_blimp_alpha.png",},
	},
    dist_moved = 0,

    on_activate = function(self,std)
	    self.sdata = core.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
        self.object:set_armor_groups({immortal=1})
    end,

    get_staticdata=function(self)
      self.sdata.remove=true
      return core.serialize(self.sdata)
    end,

    on_punch = function(self, puncher, ttime, toolcaps, dir, damage)
        local ship_attach = self.object:get_attach()
        local parent_ent = nil
        if ship_attach then
            parent_ent = ship_attach:get_luaentity()
        end

        --minetest.chat_send_all("punch")
        if not puncher or not puncher:is_player() then
            damage_vehicle(parent_ent, toolcaps, ttime, damage, steampunk_blimp.min_damage_value )
            return
        end

        local name = nil
        if (puncher:is_player()) then
	        name = puncher:get_player_name()
            local ppos = puncher:get_pos()
            if (core.is_protected(ppos, name) and
                airutils.protect_in_areas) then
                return
            end
        end

        --local weapon_name = puncher:get_wielded_item():get_name()
        if parent_ent then
            damage_vehicle(parent_ent, toolcaps, ttime, damage, steampunk_blimp.min_damage_value*2 )
        end
    end,

    on_rightclick = steampunk_blimp.right_click_hull,
})

core.register_entity("steampunk_blimp:blimp", {
    initial_properties = {
        physical = true,
        collide_with_objects = true, --true,
        collisionbox = {-4, -2.5, -4, 4, 9, 4}, --{-1,0,-1, 1,0.3,1},
        selectionbox = {-0.6,-0.6,-0.6, 0.6,3,0.6},
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
    hp_max = steampunk_blimp.max_hp,
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
    _has_cannons = false,
    _unl_can = false,
    _rev_can = false,
    item = "steampunk_blimp:blimp",
    _vehicle_name = "Steampunk Blimp",

    get_staticdata = function(self) -- unloaded/unloads ... is now saved
        return core.serialize({
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
            stored_vehicle_name = self._vehicle_name,
            stored_has_cannons = self._has_cannons or false,
            stored_rev_can = self._rev_can or false, --reverse cannons
            stored_l_pload = self._l_pload or "", --powder left cannon
            stored_r_pload = self._r_pload or "", --powder right cannon
            stored_l_armed = self._l_armed or "", --ammo left cannon
            stored_r_armed = self._r_armed or "", --ammo right cannon
            remove = self._remove or false,
        })
    end,

	on_deactivate = function(self)
        if self._remove ~= true then
            airutils.save_inventory(self)
        end
        if self.sound_handle then core.sound_stop(self.sound_handle) end
        if self.sound_handle_pistons then core.sound_stop(self.sound_handle_pistons) end
	end,

    on_activate = function(self, staticdata, dtime_s)
        --core.chat_send_all('passengers: '.. dump(self._passengers))
        if staticdata ~= "" and staticdata ~= nil then
            local data = core.deserialize(staticdata) or {}

            self._baloon_buoyancy = data.stored_baloon_buoyancy or 0
            self._energy = data.stored_energy or 0
            self._water_level = data.stored_water_level or 0
            self._boiler_pressure = data.stored_boiler_pressure or 0
            self.owner = data.stored_owner or ""
            self._shared_owners = data.stored_shared_owners or {}
            self.hp = data.stored_hp or 50
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
            self._vehicle_name = data.stored_vehicle_name

            self._has_cannons = data.stored_has_cannons
            self._rev_can = data.stored_rev_can or false
            self._l_pload = data.stored_l_pload or "" --powder left cannon
            self._r_pload = data.stored_r_pload or "" --powder right cannon
            self._l_armed = data.stored_l_armed or "" --ammo left cannon
            self._r_armed = data.stored_r_armed or "" --ammo right cannon

            self._remove = data.remove or false
            if self._remove ~= true then
                self._inv_id = data.stored_inv_id
            end
            --core.debug("loaded: ", self._energy)
            local properties = self.object:get_properties()
            properties.infotext = data.stored_owner .. " nice blimp"
            self.object:set_properties(properties)

            if self._remove == true then
                airutils.destroy_inventory(self)
                self.object:remove()
                return
            end
            --core.chat_send_all(dump(staticdata))
        end

        local colstr = steampunk_blimp.colors[self.color]
        if not colstr then
            colstr = "blue"
            self.color = colstr
        end
        steampunk_blimp.paint(self, self.color)
        steampunk_blimp.paint2(self, self.color2)
        local pos = self.object:get_pos()

        if airutils.debug_log then
            core.log("action","activating: "..self._vehicle_name.." from "..self.owner.." at position "..math.floor(pos.x)..","..math.floor(pos.y)..","..math.floor(pos.z))
        end

        local fire=core.add_entity(pos,'steampunk_blimp:fire')
        fire:set_attach(self.object,'',{x=0.0,y=0.0,z=0.0},{x=0,y=0,z=0})
	    self.fire = fire

        if self._has_cannons == true then
            local cannons = core.add_entity(pos, 'steampunk_blimp:cannons')
            cannons:set_attach(self.object,'',{x=0.0,y=0.0,z=0.0},{x=0,y=0,z=0})
            self.cannons = cannons

            self._cannon_r_interactor = core.add_entity(pos, 'steampunk_blimp:cannon_interactor')
            self._cannon_r_interactor:set_attach(self.object,'',{x=steampunk_blimp.cannons_loc.x,y=steampunk_blimp.cannons_loc.y,z=steampunk_blimp.cannons_loc.z},{x=0,y=0,z=0})
            self._cannon_l_interactor = core.add_entity(pos, 'steampunk_blimp:cannon_interactor')
            self._cannon_l_interactor:set_attach(self.object,'',{x=-steampunk_blimp.cannons_loc.x,y=steampunk_blimp.cannons_loc.y,z=steampunk_blimp.cannons_loc.z},{x=0,y=0,z=0})

            self._cannon_r = core.add_entity(pos, 'steampunk_blimp:cannon_mouth')
            self._cannon_r:set_attach(self.object,'',{x=steampunk_blimp.cannons_loc.x,y=steampunk_blimp.cannons_loc.y,z=steampunk_blimp.cannons_loc.z+steampunk_blimp.cannons_sz},{x=0,y=0,z=0})
            self._cannon_l = core.add_entity(pos, 'steampunk_blimp:cannon_mouth')
            self._cannon_l:set_attach(self.object,'',{x=-steampunk_blimp.cannons_loc.x,y=steampunk_blimp.cannons_loc.y,z=steampunk_blimp.cannons_loc.z+steampunk_blimp.cannons_sz},{x=0,y=0,z=0})

            local override
            if self._rev_can == true then
                override = {
                    rotation = { vec={x=math.rad(-180),y=0,z=0}, interpolation = 1, absolute = false }
                    }
            else
                override = {
                    rotation = { vec={x=math.rad(360),y=0,z=0}, interpolation = 1, absolute = false }
                    }
            end
            self.cannons:set_bone_override("cannon_l", override)
            self.cannons:set_bone_override("cannon_r", override)
        else
            local wings = core.add_entity(pos, 'steampunk_blimp:wings')
            wings:set_attach(self.object,'',{x=0.0,y=0.0,z=0.0},{x=0,y=0,z=0})
            self.wings = wings
        end

        self._helm_interactor = core.add_entity(pos, 'steampunk_blimp:helm_interactor')
        local helm_interactor_pos = vector.new(steampunk_blimp.pilot_base_pos)
        helm_interactor_pos.z = helm_interactor_pos.z + 7
        self._helm_interactor:set_attach(self.object,'',helm_interactor_pos,{x=0,y=0,z=0})

        self._hull_interactor = core.add_entity(pos, 'steampunk_blimp:hull_interactor')
        self._hull_interactor:set_attach(self.object,'',{x=0.0,y=0.0,z=0.0},{x=0,y=0,z=0})

        --passengers positions
        self._passenger_is_sit = steampunk_blimp.copy_vector({})
        self._passengers_base = steampunk_blimp.copy_vector({})
        self._passengers_base_pos = steampunk_blimp.copy_vector({})
        for i = 1,steampunk_blimp.max_seats,1
        do
            self._passenger_is_sit[i] = 0
            self._passengers_base_pos[i] = steampunk_blimp.copy_vector(steampunk_blimp.passenger_pos[i])
            self._passengers_base[i]=core.add_entity(pos,'steampunk_blimp:stand_base')
            self._passengers_base[i]:set_attach(self.object,'',self._passengers_base_pos[i],{x=0,y=0,z=0})
        end

        --animation load - stoped
        self.object:set_animation({x = 1, y = 47}, 0, 0, true)

        self.object:set_bone_position("low_rudder_a", {x=0,y=0,z=-40}, {x=-5.35,y=0,z=0})

        airutils.actfunc(self, staticdata, dtime_s)

        if self._remove ~= true then
		    local inv = core.get_inventory({type = "detached", name = self._inv_id})
		    -- if the game was closed the inventories have to be made anew, instead of just reattached
		    if not inv then
                airutils.create_inventory(self, steampunk_blimp.trunk_slots)
		    else
		        self.inv = inv
            end
        end

        steampunk_blimp.setText(self, self._vehicle_name)

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

        local hull_direction = core.yaw_to_dir(yaw)
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
        if self.hp <= steampunk_blimp.min_hp then
            self._engine_running = false
            if self._boiler_pressure > 0 then
                minetest.sound_play({name = "default_cool_lava"},
                    {object = self.object, gain = 1.0,
                        pitch = 1.0,
                        max_hear_distance = 32,
                        loop = false,}, true)
                self._boiler_pressure = 0
            end
        end --stop all when damaged

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
        local sdir = core.yaw_to_dir(newyaw)
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
        --core.chat_send_all('newroll: '.. newroll)
        ---------------------------------
        -- end roll

        if steampunk_blimp.wind_enabled then
            --local wind_yaw = core.dir_to_yaw(wind_speed)
            --core.chat_send_all("x: "..wind_speed.x.. " - z: "..wind_speed.z.." - yaw: "..math.deg(wind_yaw).. " - orig: "..wind_yaw)

            if self.anchored == false and self.isonground == false then
                accel = vector.add(accel, wind_speed)
            else
                accel = vector.new()
            end
        end
        accel.y = accel_y

        newpitch =  velocity.y * math.rad(1.5) * (relative_longit_speed/3)

        local limit_pitch = math.rad(30)
        local pitch_by_accel = steampunk_blimp.pitch_by_accel(self, accel, hull_direction, limit_pitch)

        newpitch = newpitch + pitch_by_accel
        if newpitch > limit_pitch then newpitch = limit_pitch end
        if limit_pitch < -limit_pitch then newpitch = -limit_pitch end

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
        steampunk_blimp.setText(self, self._vehicle_name)

        if not puncher or not puncher:is_player() then
            damage_vehicle(self, toolcaps, ttime, damage, steampunk_blimp.min_damage_value )
            return
        end

        local name = nil
        if (puncher:is_player()) then
	        name = puncher:get_player_name()
            local ppos = puncher:get_pos()
            if (core.is_protected(ppos, name) and
                airutils.protect_in_areas) then
                return
            end
        end

        local weapon_name = puncher:get_wielded_item():get_name()
        damage_vehicle(self, toolcaps, ttime, damage, steampunk_blimp.min_damage_value )

        --[[if (string.find(weapon_name, "rayweapon") or string.find(weapon_name,"bows:") or
            string.find(weapon_name, "steampunk_blimp:cannon_")
            or toolcaps.damage_groups.vehicle) then
                damage_vehicle(self, toolcaps, ttime, damage)
        end]]--
        
        local is_admin
        is_admin = core.check_player_privs(puncher, {server=true})
        if self.owner == nil then
            self.owner = name
        end

        local is_attached = steampunk_blimp.checkAttach(self, puncher)

        local itmstck=puncher:get_wielded_item()
        local item_name = ""
        if itmstck then item_name = itmstck:get_name() end
        --core.chat_send_all(item_name)

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
            --core.chat_send_all(dump(item_name))
            local find_str = 'dye:'
            if airutils.is_mcl and not core.get_modpath("mcl_playerplus") then
                --mineclonia
                find_str = 'mcl_dyes:'
            end
            local _,indx = item_name:find(find_str)
            if indx then
                --lets paint!!!!
                local color = nil
                if not airutils.is_repixture then
                    color = item_name:sub(indx+1)
                end
                local colstr = steampunk_blimp.colors[color]
                --core.chat_send_all(color ..' '.. dump(colstr))
                if colstr and (name == self.owner or core.check_player_privs(puncher, {protection_bypass=true})) then
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

            local repair = airutils.contains(steampunk_blimp.rep_material, item_name)
            if repair then
                local stack = ItemStack(item_name .. " 1")
                if self.hp < steampunk_blimp.max_hp then
                    itmstck:set_count(1)
                    local inv = puncher:get_inventory()
                    inv:remove_item("main", itmstck)
                    if repair then
                        self.hp = self.hp + repair.amount
                    end
                    if self.hp > steampunk_blimp.max_hp then self.hp = steampunk_blimp.max_hp end
                end
                if self.hp >= steampunk_blimp.max_hp then core.chat_send_player(name, "The blimp has already been fixed!") end
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


            --[[if not has_passengers and toolcaps and toolcaps.damage_groups and
                    toolcaps.groupcaps and (toolcaps.groupcaps.choppy or toolcaps.groupcaps.axey_dig) then

                local is_empty = true

                --airutils.make_sound(self,'hit')
                if is_empty == true then
                    self.hp = self.hp - 10
                    core.sound_play("steampunk_blimp_collision", {
                        object = self.object,
                        max_hear_distance = 5,
                        gain = 1.0,
                        fade = 0.0,
                        pitch = 1.0,
                    })
                end
            end

            if self.hp <= 0 then
                steampunk_blimp.get_blimp_back(self, puncher, false)
            end]]--

        end

    end,

    on_rightclick = steampunk_blimp.right_click,

    on_deactivate = airutils.on_deactivate,
})
