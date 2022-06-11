steampunk_blimp={}
steampunk_blimp.gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.8
steampunk_blimp.trunk_slots = 50
steampunk_blimp.fuel = {['default:coal_lump'] = {amount=1},['default:coalblock'] = {amount=10}}
steampunk_blimp.water = {['default:water_source'] = {amount=1},['default:river_water_source'] = {amount=1}, ['bucket:bucket_water'] = {amount=1}, ['bucket:bucket_river_water'] = {amount=1}}  --bucket:bucket_empty
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

steampunk_blimp.canvas_texture = "wool_white.png^[colorize:#f4e7c1:128"
steampunk_blimp.metal_texture = "default_clay.png^[colorize:#a3acac:128"
steampunk_blimp.black_texture = "default_clay.png^[colorize:#030303:200"
steampunk_blimp.wood_texture = "default_clay.png^[colorize:#3a270d:230"
steampunk_blimp.forno_texture = steampunk_blimp.black_texture.."^[mask:steampunk_blimp_forno_mask.png"
steampunk_blimp.rotor_texture = "("..steampunk_blimp.canvas_texture.."^[mask:steampunk_blimp_rotor_mask2.png)^(default_wood.png^[mask:steampunk_blimp_rotor_mask.png)"
steampunk_blimp.textures = {
            steampunk_blimp.black_texture, --alimentacao balao
            "default_wood.png", --asa
            steampunk_blimp.canvas_texture, --asa
            steampunk_blimp.canvas_texture, --balao
            "wool_yellow.png", --faixas brancas nariz
            "wool_blue.png", --faixas azuis nariz
            steampunk_blimp.metal_texture, --pontas do balão
            steampunk_blimp.black_texture, --caldeira
            steampunk_blimp.forno_texture, --caldeira
            "default_junglewood.png", --casco
            steampunk_blimp.canvas_texture, --leme
            "default_junglewood.png", --leme
            steampunk_blimp.wood_texture, --timao
            "default_ladder_wood.png", --escada
            "default_wood.png", --mureta
            steampunk_blimp.wood_texture, --mureta
            steampunk_blimp.black_texture, --nacele rotores
            steampunk_blimp.wood_texture, --quilha
            "default_wood.png", --rotores
            steampunk_blimp.rotor_texture, --"steampunk_blimp_rotor.png", --rotores
            steampunk_blimp.black_texture, --suportes rotores
            "default_junglewood.png", --suporte timao
            "steampunk_blimp_rope.png", --cordas
            "wool_blue.png", --det azul
            "wool_yellow.png", --det branco
            steampunk_blimp.wood_texture, --fixacao cordas
            "steampunk_blimp_alpha_logo.png", --logo
            --"steampunk_blimp_metal.png",
            --"steampunk_blimp_red.png",
        }

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

dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "utilities.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "control.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "fuel_management.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "engine_management.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "custom_physics.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "hud.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "entities.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "forms.lua")
dofile(minetest.get_modpath("steampunk_blimp") .. DIR_DELIM .. "manual.lua")

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
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]
        
		pointed_pos.y=pointed_pos.y+3
		local blimp = minetest.add_entity(pointed_pos, "steampunk_blimp:blimp")
		if blimp and placer then
            local ent = blimp:get_luaentity()
            ent._passengers = steampunk_blimp.copy_vector({[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil,})
            --minetest.chat_send_all('passengers: '.. dump(ent._passengers))
            local owner = placer:get_player_name()
            ent.owner = owner
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


--
-- crafting
--

if not minetest.settings:get_bool('steampunk_blimp.disable_craftitems') then
    minetest.register_craft({
	    output = "steampunk_blimp:cylinder_part",
	    recipe = {
		    {"default:stick", "wool:white", "default:stick"},
		    {"wool:white", "group:wood", "wool:white"},
            {"default:stick", "wool:white", "default:stick"},
	    }
    })

    minetest.register_craft({
	    output = "steampunk_blimp:cylinder",
	    recipe = {
		    {"steampunk_blimp:cylinder_part", "steampunk_blimp:cylinder_part", "steampunk_blimp:cylinder_part"},
	    }
    })

    minetest.register_craft({
	    output = "steampunk_blimp:rotor",
	    recipe = {
		    {"wool:white", "default:stick", ""},
		    {"wool:white", "default:stick", "default:steelblock"},
		    {"wool:white", "default:stick", ""},
	    }
    })

    minetest.register_craft({
	    output = "steampunk_blimp:boiler",
	    recipe = {
		    {"default:steel_ingot","default:steel_ingot"},
		    {"default:steelblock","default:steel_ingot",},
		    {"default:steelblock","default:steel_ingot"},
	    }
    })

    minetest.register_craft({
	    output = "steampunk_blimp:boat",
	    recipe = {
		    {"group:wood", "group:wood", "steampunk_blimp:rotor"},
		    {"group:wood", "steampunk_blimp:boiler", "group:wood"},
		    {"group:wood", "group:wood", "steampunk_blimp:rotor"},
	    }
    })

	minetest.register_craft({
		output = "steampunk_blimp:blimp",
		recipe = {
			{"steampunk_blimp:cylinder",},
			{"steampunk_blimp:boat",},
		}
	})

    -- cylinder section
    minetest.register_craftitem("steampunk_blimp:cylinder_part",{
	    description = "steampunk_blimp cylinder section",
	    inventory_image = "steampunk_blimp_cylinder_part.png",
    })

    -- cylinder
    minetest.register_craftitem("steampunk_blimp:cylinder",{
	    description = "steampunk_blimp cylinder",
	    inventory_image = "steampunk_blimp_cylinder.png",
    })

    -- boiler
    minetest.register_craftitem("steampunk_blimp:boiler",{
	    description = "steampunk_blimp boiler",
	    inventory_image = "steampunk_blimp_boiler.png",
    })

    -- boiler
    minetest.register_craftitem("steampunk_blimp:rotor",{
	    description = "steampunk_blimp rotor",
	    inventory_image = "steampunk_blimp_rotor.png",
    })

    -- fuselage
    minetest.register_craftitem("steampunk_blimp:boat",{
	    description = "steampunk_blimp fuselage",
	    inventory_image = "steampunk_blimp_boat.png",
    })
end

