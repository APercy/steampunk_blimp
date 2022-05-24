--
-- fuel
--
steampunk_blimp.MAX_FUEL = minetest.settings:get("steampunk_blimp_max_fuel") or 99
steampunk_blimp.FUEL_CONSUMPTION = minetest.settings:get("steampunk_blimp_fuel_consumption") or 6000

minetest.register_entity('steampunk_blimp:pointer',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "pointer.b3d",
	textures = {"steampunk_blimp_interior.png"},
	},
	
on_activate = function(self,std)
	self.sdata = minetest.deserialize(std) or {}
	if self.sdata.remove then self.object:remove() end
end,
	
get_staticdata=function(self)
  	
  self.sdata.remove=true
  return minetest.serialize(self.sdata)
end,
	
})

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

    --minetest.chat_send_all("fuel: ".. dump(item_name))
    local fuel = steampunk_blimp.contains(steampunk_blimp.fuel, item_name)
    if fuel then
        local stack = ItemStack(item_name .. " 1")

        if self._energy < steampunk_blimp.MAX_FUEL then
            inv:remove_item("main", stack)
            self._energy = self._energy + fuel.amount
            if self._energy > steampunk_blimp.MAX_FUEL then self._energy = steampunk_blimp.MAX_FUEL end
            --minetest.chat_send_all(self.energy)
            
            if fuel.drop then
                local leftover = inv:add_item("main", fuel.drop)
                if leftover then
                    minetest.item_drop(leftover, player, player:get_pos())
                end
            end

            --local energy_indicator_angle = steampunk_blimp.get_pointer_angle(self._energy, steampunk_blimp.MAX_FUEL)
        end
        
        return true
    end

    return false
end

