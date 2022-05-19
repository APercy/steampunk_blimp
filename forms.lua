
--------------
-- Manual --
--------------

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
        "size[6,8]",
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
    basic_form = basic_form.."button[1,2.0;4,1;hud;Show/Hide Gauges]"

    basic_form = basic_form.."checkbox[1,4.6;take_control;Take the Control;"..take_control.."]"
    basic_form = basic_form.."checkbox[1,5.2;anchor;Anchor away;"..anchor.."]"
    basic_form = basic_form.."button[1,6.0;4,1;go_out;Go Offboard]"

    minetest.show_formspec(name, "steampunk_blimp:pilot_main", basic_form)
end

function steampunk_blimp.pax_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,3]",
	}, "")

	basic_form = basic_form.."button[1,1.0;4,1;go_out;Go Offboard]"

    minetest.show_formspec(name, "steampunk_blimp:passenger_main", basic_form)
end

function steampunk_blimp.owner_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,4]",
	}, "")

	basic_form = basic_form.."button[1,1.0;4,1;take;Take the Control Now]"
    basic_form = basic_form.."button[1,2.0;4,1;go_out;Go Offboard]"

    minetest.show_formspec(name, "steampunk_blimp:owner_main", basic_form)
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
		    if fields.go_out then
                steampunk_blimp.dettach_pax(ent, player)
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
		    if fields.go_out then
                steampunk_blimp.dettach_pax(ent, player)
		    end
        end
        minetest.close_formspec(name, "steampunk_blimp:passenger_main")
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
            if fields.hud then
                if ent._show_hud == true then
                    ent._show_hud = false
                else
                    ent._show_hud = true
                end
            end
		    if fields.take_control then
                if fields.take_control == "true" then
                    if ent.driver_name == nil then
                        ent._at_control = true
                        for i = 5,1,-1 
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
                    end
                else
                    ent.driver_name = nil
                    ent._at_control = false
                end
		    end
		    if fields.go_out then
                --=========================
                --  dettach player
                --=========================
                -- eject passenger if the plane is on ground
                local touching_ground, liquid_below = airutils.check_node_below(plane_obj, 2.5)
                --if ent.isinliquid or touching_ground then --isn't flying?
                    --ok, remove pax
                    local passenger = nil
                    for i = 5,1,-1 
                    do 
                        if ent._passengers[i] == name then
                            passenger = minetest.get_player_by_name(ent._passengers[i])
                            if passenger then
                                steampunk_blimp.dettach_pax(ent, passenger)
                                --minetest.chat_send_all('saiu')
                                break
                            end
                        end
                    end
                --end
		    end
		    if fields.bring then

		    end
            if fields.anchor then
                if fields.anchor == "true" then
                    local max_speed_anchor = 0.2
                    if ent._longit_speed then
                        if ent._longit_speed < max_speed_anchor and
                           ent._longit_speed > -max_speed_anchor then

                            ent.anchored = true
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
	description = "Removes ownewrshipfrom someone",
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
