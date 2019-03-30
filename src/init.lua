GLOBAL_CONSTANTS = {
    SETTINGS = {
        ssid_settings_name = "ESP8266_CONFIG",
        filename = "settings.ini",
        ssid_prefix = "SSID=",
        password_prefix = "PASSWORD=",
        device_type_filename = "type.ini",
        device_type = "undefined",
        deivice_id_filename = "id.ini",
        device_id = "0",
        device_name_filename = "device_name.ini",
        device_name = ""
    },

    SETUP_MODE = false,

    FATAL_ERROR = nil,

    WIFI_STATE = nil,

    WIFI_INFO = {
        CONNECTION_TIMEPOINT = nil,
        RECONNECT_COUNT = 0,
        LAST_REASON_RECONNECTION = nil
    },
    
    GPIO_INFO = {
        OUTPUT_LAST_CHANGE = "Default"
    },

    UDP_SERVER_SETTINGS = {
        PORT = 55100,
        INTERVAL = 1000,
    },
        
    BUTTON_PIN = { 5, 6 },

    BUTTON_STATE = {},

    OUTPUT_PIN_NAMES = {},
    
    OUTPUT_PIN_NAME_FILENAME = function(pinout) 
        return "relay/name/"..pinout
    end,
    
    OUTPUT_PIN = { 1, 2 },
    
    BUTTON_BINDING = { [5] = 1, [6] = 2 },
    
    has_value = function(tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
        return false
    end
}

-- begin function
local load_settings_from_file = function(filename, parent, key)
    local f = file.open(filename, "r")
    if f ~= nil then
        GLOBAL_CONSTANTS[parent][key] = f:readline()
        print("Load "..key..": "..GLOBAL_CONSTANTS[parent][key].." from "..filename)
        f:close()
    else
        print("Failed load value from "..filename)
    end
end
-- end function

local switching_mode_pin = 5
gpio.mode(switching_mode_pin, gpio.INT, gpio.PULLUP)

load_settings_from_file(GLOBAL_CONSTANTS["SETTINGS"]["device_type_filename"], "SETTINGS", "device_type")
load_settings_from_file(GLOBAL_CONSTANTS["SETTINGS"]["deivice_id_filename"], "SETTINGS", "device_id")
load_settings_from_file(GLOBAL_CONSTANTS["SETTINGS"]["device_name_filename"], "SETTINGS", "device_name")

-- load name relays from files
for _, pinout in ipairs(GLOBAL_CONSTANTS["OUTPUT_PIN"]) do
    load_settings_from_file(GLOBAL_CONSTANTS["OUTPUT_PIN_NAME_FILENAME"](pinout), "OUTPUT_PIN_NAMES", pinout)
end

local settings_file = file.open(GLOBAL_CONSTANTS["SETTINGS"]["filename"], "r")

if(gpio.read(switching_mode_pin) == 0 or settings_file == nil) then
    print("Setup mode")
    GLOBAL_CONSTANTS["SETUP_MODE"] = true
    wifi.setmode(wifi.SOFTAP, false)
    wifi.ap.config({ssid=GLOBAL_CONSTANTS["SETTINGS"]["ssid_settings_name"], auth=wifi.OPEN, save=false})
    GLOBAL_CONSTANTS["WIFI_STATE"] = "as_ap"    
else
    print("Normal mode")
    local find_pattern = function(field)
        return field.."([^\r\n]*)"
    end

    local _, _, _, ssid = pcall(function() 
        return settings_file:readline():find(find_pattern(GLOBAL_CONSTANTS["SETTINGS"]["ssid_prefix"])) 
        end)
    local _, _, _, password = pcall(function() 
        return settings_file:readline():find(find_pattern(GLOBAL_CONSTANTS["SETTINGS"]["password_prefix"]))
        end)

    --print(pcall(settings_file:readline():find, find_pattern("SSID")))
    --print(password)
   if ssid ~= nil and password ~=nil then
   
        print("Gpio start")
        local gpio_result, gpio_string_error = pcall(loadfile("gpio.lua"))
        if not gpio_result then
            GLOBAL_CONSTANTS["FATAL_ERROR"] = gpio_string_error
            print("Gpio: "..GLOBAL_CONSTANTS["FATAL_ERROR"])
        else
            print("Gpio ok")
        end        

        print("Wifi start")
        local wifi_result, wifi_string_error = pcall(loadfile("wifi_station.lua"), ssid, password)
        print(wifi_result)
        if not wifi_result then
            GLOBAL_CONSTANTS["FATAL_ERROR"] = wifi_string_error
            print("Wifi: "..GLOBAL_CONSTANTS["FATAL_ERROR"])
        else
            print("Wifi ok")
        end
               
   else
        GLOBAL_CONSTANTS["FATAL_ERROR"] = "Settings corrupted";
        print(GLOBAL_CONSTANTS["FATAL_ERROR"])
   end
    
end

if(settings_file ~= nil) then
    settings_file:close()
end

print("Server start")

local server_result, server_string_error = pcall(loadfile("server.lua"))
if not server_result then
    GLOBAL_CONSTANTS["FATAL_ERROR"] = server_string_error
    print("Server: "..GLOBAL_CONSTANTS["FATAL_ERROR"])
else
    print("Server ok")
end
