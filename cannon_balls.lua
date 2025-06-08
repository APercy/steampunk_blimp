
local function rot_to_dir(rot) -- keep rot within <-pi/2,pi/2>
	local dir = core.yaw_to_dir(rot.y)
	dir.y = dir.y+math.tan(rot.x)*vector.length(dir)
	return vector.normalize(dir)
end

function steampunk_blimp.spawn_shell(self, pos, dir, player_name, ent_name, velocity)
    local rotation = self.object:get_rotation()
    local curr_speed = self.object:get_velocity() --we could be flying
	local bullet_obj = nil
	bullet_obj = core.add_entity(pos, ent_name)

	if not bullet_obj then
		return
	end

	local lua_ent = bullet_obj:get_luaentity()
	lua_ent.shooter_name = player_name
    lua_ent.damage = lua_ent.damage * (math.random(5, 15)/10)

    bullet_obj:set_velocity({x=dir.x*velocity+curr_speed.x, y=-1, z=dir.z*velocity+curr_speed.z})
    bullet_obj:set_acceleration({x=dir.x*-3, y=airutils.gravity, z=dir.z*-3})
end

function steampunk_blimp.remove_nodes(pos, radius, disable_drop_nodes)
    if not pos then return end
    if not disable_drop_nodes then disable_drop_nodes = false end
    local pr = PseudoRandom(os.time())
    for z = -radius, radius do
        for y = -radius, radius do
            for x = -radius, radius do
                -- remove the nodes
                local r = vector.length(vector.new(x, y, z))
                if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
                    local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                    
	                local node = core.get_node(p).name
	                local nodedef = core.registered_nodes[node]
	                local is_liquid = nodedef.liquidtype ~= "none"
                    local is_leaf = (nodedef.drawtype == "plantlike") or (nodedef.drawtype == "allfaces_optional")

                    if is_leaf then
                        local node_name = "air"
                        node_name = "fire:basic_flame"

                        core.set_node(p, {name = node_name})
                    elseif not is_liquid then
                        core.remove_node(p)
                    end
                end
            end
        end
    end
    if disable_drop_nodes == false then
        local radius = radius
        for z = -radius, radius do
            for y = -radius, radius do
                for x = -radius, radius do
                    -- do fancy stuff
                    local r = vector.length(vector.new(x, y, z))
                    if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
                        local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                        core.spawn_falling_node(p)
                    end
                end
            end
        end
    end
end

function steampunk_blimp.explode(object, radius, ipos)
    if not object then return end
    local rnd_radius = math.random(radius-1, radius+1)
    local pos = ipos or object:get_pos()
    airutils.add_destruction_effects(pos, rnd_radius + math.random(2,4), true)

    -- remove nodes
    local ent = object:get_luaentity()
    if steampunk_blimp.bypass_protection == false then
        local name = ""
        if ent.shooter_name then
            name = ent.shooter_name
        end

        if core.is_protected(pos, name) == false then
            steampunk_blimp.remove_nodes(pos, rnd_radius)
        end
    else
        steampunk_blimp.remove_nodes(pos, rnd_radius)
    end

    --damage entites/players
    airutils.add_blast_damage(pos, rnd_radius+math.random(4,6), 50)

    object:remove()
end

local function add_flash(obj_pos)
    core.add_particle({
        pos = obj_pos,
        velocity = {x=0, y=0, z=0},
      	acceleration = {x=0, y=0, z=0},
        expirationtime = 1,
        size = math.random(10,20)/10,
        collisiondetection = false,
        vertical = false,
        texture = "steampunk_blimp_boom.png",
        glow = 10,
    })

end

