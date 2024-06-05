function steampunk_blimp.getPlaneFromPlayer(player)
    local seat = player:get_attach()
    if seat then
        local plane = seat:get_attach()
        return plane
    end
    return nil
end

function steampunk_blimp.pilot_formspec(name)
    local basic_form = table.concat({
        "formspec_version[5]",
        "size[6,9]",
	}, "")

    local player = minetest.get_player_by_name(name)
    local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
    if plane_obj == nil then
        return
    end
    local ent = plane_obj:get_luaentity()

    local take_control = "false"
    if ent._at_control then take_control = "true" end
    local anchor = "false"
    if ent.anchored == true then anchor = "true" end

	basic_form = basic_form.."button[1,1.0;4,1;turn_on;Start/Stop the fire]"
    basic_form = basic_form.."button[1,2.0;4,1;water;Load water from below]"
    if ent._remove ~= true then
        basic_form = basic_form.."button[1,3.0;4,1;inventory;Open inventory]"
    end
    basic_form = basic_form.."button[1,4.0;4,1;manual;Show Manual Menu]"

    basic_form = basic_form.."checkbox[1,5.6;take_control;Take the Control;"..take_control.."]"
    basic_form = basic_form.."checkbox[1,6.2;anchor;Anchor away;"..anchor.."]"

    basic_form = basic_form.."label[1,7.0;Disembark:]"
    basic_form = basic_form.."button[1,7.2;2,1;disembark_l;<< Left]"
    basic_form = basic_form.."button[3,7.2;2,1;disembark_r;Right >>]"

    minetest.show_formspec(name, "steampunk_blimp:pilot_main", basic_form)
end

function steampunk_blimp.pax_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,3]",
	}, "")

    basic_form = basic_form.."label[1,1.0;Disembark:]"
    basic_form = basic_form.."button[1,1.2;2,1;disembark_l;<< Left]"
    basic_form = basic_form.."button[3,1.2;2,1;disembark_r;Right >>]"

    minetest.show_formspec(name, "steampunk_blimp:passenger_main", basic_form)
end

local default_logos = {
    "blimp_clover.png",
    "blimp_liz.png",
    "blimp_shotting_star.png",
    "blimp_skull.png",
    "blimp_jack.png",
    "blimp_xmas.png",
}
function steampunk_blimp.logo_ext_formspec(name, t_index, t_page, t_type)
    t_index = t_index or 1
    t_page = t_page or 1
    t_type = t_type or 1

    if airutils.isTextureLoaded then
        airutils.isTextureLoaded('heart.png') --force the textures first load
    else
        minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are using an old version of airutils, update it first"))
        return
    end

    local basic_form = table.concat({
        "formspec_version[4]",
        "size[12,9]",
	}, "")

    local textures = {}
    if t_type == "1" or t_type == 1 then textures = airutils.properties_copy(default_logos) end
    if t_type == "2" or t_type == 2 then textures = airutils.properties_copy(airutils.all_game_textures) end
    if t_type == "3" or t_type == 3 then textures = airutils.properties_copy(airutils.all_entities_textures) end
    if t_type == "4" or t_type == 4 then textures = airutils.properties_copy(airutils.all_items_textures) end

    local text_count = #textures
    local items_per_page = 50
    local pages = math.ceil(text_count / items_per_page)
    local logolist = ""
    local items_count = 0
    local item_start = ((t_page-1)*items_per_page) + 1
    for k, v in pairs(textures) do
        if k >= item_start and items_count < items_per_page then
            logolist = logolist .. v .. ","
            items_count = items_count + 1
        end
        if items_count >= items_per_page then break end
    end

    local pages_list = ""
    for i = 1,pages,1 
    do 
       pages_list = pages_list .. i .. ","
    end

    basic_form = basic_form.."label[0.5,0.9;Type]"
    basic_form = basic_form.."dropdown[2,0.5;3,0.8;t_type;Default,Nodes,Entities,Items;"..t_type..";true]"
    basic_form = basic_form.."textlist[0.5,1.5;4.5,6;logos;"..logolist..";"..t_index..";false]"
    local curr_real_index = (items_per_page * (t_page-1)) + t_index
    local texture_name = textures[curr_real_index] or ""
    basic_form = basic_form.."image[5.5,1.5;6,6;"..texture_name.."]"
    basic_form = basic_form.."label[0.6,8.2;Page]"
    basic_form = basic_form.."dropdown[1.8,7.8;1.9,0.8;t_page;"..pages_list..";"..t_page..";true]"
    basic_form = basic_form.."button[8.5,7.8;3,0.8;set_texture;Set Texture]"

    basic_form = basic_form.."field[5.3,20.0;3,0.8;texture_name;;"..texture_name.."]"
    basic_form = basic_form.."field[5.3,21.0;3,0.8;last_type;;"..t_type.."]"

    minetest.show_formspec(name, "steampunk_blimp:logo_ext", basic_form)
