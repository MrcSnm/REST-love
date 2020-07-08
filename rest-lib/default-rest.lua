local _hasOsSupport = os.execute("echo 'Checking if has OS Support'") == 0
if(_hasOsSupport) then
    love.filesystem.createDirectory("os")
end

local _hasCurlSupport = os.execute("curl --help") == 0
local dir = love.filesystem.getSaveDirectory().."/os/"
local fileBuffer = "os/buffer.txt"

local function getOsExecResult(execCommand)
    os.execute(execCommand.." >> "..dir.."buffer.txt")
    local ret = love.filesystem.read(fileBuffer)
    love.filesystem.remove(fileBuffer)
    return ret
end


local function generateHeader(tbHeader)
    local header = ""
    if tbHeader == nil then return header end
    for key, value in pairs(tbHeader) do
        header = header..'-H "'..key..': '..value..'" '
    end
    return header
end

local function get(url, requestHeader)
    if(not _hasCurlSupport) then return end
    return getOsExecResult("curl "..generateHeader(requestHeader)..url)
end

local function post(url, requestHeader, data)
    if(not _hasCurlSupport) then return end
    data = _TABLE_TO_JSON(data)
    return getOsExecResult("curl "..generateHeader(requestHeader).." -X POST -d "..data.." '"..url.."'")
end

local function put(url, requestHeader, data)
    if(not _hasCurlSupport) then return end
    data = _TABLE_TO_JSON(data)
    return getOsExecResult("curl "..generateHeader(requestHeader).." -X PUT -d "..data.." '"..url.."'")
end

local function patch(url, requestHeader, data)
    if(not _hasCurlSupport) then return end
    data = _TABLE_TO_JSON(data)
    return getOsExecResult("curl "..generateHeader(requestHeader).. " -X PATCH -d "..data.." '"..url.."'")
end

local function delete(url, requestHeader, data)
    if(not _hasCurlSupport) then return end
    data = _TABLE_TO_JSON(data)
    return getOsExecResult("curl "..generateHeader(requestHeader).. " -X DELETE -d "..data.." '"..url.."'")
end

return{
    get = get;
    post = post;
    put = put;
    patch = patch;
    delete = delete;
}