function steampunk_blimp.register_shell(ent_name, inv_image, bullet_texture, description, bullet_damage, boom_radius, bullets_max_stack)
    bullets_max_stack = bullets_max_stack or 99
	core.register_entity(ent_name, {
		hp_max = 5,
		physical = false,
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		visual = "sprite",
		textures = {bullet_texture},
        lastpos = {},
		visual_size = {x = 1.0, y = 1.0},
        collide_with_objects = false,
		old_pos = nil,
		velocity = nil,
		is_liquid = nil,
		shooter_name = "",
        damage = bullet_damage,
		groups = {bullet = 1},
        _total_time = 0,
        bomb_radius = boom_radius,

		on_activate = function(self)
			self.object:set_acceleration({x = 0, y = -9.81, z = 0})
		end,

		on_step = function(self, dtime, moveresult)
            self._total_time = self._total_time + dtime
            if self._total_time > 5 then
                --destroy after 5 seconds
                self.object:remove()
            end

			local pos = self.object:get_pos()
            if not pos then return end
			self.old_pos = self.old_pos or pos
			local velocity = self.object:get_velocity()
			local hit_bullet_sound = "steampunk_blimp_collision"

			local cast = core.raycast(self.old_pos, pos, true, true)
			local thing = cast:next()
			while thing do
				if thing.type == "object" and thing.ref ~= self.object then
                    local is_the_shooter_vehicle = false
                    local ent = thing.ref:get_luaentity()
                    if ent then
                        local driver_name = ""
                        if ent.driver_name then
                            driver_name = ent.driver_name
                        else
                            local parent = thing.ref:get_attach()
                            if parent then
                                local parent_ent = parent:get_luaentity()
                                if parent_ent then
                                    if parent_ent.driver_name then
                                        driver_name = parent_ent.driver_name
                                    end
                                end
                            end
                        end

                        if driver_name == self.shooter_name then is_the_shooter_vehicle = true end
                    end
					if (not thing.ref:is_player() or thing.ref:get_player_name() ~= self.shooter_name) and is_the_shooter_vehicle == false then
                        --core.chat_send_all("acertou "..thing.ref:get_entity_name())
						local thing_pos = thing.ref:get_pos()
                        --core.chat_send_all("ent dam: "..dump(self.damage))
						thing.ref:punch(self.object, 1.0, {
			                full_punch_interval=1.0,
			                damage_groups={fleshy=self.damage, choppy = self.damage},
			                }, nil)

						if thing_pos then
                            core.sound_play(hit_bullet_sound, {
                                object = self.object,
                                max_hear_distance = 50,
                                gain = 1.0,
                                fade = 0.0,
                                pitch = 1.0,
                            }, true)
                            steampunk_blimp.explode(self.object, self.bomb_radius)
						end

						self.object:remove()

                        --do damage on my old planes
                        --[[if ent then
                            if ent.hp_max then ent.hp_max = ent.hp_max - self.damage end
                        end]]--

						if core.is_protected(pos, self.shooter_name) then
							return
						end

						return
					end
				elseif thing.type == "node" then
					local node_name = core.get_node(thing.under).name
                    if not node_name or node_name == nil or node_name == "" or node_name == "ignore" then return end
					local drawtype = core.registered_nodes[node_name]["drawtype"]
					if drawtype == 'liquid' then
						if not self.is_liquid then
							self.velocity = velocity
							self.is_liquid = true
							local liquidviscosity = core.registered_nodes[node_name]["liquid_viscosity"]
							local drag = 1/(liquidviscosity*3)
							self.object:set_velocity(vector.multiply(velocity, drag))
							self.object:set_acceleration({x = 0, y = -1.0, z = 0})
							--TODO splash here
						end
					elseif self.is_liquid then
						self.is_liquid = false
						if self.velocity then
							self.object:set_velocity(self.velocity)
						end
						self.object:set_acceleration({x = 0, y = -9.81, z = 0})
					end
					if core.registered_items[node_name].walkable then
                        core.sound_play(hit_bullet_sound, {
                            object = self.object,
                            max_hear_distance = 50,
                            gain = 1.0,
                            fade = 0.0,
                            pitch = 1.0,
                        }, true)

                        --explode TNT
                        local node = core.get_node(pos)
                        local node_name = node.name
                        if node_name == "tnt:tnt" then core.set_node(pos, {name = "tnt:tnt_burning"}) end

                        local i_pos = thing.intersection_point
                        add_flash(i_pos)

                        --explode here
                        steampunk_blimp.explode(self.object, self.bomb_radius, i_pos)

						self.object:remove()

						if core.is_protected(pos, self.shooter_name) then
							return
						end

                        local player = core.get_player_by_name(self.shooter_name)
                        if player then
                            core.node_punch(pos, node, player, {damage_groups={fleshy=20}})--{type = "punch"})
                        end

						--replace node
						--core.set_node(pos, {name = "air"})
                        --core.add_item(pos,node_name)

						return
					end
				end
				thing = cast:next()
			end
            --TODO set a trail here using the stored old position
			self.old_pos = pos
		end,
	})
	core.register_craftitem(ent_name, {
		description = description,
		inventory_image = inv_image,
		stack_max = bullets_max_stack,
	})
