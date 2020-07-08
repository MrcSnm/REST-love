require "module-loader"

local OS = love.system.getOS()
local rest = {}

function _TABLE_TO_JSON(data, isRecursive)
    if(type(data) == "table") then
        local nData = '{'
        if(not isRecursive) then
          nData = "\'"..nData
        end
        local isFirst = true
        for key, value in pairs(data) do
            if(isFirst) then
                isFirst = false
            else
                nData = nData..", "
            end
            if(type(value) == "table") then
              nData = nData..'"'..key..'"'..' : '.._TABLE_TO_JSON(value, true)
            else
              nData = nData..'"'..key..'"'..' : "'..value..'"'
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


function UPDATE(dt)
    if(love.system.getOS() == "Web") then
        return retrieveData(dt)
    else
        return false
    end
end

betterOs = 
{
    hasSupport = _hasOsSupport,
    outDir = dir,
    exec = getOsExecResult,
    isDebug = true,
    rest = rest
}