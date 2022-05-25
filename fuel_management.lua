--
-- fuel
--
steampunk_blimp.MAX_FUEL = minetest.settings:get("steampunk_blimp_max_fuel") or 99
steampunk_blimp.FUEL_CONSUMPTION = minetest.settings:get("steampunk_blimp_fuel_consumption") or 6000

steampunk_blimp.MAX_WATER = 10
steampunk_blimp.WATER_CONSUMPTION = 50000

function steampunk_blimp.contains(table, val)
    for k,v in pairs(table) do
        if k == val then
            return v
        end
    end
    return false
end

function steampunk_blimp.load_fuel(self, player)
    local inv = player:get_inventory()

    local itmstck=player:get_wielded_item()
    local item_name = ""
    if itmstck then item_name = itmstck:get_name() end

    local grp_wood = minetest.get_item_group(item_name, "wood")
    local grp_tree = minetest.get_item_group(item_name, "tree")
    if grp_wood == 1 or grp_tree == 1 then
        local stack = ItemStack(item_name .. " 1")

        if self._energy < steampunk_blimp.MAX_FUEL then
            inv:remove_item("main", stack)
            local amount = 1
            if grp_tree == 1 then amount = 4 end
            self._energy = self._energy + amount
            if self._energy > steampunk_blimp.MAX_FUEL then self._energy = steampunk_blimp.MAX_FUEL end
        end
        return true
    end

    --minetest.chat_send_all("fuel: ".. dump(item_name))
    local fuel = steampunk_blimp.contains(steampunk_blimp.fuel, item_name)
    if fuel then
        local stack = ItemStack(item_name .. " 1")

        if self._energy < steampunk_blimp.MAX_FUEL then
            inv:remove_item("main", stack)
            self._energy = self._energy + fuel.amount
            if self._energy > steampunk_blimp.MAX_FUEL then self._energy = steampunk_blimp.MAX_FUEL end
            --minetest.chat_send_all(self.energy)

            --local energy_indicator_angle = steampunk_blimp.get_pointer_angle(self._energy, steampunk_blimp.MAX_FUEL)
        end
        
        return true
    end

    return false
end

function steampunk_blimp.load_water(self, player)
    local inv = player:get_inventory()

    local itmstck=player:get_wielded_item()
    local item_name = ""
    if itmstck then item_name = itmstck:get_name() end

    --minetest.chat_send_all("water: ".. dump(item_name))
    local water = steampunk_blimp.contains(steampunk_blimp.water, item_name)
    if water then
        if self._water_level < steampunk_blimp.MAX_WATER then
            local itemstack = ItemStack(item_name .. " 1")
            inv:remove_item("main", itemstack)

            local indx = item_name:find('bucket:bucket')
            if indx then
                itemstack = ItemStack("bucket:bucket_empty")
                inv:add_item("main", itemstack)
                player:set_wielded_item(itemstack)
            end

            self._water_level = self._water_level + water.amount
            if self._water_level > steampunk_blimp.MAX_WATER then self._water_level = steampunk_blimp.MAX_WATER end
        end
        
        return true
    end

    return false
end
