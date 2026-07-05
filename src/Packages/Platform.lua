-- General cross-platform functions for random stuff
local ffi = require('ffi')

local C = ffi.C

ffi.cdef[[
    char * tinyfd_openFileDialog(
	char const * aTitle, /* NULL or "" */
	char const * aDefaultPathAndOrFile, /* NULL or "" , ends with / to set only a directory */
	int aNumOfFilterPatterns , /* 0 (2 in the following example) */
	char const * const * aFilterPatterns, /* NULL or char const * lFilterPatterns[2]={"*.png","*.jpg"}; */
	char const * aSingleFilterDescription, /* NULL or "image files" */
	int aAllowMultipleSelects ) ;

	char const * tinyfd_selectFolderDialog (
	char const * const aTitle ,
	char const * const aDefaultPath ) ;
]]

-- POSIX standard functions that should work on all OS'es (Android, Linux, MacOS, Windows) assuming microsoft decides to not be different for once
ffi.cdef([[
    int execv(char const* path, const char* argv[]);
]])

local Platform = {}
Platform.Identity = "Unnamed"

function Platform.GetHome()
	return love.filesystem.getUserDirectory()
end

function Platform.GetDocuments()
	return Platform.GetHome().."/Documents/"..Platform.Identity
end

function Platform.ParsePath(Path)
	local FullPath = NativeFS.getFullPath(Path)
    local LastChar = string.sub(FullPath, -1, -1)

    print("Mounting new project, Non-formatted full path: "..FullPath)
    
    if LastChar ~= "/" and LastChar ~= "\\" then
        if love.system.getOS() == 'Windows' then
            FullPath = FullPath.."\\"
        else
            FullPath = FullPath.."/"
        end

        print("FullPath Doesnt seem to have a trailing slash")
        print("Formatted Mount Point: "..FullPath)
    end

	return FullPath
end

function Platform.Init(Identity)
	Platform.IsWindows = (love.system.getOS() == 'Windows')
	Platform.Identity = Identity

	if (not NativeFS) then error("Platform requires NativeFS Package!") end

	local DocumentsFolder = Platform.GetDocuments()

	if (not NativeFS.getInfo(DocumentsFolder)) then
		print("Attempt to create documents folder")
		NativeFS.createDirectory(DocumentsFolder)
	end
end

function Platform.Execute(...)
	local Args = table.pack(...)

	-- we REALLY shouldnt be doing this, but exec force closes the program
	os.execute(table.concat(Args, " "))

	--[[local Args = table.pack(...)
	local ArgsProcessed = {}

	for i, v in pairs(Args) do
		if i ~= "n" then
			table.insert(ArgsProcessed, tostring(v))
		end
	end

	local ArgsC = ffi.new("const char*["..(Args.n+1).."]", ArgsProcessed)
	local a = C.execvp(ArgsC[0], ArgsC)]]
end

--[[
	Open a file or folder with a callback function

	Returns Callback result and path if sucessful, otherwise nothing
]]
function Platform.OpenWithCallback(Title, Type, Callback)
	local Path = Platform[Type](Title)

	if Path then
		return Callback(Path), Path
	else
		return
	end
end

-- bloctans is stupid he says
function Platform.ExecuteAndReplace(Path)
    local a = C.execv(Path, nil)
	print(a)
end

return Platform