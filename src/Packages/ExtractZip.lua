local Extractor = {}
local NativeFS = require("Packages.nativefs")

local function enu(folder, saveDir)
    for _, v in ipairs(love.filesystem.getDirectoryItems(folder)) do
        local src = folder .. "/" .. v
        local dst = saveDir .. "/" .. v

        --if love.filesystem.getInfo(src, "directory") then
        --    NativeFS.createDirectory(dst)
        --    enu(src, dst)
        --else
        local data = love.filesystem.read(src)
        love.filesystem.write(dst, data)
        --end
    end
end

function Extractor.extractZIP(file, target)
    love.filesystem.createDirectory(target)

    local success,err = love.filesystem.mount(file, "Zip")

    if success then
        enu("Zip", target)
        love.filesystem.unmount("Zip")
    else
        print("FAIL!!!! OPS!!")
    end
end


return Extractor