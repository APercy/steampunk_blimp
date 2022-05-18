steampunk_blimp={}
steampunk_blimp.gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.8
steampunk_blimp.fuel = {['default:coal_lump'] = {amount=1},['default:coalblock'] = {amount=10}}
steampunk_blimp.ideal_step = 0.02
steampunk_blimp.rudder_limit = 30
steampunk_blimp.iddle_rotation = 0
steampunk_blimp.max_engine_acc = 3
steampunk_blimp.pilot_base_pos = {x=0.0,y=20.821,z=-30.844}
steampunk_blimp.passenger_pos = {
    [1] = {x=0.0,y=0,z=-15},
    [2] = {x=-11,y=0,z=-12},
    [3] = {x=11,y=0,z=-12},
    [4] = {x=-11,y=0,z=14},
    [5] = {x=11,y=0,z=14},
    }

local steampunk_blimp_attached = {}

steampunk_blimp.colors ={
    black='#2b2b2b',
    blue='#0063b0',
    brown='#8c5922',
    cyan='#07B6BC',
    dark_green='#567a42',
    dark_grey='#6d6d6d',
    green='#4ee34c',
    grey='#9f9f9f',
    magenta='#ff0098',
    orange='#ff8b0e',
    pink='#ff62c6',
    red='#dc1818',
    violet='#a437ff',
    white='#FFFFFF',
    yellow='#ffe400',
}

function steampunk_blimp.clone_node(node_name)
    if not (node_name and type(node_name) == 'string') then
        return
    end

    local node = minetest.registered_nodes[node_name]
    return table.copy(node)
end

dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "utilities.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "control.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "fuel_management.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "custom_physics.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "entities.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "forms.lua")

--
-- helpers and co.
--

function steampunk_blimp.get_hipotenuse_value(point1, point2)
    return math.sqrt((point1.x - point2.x) ^ 2 + (point1.y - point2.y) ^ 2 + (point1.z - point2.z) ^ 2)
end

function steampunk_blimp.dot(v1,v2)
    return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
end

function steampunk_blimp.sign(n)
    return n>=0 and 1 or -1
end

function steampunk_blimp.minmax(v,m)
    return math.min(math.abs(v),m)*steampunk_blimp.sign(v)
end

-----------
-- items
-----------

-- blimp
minetest.register_craftitem("steampunk_blimp:blimp", {
	description = "Steampunk Blimp",
	inventory_image = "steampunk_blimp_icon.png",
    liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local pointed_pos = pointed_thing.under
        local node_below = minetest.get_node(pointed_pos).name
        local nodedef = minetest.registered_nodes[node_below]
        if nodedef.liquidtype ~= "none" then
        end

		pointed_pos.y=pointed_pos.y+5
		local blimp = minetest.add_entity(pointed_pos, "steampunk_blimp:blimp")
		if boat and placer then
            local ent = blimp:get_luaentity()
            local owner = placer:get_player_name()
            ent.owner = owner
			blimp:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()

            local properties = ent.object:get_properties()
            properties.infotext = owner .. " nice blimp"
            ent.object:set_properties(properties)
		end

		return itemstack
	end,
})



