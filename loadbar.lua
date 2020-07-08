require 'asyncloader'

LoadBar = 
{
    x = 0;
    y = 0;
    width = 0;
    height = 0;
    progress = 0;
    hasRenderedFirstFrame = false;
    frontTexture = nil;
    backTexture = nil;
}

function LoadBar:new(width, height, frontTexture, backTexture)
    local obj = setmetatable({}, self)
    self.__index = self
    obj.width = width
    obj.height = height
    obj.frontTexture = frontTexture or nil
    obj.backTexture = backTexture or nil
    return obj
end

function LoadBar:setPosition(x, y)
    self.x=x
    self.y=y
end


--If content name has a $, it will be substituted for the current progress
function LoadBar:addContentToLoad(loadFunction, onLoad, contentName)
    asyncLoader.loadFunc(loadFunction, onLoad, contentName)
end

function LoadBar:startLoading(onResourcesLoaded)
    local _self = self
    asyncLoader.startLoading(function()
        _self.hasRenderedFirstFrame = false
        onResourcesLoaded()
    end)
end

function LoadBar:update(dt)
    if(self.hasRenderedFirstFrame) then
        asyncLoader.update(dt)
    end
end

function LoadBar:render()
    if(not asyncLoader.hasStarted)then 
        return 
    else
        self.hasRenderedFirstFrame = true
    end
    self.progress = asyncLoader.progress
    love.graphics.clear()
    if self.backTexture then
        love.graphics.draw(self.backTexture, self.x, self.y, 0, self.width / self.backTexture:getWidth(), self.backTexture:getHeight())
    else
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end
    if self.frontTexture then
        love.graphics.draw(self.frontTexture, self.x, self.y, 0, self.width * self.progress, self.backTexture:getHeight())
    else
        love.graphics.setColor(0.2,0.8,0.2,1)
        love.graphics.rectangle('fill', self.x, self.y, self.width * self.progress, self.height)
    end

    if(asyncLoader.currentContent ~= "") then
        love.graphics.setColor(1,1,1,1)
        if(asyncLoader.currentContent:match("%$")) then
            local indexS = string.find(asyncLoader.currentContent, "%$")
            local toPrint = string.sub(asyncLoader.currentContent, 1, indexS - 1)
            toPrint = toPrint..tostring(self.progress*100).."%"..asyncLoader.currentContent:sub(indexS + 1)
            love.graphics.printf("Loading: "..toPrint, self.x, self.y-40, self.width,"center")
        else
            love.graphics.printf("Loading: "..asyncLoader.currentContent, self.x, self.y-40, self.width,"center")
        end
    end
end

