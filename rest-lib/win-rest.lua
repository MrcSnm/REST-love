if(requireFromLib == nil) then
    require "lib.REST-love.module-loader"
end

local req = requireFromLib("luajit-request", "luajit-request")

love.filesystem.createDirectory("os")
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
--@Shared Function
--This function is redefined on Thread, so it need to be mantained here and on the thread
local function _WIN_REST(url, method, headers, data)
    local tab = {}
    local isHead = (data == "HEAD")
    if(headers == nil) then
        headers = {}
    end
    if(not isHead and data) then
        tab.data = data
    end
    tab.method = method
    if(headers["Content-Type"] == nil) then
        headers["Content-Type"] = "application/json"
    end
    tab.headers = headers
    local resp = req.send(url, tab)
    if(isHead) then
        return resp.raw_headers
    else
        return resp.body
    end
end

local function start()
    
    thread = love.thread.newThread(
        [[
            require "lib.REST-love.module-loader"

            local req = requireFromLib("lib/REST-love/luajit-request", "luajit-request")


            local function _WIN_REST(url, method, headers, data)
                local tab = {}
                local isHead = (data == "HEAD")
                if(headers == nil) then
                    headers = {}
                end
                if(not isHead and data) then
                    tab.data = data
                end
                tab.method = method
                if(headers["Content-Type"] == nil) then
                    headers["Content-Type"] = "application/json"
                end
                tab.headers = headers
                local resp = req.send(url, tab)
                if(isHead) then
                    return resp.raw_headers
                else
                    return resp.body
                end
            end

            local command = ""
            local input = love.thread.getChannel("REST_INPUT")
            local output = love.thread.getChannel("REST_OUTPUT")

            while true do
                command = input:demand()
                if(command == "REST_EXIT") then
                    return
                elseif(command ~= nil and command ~= "nil") then
                    local url = command
                    local method = input:demand()
                    local header = input:demand()
                    local data = input:demand()
                    local out = _WIN_REST(url, method, header, data)
                    output:push(out)
                    output:push(tostring(input:demand()))
                end
            end
        ]])
    thread:start()

    inputChannel = love.thread.getChannel("REST_INPUT")
    outputChannel = love.thread.getChannel("REST_OUTPUT")
    local _quit = love.event.quit
    love.event.quit = function (str)
        inputChannel:push("REST_EXIT")
        _quit(str)
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

local function asyncOnLoad(url, method, header,data, onLoad)

    inputChannel:push(url)
    inputChannel:push(method)
    inputChannel:push(header)
    inputChannel:push(data)

    local request = _Request:new(onLoad)
    table.insert(requestQueue, request)
    inputChannel:push(tostring(request.id))
end

local function syncOnLoad(url, method, header, data, onLoad)
    onLoad(_WIN_REST(url, method, data, header))
    idNum = idNum + 1
end

local function prepareData(data)
    if(data == "HEAD")then return data end
    if(type(data) == "string") then
        return '"'..data..'"'
    elseif(type(data) == "table") then
        data = _TABLE_TO_JSON(data)
        data = data:sub(2, #data - 1)
    end
    return data
end

local function load(url, method, header, data, onLoad)
    if(data) then
        data = prepareData(data)
    end
    if(method == METHODS.PUT or method == METHODS.PATCH or method == METHODS.DELETE) then
        local nMethod = METHODS.POST
        if(header == nil) then
            header = {}
        end
        header["X-HTTP-Method-Override"] = method
        method = nMethod
    end
    if(sync) then
        syncOnLoad(url, method, header, data, onLoad)
    else
        asyncOnLoad(url, method, header, data, onLoad)
    end
end

local function head(url, requestHeader, meth, onLoad)  
    if(type(meth) == "function") then
        load(url, "GET",  requestHeader, METHODS.HEAD,  meth)
    elseif(meth == nil) then
        load(url, "GET",  requestHeader, METHODS.HEAD,  onLoad)
    else
        load(url, meth,  requestHeader, METHODS.HEAD,  onLoad)
    end
end
local function get(url, requestHeader, onLoad)         load(url, METHODS.GET,   requestHeader, nil,  onLoad)end
local function post(url, requestHeader, data, onLoad)  load(url, METHODS.POST,  requestHeader, data, onLoad)end
local function put(url, requestHeader, data, onLoad)   load(url, METHODS.PUT,   requestHeader, data, onLoad)end
local function patch(url, requestHeader, data, onLoad) load(url, METHODS.PATCH, requestHeader, data, onLoad)end
local function delete(url, requestHeader, onLoad)load(url, METHODS.DELETE,requestHeader, nil, onLoad)end

return{
    head = head;
    get = get;
    post = post;
    put = put;
    patch = patch;
    delete = delete;
    retrieveFunction = retrieveData;
    start = start;
}