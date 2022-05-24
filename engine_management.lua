steampunk_blimp.PRESSURE_CONSUMPTION = 500

local lost_power = (1/steampunk_blimp.FUEL_CONSUMPTION)*500
local gained_power = (2/steampunk_blimp.FUEL_CONSUMPTION)*500

function steampunk_blimp.start_boyler(self)
    if self._boiler_pressure < 150 then
        -- sound and animation
        if self.sound_handle_pistons then
            minetest.sound_stop(self.sound_handle_pistons)
            self.sound_handle_pistons = nil
        end
    elseif self._boiler_pressure >= 150 then
        -- sound
        --minetest.chat_send_all(dump(self.sound_handle_pistons))
        if self.sound_handle_pistons == nil then
            if self.object then
                self.sound_handle_pistons = minetest.sound_play({name = "default_cool_lava"},--"default_item_smoke"},
                    {object = self.object, gain = 0.05,
                        pitch = 0.4,
                        max_hear_distance = 32,
                        loop = true,})
            end
        end
    end
end

local function boiler_step(self, accel)
    steampunk_blimp.start_boyler(self)

    local consumed_pressure = self._power_lever/steampunk_blimp.PRESSURE_CONSUMPTION
    if self._engine_running == false then consumed_pressure = consumed_pressure + lost_power end

    if self._boiler_pressure > 310 then self._boiler_pressure = 310 end
    if self._boiler_pressure > 155 then
        --[[-- sound and animation
        steampunk_blimp.engineSoundPlay(self)
        self.object:set_animation_frame_speed(steampunk_blimp.iddle_rotation)]]--

        steampunk_blimp.engine_set_sound_and_animation(self)
    end
    if self._boiler_pressure < 155 then
        self._power_lever = 0
        --if self.sound_handle_pistons then minetest.sound_stop(self.sound_handle_pistons) end
        self.object:set_animation_frame_speed(0)
    end

    self._boiler_pressure = self._boiler_pressure - consumed_pressure
    if self._boiler_pressure < 0 then self._boiler_pressure = 0 end
end

local function furnace_step(self, accel)
    if self._energy > 0 and self._engine_running then
        local consumed_power = (1/steampunk_blimp.FUEL_CONSUMPTION)
        self._boiler_pressure = self._boiler_pressure + gained_power --pressure for the boiler
        self._energy = self._energy - consumed_power; --removes energy
    end
    if self._energy <= 0 then
        self._engine_running = false
        if self.sound_handle then minetest.sound_stop(self.sound_handle) end
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

