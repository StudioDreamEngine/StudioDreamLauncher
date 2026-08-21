-- Packages
local ffi = require "ffi"
require('Packages.LuauPolyfill')

NativeFS    = require('Packages.nativefs')
Platform    = require('Packages.Platform')
HTTPS       = require('https')
JSON        = require('Packages.json')
ZIP         = require("Packages.ExtractZip")
ShortcutMaker = require("Packages.ShortcutMaker")

local content = {}
local text = 'Loading'

local LETHIMDRAW = true
local needsDownload = false
local latest = '0.6'
local ext = '.AppImage'
local file = 'StudioDream-'
local execFile = 'StudioDream-Linux.AppImage'
local os = 'Linux'
local launch = true
local extract = false
local path = false
local ExePath = nil
local timer = 0


local function getData(from, headers)
    print(from)
    local code, body, header = HTTPS.request(from, {headers=headers})
    print("CODE", code)
    print("HEADER", header)
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

    local body = getData('https://api.github.com/repos/StudioDreamEngine/StudioDream/releases/latest', {["User-Agent"]="StudioDreamLauncher"})
    print("BODY", body)
    latest = JSON.decode(body).name
    print(latest)
    
    os = love.system.getOS()
    
    ext = os == 'Windows' and '.zip' or '.AppImage'
    file = 'StudioDream-' .. love.system.getOS() .. ext
    execFile = os == 'Windows' and 'StudioDream/StudioDream.exe' or 'StudioDream.AppImage'

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
    if not table.find(NativeFS.getDirectoryItems(Platform.GetDesktop()), "Studio Dream.url") then
        print("DIDNT FOUND THE SHORTCUT")
        path = true
        launch = false
    end
end

function love.update(dt)
    timer = timer - dt

    if needsDownload then text = 'Downloading...' end
    if extract then text = 'Extracting...' end
    if launch then text = 'Launching...' end
    if path then text = 'Creating Path...' end

    if timer <= 0 and not launch and not needsDownload and not extract and not path then
        --[[print(Platform.GetDocuments())
        print(execFile)
        print(Platform.GetDocuments() .. '/' .. execFile)]]
        Platform.ExecuteAndReplace(Platform.GetDocuments() .. '/' .. execFile)
        love.event.quit()
    end

    if LETHIMDRAW then
        LETHIMDRAW = false
        return
    end

    if launch then
        launch = false
        timer = 2
    end

    if extract then
        extract = false
        print('extracting')
        if os == "Windows" then
            
            ZIP.extractZIP(Platform.GetDocuments() .. "/StudioDream.zip",Platform.GetDocuments(),true)
        end
        --os.execute("powershell.exe -nologo -noprofile -command \"& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('StudioDream-Windows.zip', 'StudioDream'); }\"")
        text = 'Extracted'
        path = true
    end

    if needsDownload then
        needsDownload = false
        downloadFile("https://github.com/StudioDreamEngine/StudioDream/releases/download/" .. latest .. '/' .. file, Platform.GetDocuments() .. '/StudioDream' .. ext)
        NativeFS.write(Platform.GetDocuments() .. '/version', latest)
        text = 'Downloaded'
        if os == 'Windows' then
            extract = true
        else path = true end
    end

    if path then
        path = false
        if not Platform.FileExist(Platform.GetDesktop() .. "Studio Dream Launcher.url") then
            print("Creating path...")
            ExePath = Platform.GetExecutablePath()--os == "Windows" and Platform.GetDocuments() .. "/StudioDream/StudioDream.exe" or Platform.GetDocuments() .. "/StudioDream.AppImage"
            if not ExePath then
                ExePath = os == "Windows" and Platform.GetDocuments() .. "/StudioDream/StudioDream.exe" or Platform.GetDocuments() .. "/StudioDream.AppImage"
            end
            ShortcutMaker.Create(ExePath,"Studio Dream Launcher")
        end
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
    love.graphics.printf(text, 0, 460, 1920/2, "right")

   --[[ love.graphics.setFont(content.roboto)
    love.graphics.printf("Created by: Dream Team", 0, 480, 1920/2, "left",0,0.5)]]
end