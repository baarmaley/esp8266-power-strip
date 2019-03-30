local url = ...

if url == nil then
    do return end
end

if GLOBAL_CONSTANTS == nil then
    error("Run only after init.lua")
end

-- function utils

local success_result = "{\"Result:\": \"Ok\"}"

local check_pinout = function(pinout)
    if GLOBAL_CONSTANTS["has_value"](GLOBAL_CONSTANTS["OUTPUT_PIN"], tonumber(pinout)) == false then
        error("Pinout: "..pinout.." is not an output pin")
    end
end

local dofile_in_route_env = function(filename)
    local route_env = {
        success_result = success_result,
        check_pinout = check_pinout
    }
    local chunk = loadfile(filename)
    setmetatable(route_env, {__index = _G})
    setfenv(chunk, route_env)
    return chunk()
end

local check_settings_mode = function()
    if GLOBAL_CONSTANTS["SETUP_MODE"] then 
        error("Unavailable because setup mode is enabled")
    end
end

-- end function utils

local routing = {
    action = function(action)
        check_settings_mode() 
        return dofile_in_route_env("route_action.lua")[action]
    end,
    set = function(set)
        return dofile_in_route_env("route_set.lua")[set]
    end,
    status = function()
        return loadfile("route_status.lua")
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
