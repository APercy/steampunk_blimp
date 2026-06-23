

steampunk_blimp.color1_texture = "steampunk_blimp_color_wrapper1.png"
steampunk_blimp.color2_texture = "steampunk_blimp_color_wrapper2.png"
steampunk_blimp.hull_color = "steampunk_blimp_color_wrapper3.png"

local function repixture_defaults()

	steampunk_blimp.fire_tex =
	"[combine:16x16:0,0=steampunk_blimp_alpha.png:0,0=rp_fire_bonfire_flame.png" --"rp_fire_bonfire_flame.png^[resize:16x16"
	steampunk_blimp.canvas_texture = "mobs_wool.png^[colorize:#f4e7c1:128"
	steampunk_blimp.metal_texture = "default_sand.png^[colorize:#a3acac:128"
	steampunk_blimp.black_texture = "default_sand.png^[colorize:#030303:200"
	steampunk_blimp.wood_texture = "default_sand.png^[colorize:#3a270d:230"
	steampunk_blimp.forno_texture = steampunk_blimp.black_texture .. "^[mask:steampunk_blimp_forno_mask.png"
	steampunk_blimp.rotor_texture = "(" ..
		steampunk_blimp.canvas_texture ..
		"^[mask:steampunk_blimp_rotor_mask2.png)^(default_wood_oak.png^[mask:steampunk_blimp_rotor_mask.png)"
end

local function minetest_defaults()

	steampunk_blimp.fire_tex = "default_furnace_fire_fg.png"
	steampunk_blimp.canvas_texture = "wool_white.png^[colorize:#f4e7c1:128"
	steampunk_blimp.metal_texture = "default_clay.png^[colorize:#a3acac:128"
	steampunk_blimp.black_texture = "default_clay.png^[colorize:#030303:200"
	steampunk_blimp.wood_texture = "default_clay.png^[colorize:#3a270d:230"
	steampunk_blimp.forno_texture = steampunk_blimp.black_texture .. "^[mask:steampunk_blimp_forno_mask.png"
	steampunk_blimp.rotor_texture = "(" ..
		steampunk_blimp.canvas_texture ..
		"^[mask:steampunk_blimp_rotor_mask2.png)^(default_wood.png^[mask:steampunk_blimp_rotor_mask.png)"
end

function steampunk_blimp.set_repixture_blimptextures ()
	repixture_defaults()
	local ladder_texture = "default_ladder.png"

	steampunk_blimp.blimp_textures = {
		steampunk_blimp.black_texture,			--alimentacao balao
		steampunk_blimp.canvas_texture,		   --balao
		steampunk_blimp.color2_texture,		   --faixas brancas nariz
		steampunk_blimp.color1_texture,		   --faixas azuis nariz
		steampunk_blimp.metal_texture,			--pontas do balão
		"airutils_name_canvas.png",
		steampunk_blimp.black_texture,			--caldeira
		steampunk_blimp.forno_texture,			--caldeira
		"default_wood_oak.png^[multiply:#A09090", --casco
		steampunk_blimp.black_texture,			-- corpo da bussola
		steampunk_blimp.metal_texture,			-- indicador bussola
		steampunk_blimp.canvas_texture,		   --leme
		"default_wood_oak.png^[multiply:#A09090", --leme
		steampunk_blimp.wood_texture,			 --timao
		"steampunk_blimp_compass.png",
		ladder_texture,						   --escada
		"default_wood_oak.png",				   --mureta
		steampunk_blimp.wood_texture,			 --mureta
		"steampunk_blimp_engine.png",			 --nacele rotores
		steampunk_blimp.wood_texture,			 --quilha
		"default_wood_oak.png",				   --rotores
		steampunk_blimp.rotor_texture,			--"steampunk_blimp_rotor.png", --rotores
		steampunk_blimp.black_texture,			--suportes rotores
		"default_wood_oak.png^[multiply:#A09090", --suporte timao
		"steampunk_blimp_rope.png",			   --cordas
		steampunk_blimp.color1_texture,		   --det azul
		steampunk_blimp.color2_texture,		   --det branco
		steampunk_blimp.wood_texture,			 --fixacao cordas
		"steampunk_blimp_alpha_logo.png",		 --logo
	}
