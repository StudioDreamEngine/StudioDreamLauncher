local Extractor = {}
local NativeFS = require("Packages.nativefs")
local lfs = love.filesystem

local function enu(folder, saveDir)
    for _, v in ipairs(lfs.getDirectoryItems(folder)) do
        local src = folder .. "/" .. v
        local dst = saveDir .. "/" .. v

        if lfs.getInfo(src, "directory") then
            NativeFS.createDirectory(dst)
            enu(src, dst)
        else
            local data = lfs.read(src)
            NativeFS.write(dst, data)
        end
    end
end

function Extractor.extractZIP(file, dir, delete)
    dir = dir or ""

    if dir ~= "" then
		print("DIR INST NIL")
		dir = dir.."/StudioDream"
        NativeFS.createDirectory(dir)
    end

    local temp = tostring(math.random(1000, 2000))
    local success,err = lfs.mountFullPath(file, temp)

    if success then
        print("it worked")
        enu(temp, dir)
        lfs.unmountFullPath(file)
    else
        print("FAIL!!!! OPS!!")
    end

    if delete then
        NativeFS.remove(file)
    end
end


return Extractor