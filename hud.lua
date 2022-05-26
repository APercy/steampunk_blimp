steampunk_blimp.hud_list = {}

function steampunk_blimp.get_pointer_angle(value, maxvalue)
    local angle = value/maxvalue * 180
    --angle = angle - 90
    --angle = angle * -1
    return angle
end

function steampunk_blimp.animate_gauge(player, ids, prefix, x, y, angle)
    local angle_in_rad = math.rad(angle + 180)
    local dim = 10
    local pos_x = math.sin(angle_in_rad) * dim
    local pos_y = math.cos(angle_in_rad) * dim
    player:hud_change(ids[prefix .. "2"], "offset", {x = pos_x + x, y = pos_y + y})
    dim = 20
    pos_x = math.sin(angle_in_rad) * dim
    pos_y = math.cos(angle_in_rad) * dim
    player:hud_change(ids[prefix .. "3"], "offset", {x = pos_x + x, y = pos_y + y})
    dim = 30
    pos_x = math.sin(angle_in_rad) * dim
    pos_y = math.cos(angle_in_rad) * dim
    player:hud_change(ids[prefix .. "4"], "offset", {x = pos_x + x, y = pos_y + y})
    dim = 40
    pos_x = math.sin(angle_in_rad) * dim
    pos_y = math.cos(angle_in_rad) * dim
    player:hud_change(ids[prefix .. "5"], "offset", {x = pos_x + x, y = pos_y + y})
    dim = 50
    pos_x = math.sin(angle_in_rad) * dim
    pos_y = math.cos(angle_in_rad) * dim
    player:hud_change(ids[prefix .. "6"], "offset", {x = pos_x + x, y = pos_y + y})
    dim = 60
    pos_x = math.sin(angle_in_rad) * dim
    pos_y = math.cos(angle_in_rad) * dim
    player:hud_change(ids[prefix .. "7"], "offset", {x = pos_x + x, y = pos_y + y})
end

function steampunk_blimp.update_hud(player, coal, water, pressure, power_lever)
    if player == nil then return end
    local player_name = player:get_player_name()

    local screen_pos_y = -100
    local screen_pos_x = 10

    local water_gauge_x = screen_pos_x + 374
    local water_gauge_y = screen_pos_y
    local press_gauge_x = screen_pos_x + 85
    local press_gauge_y = water_gauge_y
    local coal_1_x = screen_pos_x + 182
    local coal_1_y = screen_pos_y
    local coal_2_x = coal_1_x + 60
    local coal_2_y = screen_pos_y
    local throttle_x = screen_pos_x + 395
    local throttle_y = screen_pos_y + 45

    local ids = steampunk_blimp.hud_list[player_name]
    if ids then
        local coal_value = coal
        if coal_value > 99 then coal_value = 99 end
        if coal_value < 0 then coal_value = 0 end
        player:hud_change(ids["coal_1"], "text", "steampunk_blimp_"..(math.floor(coal_value/10))..".png")
        player:hud_change(ids["coal_2"], "text", "steampunk_blimp_"..(math.floor(coal_value%10))..".png")

        player:hud_change(ids["throttle"], "offset", {x = throttle_x, y = throttle_y - power_lever})

        steampunk_blimp.animate_gauge(player, ids, "water_pt_", water_gauge_x, water_gauge_y, water)
        steampunk_blimp.animate_gauge(player, ids, "press_pt_", press_gauge_x, press_gauge_y, pressure)
    else
        ids = {}

        ids["title"] = player:hud_add({
            hud_elem_type = "text",
            position  = {x = 0, y = 1},
            offset    = {x = screen_pos_x + 240, y = screen_pos_y - 100},
            text      = "Blimp engine state",
            alignment = 0,
            scale     = { x = 100, y = 30},
            number    = 0xFFFFFF,
        })

        ids["bg"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = screen_pos_x, y = screen_pos_y},
            text      = "steampunk_blimp_hud_panel.png",
            scale     = { x = 0.5, y = 0.5},
            alignment = { x = 1, y = 0 },
        })

        ids["coal_1"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = coal_1_x, y = coal_1_y},
            text      = "steampunk_blimp_0.png",
            scale     = { x = 0.5, y = 0.5},
            alignment = { x = 1, y = 0 },
        })

        ids["coal_2"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = coal_2_x, y = coal_2_y},
            text      = "steampunk_blimp_0.png",
            scale     = { x = 0.5, y = 0.5},
            alignment = { x = 1, y = 0 },
        })
        
        ids["throttle"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = throttle_x, y = throttle_y},
            text      = "steampunk_blimp_throttle.png",
            scale     = { x = 0.5, y = 0.5},
            alignment = { x = 1, y = 0 },
        })

        ids["water_pt_1"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = water_gauge_x, y = water_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })

        ids["water_pt_2"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = water_gauge_x, y = water_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["water_pt_3"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = water_gauge_x, y = water_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["water_pt_4"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = water_gauge_x, y = water_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["water_pt_5"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = water_gauge_x, y = water_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["water_pt_6"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = water_gauge_x, y = water_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["water_pt_7"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = water_gauge_x, y = water_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })

        ids["press_pt_1"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = press_gauge_x, y = press_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["press_pt_2"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = press_gauge_x, y = press_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["press_pt_3"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = press_gauge_x, y = press_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["press_pt_4"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = press_gauge_x, y = press_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["press_pt_5"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = press_gauge_x, y = press_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["press_pt_6"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = press_gauge_x, y = press_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })
        ids["press_pt_7"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = press_gauge_x, y = press_gauge_y},
            text      = "steampunk_blimp_ind_box.png",
            scale     = { x = 6, y = 6},
            alignment = { x = 1, y = 0 },
        })

        steampunk_blimp.hud_list[player_name] = ids
    end
end


function steampunk_blimp.remove_hud(player)
    if player then
        local player_name = player:get_player_name()
        --minetest.chat_send_all(player_name)
        local ids = steampunk_blimp.hud_list[player_name]
        if ids then
            --player:hud_remove(ids["altitude"])
            --player:hud_remove(ids["time"])
            player:hud_remove(ids["title"])
            player:hud_remove(ids["bg"])
            player:hud_remove(ids["coal_1"])
            player:hud_remove(ids["coal_2"])
            player:hud_remove(ids["throttle"])
            player:hud_remove(ids["water_pt_7"])
            player:hud_remove(ids["water_pt_6"])
            player:hud_remove(ids["water_pt_5"])
            player:hud_remove(ids["water_pt_4"])
            player:hud_remove(ids["water_pt_3"])
            player:hud_remove(ids["water_pt_2"])
            player:hud_remove(ids["water_pt_1"])
            player:hud_remove(ids["press_pt_7"])
            player:hud_remove(ids["press_pt_6"])
            player:hud_remove(ids["press_pt_5"])
            player:hud_remove(ids["press_pt_4"])
            player:hud_remove(ids["press_pt_3"])
            player:hud_remove(ids["press_pt_2"])
            player:hud_remove(ids["press_pt_1"])
        end
        steampunk_blimp.hud_list[player_name] = nil
    end

end
