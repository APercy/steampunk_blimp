--global constants

steampunk_blimp.vector_up = vector.new(0, 1, 0)

function steampunk_blimp.check_node_below(obj)
	local pos_below = obj:get_pos()
	pos_below.y = pos_below.y - 0.1
	local node_below = minetest.get_node(pos_below).name
	local nodedef = minetest.registered_nodes[node_below]
	local touching_ground = not nodedef or -- unknown nodes are solid
			nodedef.walkable or false
	local liquid_below = not touching_ground and nodedef.liquidtype ~= "none"
	return touching_ground, liquid_below
end

function steampunk_blimp.powerAdjust(self,dtime,factor,dir,max_power)
    local max = max_power or 100
    local add_factor = factor/2
    add_factor = add_factor * (dtime/steampunk_blimp.ideal_step) --adjusting the command speed by dtime
    local power_index = self._power_lever

    if dir == 1 then
        if self._power_lever < max then
            self._power_lever = self._power_lever + add_factor
        end
        if self._power_lever > max then
            self._power_lever = max
        end
    end
    if dir == -1 then
        self._power_lever = self._power_lever - add_factor
        if self._power_lever < -15 then self._power_lever = -15 end
    end
end

function steampunk_blimp.control(self, dtime, hull_direction, longit_speed, accel)
    if self._last_time_command == nil then self._last_time_command = 0 end
    self._last_time_command = self._last_time_command + dtime
    if self._last_time_command > 1 then self._last_time_command = 1 end
	local player = nil
    if self.driver_name then
        player = minetest.get_player_by_name(self.driver_name)
    end
    local retval_accel = accel;
    
	-- player control
    local ctrl = nil
	if player and self._at_control == true then
		ctrl = player:get_player_control()
		local max_speed_anchor = 0.2

        if self.anchored == false then
            local factor = 1
            if ctrl.up then
                local can_acc = true
                if self._power_lever >= 82 then can_acc = false end
                if ctrl.aux1 then can_acc = true end
                if can_acc then
                    steampunk_blimp.powerAdjust(self, dtime, factor, 1)
                end
            elseif ctrl.down then
                steampunk_blimp.powerAdjust(self, dtime, factor, -1)
            else
                --self.object:set_animation_frame_speed(steampunk_blimp.iddle_rotation)
            end
        end
        if not ctrl.aux1 and self._power_lever < 0 then self._power_lever = 0 end

        self._is_going_up = false
		if ctrl.jump then
            if self._boiler_pressure > 0 then
                self._baloon_buoyancy = 1.02
            end
            self._is_going_up = true
		elseif ctrl.sneak then
            self._baloon_buoyancy = -1.02
		end

		-- rudder
        local rudder_limit = 30
        local speed = 10
		if ctrl.right then
			self._rudder_angle = math.max(self._rudder_angle-speed*dtime,-rudder_limit)
		elseif ctrl.left then
			self._rudder_angle = math.min(self._rudder_angle+speed*dtime,rudder_limit)
		end
	end


    --engine acceleration calc
    local engineacc = (self._power_lever * steampunk_blimp.max_engine_acc) / 100;

    --do not exceed
    local max_speed = 3
    if longit_speed > max_speed then
        engineacc = engineacc - (longit_speed-max_speed)
    end

    if engineacc ~= nil then
        retval_accel=vector.add(accel,vector.multiply(hull_direction,engineacc))
    end
    --minetest.chat_send_all('paddle: '.. paddleacc)


    if longit_speed > 0 then
        if ctrl then
            if ctrl.right or ctrl.left then
            else
                steampunk_blimp.rudder_auto_correction(self, longit_speed, dtime)
            end
        else
            steampunk_blimp.rudder_auto_correction(self, longit_speed, dtime)
        end
    end

    steampunk_blimp.buoyancy_auto_correction(self, self.dtime)

    return retval_accel
end

function steampunk_blimp.rudder_auto_correction(self, longit_speed, dtime)
    local factor = 1
    if self._rudder_angle > 0 then factor = -1 end
    local correction = (steampunk_blimp.rudder_limit*(longit_speed/2000)) * factor * (dtime/steampunk_blimp.ideal_step)
    local before_correction = self._rudder_angle
    local new_rudder_angle = self._rudder_angle + correction
    if math.sign(before_correction) ~= math.sign(new_rudder_angle) then
        self._rudder_angle = 0
    else
        self._rudder_angle = new_rudder_angle
    end
end

function steampunk_blimp.buoyancy_auto_correction(self, dtime)
    local factor = 1
    --minetest.chat_send_player(self.driver_name, "antes: " .. self._baloon_buoyancy)
    if self._baloon_buoyancy > 0 then factor = -1 end
    local time_correction = (dtime/steampunk_blimp.ideal_step)
    local intensity = 0.2
    local correction = (intensity*factor) * time_correction
    --minetest.chat_send_player(self.driver_name, correction)
    local before_correction = self._baloon_buoyancy
    local new_baloon_buoyancy = self._baloon_buoyancy + correction
    if math.sign(before_correction) ~= math.sign(new_baloon_buoyancy) then
        self._baloon_buoyancy = 0
    else
        self._baloon_buoyancy = new_baloon_buoyancy
    end
    --minetest.chat_send_player(self.driver_name, "depois: " .. self._baloon_buoyancy)
end

