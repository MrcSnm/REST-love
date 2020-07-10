require "REST"
function love.load()
    REST.get("https://example.com", nil, print)
end

function love.update()
    REST.retrieve(dt)
end