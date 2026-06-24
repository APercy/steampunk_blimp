steampunk_blimp = {}
steampunk_blimp.gravity = 9.8
local modpath = core.get_modpath(core.get_current_modname())
steampunk_blimp.fuel = {
	['default:coal_lump'] = { amount = 1 },
	['default:coalblock'] = { amount = 10 },
	['rp_default:lump_coal'] = { amount = 1 },
	['rp_default:block_coal'] = { amount = 10 },
	['mcl_core:coal_lump'] = { amount = 1 },
	['mcl_core:coalblock'] = { amount = 10 },
	['default:coal_lump'] = { amount = 1 },
	['default:coalblock'] = { amount = 10 }
}
steampunk_blimp.water = {
	['default:water_source'] = { amount = 1 },
	['default:river_water_source'] = { amount = 1 },
	['bucket:bucket_water'] = { amount = 1 },
	['bucket:bucket_river_water'] = { amount = 1 },
	['mcl_buckets:bucket_water'] = { amount = 1 },
	['mcl_buckets:bucket_river_water'] = { amount = 1 },
	['mcl_core:water_source'] = { amount = 1 },
	['rp_default:bucket_water'] = { amount = 1 },
	['rp_default:bucket_river_water'] = { amount = 1 },
} --bucket:bucket_empty
steampunk_blimp.rep_material = {
	['default:gold_lump'] = { amount = 5 },
	['default:gold_ingot'] = { amount = 10 },
	['mcl_core:gold_ingot'] = { amount = 10 }
}
steampunk_blimp.avail_powder = { "tnt:gunpowder", "mcl_mobitems:gunpowder", "cannons:gunpowder", }
steampunk_blimp.avail_ammo = { "steampunk_blimp:cannon_ball1", }

if core.get_modpath("cannons") then
	local cannons_entities = {
		"cannons:ball_wood_stack_1",
		"cannons:ball_stone_stack_1",
		"cannons:ball_steel_stack_1",
		"cannons:ball_fire_stack_1",
		"cannons:ball_exploding_stack_1",
	}
	for _, v in ipairs(cannons_entities) do table.insert(steampunk_blimp.avail_ammo, v) end
end

steampunk_blimp.ideal_step = 0.02
steampunk_blimp.min_hp = 10
steampunk_blimp.max_hp = 50
steampunk_blimp.min_damage_value = 20 --min value to cause damage
steampunk_blimp.rudder_limit = 30
steampunk_blimp.iddle_rotation = 0
steampunk_blimp.wind_enabled = false

--[[steampunk_blimp.passenger_pos = {
	[1] = { x = 0.0, y = 0, z = -15 },
	[2] = { x = -11, y = 0, z = -12 },
	[3] = { x = 11, y = 0, z = -12 },
	[4] = { x = -11, y = 0, z = 14 },
	[5] = { x = 11, y = 0, z = 14 },
	[6] = { x = -11, y = 0, z = 13 },
	[7] = { x = 11, y = 0, z = 13 },
}]]--
function steampunk_blimp.get_random_pos(posy, limx, minz, maxz)
 return {x=math.random(-limx, limx), y = posy, z=math.random(minz, maxz) }
end


steampunk_blimp.furnace_sound = { name = "default_furnace_active", pitch = 1.0, gain = 0.2 }
steampunk_blimp.piston_sound = { name = "default_cool_lava", pitch = 0.4, gain = 0.05 }
steampunk_blimp.steps_sound = { name = "default_wood_footstep", pitch = 1.0, gain = 0.1 }

if airutils.is_mcl then
	steampunk_blimp.furnace_sound = { name = "fire_fire", pitch = 1.0, gain = 0.2 }
elseif airutils.is_repixture then
	steampunk_blimp.furnace_sound = nil
	steampunk_blimp.piston_sound = { name = "rp_default_torch_burnout", pitch = 0.3, gain = 0.15 }
	steampunk_blimp.steps_sound = { name = "rp_sounds_footstep_wood", pitch = 1.0, gain = 0.5 }
end

dofile(modpath .. DIR_DELIM .. "textures.lua")

if airutils.is_repixture then
    steampunk_blimp.set_repixture_blimptextures()
else
    steampunk_blimp.set_minetest_blimptextures()
    steampunk_blimp.set_minetest_hsatextures()
end

steampunk_blimp.colors = {
	black = 'black',
	blue = 'blue',
	brown = 'brown',
	cyan = 'cyan',
	dark_green = 'dark_green',
	dark_grey = 'dark_grey',
	green = 'green',
	grey = 'grey',
	magenta = 'magenta',
	orange = 'orange',
	pink = 'pink',
	red = 'red',
	violet = 'violet',
	white = 'white',
	yellow = 'yellow',
}

steampunk_blimp.cannons_loc = { x = 24, y = -2, z = 0 }
steampunk_blimp.cannons_sz = 15

