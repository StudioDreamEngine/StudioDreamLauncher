local ShortcutMaker = {}

function ShortcutMaker.Create(Path,Name)
    local FilePath = Platform.GetDesktop() .. Name ..".url"

    local File = io.open(FilePath, "w")

    File:write("[InternetShortcut]\n")
    File:write("URL=file://" .. Path .. "\n")
    File:write("IconFile=" .. Path .. "\n")
    File:write("IconIndex=0\n")
    File:close()
    
    return true
end

return ShortcutMaker