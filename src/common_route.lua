local success_result = "{\"Result:\": \"Ok\"}"

local check_pinout = function(pinout)
    if GLOBAL_CONSTANTS["has_value"](GLOBAL_CONSTANTS["OUTPUT_PIN"], tonumber(pinout)) == false then
        error("Pinout: "..pinout.." is not an output pin")
    end
end