end

function steampunk_blimp.set_minetest_blimptextures()
	minetest_defaults()
	local ladder_texture = "default_ladder_wood.png"
	if airutils.is_mcl then ladder_texture = "default_ladder.png" end

	steampunk_blimp.blimp_textures = {
		steampunk_blimp.black_texture,	--alimentacao balao
		steampunk_blimp.canvas_texture,   --balao
		steampunk_blimp.color2_texture,   --faixas brancas nariz
		steampunk_blimp.color1_texture,   --faixas azuis nariz
		steampunk_blimp.metal_texture,	--pontas do balão
		"airutils_name_canvas.png",
		steampunk_blimp.black_texture,	--caldeira
		steampunk_blimp.forno_texture,	--caldeira
		"default_junglewood.png",		 --casco
		steampunk_blimp.black_texture,	-- corpo da bussola
		steampunk_blimp.metal_texture,	-- indicador bussola
		steampunk_blimp.canvas_texture,   --leme
		"default_junglewood.png",		 --leme
		steampunk_blimp.wood_texture,	 --timao
		"steampunk_blimp_compass.png",
		ladder_texture,				   --escada
		"default_wood.png",			   --mureta
		steampunk_blimp.wood_texture,	 --mureta
		"steampunk_blimp_engine.png",	 --nacele rotores
		steampunk_blimp.wood_texture,	 --quilha
		"default_wood.png",			   --rotores
		steampunk_blimp.rotor_texture,	--"steampunk_blimp_rotor.png", --rotores
		steampunk_blimp.black_texture,	--suportes rotores
		"default_junglewood.png",		 --suporte timao
		"steampunk_blimp_rope.png",	   --cordas
		steampunk_blimp.color1_texture,   --det azul
		steampunk_blimp.color2_texture,   --det branco
		steampunk_blimp.wood_texture,	 --fixacao cordas
		"steampunk_blimp_alpha_logo.png", --logo
		--"steampunk_blimp_metal.png",
		--"steampunk_blimp_red.png",
	}
end

function steampunk_blimp.set_minetest_hsatextures()
	minetest_defaults()

	steampunk_blimp.hsa_textures = {
        "default_junglewood.png",                   --casco inferior
        "default_wood.png",                         --quilha
        "default_junglewood.png",                   --interior
        "steampunk_hsa_glasses.png",                --vidros frontais
        "steampunk_hsa_front_windows.png",          --janelas metal
        "steampunk_hsa_glasses.png",                --janelas redondas
        "airutils_black.png",                       --coluna timao
        "steampunk_blimp_steel.png",                --borda janelas inferiores
        "steampunk_hsa_glasses.png",                --vidros janelas inferiores
        steampunk_blimp.wood_texture,               --timao
        "steampunk_blimp_compass.png",              --bussola
        steampunk_blimp.color2_texture,             --det branco
        steampunk_blimp.color1_texture,             --det azul
        steampunk_blimp.black_texture,              --corpo bussola
        "default_wood.png",                         --moldura janela traseira
        "default_wood.png",                         --grade janela traseira
        "steampunk_hsa_glasses.png",                --vidros janela traseira
        "default_wood.png",                         --rotor 1
        "default_wood.png",                         --rotor 2
        "steampunk_blimp_engine.png",               --nacele rotores
        "default_wood.png",                         --borda traseira
        steampunk_blimp.black_texture,	            --caldeira
        "default_wood.png",                         --montante asas
        steampunk_blimp.black_texture,	            --conexao asas
        "default_wood.png",                         --suporte asas
        steampunk_blimp.canvas_texture,             --balao
        steampunk_blimp.color1_texture,             --det azul
        steampunk_blimp.color2_texture,             --det branco
        "airutils_name_canvas.png",                 --faixa do nome
        "steampunk_blimp_alpha_logo.png",           --logo
        steampunk_blimp.hull_color,                 --casco superior
        "steampunk_blimp_steel.png",                --divsao parabrisa
        steampunk_blimp.forno_texture,              --grade do forno
        steampunk_blimp.metal_texture,              --pontas do balão
	}
end
