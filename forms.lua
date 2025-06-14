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
        "size[11.0,6.0]",
	}, "")

    local player = core.get_player_by_name(name)
    local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
    if plane_obj == nil then
        return
    end
    local ent = plane_obj:get_luaentity()

    local take_control = "false"
    if ent._at_control then take_control = "true" end
    local anchor = "false"
    if ent.anchored == true then anchor = "true" end
    local is_driver = false
    if name == ent.driver_name then is_driver = true end
    local unl_can = "false"
    if ent._unl_can == true then unl_can = "true" end
    local rev_can = "false"
    if ent._rev_can == true then rev_can = "true" end

	basic_form = basic_form.."button[1.0,1.0;4,1;turn_on;Start/Stop the fire]"
    basic_form = basic_form.."button[1.0,2.0;4,1;water;Load water from below]"
    if ent._remove ~= true then
        basic_form = basic_form.."button[1.0,3.0;4,1;inventory;Open inventory]"
    end
    basic_form = basic_form.."button[1.0,4.0;4,1;manual;Show Manual Menu]"

    basic_form = basic_form.."checkbox[6.0,1.2;take_control;Take the Control;"..take_control.."]"
    basic_form = basic_form.."checkbox[6.0,1.8;anchor;Anchor away;"..anchor.."]"
    if is_driver and ent._has_cannons == true then
        basic_form = basic_form.."checkbox[6,2.4;unlock;Unlock cannons;"..unl_can.."]"
        basic_form = basic_form.."checkbox[6,3.0;rev_can;Reverse cannons;"..rev_can.."]"
    end

    basic_form = basic_form.."label[6.0,3.8;Disembark:]"
    basic_form = basic_form.."button[6.0,4.0;2,1;disembark_l;<< Left]"
    basic_form = basic_form.."button[8.0,4.0;2,1;disembark_r;Right >>]"

    core.show_formspec(name, "steampunk_blimp:pilot_main", basic_form)
end

function steampunk_blimp.pax_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,3]",
	}, "")

    basic_form = basic_form.."label[1,1.0;Disembark:]"
    basic_form = basic_form.."button[1,1.2;2,1;disembark_l;<< Left]"
    basic_form = basic_form.."button[3,1.2;2,1;disembark_r;Right >>]"

    core.show_formspec(name, "steampunk_blimp:passenger_main", basic_form)
end

function steampunk_blimp.prepare_cannon_formspec(self, name, side)
    local player = core.get_player_by_name(name)
    local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
    if plane_obj == nil then
        return
    end
    local ent = plane_obj:get_luaentity()

    local basic_form = table.concat({
        "formspec_version[3]",
        "size[5,3]",},"")

    local powder_opt = "false"
    local powder_name = ""
    if side == "l" then
        if ent._l_pload ~= "" then
            powder_opt = "true"
            powder_name = ent._l_pload
        end
    else
        if ent._r_pload ~= "" then
            powder_opt = "true"
            powder_name = ent._r_pload
        end
    end
    basic_form = basic_form.."checkbox[1.0,1.0;load_powder;Put Gunpowder;"..powder_opt.."]"

    local ammo_opt = "false"
    local ammo_name = ""
    if side == "l" then
        if ent._l_armed ~= "" then
            ammo_opt = "true"
            ammo_name = ent._l_armed
        end
    else
        if ent._r_armed ~= "" then
            ammo_opt = "true"
            ammo_name = ent._r_armed
        end
    end

    if powder_name ~= "" then
        basic_form = basic_form.."checkbox[1.0,2.0;load_ammo;Load Ammo;"..ammo_opt.."]"
        --[[if ammo_name then
            basic_form = basic_form.."label[1.0,2.4;"..ammo_name.."]"
        end]]--
    end

    basic_form = table.concat({ basic_form,
        "field[1.0,6.0;1.5,0.8;side;Side;"..side.."]",
        '["key_enter"]="false"',
	}, "")
    core.show_formspec(name, "steampunk_blimp:prep_cannon", basic_form)
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
        core.chat_send_player(name,core.colorize('#ff0000', " >>> you are using an old version of airutils, update it first"))
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

    core.show_formspec(name, "steampunk_blimp:logo_ext", basic_form)
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

    core.show_formspec(name, "steampunk_blimp:owner_main", basic_form)