dofile(modpath .. DIR_DELIM .. "cannon_balls.lua")
dofile(modpath .. DIR_DELIM .. "walk_map.lua")
dofile(modpath .. DIR_DELIM .. "utilities.lua")
dofile(modpath .. DIR_DELIM .. "control.lua")
dofile(modpath .. DIR_DELIM .. "fuel_management.lua")
dofile(modpath .. DIR_DELIM .. "engine_management.lua")
dofile(modpath .. DIR_DELIM .. "custom_physics.lua")
dofile(modpath .. DIR_DELIM .. "hud.lua")
dofile(modpath .. DIR_DELIM .. "entities.lua")
dofile(modpath .. DIR_DELIM .. "forms.lua")
dofile(modpath .. DIR_DELIM .. "manual.lua")

--
-- helpers and co.
--

function steampunk_blimp.get_hipotenuse_value(point1, point2)
	return math.sqrt((point1.x - point2.x) ^ 2 + (point1.y - point2.y) ^ 2 + (point1.z - point2.z) ^ 2)
end

function steampunk_blimp.dot(v1, v2) return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z end

function steampunk_blimp.sign(n) return n >= 0 and 1 or -1 end

function steampunk_blimp.minmax(v, m) return math.min(math.abs(v), m) * steampunk_blimp.sign(v) end

-----------
-- items
-----------
-- blimp
core.register_tool("steampunk_blimp:blimp", {
	description = "Steampunk Blimp",
	inventory_image = "steampunk_blimp_icon.png",
	liquids_pointable = true,
	stack_max = 1,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return end

		local stack_meta = itemstack:get_meta()
		local staticdata = stack_meta:get_string("staticdata")

		local pointed_pos = pointed_thing.under
		--local node_below = core.get_node(pointed_pos).name
		--local nodedef = core.registered_nodes[node_below]

		pointed_pos.y = pointed_pos.y + 3
		local blimp = core.add_entity(pointed_pos, "steampunk_blimp:blimp", staticdata)
		if blimp and placer then
			local ent = blimp:get_luaentity()
			ent._passengers = steampunk_blimp.allocate_array(ent.max_seats)
			--core.chat_send_all('passengers: '.. dump(ent._passengers))
			local owner = placer:get_player_name()
			ent.owner = owner
			--ent.hp = 50 --reset hp
			blimp:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
			steampunk_blimp.create_inventory(ent, ent.trunk_slots)

			local properties = ent.object:get_properties()
			properties.infotext = owner .. " nice blimp"
			blimp:set_properties(properties)
			--steampunk_blimp.attach_pax(ent, placer)
		end

		return itemstack
	end,
})


-- tactical steampunk blimp
core.register_tool("steampunk_blimp:cannon_blimp", {
	description = "Gunboat Steampunk Blimp",
	inventory_image = "steampunk_blimp_gunboat_icon.png",
	liquids_pointable = true,
	stack_max = 1,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return end

		local owner = placer:get_player_name()

		local stack_meta = itemstack:get_meta()
		local staticdata = stack_meta:get_string("staticdata")
		if staticdata == nil or staticdata == "" then
			staticdata = 'return {stored_has_cannons=true,stored_owner="' .. owner .. '",}'
		end

		local pointed_pos = pointed_thing.under
		--local node_below = core.get_node(pointed_pos).name
		--local nodedef = core.registered_nodes[node_below]

		pointed_pos.y = pointed_pos.y + 3
		local blimp = core.add_entity(pointed_pos, "steampunk_blimp:blimp", staticdata)
		if blimp and placer then
			local ent = blimp:get_luaentity()
			ent._passengers = steampunk_blimp.allocate_array(ent.max_seats)
			--core.chat_send_all('passengers: '.. dump(ent._passengers))
			ent.owner = owner
			--ent.hp = 50 --reset hp
			ent._vehicle_name = "Gunboat Steampunk Blimp",
				steampunk_blimp.paint(ent, "black")
			blimp:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
			steampunk_blimp.create_inventory(ent, ent.trunk_slots)

			local properties = ent.object:get_properties()
			properties.infotext = owner .. " war blimp"
			blimp:set_properties(properties)
			--steampunk_blimp.attach_pax(ent, placer)
		end

		return itemstack
	end,
})


