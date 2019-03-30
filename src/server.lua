if GLOBAL_CONSTANTS == nil then
    error("Run only after init.lua")
end

local response_header = "HTTP/1.1 200 OK\r\n\r\n"

local create_pair_with_string = function(key, value)
	return "{\""..key.."\":\""..value.."\"}"
end

local create_pair_with_object = function(key, value)
	return "{\""..key.."\":"..value.."}"
end

local sent_handler = function(sck)
    sck:on("receive", nil)
    sck:close()
end

local receive_handler = function(sck,payload) 
    --parsing http header
    local is_success_parse, _, _, url = pcall(function()
            return payload:gmatch("[^\r\n]+")():find("GET ([%a%d%p]*) HTTP")
        end)
    
    if not is_success_parse then
        print("Parsing error: "..payload)
        sck:close()
        do return end
    end
    
    local response_body = ""
            
    if GLOBAL_CONSTANTS["FATAL_ERROR"] ~= nil then
        response_body = create_pair_with_string("Error", GLOBAL_CONSTANTS["FATAL_ERROR"])
    elseif url ~= nil then
        local success, error_string, result_string = pcall(loadfile("route.lua"), url)
        if not success then
            response_body = create_pair_with_string("Error", error_string)
        else
            if result_string ~= nil then
                response_body = result_string
            else
                response_body = create_pair_with_string("Error", "Invalid request")
            end
        end 
    else
        response_body = create_pair_with_string("Error", "Invalid request")
    end
    
    local response = response_header..response_body
    
    print(response)
    
    sck:send(response, sent_handler)
end

local timer_udp = tmr.create()

srv=net.createServer(net.TCP) 
if srv then 
    srv:listen(80,function(sck) 
        sck:on("receive", receive_handler)
	end)
end

udpSrv = net.createUDPSocket()
if udpSrv then
 print("Udp server: start")
 timer_udp:alarm(GLOBAL_CONSTANTS["UDP_SERVER_SETTINGS"]["INTERVAL"], tmr.ALARM_SEMI, function(current_timer)
    if GLOBAL_CONSTANTS["WIFI_STATE"] == "as_station" then
        local success, error_string, status_result = pcall(loadfile("route.lua"), "status")
        if success and status_result ~= nil then
            --the maximum size of a UDP packet is 65507 bytes       
            udpSrv:send(GLOBAL_CONSTANTS["UDP_SERVER_SETTINGS"]["PORT"], "255.255.255.255", status_result)
        else
            print("Udp route error: "..(error_string or "unknown error"))     
        end
    end
    current_timer:start()
 end)
 timer_udp:start()
end
