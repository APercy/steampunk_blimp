local modpath = core.get_modpath(core.get_current_modname())
dofile(modpath .. DIR_DELIM .. "walk_maps_blimp.lua")
dofile(modpath .. DIR_DELIM .. "walk_maps_hsa.lua")

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

function steampunk_blimp.is_obstacle_zone(pos, start_point, end_point)
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
                core.sound_play({name = steampunk_blimp.steps_sound.name},
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

    for i = self.max_seats,1,-1
    do
        local player = nil
        if self._passengers[i] then player = core.get_player_by_name(self._passengers[i]) end

        if self.driver_name and self._passengers[i] == self.driver_name then
            --clean driver if it's nil
            if player == nil then
                self._passengers[i] = nil
                self.driver_name = nil
            end
        else
            if self._passengers[i] ~= nil then
                --core.chat_send_all("pass: "..dump(self._passengers[i]))
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
                            --core.chat_send_all(dump(new_pos))
                            local pos_d = vector.new()

                            --select blimp type to navigate
                            if self.item == "steampunk_blimp:blimp" then
                                pos_d = steampunk_blimp.navigate_blimp_deck(self._passengers_base_pos[i], new_pos, player)
                            elseif self.item == "steampunk_blimp:hsa" then
                                pos_d = steampunk_blimp.navigate_hsa_deck(self._passengers_base_pos[i], new_pos, player)
                            end
                            --core.chat_send_all(dump(height))

                            if (self._passengers_base_pos[i].x ~= pos_d.x or self._passengers_base_pos[i].z ~= pos_d.z or self._passengers_base_pos[i].y ~= pos_d.y) then
                                --or self.profiler_counter1 == 1000 then --vai entrar sempre qdo for maior ou igual a 100
                                --core.chat_send_all(dump(self.dtime))
                                self._passengers_base_pos[i] = steampunk_blimp.copy_vector(pos_d)
                                if steampunk_blimp.move_player_mode == 1 then
                                    self._passengers_base[i]:set_attach(self.object,'',self._passengers_base_pos[i],{x=0,y=0,z=0})
                                else
                                    self.object:set_bone_override("p"..i, {position = {vec = self._passengers_base_pos[i], absolute = true},})
                                end
                            end
                        end
                        --core.chat_send_all(dump(self._passengers_base_pos[i]))
                        player:set_attach(self._passengers_base[i], "", {x = 0, y = 0, z = 0}, {x = 0, y = y_rot, z = 0})
                    end
                end
            end
        end
    end
    
end


