local Stages = {}

--[[
    if timer <= 0 and not launch and not needsDownload and not extract and not path then
        Platform.ExecuteAndReplace(Platform.GetDocuments() .. '/' .. execFile)
        love.event.quit()
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
        neededDown = true
        downloadFile("https://github.com/StudioDreamEngine/StudioDream/releases/download/" .. latest .. '/' .. file, Platform.GetDocuments() .. '/StudioDream' .. ext)
        NativeFS.write(Platform.GetDocuments() .. '/version', latest)
        text = 'Downloaded'
        if os == 'Windows' then
            extract = true
        else path = true end
    end

]]

local NeedsUpgrade = false
local CurrentVersion

local SavePath = love.filesystem.getSaveDirectory().."/"

local FileNames = {
    Windows = "StudioDream-Windows.zip",
    Linux = "StudioDream-Linux.AppImage"
}
local FileName = FileNames[love.system.getOS()]

function Stages.Checks(_)
    local InstalledVersion = Util.Read("version")
    local Success, Data = Util.GetData("https://api.github.com/repos/StudioDreamEngine/StudioDream/releases/latest", true)

    if (not Success) or (not Data) then
        return false, "Failed to get latest"
    end

    CurrentVersion = Data.name

    if CurrentVersion ~= InstalledVersion or (not Util.Read(FileName)) then
        NeedsUpgrade = true
    end

    return true, {
        Delay = 0,
        NextStage = "DownloadThumb",
        Text = "Downloading Assets",
        Data = {
            Ver = CurrentVersion,
            Message = "Getting StudioDream (Be Patient!)"
        }
    }
end

function Stages.DownloadThumb(Data)
    if (not NeedsUpgrade) then
        return true, {
            Delay = 0,
            NextStage = "Execute"
        }
    end

    local Success, Thumbnail = Util.GetData("https://raw.githubusercontent.com/StudioDreamEngine/StudioDream/main/src/Assets/Thumbnails/Latest.png")

    if Success then
        Util.Write("Latest.png", Thumbnail)
        Content.thumb = love.graphics.newImage("Latest.png")
        Content.thumbtime = love.timer.getTime()
    else
        print("Thumbnail failed to download, oh well!")
    end

    return true, {
        Delay = .5,
        NextStage = "Download",
        Text = Data.Message,
        Data = Data.Ver
    }
end

function Stages.Download(Data)
    local Success, Downloaded = Util.GetData("https://github.com/StudioDreamEngine/StudioDream/releases/download/"..Data.."/"..FileName)

    if (not Success) then
        return false, "Failed to download StudioDream"
    end

    Util.Write(FileName, Downloaded)
    Util.Write("version", CurrentVersion)

    return true, {
        NextStage = "Execute",
        Text = "Figuring things out"
    }
end

function Stages.Execute()
    return true, {
        Delay = .5,
        NextStage = Platform.IsWindows and "ExecuteExe" or "ExecuteAppimage",
        Text = "Extracting & Executing"
    }
end

-- Linux
function Stages.ExecuteAppimage()
    local AppImagePath = SavePath..FileName

    os.execute("chmod +x "..AppImagePath)
    Platform.ExecuteAndReplace(AppImagePath)

    return true, {
        NextStage = "Halt"
    }
end

-- Windows
function Stages.ExecuteExe()
    if NeedsUpgrade then -- Extract zip
        ZIP.extractZIP(FileName, "StudioDream/")
    end

    Platform.ExecuteAndReplace(SavePath.."StudioDream/StudioDream.exe")
end

function Stages.Halt(_)
    love.event.quit()
end

return Stages