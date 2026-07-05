local content = {}

function love.load()
    content.thumb = love.graphics.newImage("Assets/thumb.png")
    content.roboto = love.graphics.newFont("Assets/Fonts/Roboto/Roboto-Regular.ttf", 128)
end

function love.update(dt)
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()
    love.graphics.scale(0.5, 0.5)
    love.graphics.draw(content.thumb)
    love.graphics.pop()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(content.roboto)
    love.graphics.print("Hello", 0, 0)
end