end

function steampunk_blimp.owner_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,4.2]",
	}, "")

	basic_form = basic_form.."button[1,1.0;4,1;take;Take the Control Now]"
    basic_form = basic_form.."label[1,2.2;Disembark:]"
    basic_form = basic_form.."button[1,2.4;2,1;disembark_l;<< Left]"
    basic_form = basic_form.."button[3,2.4;2,1;disembark_r;Right >>]"

    minetest.show_formspec(name, "steampunk_blimp:owner_main", basic_form)
end

function set_list(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "steampunk_blimp:owner_main" then
        local name = player:get_player_name()
        local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "steampunk_blimp:owner_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
		    if fields.disembark_l then
                steampunk_blimp.dettach_pax(ent, player, "l")
		    end
		    if fields.disembark_r then
                steampunk_blimp.dettach_pax(ent, player, "r")
		    end
		    if fields.take then
                ent._at_control = true
                for i = 5,1,-1
                do
                    if ent._passengers[i] == name then
                        ent._passengers_base_pos[i] = vector.new(steampunk_blimp.pilot_base_pos)
                        ent._passengers_base[i]:set_attach(ent.object,'',steampunk_blimp.pilot_base_pos,{x=0,y=0,z=0})
                        player:set_attach(ent._passengers_base[i], "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
                    end
                    if ent._passengers[i] == ent.driver_name then
                        ent._passengers_base_pos[i] = vector.new(steampunk_blimp.passenger_pos[i])
                        ent._passengers_base[i]:set_attach(ent.object,'',ent._passengers_base_pos[i],{x=0,y=0,z=0})
                    end
                end
                ent.driver_name = name
		    end
        end
        minetest.close_formspec(name, "steampunk_blimp:owner_main")
    end
	if formname == "steampunk_blimp:passenger_main" then
        local name = player:get_player_name()
        local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "steampunk_blimp:passenger_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
		    if fields.disembark_l then
                steampunk_blimp.dettach_pax(ent, player, "l")
		    end
		    if fields.disembark_r then
                steampunk_blimp.dettach_pax(ent, player, "r")
		    end
        end
        minetest.close_formspec(name, "steampunk_blimp:passenger_main")
	end
    if formname == "steampunk_blimp:logo_ext" then
        local name = player:get_player_name()
        local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "steampunk_blimp:logo_ext")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
            if fields.set_texture then
                if ent.name == "steampunk_blimp:blimp" then
                    if ent.owner == name or minetest.check_player_privs(name, {protection_bypass=true}) then
                        if fields.texture_name then
                            local image_name = fields.texture_name
                            local logo_list = set_list(default_logos)
                            if airutils.isTextureLoaded(image_name) or logo_list[image_name] then
                                steampunk_blimp.set_logo(ent, image_name)
                                minetest.chat_send_player(name,core.colorize('#00ff00', " >>> texture '"..image_name.."' set"))
                                --minetest.close_formspec(name, "steampunk_blimp:logo_ext")
                                return
                            end
                        end
                    end
                end
            end
		    if fields.logos or fields.t_page then
                --minetest.close_formspec(name, "steampunk_blimp:logo_ext")
                --steampunk_blimp.logo_ext_formspec(name,fields.logos)
                local result = minetest.explode_textlist_event(fields.logos)
                if result.type == "CHG" then
                    --minetest.chat_send_all(dump(result.index))
                    --minetest.close_formspec(name, "steampunk_blimp:logo_ext")
                    steampunk_blimp.logo_ext_formspec(name,result.index,fields.t_page,fields.last_type)
                    return
                end
                steampunk_blimp.logo_ext_formspec(name,1,fields.t_page,fields.last_type)
                return
		    end
            if fields.t_type then
                steampunk_blimp.logo_ext_formspec(name,1,1,fields.t_type)
                return
            end
        end
    end
    if formname == "steampunk_blimp:pilot_main" then
        local name = player:get_player_name()
        local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "steampunk_blimp:pilot_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
		    if fields.turn_on then
                steampunk_blimp.start_furnace(ent)
		    end
            if fields.water then
                if ent.isinliquid then
                    if ent._engine_running == true then
                        steampunk_blimp.start_furnace(ent)
                    end
                    if ent._boiler_pressure > 0 then
                        minetest.sound_play({name = "default_cool_lava"},
                            {object = ent.object, gain = 1.0,
                                pitch = 1.0,
                                max_hear_distance = 32,
                                loop = false,}, true)
                    end
                    ent._boiler_pressure = 0
                    ent._water_level = steampunk_blimp.MAX_WATER
                else
                    minetest.chat_send_player(name,core.colorize('#ff0000', " >>> Impossible. The ship needs to be in the water."))
                end
            end
            if fields.inventory then
                if ent._remove ~= true then
                    airutils.show_vehicle_trunk_formspec(ent, player, steampunk_blimp.trunk_slots)
                end
            end
            if fields.manual then
                steampunk_blimp.manual_formspec(name)
            end
		    if fields.take_control then
                if fields.take_control == "true" then
                    if ent.driver_name == nil or ent.driver_name == "" then
                        ent._at_control = true
                        for i = steampunk_blimp.max_seats,1,-1
                        do
                            if ent._passengers[i] == name then
                                ent._passengers_base_pos[i] = vector.new(steampunk_blimp.pilot_base_pos)
                                ent._passengers_base[i]:set_attach(ent.object,'',steampunk_blimp.pilot_base_pos,{x=0,y=0,z=0})
                                player:set_attach(ent._passengers_base[i], "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
                                ent.driver_name = name
                                --minetest.chat_send_all(">>"..ent.driver_name)
                                break
                            end
                        end
                    else
                        minetest.chat_send_player(name,core.colorize('#ff0000', " >>> Impossible. Someone is at the blimp control now."))
                    end
                else
                    ent.driver_name = nil
                    ent._at_control = false
                    steampunk_blimp.remove_hud(player)
                end
		    end
		    if fields.disembark_l then
                --=========================
                --  dettach player
                --=========================
                -- eject passenger if the plane is on ground

                steampunk_blimp.dettach_pax(ent, player, "l")

		    end
		    if fields.disembark_r then
                --=========================
                --  dettach player
                --=========================
                -- eject passenger if the plane is on ground

                steampunk_blimp.dettach_pax(ent, player, "r")

		    end
            if fields.anchor then
                if fields.anchor == "true" then
                    local max_speed_anchor = 0.6
                    if ent._longit_speed then
                        if math.abs(ent._longit_speed) < max_speed_anchor then

                            ent.anchored = true
                            ent.object:set_acceleration(vector.new())
                            ent.object:set_velocity(vector.new())
                            if name then
                                minetest.chat_send_player(name,core.colorize('#00ff00', " >>> Anchor away!"))
                            end
                            --ent.buoyancy = 0.1
                        else
                            if name then
                                minetest.chat_send_player(name,core.colorize('#ff0000', " >>> Too fast to set anchor!"))
                            end
                        end
                    end
                else
                    ent.anchored = false
                    if name then
                        minetest.chat_send_player(name,core.colorize('#00ff00', " >>> Weigh anchor!"))
                    end
                end
                --ent._rudder_angle = 0
            end
        end
        minetest.close_formspec(name, "steampunk_blimp:pilot_main")
    end
end)


minetest.register_chatcommand("blimp_share", {
	params = "name",
	description = "Share ownewrship with your friends",
	privs = {interact = true},
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local target_player = minetest.get_player_by_name(param)
        local attached_to = player:get_attach()

		if attached_to ~= nil and target_player ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        if entity.owner == name then
                            local exists = false
                            for k, v in pairs(entity._shared_owners) do
                                if v == param then
                                    exists = true
                                    break
                                end
                            end
                            if exists == false then
                                table.insert(entity._shared_owners, param)
                                minetest.chat_send_player(name,core.colorize('#00ff00', " >>> blimp shared"))
                                --minetest.chat_send_all(dump(entity._shared_owners))
                            else
                                minetest.chat_send_player(name,core.colorize('#ff0000', " >>> this user is already registered for blimp share"))
                            end
                        else
                            minetest.chat_send_player(name,core.colorize('#ff0000', " >>> only the owner can share this blimp"))
                        end
                    else
			            minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
                    end
                end
            end
		else
			minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
		end
	end
})

minetest.register_chatcommand("blimp_remove", {
	params = "name",
	description = "Removes ownewrship from someone",
	privs = {interact = true},
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        if entity.owner == name then
                            for k, v in pairs(entity._shared_owners) do
                                if v == param then
                                    table.remove(entity._shared_owners,k)
                                    break
                                end
                            end
                            minetest.chat_send_player(name,core.colorize('#00ff00', " >>> user removed"))
                            --minetest.chat_send_all(dump(entity._shared_owners))
                        else
                            minetest.chat_send_player(name,core.colorize('#ff0000', " >>> only the owner can do this action"))
                        end
                    else
			            minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
                    end
                end
            end
		else
			minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
		end
	end
})

minetest.register_chatcommand("blimp_list", {
	params = "",
	description = "Lists the blimp shared owners",
	privs = {interact = true},
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        minetest.chat_send_player(name,core.colorize('#ffff00', " >>> Current owners are:"))
                        minetest.chat_send_player(name,core.colorize('#0000ff', entity.owner))
                        for k, v in pairs(entity._shared_owners) do
                            minetest.chat_send_player(name,core.colorize('#00ff00', v))
                        end
                        --minetest.chat_send_all(dump(entity._shared_owners))
                    else
			            minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
                    end
                end
            end
		else
			minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
		end
	end
})

minetest.register_chatcommand("blimp_lock", {
	params = "true/false",
	description = "Blocks boarding of non-owners. true to lock, false to unlock",
	privs = {interact = true},
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        if param == "true" then
                            entity._passengers_locked = true
                            minetest.chat_send_player(name,core.colorize('#ffff00', " >>> Non owners cannot enter now."))
                        elseif param == "false" then
                            entity._passengers_locked = false
                            minetest.chat_send_player(name,core.colorize('#00ff00', " >>> Non owners are free to enter now."))
                        end
                    else
			            minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
                    end
                end
            end
		else
			minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
		end
	end
})

minetest.register_chatcommand("blimp_logo", {
	params = "<image_name.png>",
	description = "Changes blimp logo",
	privs = {interact = true},
	func = function(name, param)
        local image_name = param --"blimp_alpha.png^"..param
        local colorstring = core.colorize('#ff0000', " >>> you are not inside a blimp")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        if entity.owner == name or minetest.check_player_privs(name, {protection_bypass=true}) then
                            if airutils.isTextureLoaded then
                                if param == '' then
                                    steampunk_blimp.logo_ext_formspec(name)
                                else
                                    local logo_list = set_list(default_logos)
                                    if airutils.isTextureLoaded(image_name) or logo_list[image_name] then
                                        steampunk_blimp.set_logo(entity, image_name)
                                        minetest.chat_send_player(name,core.colorize('#00ff00', " >>> texture '"..image_name.."' set"))
                                    else
                                        minetest.chat_send_player(name,core.colorize('#ff0000', " >>> texture '"..image_name.."' not found"))
                                    end
                                end
                            else
                                minetest.chat_send_player(name,core.colorize('#ff0000', " >>> you are using an old version of airutils, update it first"))
                            end
                        else
                            minetest.chat_send_player(name,core.colorize('#ff0000', " >>> only the owner can do this action"))
                        end
                    else
			            minetest.chat_send_player(name,colorstring)
                    end
                end
            end
		else
			minetest.chat_send_player(name,colorstring)
		end
	end
})

minetest.register_chatcommand("blimp_eject", {
	params = "",
	description = "Ejects from the blimp - useful for clients before 5.3",
	privs = {interact = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside a blimp")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        for i = steampunk_blimp.max_seats,1,-1
                        do
                            if entity._passengers[i] == name then
                                steampunk_blimp.dettach_pax(entity, player, "l")
                                break
                            end
                        end
                    else
			            minetest.chat_send_player(name,colorstring)
                    end
                end
            end
		else
			minetest.chat_send_player(name,colorstring)
		end
	end
})

if airutils.is_repixture then
    local available_text = "The available colors are: black, blue, brown, cyan, dark_green, dark_grey, green, grey, magenta, orange, pink, red, violet, white or yellow"
    minetest.register_chatcommand("blimp_paint", {
	    params = "<color1> <color2>",
	    description = "Paints the blimp with a primary and secondary colors. "..available_text,
	    privs = {interact = true},
	    func = function(name, param)
            local colorstring = core.colorize('#ff0000', " >>> you are not inside a blimp")
            local player = minetest.get_player_by_name(name)
            local attached_to = player:get_attach()

		    if attached_to ~= nil then
                local seat = attached_to:get_attach()
                if seat ~= nil then
                    local entity = seat:get_luaentity()
                    if entity then
                        if entity.name == "steampunk_blimp:blimp" then
                            if entity.owner == name or minetest.check_player_privs(name, {protection_bypass=true}) then
                                --lets paint!!!!
                                local color1, color2 = param:match("^([%a%d_-]+) (.+)$")

                                --minetest.chat_send_all(dump(color1).." - "..dump(color2))
                                local colstr = steampunk_blimp.colors[color1]
                                local colstr2 = steampunk_blimp.colors[color2 or "white"]
                                --minetest.chat_send_all(color ..' '.. dump(colstr))
                                if colstr and colstr2 then
                                    steampunk_blimp.paint2(entity, colstr)
                                    steampunk_blimp.paint(entity, colstr2)
                                    minetest.chat_send_player(name,core.colorize('#00ff00', " >>> colors set successfully"))
                                else
                                    minetest.chat_send_player(name,core.colorize('#ff0000', " >>> some of the colors wasn't specified correctly. "..available_text))
                                end
                            else
                                minetest.chat_send_player(name,core.colorize('#ff0000', " >>> only the owner can do this action"))
                            end
                        else
			                minetest.chat_send_player(name,colorstring)
                        end
                    end
                end
		    else
			    minetest.chat_send_player(name,colorstring)
		    end
	    end
    })
end
