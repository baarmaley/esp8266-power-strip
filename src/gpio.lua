if GLOBAL_CONSTANTS == nil then
    error("Run only after init.lua")
end

local lock_buttons = false


local timer_button = tmr.create()

for _, output_pin in pairs(GLOBAL_CONSTANTS["OUTPUT_PIN"]) do
    gpio.mode(output_pin, gpio.OUTPUT)
end

for _, btn_pin in pairs(GLOBAL_CONSTANTS["BUTTON_PIN"]) do
    gpio.mode(btn_pin, gpio.INPUT, gpio.PULLUP)
    GLOBAL_CONSTANTS["BUTTON_STATE"][btn_pin] = gpio.read(btn_pin)
end

local pressed_handler = function(pin_input)
    local pin_out = GLOBAL_CONSTANTS["BUTTON_BINDING"][pin_input]
    print("Pressed:"..pin_input)
    --print(pin_out)
    if pin_out == nil  then
        do return end
    end
    print("Ok")
    local success, string_error = pcall(loadfile("route.lua"), "/action/inversion/"..pin_out)
    
    if not success then
        print("Error: "..string_error)
    end
    
end

timer_button:alarm(100, tmr.ALARM_SEMI, function()
        --print("Timer out")
        for _, btn_pin in pairs(GLOBAL_CONSTANTS["BUTTON_PIN"]) do
            local btn_state = gpio.read(btn_pin)
            local prev_btn_state = GLOBAL_CONSTANTS["BUTTON_STATE"][btn_pin] 
            
            if btn_state == 0 and prev_btn_state ~= 0 then
                pressed_handler(btn_pin)
            end

            GLOBAL_CONSTANTS["BUTTON_STATE"][btn_pin] = btn_state
        end
        timer_button:start()
end)

timer_button:start()

