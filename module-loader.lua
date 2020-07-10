local _defaultCPath = ""
local os = ""
if(love.system == nil) then
    os = "Thread"
else
    os = love.system.getOS()
end

if(os ~= "Web") then
    _defaultCPath = love.filesystem.getCRequirePath()
end
local _defaultLPath = love.filesystem.getRequirePath()

local function setReqPath(path)
    if(os ~= "Web") then
        love.filesystem.setCRequirePath(path.."/??;??")
    end
    love.filesystem.setRequirePath(path.."/?.lua;"..path.."/?/init.lua;?.lua;?/init.lua")
end
local function restorePath()
    if(os ~= "Web") then
        love.filesystem.setCRequirePath(_defaultCPath)
    end
    love.filesystem.setRequirePath(_defaultLPath)
end

function loadFromLib(libsPath, ...)
    setReqPath(libsPath)
    for _, files in ipairs(arg) do
        require(files)
    end
    restorePath()
end

function requireFromLib(libPath, fileName)
    setReqPath(libPath)
    local ret = require(fileName)
    restorePath()
    return ret
end