


local function boiler_step(self, accel)


end

local function furnace_step(self, accel)
    if self._energy > 0 and self._engine_running then
        local zero_reference = vector.new()
        local acceleration = steampunk_blimp.get_hipotenuse_value(accel, zero_reference)
        local consumed_power = acceleration/steampunk_blimp.FUEL_CONSUMPTION
        self._energy = self._energy - consumed_power;
    end
    if self._energy <= 0 then
        self._engine_running = false
        if self.sound_handle then minetest.sound_stop(self.sound_handle) end
        self.object:set_animation_frame_speed(0)
    end
end

function steampunk_blimp.engine_step(self, accel)
    furnace_step(self, accel)
    boiler_step(self, accel)

    if self.driver_name then
        local player = minetest.get_player_by_name(self.driver_name)

        local pressure = steampunk_blimp.get_pointer_angle(self._boiler_pressure, 200 )
        local water = steampunk_blimp.get_pointer_angle(self._water_level, steampunk_blimp.MAX_FUEL)
        local coal = self._energy
        steampunk_blimp.update_hud(player, coal, 180-water, -pressure)
    end
end

