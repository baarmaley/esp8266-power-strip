local url = ...

if url == nil then
    do return end
end

if GLOBAL_CONSTANTS == nil then
    error("Run only from init.lua")
end

local check_pinout = function(pinout)
    if GLOBAL_CONSTANTS["has_value"](GLOBAL_CONSTANTS["OUTPUT_PIN"], tonumber(pinout)) == false then
        error("Pinout: "..pinout.." is not an output pin")
    end
end

local check_settings_mode = function()
    if GLOBAL_CONSTANTS["SETUP_MODE"] then 
        error("Unavailable because setup mode is enabled")
    end
end

local check_length_string = function(str)
    if str:len() > 1023 then
        print("Warning! length > 1023")
    end
    return str
end

local routing_set = {
    station = function(ssid)
        return function(password)
            local fd = file.open(GLOBAL_CONSTANTS["SETTINGS"]["filename"], "w+")
            fd:writeline(check_length_string(GLOBAL_CONSTANTS["SETTINGS"]["ssid_prefix"]..ssid))
            fd:writeline(check_length_string(GLOBAL_CONSTANTS["SETTINGS"]["password_prefix"]..password))
            fd:flush()
            fd:close()
            node.restart()
        end
    end
}

local routing_action = {
    on = function(pinout)
        check_pinout(pinout)
        gpio.write(pinout, gpio.HIGH)
    end,

    off = function(pinout)
        check_pinout(pinout)
        gpio.write(pinout, gpio.LOW)
    end,
    inversion = function(pinout)
        check_pinout(pinout)
        gpio.write(pinout, gpio.read(pinout) == 1 and gpio.LOW or gpio.HIGH)
    end 
}

local routing = {
    action = function(action)
        check_settings_mode() 
        return routing_action[action]  
    end,
    set = function(set)
        return routing_set[set]
    end,
    state = function()
        local result = {}
        result[#result + 1] = "{"
        for _, pinout in ipairs(GLOBAL_CONSTANTS["OUTPUT_PIN"]) do
            result[#result + 1] = "\""..pinout.."\":"
            result[#result + 1] = "\""..gpio.read(pinout).."\""
            result[#result + 1] = ","
        end
        result[#result] = "}"
        return table.concat(result)
    end
}

local next_part = url:gmatch("[^/]+")
local route = routing[next_part()] 

while route ~= nil do
    local t = type(route)
    if t == "function" then
      route = route(next_part())   
    elseif t == "table" then
      route = route[next_part()]
    elseif t == "string" then
        return nil, route  
    end             
end

