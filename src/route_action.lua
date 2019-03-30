local change_button_event = function()
    GLOBAL_CONSTANTS["GPIO_INFO"]["OUTPUT_LAST_CHANGE"] = "Server"
end

local routing_action = {
    on = function(pinout)
        check_pinout(pinout)
        gpio.write(pinout, gpio.HIGH)
        change_button_event()
        return success_result
    end,

    off = function(pinout)
        check_pinout(pinout)
        gpio.write(pinout, gpio.LOW)
        change_button_event()
        return success_result
    end,
    inversion = function(pinout)
        check_pinout(pinout)
        gpio.write(pinout, gpio.read(pinout) == 1 and gpio.LOW or gpio.HIGH)
        change_button_event()
        return success_result
    end, 
    all_off = function()
        for _, pinout in ipairs(GLOBAL_CONSTANTS["OUTPUT_PIN"]) do
            gpio.write(pinout, gpio.LOW)
        end
        change_button_event()
        return success_result
    end,
    all_on = function()
        for _, pinout in ipairs(GLOBAL_CONSTANTS["OUTPUT_PIN"]) do
            gpio.write(pinout, gpio.HIGH)
        end
        change_button_event()
        return success_result
    end
}

return routing_action
