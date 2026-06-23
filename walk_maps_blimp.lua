function steampunk_blimp.boat_upper_deck_map(pos, dpos)
    local orig_pos = steampunk_blimp.copy_vector(pos)
    local position = steampunk_blimp.copy_vector(dpos)
    local new_pos = steampunk_blimp.copy_vector(dpos)

    new_pos.z = steampunk_blimp.clamp(new_pos.z, -47, -16)
    new_pos = steampunk_blimp.is_obstacle_zone(new_pos, {x=4, z=-28}, {x=-4, z=-20}) --timao

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

function steampunk_blimp.boat_lower_deck_map(pos, dpos)
    local position = steampunk_blimp.copy_vector(dpos)
    local new_pos = steampunk_blimp.copy_vector(dpos)
    new_pos.z = steampunk_blimp.clamp(new_pos.z, -29, 45)

    if position.z > -31 and position.z < -14 then --limit 10
        new_pos.y = 0
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -10, 10)
        new_pos = steampunk_blimp.is_obstacle_zone(new_pos, {x=-6, z=-9}, {x=6, z=14}) --caldeira
        return new_pos
    end

    if position.z >= -14 and position.z < -4 then --limit 11
        new_pos.y = 0
        new_pos.x = steampunk_blimp.clamp(new_pos.x, -12, 12)
        new_pos = steampunk_blimp.is_obstacle_zone(new_pos, {x=-6, z=-9}, {x=6, z=14}) --caldeira
        return new_pos
    end

    if position.z >= -4 and position.z <= 4 then --limit 14
        new_pos.y = 0
        new_pos.x = steampunk_blimp.clamp(position.x, -14, 14)
        new_pos = steampunk_blimp.is_obstacle_zone(new_pos, {x=-6, z=-9}, {x=6, z=14}) --caldeira
        return new_pos
    end

    if position.z > 4 and position.z <= 19 then --limit 11
        new_pos.y = 0
        new_pos.x = steampunk_blimp.clamp(position.x, -12, 12)
        new_pos = steampunk_blimp.is_obstacle_zone(new_pos, {x=-6, z=-9}, {x=6, z=14}) --caldeira
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

local function is_ladder_zone(pos)
    local ladder_zone = false
    if pos.z <= -12 and pos.z >= -18 and pos.x > 4 and pos.x < 12 then ladder_zone = true end
    return ladder_zone
end

function steampunk_blimp.navigate_blimp_deck(pos, dpos, player)
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
                --core.chat_send_all(dump(pos))
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
    --core.chat_send_all(dump(pos_d))

    return pos_d
end