end

local function play_cannon_sound(self)
    core.sound_play("steampunk_blimp_explode", {
        --to_player = self.driver_name,
        object = self.object,
        max_hear_distance = 120,
        gain = 5.0,
        fade = 0.0,
        pitch = 1.0,
    }, true)
end

local function smoke_particle(self, object)
    core.sound_play("steampunk_blimp_explode", {
        object = self.object,
        max_hear_distance = 50,
        gain = 5.0,
        fade = 0.0,
        pitch = 1.0,
    }, true)

    core.add_particlespawner({
	    amount = 20,
	    time = 0.5,
	    --minpos = pos,
	    --maxpos = pos,
	    minvel = {x = -1, y = -1, z = -1},
	    maxvel = {x = 1, y = 5, z = 1},
	    minacc = vector.new(),
	    maxacc = vector.new(),
        attached = object,
	    minexptime = 3,
	    maxexptime = 5.5,
	    minsize = 10,
	    maxsize = 15,
	    texture = "steampunk_blimp_smoke.png",
    })
end

function steampunk_blimp.cannon_shot(self, dest_obj, ammo_name)
    ammo_name = ammo_name or "steampunk_blimp:cannon_ball1"
    local speed = 50

    local pos=self.object:get_pos()
    local rel_pos=steampunk_blimp.cannons_loc
    local rotation = self.object:get_rotation()
    local dir=rot_to_dir(rotation) --core.yaw_to_dir(self.object:get_yaw())

    local cannons = {vector.new(rel_pos),vector.new(rel_pos)}
    cannons[2].x = cannons[2].x * -1
    local yaw = self.object:get_yaw()
    for i = 1,2,1 do
        local orig_x = cannons[i].x/10
        local orig_z = cannons[i].z/10
        cannons[i].x = (orig_x * math.cos(yaw)) - (orig_z * math.sin(yaw))
        cannons[i].z = (orig_x * math.sin(yaw)) + (orig_z * math.cos(yaw))
    end

    local shot_pos = vector.new(pos)
    --right
    if dest_obj == self._cannon_r then
        if self._r_pload == true then
            smoke_particle(self, dest_obj)
            self._r_pload = false
            shot_pos = vector.add(shot_pos, cannons[1])
            if self._r_armed == true then
                steampunk_blimp.spawn_shell(self, shot_pos, dir, self.driver_name, ammo_name, speed)
                self._r_armed = false
            end
            return 1 --for recoil calc
        end
    end

    --left
    if dest_obj == self._cannon_l then
        if self._l_pload == true then
            smoke_particle(self, dest_obj)
            self._l_pload = false
            shot_pos = vector.add(shot_pos, cannons[2])
            if self._l_armed == true then
                steampunk_blimp.spawn_shell(self, shot_pos, dir, self.driver_name, ammo_name, speed)
                self._l_armed = false
            end
            return 1 --for recoil calc
        end
    end

    --[[TODO
    timer set just for tests
    in the final version it
    will be function/work for tripulation
    ]]--
    --[[core.after(0.5, function(self)
        self._l_armed = true
        self._r_armed = true
    end, self)]]--
    -- end TODO

    return 0 --for recoil calc
end

local direct_impact_damage = 30
local speed = 100
local radius = 3
steampunk_blimp.register_shell("steampunk_blimp:cannon_ball1", "steampunk_blimp_ball.png", "steampunk_blimp_ball.png", "Cannon Ball 1", direct_impact_damage, radius, speed)
