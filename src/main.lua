---@diagnostic disable: cast-local-type
-- Configure CPath
local CurrentOS = love.system.getOS()

local Extensions = {
    Linux = "so",
    Windows = "dll"
}

package.cpath = package.cpath..";./CLibraries/"..string.lower(CurrentOS).."/?."..Extensions[CurrentOS]

-- Packages
require('Packages.LuauPolyfill')
POLYFILL_FLAGS = {
	Verbose = false, -- If verbose printing is enabled
	ExternalOutput = false,
	utf8 = false -- If you do not have a utf8 library, set this to false
}

NativeFS    = require('Packages.nativefs')
Platform    = require('Packages.Platform')
HTTPS       = require('https')
JSON        = require('Packages.json')
ZIP         = require("Packages.ExtractZip")
--ShortcutMaker = require("Packages.ShortcutMaker")

Util = require("Util")

Content = {}

GlobalTick = 0
local NextStart = 0.1

local Data = {}
local LauncherRoutine = require("LauncherRoutine")
local Text = "Checking Version..."
local CurrentStage = LauncherRoutine.Checks

function love.load()
    Content.bg      = love.graphics.newImage(Util.Read("Latest.png") and "Latest.png" or "Assets/base.png")
    Content.thumb   = nil
    Content.thumbtime = nil

    Content.icon    = love.image.newImageData("Assets/icon.png")
    Content.roboto  = love.graphics.newFont("Assets/Fonts/Roboto/Roboto-Bold.ttf", 50)
    Content.bar     = love.graphics.newImage("Assets/bar.png")

    love.window.setIcon(Content.icon)
    Platform.Init("StudioDreamLauncher")
end

local function UpdateState(Delay, NewText, NextStage)
    NextStart = love.timer.getTime() + (Delay or 0)
    Text = NewText or "Unknown Message"

    CurrentStage = LauncherRoutine[NextStage]
end

function love.update(dt)
    GlobalTick = love.timer.getTime()

    if (GlobalTick - NextStart) > 0 then
        local Success, Message = CurrentStage(Data)

        if (not Success) then
            UpdateState(2, Message, "Halt")
        else
            print(Message)
            UpdateState(Message.Delay, Message.Text, Message.NextStage)

            Data = Message.Data
        end
    end
end

function love.draw()
    local w,h = love.graphics.getDimensions()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Content.bg,0,0,0,w/Content.bg:getWidth(),h/Content.bg:getHeight())

    if Content.thumbtime then
        love.graphics.setColor(1, 1, 1, math.min((GlobalTick - Content.thumbtime) * 4, 1))
    end

    if Content.thumb then
        love.graphics.draw(Content.thumb,0,0,0,w/Content.thumb:getWidth(),h/Content.thumb:getHeight())
    end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(Content.bar, 0, 400)

    love.graphics.setFont(Content.roboto)
    love.graphics.printf(Text, 0, h-80, 880, "center")
end