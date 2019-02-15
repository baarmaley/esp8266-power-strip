local url = ...

if url == nil then
    do return end
end

if GLOBAL_CONSTANTS == nil then
    error("Run only after init.lua")
end

local success_result = "\"Ok\""

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

local save_settings_to_file = function(filename, key, value)
    local fd = file.open(filename, "w+")
    fd:write(value)
    fd:flush()
    fd:close()
    GLOBAL_CONSTANTS["SETTINGS"][key] = value
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
            return success_result
        end
    end,
    device_type = function(type)    
        save_settings_to_file(GLOBAL_CONSTANTS["SETTINGS"]["device_type_filename"], "device_type", type)
        return success_result
    end,
    device_id = function(id)
        save_settings_to_file(GLOBAL_CONSTANTS["SETTINGS"]["deivice_id_filename"], "device_id", id)
        return success_result
    end
}

local change_button_event = function()
    GLOBAL_CONSTANTS["DEBUG"]["OUTPUT_LAST_CHANGE"] = "Server"
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
        result[#result + 1] = " \"device_id\" : \""..GLOBAL_CONSTANTS["SETTINGS"]["device_id"].."\","
        result[#result + 1] = " \"device_type\" : \""..GLOBAL_CONSTANTS["SETTINGS"]["device_type"].."\","
        result[#result + 1] = " \"output_pin\" : {"
        for _, pinout in ipairs(GLOBAL_CONSTANTS["OUTPUT_PIN"]) do
            result[#result + 1] = "\""..pinout.."\":"
            result[#result + 1] = "\""..gpio.read(pinout).."\""
            result[#result + 1] = ","
        end
        result[#result] = "}}"
        return table.concat(result)
    end,
    debug = function()
        local result = {}
        result[#result + 1] = "{"
        result[#result + 1] = "\"last_change\":\""..GLOBAL_CONSTANTS["DEBUG"]["OUTPUT_LAST_CHANGE"].."\","
        result[#result + 1] = "\"uptime\": "..tmr.time()..","
        result[#result + 1] = "\"heap\":"..node.heap()..","
        result[#result + 1] = "\"connection_timepoint\":"..(tmr.time() - GLOBAL_CONSTANTS["DEBUG"]["WIFI_CONNECTION_TIMEPOINT"])..","
        result[#result + 1] = "\"reconnect_count\" :"..GLOBAL_CONSTANTS["DEBUG"]["WIFI_RECONNECT_COUNT"]
        result[#result + 1] = ","
        
        if GLOBAL_CONSTANTS["DEBUG"]["WIFI_LAST_REASON_RECONNECTION"] ~= nil  then
            result[#result + 1] = "\"last_reason_reconnection\":\""..GLOBAL_CONSTANTS["DEBUG"]["WIFI_LAST_REASON_RECONNECTION"].."\""
            result[#result + 1] = ","
        end
        
        result[#result] = "}}"
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

