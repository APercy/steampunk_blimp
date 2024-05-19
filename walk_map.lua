function steampunk_blimp.clamp(value, min, max)
    local retVal = value
    if value < min then retVal = min end
    if value > max then retVal = max end
    --minetest.chat_send_all(value .. " - " ..retVal)
    return retVal
end

function steampunk_blimp.reclamp(value, min, max)
    local retVal = value
    local mid = (max-min)/2
    if value > min and value <= (min+mid) then retVal = min end
    if value < max and value > (max-mid) then retVal = max end
    --minetest.chat_send_all(value .. " - return: " ..retVal .. " - mid: " .. mid)
    return retVal
end

local function is_obstacle_zone(pos, start_point, end_point)
    local retVal = steampunk_blimp.table_copy(pos)

    local min_x, min_z, max_x, max_z

    if start_point.x <= end_point.x then min_x = start_point.x else min_x = end_point.x end
    if start_point.z <= end_point.z then min_z = start_point.z else min_z = end_point.z end
    if start_point.x > end_point.x then max_x = start_point.x else max_x = end_point.x end
    if start_point.z > end_point.z then max_z = start_point.z else max_z = end_point.z end

    local mid_x = (max_x - min_x)/2
    local mid_z = (max_z - min_z)/2

    if pos.x < max_x and pos.x > min_x+mid_x and
            pos.z < max_z and pos.z > min_z then
        retVal.x = max_x + 1
        return retVal
    end
    if pos.x > min_x and pos.x <= min_x+mid_x and
            pos.z < max_z and pos.z > min_z then
        retVal.x = min_x - 1
        return retVal
    end

    local death_zone = 1.5 --to avoid the "slip" when colliding in y direction
    if pos.z < max_z + death_zone and pos.z > min_z+mid_z and
            pos.x > min_x and pos.x < max_x then
        retVal.z = max_z + 1
        return retVal
    end
    if pos.z > min_z - death_zone and pos.z <= min_z+mid_z and
            pos.x > min_x and pos.x < max_x then
        retVal.z = min_z - 1
        return retVal
    end

    return retVal
end


function steampunk_blimp.boat_upper_deck_map(pos, dpos)
    local orig_pos = steampunk_blimp.copy_vector(pos)
    local position = steampunk_blimp.copy_vector(dpos)
    local new_pos = steampunk_blimp.copy_vector(dpos)

    new_pos.z = steampunk_blimp.clamp(new_pos.z, -47, -16)
    new_pos = is_obstacle_zone(new_pos, {x=4, z=-28}, {x=-4, z=-20}) --timao
    new_pos = is_obstacle_zone(new_pos, {x=-30, z=-24}, {x=4, z=-12})

    if position.z >= -49 and position.z < -32 then --limit 10
        new_pos.y = 20.821
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -8, 8)
        return new_pos
    end
    if position.z >= -32 and position.z < -14 then --limit 11
        new_pos.y = 20.821
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -11, 11)

        if position.z > -24 then --escada
            if orig_pos.x <= 4 then
                new_pos.z = steampunk_blimp.reclamp(new_pos.z, -24, -12)
            end
        end
        return new_pos
    end
    return new_pos
end

local function is_ladder_zone(pos)
    local ladder_zone = false
    if pos.z <= -12 and pos.z >= -18 and pos.x > 4 and pos.x < 12 then ladder_zone = true end
    return ladder_zone
end

