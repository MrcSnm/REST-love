local _hasOsSupport = os.execute("echo 'Checking if has OS Support'") == 0
if(_hasOsSupport) then
    love.filesystem.createDirectory("os")
end
local _curl = os.execute("curl")
local _hasCurlSupport = (_curl == 0 or _curl == 256 or _curl == 512 or _curl == 2 or _curl == 1) --Common accepted return codes
local dir = love.filesystem.getSaveDirectory().."/os/"
local fileBuffer = "os/buffer.txt"

local requestQueue = {}
local thread = nil
local inputChannel = nil
local outputChannel = nil

local sync = false

local idNum = 0

local _Request =
{
    onLoad = nil;
    id = "";
    new = function (self, onLoad)
        local obj = setmetatable({}, self)
        self.__index = self
        obj.onLoad = onLoad
        obj.id = tostring(idNum)
        idNum = idNum + 1
        return obj
    end
}

local function start()
    thread = love.thread.newThread(string.format(
        [[
            local command = ""
            local input = love.thread.getChannel("REST_INPUT")
            local output = love.thread.getChannel("REST_OUTPUT")
            while true do
                command = input:pop()
                if(command == "REST_EXIT") then
                    return
                elseif(command ~= nil and command ~= "nil") then
                    os.execute(command)
                    local data = love.filesystem.read("%s")
                    love.filesystem.remove("%s")
                    output:push(data)
                    output:push(tostring(input:pop()))
                end

            end
        ]], fileBuffer, fileBuffer)
    )
    thread:start()
    inputChannel = love.thread.getChannel("REST_INPUT")
    outputChannel = love.thread.getChannel("REST_OUTPUT")
    local _quit = love.event.quit
    love.event.quit = function ()
        inputChannel:push("REST_EXIT")
        _quit()
    end
end

local function retrieveData()
    local isRetrieving = #requestQueue ~= 0
    local data = outputChannel:pop()
    
    while(data ~= nil) do
        local id = outputChannel:pop()
        requestQueue[1].onLoad(data, id)
        table.remove(requestQueue, 1)
        data = outputChannel:pop()
    end

    return isRetrieving
end

local function generateOutputCommand(strCommand)
    return strCommand.." >> "..dir.."buffer.txt"
end

local function asyncOnLoad(strCommand, onLoad)
    inputChannel:push(generateOutputCommand(strCommand))
    local request = _Request:new(onLoad)
    table.insert(requestQueue, request)
    inputChannel:push(tostring(request.id))
end

local function syncOnLoad(strCommand, onLoad)
    os.execute(generateOutputCommand(strCommand))
    local data = love.filesystem.read(fileBuffer)
    love.filesystem.remove(fileBuffer)
    onLoad(data)
    idNum = idNum + 1
end

local function load(strCommand, onLoad)
    if(sync) then
        syncOnLoad(strCommand, onLoad)
    else
        asyncOnLoad(strCommand, onLoad)
    end
end

local function generateHeader(tbHeader)
    local header = ""
    if tbHeader == nil then return header end
    for key, value in pairs(tbHeader) do
        header = header..'-H "'..key..': '..value..'" '
    end
    return header
end

local function head(url, method, requestHeader, onLoad)
    if(not _hasCurlSupport) then return end
    load("curl -X "..method.." -I "..generateHeader(requestHeader)..url, onLoad)
end

local function get(url, requestHeader, onLoad)
    if(not _hasCurlSupport) then return end
    load("curl "..generateHeader(requestHeader)..url, onLoad)
end

local function post(url, requestHeader, data, onLoad)
    if(not _hasCurlSupport) then return end
    data = _TABLE_TO_JSON(data)
    load("curl "..generateHeader(requestHeader).." -X POST -d "..data.." '"..url.."'", onLoad)
end

local function put(url, requestHeader, data, onLoad)
    if(not _hasCurlSupport) then return end
    data = _TABLE_TO_JSON(data)
    load("curl "..generateHeader(requestHeader).." -X PUT -d "..data.." '"..url.."'", onLoad)
end

local function patch(url, requestHeader, data, onLoad)
    if(not _hasCurlSupport) then return end
    data = _TABLE_TO_JSON(data)
    load("curl "..generateHeader(requestHeader).. " -X PATCH -d "..data.." '"..url.."'", onLoad)
end

local function delete(url, requestHeader, data, onLoad)
    if(not _hasCurlSupport) then return end
    data = _TABLE_TO_JSON(data)
    load("curl "..generateHeader(requestHeader).. " -X DELETE -d "..data.." '"..url.."'", onLoad)
end

return{
    method = method;
    get = get;
    post = post;
    put = put;
    patch = patch;
    delete = delete;
    retrieveFunction = retrieveData;
    start = start;
}