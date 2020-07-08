local LoadContent =
{
    loadFunc = nil,
    onLoad = nil,
    contentName = ""
}

function LoadContent.new(func, onLoad, contentName)
    local obj = setmetatable({}, LoadContent)
    obj.loadFunc = func
    obj.onLoad = onLoad or nil
    obj.contentName = contentName or ""
    return obj
end


local _coroutine = nil

asyncLoader =
{
    queue = {},
    resourcesLoaded = 0,
    progress = 0,
    currentContent = "",
    hasStarted = false
}

function asyncLoader.reset()
    asyncLoader.queue = {}
    asyncLoader.resourcesLoaded = 0
    asyncLoader.currentContent = ""
    asyncLoader.progress = 1
    asyncLoader.hasStarted = false
end


function asyncLoader.loadFunc(loadFunction, onLoad, contentName)
    table.insert(asyncLoader.queue, LoadContent.new(loadFunction, onLoad, contentName))
end

function asyncLoader.startLoading(onResourcesLoaded)
    asyncLoader.hasStarted = true
    asyncLoader.currentContent = asyncLoader.queue[1].contentName
    _coroutine = coroutine.create(function()
        for i, loadContent in ipairs(asyncLoader.queue) do
            loadContent.loadFunc()
            if(loadContent.onLoad) then loadContent.onLoad() end
            asyncLoader.resourcesLoaded = i
            if(i ~= #asyncLoader.queue) then
                asyncLoader.currentContent = asyncLoader.queue[i+1].contentName
            end
            asyncLoader.progress = asyncLoader.resourcesLoaded / #asyncLoader.queue
            coroutine.yield()
        end
        _coroutine = nil
        asyncLoader.reset()
        if(onResourcesLoaded) then onResourcesLoaded() end
    end)
end

function asyncLoader.update(dt)
    if (_coroutine) then
        coroutine.resume(_coroutine)
    end
end