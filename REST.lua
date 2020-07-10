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
rest = {}
--Providing autocomplete
rest.head = function(url, requestHeader, methodOrOnLoad, onLoad)end
rest.get = function(url, requestHeader, onLoad)end
rest.post = function(url, requestHeader, data, onLoad)end
rest.put = function(url, requestHeader, data, onLoad)end
rest.patch = function(url, requestHeader, data, onLoad)end
rest.delete = function(url, requestHeader, data, onLoad)end
rest.retrieve = function(dt)end
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
    rest = require "rest-lib.js-rest"
elseif(OS == "Windows") then
    rest = require "rest-lib.win-rest"
else
    rest = require "rest-lib.default-rest"
end
if(rest.start ~= nil) then
    rest.start() 
    --Auto-destroy start for not causing any problem
    rest.start = nil
end


local function UPDATE(dt)
    return rest.retrieveFunction(dt)
end

rest.isDebug = true;
rest.retrieve = UPDATE;