function steampunk_blimp.boat_lower_deck_map(pos, dpos)
    local position = steampunk_blimp.copy_vector(dpos)
    local new_pos = steampunk_blimp.copy_vector(dpos)
    new_pos.z = steampunk_blimp.clamp(new_pos.z, -29, 45)

    if position.z > -31 and position.z < -14 then --limit 10
        new_pos.y = 0
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -10, 10)
        new_pos = is_obstacle_zone(new_pos, {x=-6, z=-9}, {x=6, z=14}) --caldeira
        return new_pos
    end

    if position.z >= -14 and position.z < -4 then --limit 11
        new_pos.y = 0
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -12, 12)
        new_pos = is_obstacle_zone(new_pos, {x=-6, z=-9}, {x=6, z=14}) --caldeira
        return new_pos
    end

    if position.z >= -4 and position.z <= 4 then --limit 14
        new_pos.y = 0
        new_pos.x = steampunk_blimp.clamp(position.x, -14, 14)
        new_pos = is_obstacle_zone(new_pos, {x=-6, z=-9}, {x=6, z=14}) --caldeira
        return new_pos
    end

    if position.z > 4 and position.z <= 19 then --limit 11
        new_pos.y = 0
        new_pos.x = steampunk_blimp.clamp(position.x, -12, 12)
        new_pos = is_obstacle_zone(new_pos, {x=-6, z=-9}, {x=6, z=14}) --caldeira
        return new_pos
    end

    if position.z > 19 and position.z <= 22 then --limit 10
        new_pos.y = 4.4
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -10, 10)
        return new_pos
    end

    if position.z > 22 and position.z <= 30 then --limit 7
        new_pos.y = 8.5
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -7, 7)
        return new_pos
    end

    if position.z > 30 and position.z <= 36 then --limit 5
        new_pos.y = 8.5
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -5, 5)
        return new_pos
    end

    if position.z > 36 and position.z < 47 then --limit 1
        new_pos.y = 8.5
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -2, 2)
        return new_pos
    end

    return new_pos
end

function steampunk_blimp.ladder_map(pos, dpos)
    local position = steampunk_blimp.copy_vector(dpos)
    local new_pos = steampunk_blimp.copy_vector(dpos)
    new_pos.z = steampunk_blimp.clamp(new_pos.z, -18, -12)
    if position.z > -20 and position.z < -10 then --limit 10
        new_pos.x = steampunk_blimp.clamp(new_pos.x, 4, 12)
    end
    return new_pos
end

function steampunk_blimp.navigate_deck(pos, dpos, player)
    local pos_d = dpos
    local ladder_zone = is_ladder_zone(pos)

    local upper_deck_y = 20.821
    local lower_deck_y = 0
    if player then
        if pos.y == upper_deck_y then
            pos_d = steampunk_blimp.boat_upper_deck_map(pos, dpos)
        elseif pos.y <= 8.5 and pos.y >= 0 then
            if ladder_zone == false then
                pos_d = steampunk_blimp.boat_lower_deck_map(pos, dpos)
            end
        elseif pos.y > 8.5 and pos.y < upper_deck_y then
            pos_d = steampunk_blimp.ladder_map(pos, dpos)
        end

        local ctrl = player:get_player_control()
        if ctrl.jump or ctrl.sneak then --ladder
            if ladder_zone then
                --minetest.chat_send_all(dump(pos))
                if ctrl.jump then
                    pos_d.y = pos_d.y + 0.9
                    if pos_d.y > upper_deck_y then pos_d.y = upper_deck_y end
                end
                if ctrl.sneak then
                    pos_d.y = pos_d.y - 0.9
                    if pos_d.y < lower_deck_y then pos_d.y = lower_deck_y end
                end
            end
        end
    end
    --minetest.chat_send_all(dump(pos_d))

    return pos_d
end

