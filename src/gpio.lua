if GLOBAL_CONSTANTS == nil then
    error("Run only from init.lua")
end

local lock_buttons = false
local latest_button_click = nil

local timer_button = tmr.create()
timer_button:alarm(100, tmr.ALARM_SEMI, function()
        if latest_button_click ~= nil and gpio.read(latest_button_click) == 0 then
            timer_button:start()
            print("Restart "..latest_button_click.." "..gpio.read(latest_button_click))
            do return end
        end
        print("Ok")
        lock_buttons = false
        latest_button_click = nil
end)

local create_button_interrupt_handler = function(pin_input, pin_out)
    return function(level, when, eventcount)
        if lock_buttons then
            do return end
        end
        lock_buttons = true
    
        local success, string_error = pcall(loadfile("route.lua"), "/action/inversion/"..pin_out)
        if not success then
            print("Error: "..string_error)
        end
    
        print("Pressed: "..level.." "..when.." "..eventcount)

        latest_button_click = pin_input
        timer_button:start()
    end
end

for _, btn_pin in pairs(GLOBAL_CONSTANTS["OUTPUT_PIN"]) do
    gpio.mode(btn_pin, gpio.OUTPUT)
end

for _, output_pin in pairs(GLOBAL_CONSTANTS["BUTTON_PIN"]) do
    gpio.mode(output_pin, gpio.INT, gpio.PULLUP)
end

for btn_pin, output_pin in pairs(GLOBAL_CONSTANTS["BUTTON_BINDING"]) do
    gpio.trig(btn_pin, "low", create_button_interrupt_handler(btn_pin, output_pin))
end
--gpio.trig(5, "low", create_button_interrupt_handler(5, 1))
--gpio.trig(6, "low", create_button_interrupt_handler(6, 4))