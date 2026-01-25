steampunk_blimp={}
steampunk_blimp.gravity = 9.8
steampunk_blimp.trunk_slots = 50
steampunk_blimp.fuel = {['default:coal_lump'] = {amount=1},['default:coalblock'] = {amount=10}, ['rp_default:lump_coal'] = {amount=1}, ['rp_default:block_coal'] = {amount=10},
    ['mcl_core:coal_lump'] = {amount=1},['mcl_core:coalblock'] = {amount=10}, ['default:coal_lump'] = {amount=1}, ['default:coalblock'] = {amount=10}}
steampunk_blimp.water = {['default:water_source'] = {amount=1},['default:river_water_source'] = {amount=1},
    ['bucket:bucket_water'] = {amount=1}, ['bucket:bucket_river_water'] = {amount=1},
    ['mcl_buckets:bucket_water'] = {amount=1}, ['mcl_buckets:bucket_river_water'] = {amount=1}, ['mcl_core:water_source'] = {amount=1},
    ['rp_default:bucket_water'] = {amount=1}, ['rp_default:bucket_river_water'] = {amount=1}, }  --bucket:bucket_empty
steampunk_blimp.rep_material = {['default:gold_lump'] = {amount=5},['default:gold_ingot'] = {amount=10}, ['mcl_core:gold_ingot'] = {amount=10}}
steampunk_blimp.avail_powder = {"tnt:gunpowder","mcl_mobitems:gunpowder", "cannons:gunpowder",}
steampunk_blimp.avail_ammo = {"steampunk_blimp:cannon_ball1",}

if core.get_modpath("cannons") then
    local cannons_entities = {
        "cannons:ball_wood_stack_1",
        "cannons:ball_stone_stack_1",
        "cannons:ball_steel_stack_1",
        "cannons:ball_fire_stack_1",
        "cannons:ball_exploding_stack_1",
        }
	for _, v in ipairs(cannons_entities) do
		table.insert(steampunk_blimp.avail_ammo, v)
	end
end

steampunk_blimp.ideal_step = 0.02
steampunk_blimp.min_hp = 10
steampunk_blimp.max_hp = 50
steampunk_blimp.min_damage_value = 20 --min value to cause damage
steampunk_blimp.rudder_limit = 30
steampunk_blimp.iddle_rotation = 0
steampunk_blimp.max_engine_acc = 3
steampunk_blimp.max_seats = 7
steampunk_blimp.wind_enabled = false
steampunk_blimp.pilot_base_pos = {x=0.0,y=20.821,z=-30}
steampunk_blimp.passenger_pos = {
    [1] = {x=0.0,y=0,z=-15},
    [2] = {x=-11,y=0,z=-12},
    [3] = {x=11,y=0,z=-12},
    [4] = {x=-11,y=0,z=14},
    [5] = {x=11,y=0,z=14},
    [6] = {x=-11,y=0,z=13},
    [7] = {x=11,y=0,z=13},
    }

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

