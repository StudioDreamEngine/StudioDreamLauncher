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
HTTPS = require('https')

local content = {}
local text = 'Loading'

local LETHIMDRAW = true
local needsDownload = false
local latest = '0.6'
local ext = '.AppImage'
local file = 'StudioDream-'
local os = 'Linux'
local launch = true
local timer = 0


local function getData(from)
    print(from)
    local code, body, header = HTTPS.request(from)
    print(code, header)
    if not body then error(code) end

    return body
end

local function downloadFile(from, filename)
    local body = getData(from)

    local f = assert(io.open(filename, 'wb'))
    f:write(body)
    f:close()
end

function love.load()
    content.icon    = love.image.newImageData("Assets/icon.png")
    content.thumb   = love.graphics.newImage("Assets/thumb.png")
    content.roboto  = love.graphics.newFont("Assets/Fonts/Roboto/Roboto-Bold.ttf", 50)
    content.bar     = love.graphics.newImage("Assets/bar.png")

    love.window.setIcon(content.icon)
    
    Platform.Init("StudioDreamLauncher")

    latest = getData('https://raw.githubusercontent.com/StudioDreamEngine/StudioDream/refs/heads/main/latest')
    print(latest)
    
    os = love.system.getOS()
    
    ext = os == 'Windows' and '.zip' or '.AppImage'
    file = 'StudioDream-' .. love.system.getOS() .. ext

    if not table.find(NativeFS.getDirectoryItems(Platform.GetDocuments()), os == 'Windows' and 'StudioDream' or 'StudioDream.AppImage') then
        print("needs download")
        needsDownload = true
        launch = false
    else
        local version = NativeFS.read(Platform.GetDocuments() .. '/version')
        if version ~= latest then
            print('out of date')
            needsDownload = true
            launch = false
        end
    end
end

function love.update(dt)
    timer = timer - dt

    if needsDownload then text = 'Downloading...' end
    if launch then text = 'Launching...' end

    if timer <= 0 and not launch and not needsDownload then
<<<<<<< HEAD
        love.event.quit()
=======
        
        print("Exec and replace")
        print(Platform.GetDocuments() .. '/StudioDream' .. ext)
        Platform.ExecuteAndReplace(Platform.GetDocuments() .. '/StudioDream' .. ext)
        --love.system.openURL(Platform.GetDocuments() .. '/StudioDream' .. ext)
        --os.execute(Platform.GetDocuments() .. '/StudioDream' .. ext)
        --love.event.quit()
>>>>>>> b34e40bb6aae4bed522acf9e9e9f8bcbdb848a66
    end

    if LETHIMDRAW then
        LETHIMDRAW = false
        return
    end

    if launch then
        launch = false
        text = 'Launched'
        timer = 2
    end

    if needsDownload then
        needsDownload = false
        downloadFile("https://github.com/StudioDreamEngine/StudioDream/releases/download/" .. latest .. '/' .. file, Platform.GetDocuments() .. '/StudioDream' .. ext)
        NativeFS.write(Platform.GetDocuments() .. '/version', latest)
        text = 'Downloaded'
        launch = true
    end


    LETHIMDRAW = true
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