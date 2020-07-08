require "module-loader"
local _hasOsSupport = os.execute("echo 'Checking if has OS Support'") == 0
if(_hasOsSupport) then
    love.filesystem.createDirectory("os")
end

local OS = love.system.getOS()
if(OS == "Web") then
    requireFromLib("js", "js")
elseif(OS == "Windows") then
    
end

local dir = love.filesystem.getSaveDirectory().."/os/"
local fileBuffer = "os/buffer.txt"

local function getOsExecResult(execCommand)
    os.execute(execCommand.." >> "..dir.."buffer.txt")
    local ret = love.filesystem.read(fileBuffer)
    love.filesystem.remove(fileBuffer)
    return ret
end

local _hasCurlSupport = os.execute("curl --help") == 0

local function _sanitizeServerPort(server, port)
    if(port) then
        port = ":"..port
    else
        port = ""
    end
    return server, port
end


local function _prepareDataSend(data, isRecursive)
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
              nData = nData..'"'..key..'"'..' : '.._prepareDataSend(value, true)
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


local function get(server, port)
    if(not _hasCurlSupport) then return end
    server,port = _sanitizeServerPort(server, port)
    return getOsExecResult("curl "..server..port)
end

local function post(server, port, data)
    if(not _hasCurlSupport) then return end
    server, port = _sanitizeServerPort(server, port)
    data = _prepareDataSend(data)
    return getOsExecResult("curl -X POST -d "..data.." '"..server..port.."'")
end

local function put(server, port, data)
    if(not _hasCurlSupport) then return end
    server, port = _sanitizeServerPort(server, port)
    data = _prepareDataSend(data)
    return getOsExecResult("curl -X PUT -d "..data.." '"..server..port.."'")
end

local function patch(server, port, data)
    if(not _hasCurlSupport) then return end
    server, port = _sanitizeServerPort(server, port)
    data = _prepareDataSend(data)
    return getOsExecResult("curl -X PATCH -d "..data.." '"..server..port.."'")
end

local function delete(server, port, data)
    if(not _hasCurlSupport) then return end
    server, port = _sanitizeServerPort(server, port)
    data = _prepareDataSend(data)
    return getOsExecResult("curl -X DELETE -d "..data.." '"..server..port.."'")
end


local function upload(server, port, data)
    if(not _hasCurlSupport) then return end

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
    curl =
    {
        hasSupport = _hasCurlSupport,
        post = post,
        get = get,
        put = put,
        patch = patch,
        delete = delete
    }
}