-- ephemeral blimp
core.register_craftitem("steampunk_blimp:ephemeral_blimp", {
	description = "Ephemeral Blimp",
	inventory_image = "steampunk_blimp_ephemeral_icon.png",
	liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return end

		local pointed_pos = pointed_thing.under
		--local node_below = core.get_node(pointed_pos).name
		--local nodedef = core.registered_nodes[node_below]

		pointed_pos.y = pointed_pos.y + 3
		local blimp = core.add_entity(pointed_pos, "steampunk_blimp:blimp")
		if blimp and placer then
			local ent = blimp:get_luaentity()
			ent._passengers = steampunk_blimp.allocate_array(ent.max_seats)
			--core.chat_send_all('passengers: '.. dump(ent._passengers))
			local owner = placer:get_player_name()
			ent.owner = owner
			ent._remove = true
			ent._water_level = steampunk_blimp.MAX_WATER --start it full loaded
			ent._energy = steampunk_blimp.MAX_FUEL	   --start it full loaded
			ent._vehicle_name = "Ephemeral Blimp",
				steampunk_blimp.paint(ent, "orange")
			blimp:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()

			local properties = ent.object:get_properties()
			properties.infotext = owner .. " nice blimp"
			blimp:set_properties(properties)
			--steampunk_blimp.attach_pax(ent, placer)
		end

		return itemstack
	end,
})

-- high speed airship
core.register_tool("steampunk_blimp:hsa", {
	description = "High Speed Airship",
	inventory_image = "steampunk_blimp_gunboat_icon.png",
	liquids_pointable = false,
	stack_max = 1,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return end

		local owner = placer:get_player_name()

		local stack_meta = itemstack:get_meta()
		local staticdata = stack_meta:get_string("staticdata")
		if staticdata == nil or staticdata == "" then
			staticdata = 'return {stored_owner="' .. owner .. '",}'
		end

		local pointed_pos = pointed_thing.under
		--local node_below = core.get_node(pointed_pos).name
		--local nodedef = core.registered_nodes[node_below]

		pointed_pos.y = pointed_pos.y + 3
		local blimp = core.add_entity(pointed_pos, "steampunk_blimp:hsa", staticdata)
		if blimp and placer then
			local ent = blimp:get_luaentity()
			ent._passengers = steampunk_blimp.allocate_array(ent.max_seats)
			--core.chat_send_all('passengers: '.. dump(ent._passengers))
			ent.owner = owner
			--ent.hp = 50 --reset hp
			ent._vehicle_name = "High Speed Airship"
			blimp:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
			steampunk_blimp.create_inventory(ent, ent.trunk_slots)

			local properties = ent.object:get_properties()
			blimp:set_properties(properties)
		end

		return itemstack
	end,
})


steampunk_blimp.wind_enabled = core.settings:get_bool('steampunk_blimp.enable_wind')
steampunk_blimp.cannons_enabled = core.settings:get_bool('steampunk_blimp.enable_cannons')
steampunk_blimp.only_owners_can_repair = core.settings:get_bool('steampunk_blimp.only_owners_can_repair')

--
-- crafting
--