if airutils.is_repixture then
    steampunk_blimp.color1_texture = "rp_default_reed_block_side.png"
    steampunk_blimp.color2_texture = "rp_default_reed_block_top.png"

    steampunk_blimp.fire_tex = "[combine:16x16:0,0=steampunk_blimp_alpha.png:0,0=rp_fire_bonfire_flame.png"      --"rp_fire_bonfire_flame.png^[resize:16x16"
    steampunk_blimp.canvas_texture = "mobs_wool.png^[colorize:#f4e7c1:128"
    steampunk_blimp.metal_texture = "default_sand.png^[colorize:#a3acac:128"
    steampunk_blimp.black_texture = "default_sand.png^[colorize:#030303:200"
    steampunk_blimp.wood_texture = "default_sand.png^[colorize:#3a270d:230"
    steampunk_blimp.forno_texture = steampunk_blimp.black_texture.."^[mask:steampunk_blimp_forno_mask.png"
    steampunk_blimp.rotor_texture = "("..steampunk_blimp.canvas_texture.."^[mask:steampunk_blimp_rotor_mask2.png)^(default_wood_oak.png^[mask:steampunk_blimp_rotor_mask.png)"
    local ladder_texture = "default_ladder.png"
    steampunk_blimp.textures = {
                steampunk_blimp.black_texture, --alimentacao balao
                steampunk_blimp.canvas_texture, --balao
                steampunk_blimp.color2_texture, --faixas brancas nariz
                steampunk_blimp.color1_texture, --faixas azuis nariz
                steampunk_blimp.metal_texture, --pontas do balão
                "airutils_name_canvas.png",
                steampunk_blimp.black_texture, --caldeira
                steampunk_blimp.forno_texture, --caldeira
                "default_wood_oak.png^[multiply:#A09090", --casco
                steampunk_blimp.black_texture, -- corpo da bussola
                steampunk_blimp.metal_texture, -- indicador bussola
                steampunk_blimp.canvas_texture, --leme
                "default_wood_oak.png^[multiply:#A09090", --leme
                steampunk_blimp.wood_texture, --timao
                "steampunk_blimp_compass.png",
                ladder_texture, --escada
                "default_wood_oak.png", --mureta
                steampunk_blimp.wood_texture, --mureta
                "steampunk_blimp_engine.png", --nacele rotores
                steampunk_blimp.wood_texture, --quilha
                "default_wood_oak.png", --rotores
                steampunk_blimp.rotor_texture, --"steampunk_blimp_rotor.png", --rotores
                steampunk_blimp.black_texture, --suportes rotores
                "default_wood_oak.png^[multiply:#A09090", --suporte timao
                "steampunk_blimp_rope.png", --cordas
                steampunk_blimp.color1_texture, --det azul
                steampunk_blimp.color2_texture, --det branco
                steampunk_blimp.wood_texture, --fixacao cordas
                "steampunk_blimp_alpha_logo.png", --logo
            }
else
    steampunk_blimp.color1_texture = "wool_blue.png"
    steampunk_blimp.color2_texture = "wool_yellow.png"

    steampunk_blimp.fire_tex = "default_furnace_fire_fg.png"
    steampunk_blimp.canvas_texture = "wool_white.png^[colorize:#f4e7c1:128"
    steampunk_blimp.metal_texture = "default_clay.png^[colorize:#a3acac:128"
    steampunk_blimp.black_texture = "default_clay.png^[colorize:#030303:200"
    steampunk_blimp.wood_texture = "default_clay.png^[colorize:#3a270d:230"
    steampunk_blimp.forno_texture = steampunk_blimp.black_texture.."^[mask:steampunk_blimp_forno_mask.png"
    steampunk_blimp.rotor_texture = "("..steampunk_blimp.canvas_texture.."^[mask:steampunk_blimp_rotor_mask2.png)^(default_wood.png^[mask:steampunk_blimp_rotor_mask.png)"
    local ladder_texture = "default_ladder_wood.png"
    if airutils.is_mcl then ladder_texture = "default_ladder.png" end
    steampunk_blimp.textures = {
                steampunk_blimp.black_texture, --alimentacao balao
                steampunk_blimp.canvas_texture, --balao
                steampunk_blimp.color2_texture, --faixas brancas nariz
                steampunk_blimp.color1_texture, --faixas azuis nariz
                steampunk_blimp.metal_texture, --pontas do balão
                "airutils_name_canvas.png",
                steampunk_blimp.black_texture, --caldeira
                steampunk_blimp.forno_texture, --caldeira
                "default_junglewood.png", --casco
                steampunk_blimp.black_texture, -- corpo da bussola
                steampunk_blimp.metal_texture, -- indicador bussola
                steampunk_blimp.canvas_texture, --leme
                "default_junglewood.png", --leme
                steampunk_blimp.wood_texture, --timao
                "steampunk_blimp_compass.png",
                ladder_texture, --escada
                "default_wood.png", --mureta
                steampunk_blimp.wood_texture, --mureta
                "steampunk_blimp_engine.png", --nacele rotores
                steampunk_blimp.wood_texture, --quilha
                "default_wood.png", --rotores
                steampunk_blimp.rotor_texture, --"steampunk_blimp_rotor.png", --rotores
                steampunk_blimp.black_texture, --suportes rotores
                "default_junglewood.png", --suporte timao
                "steampunk_blimp_rope.png", --cordas
                steampunk_blimp.color1_texture, --det azul
                steampunk_blimp.color2_texture, --det branco
                steampunk_blimp.wood_texture, --fixacao cordas
                "steampunk_blimp_alpha_logo.png", --logo
                --"steampunk_blimp_metal.png",
                --"steampunk_blimp_red.png",
            }
