local Util = {}

function Util.GetData(From, AsJson)
    print(From)
    local Code, Body, _ = HTTPS.request(From, { headers = {
        ["User-Agent"] = "StudioDreamLauncher"
    }})

    print(Code)

    if Code == 200 then
        return true, AsJson and JSON.decode(Body) or Body
    else
        return false, nil
    end
end

function Util.Write(Path, Data)
    love.filesystem.write(Path, Data)
end

function Util.Read(Path)
    return love.filesystem.read(Path)
end

return Util