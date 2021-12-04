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

local pathStack = {}

local _defaultLPath = love.filesystem.getRequirePath()
local _lastLPath = _defaultLPath
local _lastCPath = _defaultCPath

local function setReqPath(path)
    table.insert(pathStack, path);
    path = table.concat(pathStack, "/");
    _lastLPath = path


    if(os ~= "Web") then
        love.filesystem.setCRequirePath(path.."/??;??")
    end
    love.filesystem.setRequirePath(path.."/?.lua;"..path.."/?/init.lua;?.lua;?/init.lua")
end
local function restorePath()
    local newPath;
    if(#pathStack > 0) then
        table.remove(pathStack, #pathStack)
    end
    if(pathStack ~= 0) then
        newPath = table.concat(pathStack, "/")
    else
        newPath = _defaultLPath
    end


    if(os ~= "Web") then
        love.filesystem.setCRequirePath(_defaultCPath)
    end
    love.filesystem.setRequirePath(newPath)
end

function loadFromLib(libsPath, ...)
    setReqPath(libsPath)
    for _, files in ipairs({...}) do
        require(files)
    end
    restorePath()
end

--- Used only for the threaded REST
function sendCurrentReqPath(channel)
    channel:supply(_lastLPath)
    channel:supply(_lastCPath)
end

--- Used only for the threaded REST
function setCurrentReqPath(channel)
    -- print("Now waiting for messages")
    _lastLPath = channel:demand()
    _lastCPath = channel:demand()
    setReqPath(_lastLPath)
    -- print("Received from main ".._lastLPath)
end

function requireFromLib(libPath, fileName)
    setReqPath(libPath)
    local ret = require(fileName)
    restorePath()
    return ret
end