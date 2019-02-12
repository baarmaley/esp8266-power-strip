GLOBAL_CONSTANTS = {
    SETTINGS = {
        ssid_settings_name = "ESP8266_CONFIG",
        filename = "settings.ini",
        ssid_prefix = "SSID=",
        password_prefix = "PASSWORD="
    },

    SETUP_MODE = false,

    FATAL_ERROR = nil,
        
    BUTTON_PIN = { 5, 6 },

    BUTTON_STATE = {},

    OUTPUT_PIN = { 1, 2 },

    OUTPUT_LAST_CHANGE = "Default",

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


local switching_mode_pin = 5
local settings_file = file.open(GLOBAL_CONSTANTS["SETTINGS"]["filename"], "r")

gpio.mode(switching_mode_pin, gpio.INT, gpio.PULLUP)

print(gpio.read(switching_mode_pin))
if(gpio.read(switching_mode_pin) == 0 or settings_file == nil) then
    print("Setup mode")
    GLOBAL_CONSTANTS["SETUP_MODE"] = true
    wifi.setmode(wifi.SOFTAP, false)
    wifi.ap.config({ssid=GLOBAL_CONSTANTS["SETTINGS"]["ssid_settings_name"], auth=wifi.OPEN, save=false})    
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
