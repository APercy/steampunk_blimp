--------------
-- Manual --
--------------

function steampunk_blimp.manual_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,6]"
	}, "")

	basic_form = basic_form.."button[1,1.0;4,1;short;Shortcuts]"
	basic_form = basic_form.."button[1,2.5;4,1;fuel;Refueling]"
	basic_form = basic_form.."button[1,4.0;4,1;share;Sharing]"

    core.show_formspec(name, "steampunk_blimp:manual_main", basic_form)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "steampunk_blimp:manual_main" then
        local formspec_color = "#44444466"
		if fields.short then
			local text = {
				"Shortcuts \n\n",
                "* Right click: enter in / acess the internal menu \n",
                "* Punch with dye to paint the primary color\n",
                "* Punch a dye, but holding Aux (E) key to change the secondary color.\n",
                "* To change the blimp logo, call the command \""..core.colorize('#ffff00', "/blimp_logo").."\".\n",
                "* Forward or backward while in drive position: controls the power lever \n",
                "* Left or right while in drive position: controls the direction \n",
                "* Jump and sneak: controls the up and down movement \n",
                "* Aux (E) + right click while inside: acess inventory \n",
                "* Aux (E) + backward while in drive position: the machine does backward \n",
                "* Aux (E) + foward while in drive position: extra power \n",
                "* Aux (E) + left while in drive position: shot left cannon *\n",
                "* Aux (E) + right while in drive position: shot right cannon *\n",
                "* Aux (E) + space while in drive position: shot both cannons *\n\n",
                "(* the cannons must be loaded and unlocked before the shot)\n",
                "(* the ammo for the cannons must be at the bottom line of blimp inventory)"
			}
			local shortcut_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
                "no_prepend[]",
                "bgcolor["..formspec_color..";false]",
        "textarea[0.75,0.1;15.25,9;;" .. table.concat(text, "") .. ";]",
			}, "")
			core.show_formspec(player:get_player_name(), "steampunk_blimp:manual_shortcut", shortcut_form)
		end
		if fields.fuel then
			local text = {
				"Fuel \n\n",
				"To fly it, it is necessary to provide some items, such as fuel to be burned and \n",
				"water for the boiler. The fuel can be coal, coal block or wood. To supply it, \n",
				"be on board and punch the necessary items on the airship.\n",
                "There is another way to load water to the boiler: if it is landed on water, it can load \n",
				"it through the menu. But the current pressure will be lost. \n\n",
        "Repair\n",
        "Now impacts and shots will damage the airship.\nBut the damage is limited until hp reaches the value of 10.\n",
        "The damaged blimp wont fly and will fall after losing it's pressure.\n",
        "To repair the damaged airship, punch gold ingots into it.\n\n",
        "Gun load\n\n",
        "Put gunpowder and cannon ball into last line of the blimp inventory.\n",
        "Then right click on each gun for view gun load menu.\n",
        "For effective combat, a second player is needed to load the guns."
			}
			local fuel_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
                "no_prepend[]",
                "bgcolor["..formspec_color..";false]",
        "textarea[0.75,0.1;15.25,9;;" .. table.concat(text, "") .. ";]",
			}, "")
			core.show_formspec(player:get_player_name(), "steampunk_blimp:fuel", fuel_form)
		end
		if fields.share then
			local text = {
				"Sharing \n\n",
                "This vehicle was made to be shared with a team. So the owner can set more users to  \n",
                "operate it. Inside the blimp, just use the command \""..core.colorize('#ffff00', "/blimp_share <name>").."\" \n",
                "To remove someone from the sharing, \""..core.colorize('#ffff00', "/blimp_remove <name>").."\" \n",
                "To list the owners, \""..core.colorize('#ffff00', "/blimp_list").."\" \n",
                "Is possible to lock the blimp access, so only the owners can enter: \""..core.colorize('#ffff00', "/blimp_lock true").."\" \n",
                "To let anyone enter, \""..core.colorize('#ffff00', "/blimp_lock false").."\" \n",
                "All shared owners can access the blimp inventory"
			}
			local tips_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
                "no_prepend[]",
                "bgcolor["..formspec_color..";false]",
        "textarea[0.75,0.1;15.25,9;;" .. table.concat(text, "") .. ";]",
			}, "")
			core.show_formspec(player:get_player_name(), "steampunk_blimp:share", tips_form)
		end
	end
end)

core.register_chatcommand("blimp_manual", {
	params = "",
	description = "Blimp manual",
	func = function(name, param)
        steampunk_blimp.manual_formspec(name)
	end
})
