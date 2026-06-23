function steampunk_blimp.hsa_deck_map(pos, dpos)
    local position = steampunk_blimp.copy_vector(dpos)
    local new_pos = steampunk_blimp.copy_vector(dpos)
    new_pos.y = 0
    new_pos.z = steampunk_blimp.clamp(new_pos.z, 4.5, 33.5)
    new_pos.x = steampunk_blimp.clamp(new_pos.x, -5, 5)

    return new_pos
end

function steampunk_blimp.navigate_hsa_deck(pos, dpos, player)
    local pos_d = dpos

    if player then
        pos_d = steampunk_blimp.hsa_deck_map(pos, dpos)
    end
    --core.chat_send_all(dump(pos_d))

    return pos_d
end