end

steampunk_blimp.colors ={
    black='black',
    blue='blue',
    brown='brown',
    cyan='cyan',
    dark_green='dark_green',
    dark_grey='dark_grey',
    green='green',
    grey='grey',
    magenta='magenta',
    orange='orange',
    pink='pink',
    red='red',
    violet='violet',
    white='white',
    yellow='yellow',
}



steampunk_blimp.cannons_loc = {x=24, y=-2, z=0}
steampunk_blimp.cannons_sz = 15

dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "cannon_balls.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "walk_map.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "utilities.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "control.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "fuel_management.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "engine_management.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "custom_physics.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "hud.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "entities.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "forms.lua")
dofile(core.get_modpath("steampunk_blimp") .. DIR_DELIM .. "manual.lua")

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
core.register_tool("steampunk_blimp:blimp", {
    description = "Steampunk Blimp",
    inventory_image = "steampunk_blimp_icon.png",
    liquids_pointable = true,
    stack_max = 1,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end

        local stack_meta = itemstack:get_meta()
        local staticdata = stack_meta:get_string("staticdata")

        local pointed_pos = pointed_thing.under
        --local node_below = core.get_node(pointed_pos).name
        --local nodedef = core.registered_nodes[node_below]

		pointed_pos.y=pointed_pos.y+3
		local blimp = core.add_entity(pointed_pos, "steampunk_blimp:blimp", staticdata)
		if blimp and placer then
            local ent = blimp:get_luaentity()
            ent._passengers = steampunk_blimp.copy_vector({[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil, [6]=nil, [7]=nil})
            --core.chat_send_all('passengers: '.. dump(ent._passengers))
            local owner = placer:get_player_name()
            ent.owner = owner
            --ent.hp = 50 --reset hp
			blimp:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
            airutils.create_inventory(ent, steampunk_blimp.trunk_slots, owner)

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
		if pointed_thing.type ~= "node" then
			return
		end

        local owner = placer:get_player_name()

        local stack_meta = itemstack:get_meta()
        local staticdata = stack_meta:get_string("staticdata")
        if staticdata == nil or staticdata == "" then
            staticdata = 'return {stored_has_cannons=true,stored_owner="'..owner..'",}'
        end

        local pointed_pos = pointed_thing.under
        --local node_below = core.get_node(pointed_pos).name
        --local nodedef = core.registered_nodes[node_below]

		pointed_pos.y=pointed_pos.y+3
		local blimp = core.add_entity(pointed_pos, "steampunk_blimp:blimp", staticdata)
		if blimp and placer then
            local ent = blimp:get_luaentity()
            ent._passengers = steampunk_blimp.copy_vector({[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil, [6]=nil, [7]=nil})
            --core.chat_send_all('passengers: '.. dump(ent._passengers))
            ent.owner = owner
            --ent.hp = 50 --reset hp
            ent._vehicle_name = "Gunboat Steampunk Blimp",
            steampunk_blimp.paint(ent, "black")
			blimp:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
            airutils.create_inventory(ent, steampunk_blimp.trunk_slots, owner)

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
		if pointed_thing.type ~= "node" then
			return
		end

        local pointed_pos = pointed_thing.under
        --local node_below = core.get_node(pointed_pos).name
        --local nodedef = core.registered_nodes[node_below]

		pointed_pos.y=pointed_pos.y+3
		local blimp = core.add_entity(pointed_pos, "steampunk_blimp:blimp")
		if blimp and placer then
            local ent = blimp:get_luaentity()
            ent._passengers = steampunk_blimp.copy_vector({[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil, [6]=nil, [7]=nil})
            --core.chat_send_all('passengers: '.. dump(ent._passengers))
            local owner = placer:get_player_name()
            ent.owner = owner
            ent._remove = true
            ent._water_level = steampunk_blimp.MAX_WATER --start it full loaded
            ent._energy = steampunk_blimp.MAX_FUEL  --start it full loaded
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

steampunk_blimp.wind_enabled = core.settings:get_bool('steampunk_blimp.enable_wind')
steampunk_blimp.cannons_enabled = core.settings:get_bool('steampunk_blimp.enable_cannons')
steampunk_blimp.only_owners_can_repair = core.settings:get_bool('steampunk_blimp.only_owners_can_repair')

--
-- crafting
--

if not core.settings:get_bool('steampunk_blimp.disable_craftitems') then

    local item_name = "steampunk_blimp:cylinder_part"
    if airutils.is_repixture then
        crafting.register_craft({
            output = item_name,
            items = {
                "group:fuzzy 8",
                "rp_default:stick 4",
                "group:planks 1",
            }
        })
    elseif airutils.is_mcl then
        core.register_craft({
	        output = item_name,
	        recipe = {
		        {"mcl_core:stick", "mcl_wool:white", "mcl_core:stick"},
		        {"mcl_wool:white", "mcl_core:wood", "mcl_wool:white"},
                {"mcl_core:stick", "mcl_wool:white", "mcl_core:stick"},
	        }
        })
    else
        core.register_craft({
	        output = item_name,
	        recipe = {
		        {"default:stick", "wool:white", "default:stick"},
		        {"wool:white", "group:wood", "wool:white"},
                {"default:stick", "wool:white", "default:stick"},
	        }
        })
    end

    item_name = "steampunk_blimp:cylinder"
    if airutils.is_repixture then
        crafting.register_craft({
            output = item_name,
            items = {
                "steampunk_blimp:cylinder_part 3",
            }
        })
    else
        core.register_craft({
	        output = item_name,
	        recipe = {
		        {"steampunk_blimp:cylinder_part", "steampunk_blimp:cylinder_part", "steampunk_blimp:cylinder_part"},
	        }
        })
    end

    item_name = "steampunk_blimp:rotor"
    if airutils.is_repixture then
        crafting.register_craft({
            output = item_name,
            items = {
                "group:fuzzy 3",
                "rp_default:stick 3",
                "rp_default:block_wrought_iron 1",
            }
        })
    elseif airutils.is_mcl then
        core.register_craft({
	        output = item_name,
	        recipe = {
		        {"mcl_wool:white", "mcl_core:stick", ""},
		        {"mcl_wool:white", "mcl_core:stick", "mcl_core:ironblock"},
		        {"mcl_wool:white", "mcl_core:stick", ""},
	        }
        })
    else
        core.register_craft({
	        output = item_name,
	        recipe = {
		        {"wool:white", "default:stick", ""},
		        {"wool:white", "default:stick", "default:steelblock"},
		        {"wool:white", "default:stick", ""},
	        }
        })
    end

    item_name = "steampunk_blimp:boiler"
    if airutils.is_repixture then
        crafting.register_craft({
            output = item_name,
            items = {
                "rp_default:ingot_wrought_iron 4",
                "rp_default:block_wrought_iron 2",
            }
        })
    elseif airutils.is_mcl then
        core.register_craft({
	        output = item_name,
	        recipe = {
		        {"mcl_core:iron_ingot","mcl_core:iron_ingot"},
		        {"mcl_core:ironblock","mcl_core:iron_ingot",},
		        {"mcl_core:ironblock","mcl_core:iron_ingot"},
	        }
        })
    else
        core.register_craft({
	        output = item_name,
	        recipe = {
		        {"default:steel_ingot","default:steel_ingot"},
		        {"default:steelblock","default:steel_ingot",},
		        {"default:steelblock","default:steel_ingot"},
	        }
        })
    end

    if steampunk_blimp.cannons_enabled == true then
        item_name = "steampunk_blimp:cannon"
        if airutils.is_repixture then
            crafting.register_craft({
                output = item_name,
                items = {
                    "rp_default:ingot_wrought_iron 2",
                    "rp_default:block_wrought_iron 4",
                    "group:planks 3",
                }
            })
        elseif airutils.is_mcl then
            core.register_craft({
	            output = item_name,
	            recipe = {
		            {"mcl_core:ironblock","mcl_core:ironblock","group:wood"},
		            {"mcl_core:iron_ingot","mcl_core:iron_ingot","group:wood"},
		            {"mcl_core:ironblock","mcl_core:ironblock","group:wood"},
	            }
            })
        else
            core.register_craft({
	            output = item_name,
	            recipe = {
		            {"default:steelblock","default:steelblock","group:wood"},
		            {"default:steel_ingot","default:steel_ingot","group:wood"},
		            {"default:steelblock","default:steelblock","group:wood"},
	            }
            })
        end
    end

    item_name = "steampunk_blimp:boat"
    if airutils.is_repixture then
        crafting.register_craft({
            output = item_name,
            items = {
                "group:planks 6",
                "steampunk_blimp:rotor 2",
                "steampunk_blimp:boiler 1",
            }
        })
    else
        core.register_craft({
	        output = item_name,
	        recipe = {
		        {"group:wood", "group:wood", "steampunk_blimp:rotor"},
		        {"group:wood", "steampunk_blimp:boiler", "group:wood"},
		        {"group:wood", "group:wood", "steampunk_blimp:rotor"},
	        }
        })
    end

    item_name = "steampunk_blimp:blimp"
    if airutils.is_repixture then
        crafting.register_craft({
            output = item_name,
            items = {
                "steampunk_blimp:cylinder 1",
                "steampunk_blimp:boat 1",
            }
        })
    else
	    core.register_craft({
		    output = item_name,
		    recipe = {
			    {"steampunk_blimp:cylinder",},
			    {"steampunk_blimp:boat",},
		    }
	    })
    end


    if steampunk_blimp.cannons_enabled == true then
        item_name = "steampunk_blimp:cannon_blimp"
        if airutils.is_repixture then
            crafting.register_craft({
                output = item_name,
                items = {
                    "steampunk_blimp:blimp 1",
                    "steampunk_blimp:cannon 2",
                }
            })
        else
	        core.register_craft({
		        output = item_name,
		        recipe = {
			        {"steampunk_blimp:cannon","steampunk_blimp:blimp","steampunk_blimp:cannon",},
		        }
	        })
        end
        if airutils.is_minetest then
            core.register_craft({
	            output = 'steampunk_blimp:cannon_ball1',
	            recipe = {
		            {"", "default:steel_ingot",""},
		            {"default:steel_ingot","tnt:tnt_stick","default:steel_ingot"},
		            {"", "default:steel_ingot",""},
	            }
            })
        elseif airutils.is_mcl then
            core.register_craft({
	            output = 'steampunk_blimp:cannon_ball1',
	            recipe = {
		            {"", "mcl_core:iron_ingot",""},
		            {"mcl_core:iron_ingot","mcl_tnt:tnt", "mcl_core:iron_ingot"},
		            {"", "mcl_core:iron_ingot",""},
	            }
            })
        end
    end

    -- cylinder section
    core.register_craftitem("steampunk_blimp:cylinder_part",{
	    description = "steampunk_blimp cylinder section",
	    inventory_image = "steampunk_blimp_cylinder_part.png",
    })

    -- cylinder
    core.register_craftitem("steampunk_blimp:cylinder",{
	    description = "steampunk_blimp cylinder",
	    inventory_image = "steampunk_blimp_cylinder.png",
    })

    -- boiler
    core.register_craftitem("steampunk_blimp:boiler",{
	    description = "steampunk_blimp boiler",
	    inventory_image = "steampunk_blimp_boiler.png",
    })

    -- cannon
    core.register_craftitem("steampunk_blimp:cannon",{
	    description = "steampunk_blimp cannon",
	    inventory_image = "steampunk_blimp_cannon_ico.png",
    })

    -- rotor
    core.register_craftitem("steampunk_blimp:rotor",{
	    description = "steampunk_blimp rotor",
	    inventory_image = "steampunk_blimp_rotor.png",
    })

    -- fuselage
    core.register_craftitem("steampunk_blimp:boat",{
	    description = "steampunk_blimp fuselage",
	    inventory_image = "steampunk_blimp_boat.png",
    })
end

