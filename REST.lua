require "module-loader"
METHODS =
{
    HEAD = "HEAD";
    GET = "GET";
    PUT = "PUT";
    DELETE = "DELETE";
    PATCH= "PATCH";
    POST= "POST";
}

local OS = love.system.getOS()
REST = {}
--Providing autocomplete
REST.head = function(url, requestHeader, methodOrOnLoad, onLoad)end
REST.get = function(url, requestHeader, onLoad)end
REST.post = function(url, requestHeader, data, onLoad)end
REST.put = function(url, requestHeader, data, onLoad)end
REST.patch = function(url, requestHeader, data, onLoad)end
REST.delete = function(url, requestHeader, data, onLoad)end
REST.retrieve = function(dt)end
--End autocomplete

--This was meant to make it compatible out-of-the-box with the rest of the world, not only Lua, so the decision was to make
--Arrays start by index 0
function _TABLE_TO_JSON(data, isRecursive)
    if(type(data) == "table") then
        local nData = '{'
        if(not isRecursive) then
          nData = "\'"..nData
        end
        local isFirst = true
        for key, value in pairs(data) do
            local k = key
            if(tonumber(k)) then k = tonumber(k) - 1; end
            if(isFirst) then
                isFirst = false
            else
                nData = nData..", "
            end
            if(type(value) == "table") then
              nData = nData..'"'..k..'"'..' : '.._TABLE_TO_JSON(value, true)
            elseif(tonumber(value) or type(value) == "boolean") then
              nData = nData..'"'..k..'"'..' : '..tostring(value)
            else
              nData = nData..'"'..k..'"'..' : "'..value..'"'
            end
        end
        nData = nData..'}'
        if(not isRecursive) then
          nData = nData.."\'"
        end
        data = nData
    end
    return data
end

if(OS == "Web") then
    requireFromLib("js", "js")
    REST = require "rest-lib.js-rest"
elseif(OS == "Windows") then
    REST = require "rest-lib.win-rest"
else
    REST = require "rest-lib.default-rest"
end
if(REST.start ~= nil) then
    REST.start() 
    --Auto-destroy start for not causing any problem
    REST.start = nil
end


local function UPDATE(dt)
    return REST.retrieveFunction(dt)
end

REST.isDebug = true;
REST.retrieve = UPDATE;