--note: index variable just for the walk
--this function was improved by Auri Collings on steampumove_personsnk_blimp
local function get_result_pos(self, player, index)
    local pos = nil
    if player then
        local ctrl = player:get_player_control()

        local direction = player:get_look_horizontal()
        local rotation = self.object:get_rotation()
        direction = direction - rotation.y

        pos = vector.new()

        local y_rot = -math.deg(direction)
        pos.y = y_rot --okay, this is strange to keep here, but as I dont use it anyway...


        if ctrl.up or ctrl.down or ctrl.left or ctrl.right then
            if airutils.is_mcl then
                mcl_player.player_set_animation(player, "walk", 30)
            elseif airutils.is_repixture then
                rp_player.player_set_animation(player, "walk", 30)
            else
                player_api.set_animation(player, "walk", 30)
            end

            local speed = 0.4

            local dir = vector.new(ctrl.up and -1 or ctrl.down and 1 or 0, 0, ctrl.left and 1 or ctrl.right and -1 or 0)
            dir = vector.normalize(dir)
            dir = vector.rotate(dir, {x = 0, y = -direction, z = 0})

            local time_correction = (self.dtime/steampunk_blimp.ideal_step)
            local move = speed * time_correction

            pos.x = move * dir.x
            pos.z = move * dir.z

            --lets fake walk sound
            if self._passengers_base_pos[index].dist_moved == nil then self._passengers_base_pos[index].dist_moved = 0 end
            self._passengers_base_pos[index].dist_moved = self._passengers_base_pos[index].dist_moved + move;
            if math.abs(self._passengers_base_pos[index].dist_moved) > 5 then
                self._passengers_base_pos[index].dist_moved = 0
                minetest.sound_play({name = steampunk_blimp.steps_sound.name},
                    {object = player, gain = steampunk_blimp.steps_sound.gain,
                        max_hear_distance = 5,
                        ephemeral = true,})
            end
        else
            if airutils.is_mcl then
                mcl_player.player_set_animation(player, "stand", 30)
            elseif airutils.is_repixture then
                rp_player.player_set_animation(player, "stand", 30)
            else
                player_api.set_animation(player, "stand", 30)
            end
        end
    end
    return pos
end


function steampunk_blimp.move_persons(self)
    --self._passenger = nil
    if self.object == nil then return end

    for i = steampunk_blimp.max_seats,1,-1
    do
        local player = nil
        if self._passengers[i] then player = minetest.get_player_by_name(self._passengers[i]) end

        if self.driver_name and self._passengers[i] == self.driver_name then
            --clean driver if it's nil
            if player == nil then
                self._passengers[i] = nil
                self.driver_name = nil
            end
        else
            if self._passengers[i] ~= nil then
                --minetest.chat_send_all("pass: "..dump(self._passengers[i]))
                --the rest of the passengers
                if player then
                    if self._passenger_is_sit[i] == 0 then
                        local result_pos = get_result_pos(self, player, i)
                        local y_rot = 0
                        if result_pos then
                            y_rot = result_pos.y -- the only field that returns a rotation
                            local new_pos = steampunk_blimp.copy_vector(self._passengers_base_pos[i])
                            new_pos.x = new_pos.x - result_pos.z
                            new_pos.z = new_pos.z - result_pos.x
                            --minetest.chat_send_all(dump(new_pos))
                            local pos_d = steampunk_blimp.navigate_deck(self._passengers_base_pos[i], new_pos, player)
                            --minetest.chat_send_all(dump(height))
                            self._passengers_base_pos[i] = steampunk_blimp.copy_vector(pos_d)
                            self._passengers_base[i]:set_attach(self.object,'',self._passengers_base_pos[i],{x=0,y=0,z=0})
                        end
                        --minetest.chat_send_all(dump(self._passengers_base_pos[i]))
                        player:set_attach(self._passengers_base[i], "", {x = 0, y = 0, z = 0}, {x = 0, y = y_rot, z = 0})
                    else
                        local y_rot = 0
                        if self._passenger_is_sit[i] == 1 then y_rot = 0 end
                        if self._passenger_is_sit[i] == 2 then y_rot = 90 end
                        if self._passenger_is_sit[i] == 3 then y_rot = 180 end
                        if self._passenger_is_sit[i] == 4 then y_rot = 270 end
                        player:set_attach(self._passengers_base[i], "", {x = 0, y = 3.6, z = 0}, {x = 0, y = y_rot, z = 0})
                        airutils.sit(player)
                    end
                end
            end
        end
    end
end