if not core.settings:get_bool('steampunk_blimp.disable_craftitems') then
	local item_name = "steampunk_blimp:cylinder_part"
	if airutils.is_repixture then
		crafting.register_craft({ output = item_name, items = { "group:fuzzy 8", "rp_default:stick 4", "group:planks 1", } })
	elseif airutils.is_mcl then
		core.register_craft({ output = item_name, recipe = { { "mcl_core:stick", "mcl_wool:white", "mcl_core:stick" }, { "mcl_wool:white", "mcl_core:wood", "mcl_wool:white" }, { "mcl_core:stick", "mcl_wool:white", "mcl_core:stick" }, } })
	else
		core.register_craft({ output = item_name, recipe = { { "default:stick", "wool:white", "default:stick" }, { "wool:white", "group:wood", "wool:white" }, { "default:stick", "wool:white", "default:stick" }, } })
	end

	item_name = "steampunk_blimp:cylinder"
	if airutils.is_repixture then
		crafting.register_craft({ output = item_name, items = { "steampunk_blimp:cylinder_part 3", } })
	else
		core.register_craft({ output = item_name, recipe = { { "steampunk_blimp:cylinder_part", "steampunk_blimp:cylinder_part", "steampunk_blimp:cylinder_part" }, } })
	end

	item_name = "steampunk_blimp:rotor"
	if airutils.is_repixture then
		crafting.register_craft({ output = item_name, items = { "group:fuzzy 3", "rp_default:stick 3", "rp_default:block_wrought_iron 1", } })
	elseif airutils.is_mcl then
		core.register_craft({ output = item_name, recipe = { { "mcl_wool:white", "mcl_core:stick", "" }, { "mcl_wool:white", "mcl_core:stick", "mcl_core:ironblock" }, { "mcl_wool:white", "mcl_core:stick", "" }, } })
	else
		core.register_craft({ output = item_name, recipe = { { "wool:white", "default:stick", "" }, { "wool:white", "default:stick", "default:steelblock" }, { "wool:white", "default:stick", "" }, } })
	end

	item_name = "steampunk_blimp:boiler"
	if airutils.is_repixture then
		crafting.register_craft({ output = item_name, items = { "rp_default:ingot_wrought_iron 4", "rp_default:block_wrought_iron 2", } })
	elseif airutils.is_mcl then
		core.register_craft({ output = item_name, recipe = { { "mcl_core:iron_ingot", "mcl_core:iron_ingot" }, { "mcl_core:ironblock", "mcl_core:iron_ingot", }, { "mcl_core:ironblock", "mcl_core:iron_ingot" }, } })
	else
		core.register_craft({ output = item_name, recipe = { { "default:steel_ingot", "default:steel_ingot" }, { "default:steelblock", "default:steel_ingot", }, { "default:steelblock", "default:steel_ingot" }, } })
	end

	if steampunk_blimp.cannons_enabled == true then
		item_name = "steampunk_blimp:cannon"
		if airutils.is_repixture then
			crafting.register_craft({ output = item_name, items = { "rp_default:ingot_wrought_iron 2", "rp_default:block_wrought_iron 4", "group:planks 3", } })
		elseif airutils.is_mcl then
			core.register_craft({ output = item_name, recipe = { { "mcl_core:ironblock", "mcl_core:ironblock", "group:wood" }, { "mcl_core:iron_ingot", "mcl_core:iron_ingot", "group:wood" }, { "mcl_core:ironblock", "mcl_core:ironblock", "group:wood" }, } })
		else
			core.register_craft({ output = item_name, recipe = { { "default:steelblock", "default:steelblock", "group:wood" }, { "default:steel_ingot", "default:steel_ingot", "group:wood" }, { "default:steelblock", "default:steelblock", "group:wood" }, } })
		end
	end

	item_name = "steampunk_blimp:boat"
	if airutils.is_repixture then
		crafting.register_craft({ output = item_name, items = { "group:planks 6", "steampunk_blimp:rotor 2", "steampunk_blimp:boiler 1", } })
	else
		core.register_craft({ output = item_name, recipe = { { "group:wood", "group:wood", "steampunk_blimp:rotor" }, { "group:wood", "steampunk_blimp:boiler", "group:wood" }, { "group:wood", "group:wood", "steampunk_blimp:rotor" }, } })
	end

	item_name = "steampunk_blimp:blimp"
	if airutils.is_repixture then
		crafting.register_craft({ output = item_name, items = { "steampunk_blimp:cylinder 1", "steampunk_blimp:boat 1", } })
	else
		core.register_craft({ output = item_name, recipe = { { "steampunk_blimp:cylinder", }, { "steampunk_blimp:boat", }, } })
	end

	if steampunk_blimp.cannons_enabled == true then
		item_name = "steampunk_blimp:cannon_blimp"
		if airutils.is_repixture then
			crafting.register_craft({ output = item_name, items = { "steampunk_blimp:blimp 1", "steampunk_blimp:cannon 2", } })
		else
			core.register_craft({
				output = item_name,
				recipe = { { "steampunk_blimp:cannon", "steampunk_blimp:blimp", "steampunk_blimp:cannon", }, }
			})
		end
		if airutils.is_minetest then
			core.register_craft({
				output = 'steampunk_blimp:cannon_ball1',
				recipe = { { "", "default:steel_ingot", "" }, { "default:steel_ingot", "tnt:tnt_stick", "default:steel_ingot" }, { "", "default:steel_ingot", "" }, }
			})
		elseif airutils.is_mcl then
			core.register_craft({
				output = 'steampunk_blimp:cannon_ball1',
				recipe = { { "", "mcl_core:iron_ingot", "" }, { "mcl_core:iron_ingot", "mcl_tnt:tnt", "mcl_core:iron_ingot" }, { "", "mcl_core:iron_ingot", "" }, }
			})
		end
	end

	-- cylinder section
	core.register_craftitem("steampunk_blimp:cylinder_part",
		{ description = "steampunk_blimp cylinder section", inventory_image = "steampunk_blimp_cylinder_part.png", })

	-- cylinder
	core.register_craftitem("steampunk_blimp:cylinder",
		{ description = "steampunk_blimp cylinder", inventory_image = "steampunk_blimp_cylinder.png", })

	-- boiler
	core.register_craftitem("steampunk_blimp:boiler",
		{ description = "steampunk_blimp boiler", inventory_image = "steampunk_blimp_boiler.png", })

	-- cannon
	core.register_craftitem("steampunk_blimp:cannon",
		{ description = "steampunk_blimp cannon", inventory_image = "steampunk_blimp_cannon_ico.png", })

	-- rotor
	core.register_craftitem("steampunk_blimp:rotor",
		{ description = "steampunk_blimp rotor", inventory_image = "steampunk_blimp_rotor.png", })

	-- fuselage
	core.register_craftitem("steampunk_blimp:boat",
		{ description = "steampunk_blimp fuselage", inventory_image = "steampunk_blimp_boat.png", })
end
