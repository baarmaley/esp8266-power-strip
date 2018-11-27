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

    OUTPUT_PIN = { 1, 4 },

    BUTTON_BINDING = { [5] = 1, [6] = 4 },
    
    has_value = function(tab, val)
        for index, value in pairs(tab) do
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


srv=net.createServer(net.TCP) 
if srv then 
    srv:listen(80,function(conn) 
        conn:on("receive",function(conn,payload) 
            --parsing http header
            local _, _, url = payload:gmatch("[^\r\n]+")():find("GET ([%a%d%p]*) HTTP")

            local response_header = "HTTP/1.1 200 OK\r\n\r\n"
            local response_body = ""

            local create_pair = function(key, value)
                return "{\""..key.."\":\""..value.."\"}"
            end

            if GLOBAL_CONSTANTS["FATAL_ERROR"] ~= nil then
                response_body = create_pair("Error", GLOBAL_CONSTANTS["FATAL_ERROR"])
            elseif url ~= nil then
                local success, error_string, result_string = pcall(loadfile("route.lua"), url)
                if not success then
                    response_body = create_pair("Error", error_string)
                else
                    response_body = create_pair("Result", (result_string or "Ok"))
                end 
            else
                response_body = create_pair("Error", "Invalid request")
            end

            local response = response_header..response_body

            print(response)
            
            conn:send(response, function(conn)
                conn:close()
                end)
            end) 
    end)
end
