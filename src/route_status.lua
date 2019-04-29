local now_time = tmr.time()
local result = {}
result[#result + 1] = "{\"status\":"
result[#result + 1] = "{"
result[#result + 1] = "\"device_id\" : "..GLOBAL_CONSTANTS["SETTINGS"]["device_id"]..","
result[#result + 1] = "\"device_type\" : \""..GLOBAL_CONSTANTS["SETTINGS"]["device_type"].."\","
result[#result + 1] = "\"device_name\" : \""..GLOBAL_CONSTANTS["SETTINGS"]["device_name"].."\","
result[#result + 1] = " \"relays\" : ["
for _, pinout in ipairs(GLOBAL_CONSTANTS["OUTPUT_PIN"]) do
	result[#result + 1] = "{\"id\" : "..pinout..","
	result[#result + 1] = "\"status\" : "..gpio.read(pinout)..","
	result[#result + 1] = "\"name\" : \""..(GLOBAL_CONSTANTS["OUTPUT_PIN_NAMES"][pinout] or "").."\"}" 
	result[#result + 1] = ","
end
result[#result] = "],"
result[#result + 1] = "\"uptime\":"..now_time..","
result[#result + 1] = "\"heap\":"..node.heap()..","

result[#result + 1] = "\"wifi_info\":{"
	if GLOBAL_CONSTANTS["WIFI_STATE"] == "as_station" then
    	result[#result + 1] = "\"connection_timepoint\":"..(now_time - GLOBAL_CONSTANTS["WIFI_INFO"]["CONNECTION_TIMEPOINT"])..","
		result[#result + 1] = "\"rssi\":"..wifi.sta.getrssi()..","
	end
	result[#result + 1] = "\"reconnect_count\" :"..GLOBAL_CONSTANTS["WIFI_INFO"]["RECONNECT_COUNT"]
	result[#result + 1] = ","

	if GLOBAL_CONSTANTS["WIFI_INFO"]["LAST_REASON_RECONNECTION"] ~= nil then
		result[#result + 1] = "\"last_reason_reconnection\":\""..GLOBAL_CONSTANTS["WIFI_INFO"]["LAST_REASON_RECONNECTION"].."\""
		result[#result + 1] = ","
	end
result[#result] = "},"

result[#result + 1] = "\"gpio_info\":{"
	result[#result + 1] = "\"last_change\":\""..GLOBAL_CONSTANTS["GPIO_INFO"]["OUTPUT_LAST_CHANGE"].."\""
result[#result + 1] = "}"

--end status
result[#result + 1] = "}}"
return table.concat(result)
