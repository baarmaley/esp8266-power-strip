local check_length_string = function(str)
    if str:len() > 1023 then
        print("Warning! length > 1023")
    end
    return str
end

local save_settings_to_file = function(filename, parent, key, value)
    local fd = file.open(filename, "w+")
    fd:write(value)
    fd:flush()
    fd:close()
    GLOBAL_CONSTANTS[parent][key] = value
    print(key)
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
    device_type = function(type_)    
        save_settings_to_file(GLOBAL_CONSTANTS["SETTINGS"]["device_type_filename"], "SETTINGS", "device_type", type_)
        return success_result
    end,
    device_id = function(id)
        save_settings_to_file(GLOBAL_CONSTANTS["SETTINGS"]["deivice_id_filename"], "SETTINGS", "device_id", id)
        return success_result
    end,
    device_name = function(name)
        save_settings_to_file(GLOBAL_CONSTANTS["SETTINGS"]["device_name_filename"], "SETTINGS", "device_name", name)
        return success_result
    end,
    relay_name = function(pinout)
        check_pinout(pinout)
        return function(name)
            save_settings_to_file(GLOBAL_CONSTANTS["OUTPUT_PIN_NAME_FILENAME"](pinout), "OUTPUT_PIN_NAMES", tonumber(pinout), name)
            return success_result
        end
    end
}

return routing_set
