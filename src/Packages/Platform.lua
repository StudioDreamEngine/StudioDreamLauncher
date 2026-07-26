-- General cross-platform functions for random stuff
local ffi = require('ffi')

local C = ffi.C

if (love.system.getOS() == 'Windows') then
	ffi.cdef([[
		int _execv( const char *cmdname, const char *const *argv );
	]])
else
	-- POSIX standard functions that should work on all OS'es (Android, Linux, MacOS, Windows) assuming microsoft decides to not be different for once
	ffi.cdef([[
		int execv(char const* path, const char* argv[]);
	]])
end

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

-- bloctans is stupid he says
function Platform.ExecuteAndReplace(Path)
	local a

	if Platform.IsWindows then
		a = C._execv(Path, nil)
	else
		a = C.execv(Path, nil)
	end

	print(a)
end

return Platform