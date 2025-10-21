
local function is_pos_in_range(pos, range)
	if not pos then return false end
    local connected_players = core.get_connected_players()
	for _, player in pairs(connected_players) do
		if vector.distance(player:get_pos(),pos)<=range then return true end
	end
	return false
end