end

local function set_list(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local function take_item_from_ship_inventory(self, itemname)
    local inv = airutils.get_inventory(self)
    if not inv then return nil end

    local total_taken = 0
    local stack = ItemStack(itemname.." 1")
    local taken = inv:remove_item("main", stack)
    local total_taken = taken:get_count()

    if total_taken > 0 then
        airutils.save_inventory(self)
        return taken
    end
    return nil
end

local function find_in_list(item_name, list)
    for k, v in pairs(list) do
        if v == item_name then
            return k
        end
    end
    return 0
end

local function take_ammo_from_from_last_line(self)
    local inv = airutils.get_inventory(self)
    if not inv then return "" end

    local total_taken = 0
    local curr_stack = nil
    local taken = nil
    local ammo_name = ""
    for i = 41, 50, 1
    do
        curr_stack = inv:get_stack("main", i)
        ammo_name = curr_stack:get_name()
        --core.chat_send_all(dump(curr_stack))
        if find_in_list(ammo_name, steampunk_blimp.avail_ammo) > 0 then
            --core.chat_send_all("achou "..dump(curr_stack))
            local stack = ItemStack(ammo_name)
            taken = inv:remove_item("main", stack)
            break
        end
    end
    if not taken then return "" end
    local total_taken = taken:get_count()

    if total_taken > 0 then
        airutils.save_inventory(self)
        return ammo_name
    end
    return ""
end

local function take_powder_from_from_last_line(self)
    local inv = airutils.get_inventory(self)
    if not inv then return "" end

    local total_taken = 0
    local curr_stack = nil
    local taken = nil
    local item_name = ""
    for i = 1, 50, 1
    do
        curr_stack = inv:get_stack("main", i)
        item_name = curr_stack:get_name()
        --core.chat_send_all(dump(curr_stack))
        if find_in_list(item_name, steampunk_blimp.avail_powder) > 0 then
            --core.chat_send_all("achou "..dump(curr_stack))
            local stack = ItemStack(item_name)
            taken = inv:remove_item("main", stack)
            break
        end
    end
    if not taken then return "" end
    local total_taken = taken:get_count()

    if total_taken > 0 then
        airutils.save_inventory(self)
        return item_name
    end
    return ""
end

local function add_item_to_ship_inventory(self, itemname)
    local inv = airutils.get_inventory(self)
    if not inv then return nil end
    if itemname == "" or itemname == nil then return end

    local total_added = 0
    local stack = ItemStack(itemname.." 1")
    local added = inv:add_item("main", stack)
    local total_added = added:get_count()

    if total_added > 0 then
        airutils.save_inventory(self)
        return added
    end
    return nil
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "steampunk_blimp:owner_main" then
        local name = player:get_player_name()
        local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
        if plane_obj == nil then
            core.close_formspec(name, "steampunk_blimp:owner_main")
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
        core.close_formspec(name, "steampunk_blimp:owner_main")
    end
	if formname == "steampunk_blimp:passenger_main" then
        local name = player:get_player_name()
        local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
        if plane_obj == nil then
            core.close_formspec(name, "steampunk_blimp:passenger_main")
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
        core.close_formspec(name, "steampunk_blimp:passenger_main")
	end
    if formname == "steampunk_blimp:logo_ext" then
        local name = player:get_player_name()
        local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
        if plane_obj == nil then
            core.close_formspec(name, "steampunk_blimp:logo_ext")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
            if fields.set_texture then
                if ent.name == "steampunk_blimp:blimp" then
                    if ent.owner == name or core.check_player_privs(name, {protection_bypass=true}) then
                        if fields.texture_name then
                            local image_name = fields.texture_name
                            local logo_list = set_list(default_logos)
                            if airutils.isTextureLoaded(image_name) or logo_list[image_name] then
                                steampunk_blimp.set_logo(ent, image_name)
                                core.chat_send_player(name,core.colorize('#00ff00', " >>> texture '"..image_name.."' set"))
                                --core.close_formspec(name, "steampunk_blimp:logo_ext")
                                return
                            end
                        end
                    end
                end
            end
		    if fields.logos or fields.t_page then
                --core.close_formspec(name, "steampunk_blimp:logo_ext")
                --steampunk_blimp.logo_ext_formspec(name,fields.logos)
                local result = core.explode_textlist_event(fields.logos)
                if result.type == "CHG" then
                    --core.chat_send_all(dump(result.index))
                    --core.close_formspec(name, "steampunk_blimp:logo_ext")
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
            core.close_formspec(name, "steampunk_blimp:pilot_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
		    if fields.turn_on then
                steampunk_blimp.start_furnace(ent)
                if ent.hp <= steampunk_blimp.min_hp then
                    core.chat_send_player(name,core.colorize('#ff0000', " >>> The ship is severely damaged."))
                end
		    end
            if fields.water then
                if ent.isinliquid then
                    if ent._engine_running == true then
                        steampunk_blimp.start_furnace(ent)
                    end
                    if ent._boiler_pressure > 0 then
                        core.sound_play({name = "default_cool_lava"},
                            {object = ent.object, gain = 1.0,
                                pitch = 1.0,
                                max_hear_distance = 32,
                                loop = false,}, true)
                    end
                    ent._boiler_pressure = 0
                    ent._water_level = steampunk_blimp.MAX_WATER
                else
                    core.chat_send_player(name,core.colorize('#ff0000', " >>> Impossible. The ship needs to be in the water."))
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
                                --core.chat_send_all(">>"..ent.driver_name)
                                break
                            end
                        end
                    else
                        core.chat_send_player(name,core.colorize('#ff0000', " >>> Impossible. Someone is at the blimp control now."))
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
                                core.chat_send_player(name,core.colorize('#00ff00', " >>> Anchor away!"))
                            end
                            --ent.buoyancy = 0.1
                        else
                            if name then
                                core.chat_send_player(name,core.colorize('#ff0000', " >>> Too fast to set anchor!"))
                            end
                        end
                    end
                else
                    ent.anchored = false
                    if name then
                        core.chat_send_player(name,core.colorize('#00ff00', " >>> Weigh anchor!"))
                    end
                end
                --ent._rudder_angle = 0
            end
            if fields.rev_can then
                local override = {}
                if fields.rev_can == "true" then
                    ent._rev_can = true
                    --ent.cannons:set_bone_position("cannon_l", {x=-24,y=-2,z=0}, {x=0,y=0,z=0})
                    --ent.cannons:set_bone_position("cannon_r", {x= 24,y=-2,z=0}, {x=0,y=0,z=0})
                    override = {
                        rotation = { vec={x=math.rad(-180),y=0,z=0}, interpolation = 1, absolute = false }
                        }
                else
                    ent._rev_can = false
                    --ent.cannons:set_bone_position("cannon_l", {x=-24,y=-2,z=0}, {x=180,y=0,z=0})
                    --ent.cannons:set_bone_position("cannon_r", {x= 24,y=-2,z=0}, {x=180,y=0,z=0})
                    override = {
                        rotation = { vec={x=math.rad(360),y=0,z=0}, interpolation = 1, absolute = false }
                        }
                end
                ent.cannons:set_bone_override("cannon_l", override)
                ent.cannons:set_bone_override("cannon_r", override)
            end
            if fields.unlock then
                if fields.unlock == "true" then
                    ent._unl_can = true
                else
                    ent._unl_can = false
                end
            end
        end
        core.close_formspec(name, "steampunk_blimp:pilot_main")
    end
    if formname == "steampunk_blimp:prep_cannon" then
        local name = player:get_player_name()
        local plane_obj = steampunk_blimp.getPlaneFromPlayer(player)
        if plane_obj == nil then
            core.close_formspec(name, "steampunk_blimp:pilot_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        local side = fields.side

        if ent and (side == "l" or side == "r") then
            if fields.load_powder then
                if fields.load_powder == "true" then
                    if side == "l" then
                        ent._l_pload = take_powder_from_from_last_line(ent)
                    else
                        ent._r_pload = take_powder_from_from_last_line(ent)
                    end
                else
                    if side == "l" then
                        add_item_to_ship_inventory(ent, ent._l_pload)
                        ent._l_pload = ""
                    else
                        add_item_to_ship_inventory(ent, ent._r_pload)
                        ent._r_pload = ""
                    end
                end
            end
            if fields.load_ammo then
                if fields.load_ammo == "true" then
                    if side == "l" then
                        ent._l_armed = take_ammo_from_from_last_line(ent)
                    else
                        ent._r_armed = take_ammo_from_from_last_line(ent)
                    end
                else
                    if side == "l" then
                        add_item_to_ship_inventory(ent, ent._l_armed)
                        ent._l_armed = ""
                    else
                        add_item_to_ship_inventory(ent, ent._r_armed)
                        ent._r_armed = ""
                    end
                end
            end
        end
        core.close_formspec(name, "steampunk_blimp:prep_cannon")
        if side then
            steampunk_blimp.prepare_cannon_formspec(ent, name, side)
        end
    end
end)


core.register_chatcommand("blimp_share", {
	params = "name",
	description = "Share ownewrship with your friends",
	privs = {interact = true},
	func = function(name, param)
        local player = core.get_player_by_name(name)
        local target_player = core.get_player_by_name(param)
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
                                core.chat_send_player(name,core.colorize('#00ff00', " >>> blimp shared"))
                                --core.chat_send_all(dump(entity._shared_owners))
                            else
                                core.chat_send_player(name,core.colorize('#ff0000', " >>> this user is already registered for blimp share"))
                            end
                        else
                            core.chat_send_player(name,core.colorize('#ff0000', " >>> only the owner can share this blimp"))
                        end
                    else
			            core.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
                    end
                end
            end
		else
			core.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
		end
	end
})

core.register_chatcommand("blimp_remove", {
	params = "name",
	description = "Removes ownewrship from someone",
	privs = {interact = true},
	func = function(name, param)
        local player = core.get_player_by_name(name)
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
                            core.chat_send_player(name,core.colorize('#00ff00', " >>> user removed"))
                            --core.chat_send_all(dump(entity._shared_owners))
                        else
                            core.chat_send_player(name,core.colorize('#ff0000', " >>> only the owner can do this action"))
                        end
                    else
			            core.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
                    end
                end
            end
		else
			core.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
		end
	end
})

core.register_chatcommand("blimp_list", {
	params = "",
	description = "Lists the blimp shared owners",
	privs = {interact = true},
	func = function(name, param)
        local player = core.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        core.chat_send_player(name,core.colorize('#ffff00', " >>> Current owners are:"))
                        core.chat_send_player(name,core.colorize('#0000ff', entity.owner))
                        for k, v in pairs(entity._shared_owners) do
                            core.chat_send_player(name,core.colorize('#00ff00', v))
                        end
                        --core.chat_send_all(dump(entity._shared_owners))
                    else
			            core.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
                    end
                end
            end
		else
			core.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
		end
	end
})

core.register_chatcommand("blimp_lock", {
	params = "true/false",
	description = "Blocks boarding of non-owners. true to lock, false to unlock",
	privs = {interact = true},
	func = function(name, param)
        local player = core.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        if param == "true" then
                            entity._passengers_locked = true
                            core.chat_send_player(name,core.colorize('#ffff00', " >>> Non owners cannot enter now."))
                        elseif param == "false" then
                            entity._passengers_locked = false
                            core.chat_send_player(name,core.colorize('#00ff00', " >>> Non owners are free to enter now."))
                        end
                    else
			            core.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
                    end
                end
            end
		else
			core.chat_send_player(name,core.colorize('#ff0000', " >>> you are not inside a blimp to perform this command"))
		end
	end
})

core.register_chatcommand("blimp_logo", {
	params = "<image_name.png>",
	description = "Changes blimp logo",
	privs = {interact = true},
	func = function(name, param)
        local image_name = param --"blimp_alpha.png^"..param
        local colorstring = core.colorize('#ff0000', " >>> you are not inside a blimp")
        local player = core.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "steampunk_blimp:blimp" then
                        if entity.owner == name or core.check_player_privs(name, {protection_bypass=true}) then
                            if airutils.isTextureLoaded then
                                if param == '' then
                                    steampunk_blimp.logo_ext_formspec(name)
                                else
                                    local logo_list = set_list(default_logos)
                                    if airutils.isTextureLoaded(image_name) or logo_list[image_name] then
                                        steampunk_blimp.set_logo(entity, image_name)
                                        core.chat_send_player(name,core.colorize('#00ff00', " >>> texture '"..image_name.."' set"))
                                    else
                                        core.chat_send_player(name,core.colorize('#ff0000', " >>> texture '"..image_name.."' not found"))
                                    end
                                end
                            else
                                core.chat_send_player(name,core.colorize('#ff0000', " >>> you are using an old version of airutils, update it first"))
                            end
                        else
                            core.chat_send_player(name,core.colorize('#ff0000', " >>> only the owner can do this action"))
                        end
                    else
			            core.chat_send_player(name,colorstring)
                    end
                end
            end
		else
			core.chat_send_player(name,colorstring)
		end
	end
})

core.register_chatcommand("blimp_eject", {
	params = "",
	description = "Ejects from the blimp - useful for clients before 5.3",
	privs = {interact = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside a blimp")
        local player = core.get_player_by_name(name)
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
			            core.chat_send_player(name,colorstring)
                    end
                end
            end
		else
			core.chat_send_player(name,colorstring)
		end
	end
})

if airutils.is_repixture then
    local available_text = "The available colors are: black, blue, brown, cyan, dark_green, dark_grey, green, grey, magenta, orange, pink, red, violet, white or yellow"
    core.register_chatcommand("blimp_paint", {
	    params = "<color1> <color2>",
	    description = "Paints the blimp with a primary and secondary colors. "..available_text,
	    privs = {interact = true},
	    func = function(name, param)
            local colorstring = core.colorize('#ff0000', " >>> you are not inside a blimp")
            local player = core.get_player_by_name(name)
            local attached_to = player:get_attach()

		    if attached_to ~= nil then
                local seat = attached_to:get_attach()
                if seat ~= nil then
                    local entity = seat:get_luaentity()
                    if entity then
                        if entity.name == "steampunk_blimp:blimp" then
                            if entity.owner == name or core.check_player_privs(name, {protection_bypass=true}) then
                                --lets paint!!!!
                                local color1, color2 = param:match("^([%a%d_-]+) (.+)$")

                                --core.chat_send_all(dump(color1).." - "..dump(color2))
                                local colstr = steampunk_blimp.colors[color1]
                                local colstr2 = steampunk_blimp.colors[color2 or "white"]
                                --core.chat_send_all(color ..' '.. dump(colstr))
                                if colstr and colstr2 then
                                    steampunk_blimp.paint2(entity, colstr)
                                    steampunk_blimp.paint(entity, colstr2)
                                    core.chat_send_player(name,core.colorize('#00ff00', " >>> colors set successfully"))
                                else
                                    core.chat_send_player(name,core.colorize('#ff0000', " >>> some of the colors wasn't specified correctly. "..available_text))
                                end
                            else
                                core.chat_send_player(name,core.colorize('#ff0000', " >>> only the owner can do this action"))
                            end
                        else
			                core.chat_send_player(name,colorstring)
                        end
                    end
                end
		    else
			    core.chat_send_player(name,colorstring)
		    end
	    end
    })
end
