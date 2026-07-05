-- CLibraries
local CurrentOS = love.system.getOS()

local Extensions = {
    Linux = "so",
    Windows = "dll"
}

package.cpath = package.cpath..";./CLibraries/"..string.lower(CurrentOS).."/?."..Extensions[CurrentOS]

-- Packages

require('Packages.LuauPolyfill')
NativeFS = require('Packages.nativefs')
Platform = require('Packages.Platform')

local content = {}
local text = 'Loading'

function love.load()
    content.icon    = love.image.newImageData("Assets/icon.png")
    content.thumb   = love.graphics.newImage("Assets/thumb.png")
    content.roboto  = love.graphics.newFont("Assets/Fonts/Roboto/Roboto-Regular.ttf", 50)
    content.bar     = love.graphics.newImage("Assets/bar.png")

    love.window.setIcon(content.icon)
    
    Platform.Init("StudioDreamLauncher")
end

function love.update(dt)
    
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()
    love.graphics.scale(0.5, 0.5)
    love.graphics.draw(content.thumb)
    love.graphics.pop()
    love.graphics.draw(content.bar, 0, 440)
    --love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(content.roboto)
    love.graphics.printf(text, 0, 475, 1920/2, "center")
end