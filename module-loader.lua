local _defaultCPath = love.filesystem.getCRequirePath()
local _defaultLPath = love.filesystem.getRequirePath()

local function setReqPath(path)
    love.filesystem.setCRequirePath(path.."/??")
    love.filesystem.setRequirePath(path.."/?.lua;?/init.lua")
end
local function restorePath()
    love.filesystem.setCRequirePath(_defaultCPath)
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
    print(love.filesystem.getRequirePath())
    print(_defaultLPath)

    local ret = require(fileName)
    restorePath()
    return ret
end