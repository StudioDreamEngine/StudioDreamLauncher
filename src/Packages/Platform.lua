-- General cross-platform functions for random stuff
local ffi = require('ffi')

local C = ffi.C

local win_exec

if (love.system.getOS() == 'Windows') then
	-- Sorry and thank you https://github.com/NoxiousPluK/obs-call-webhook/blob/main/call_webhook.lua, I REALLY dont wanna touch ffi so i just had to steal this
	ffi.cdef [[
		typedef void* HANDLE;
		typedef int    BOOL;
		typedef struct {
			unsigned long  cb;
			char          *lpReserved, *lpDesktop, *lpTitle;
			unsigned long  dwX, dwY, dwXSize, dwYSize;
			unsigned long  dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags;
			unsigned short wShowWindow, cbReserved2;
			unsigned char *lpReserved2;
			HANDLE         hStdInput, hStdOutput, hStdError;
		} STARTUPINFOA;
		typedef struct {
			HANDLE hProcess, hThread;
			unsigned long dwProcessId, dwThreadId;
		} PROCESS_INFORMATION;
		BOOL CreateProcessA(
			const char *lpApplicationName, char *lpCommandLine,
			void *lpProcessAttributes, void *lpThreadAttributes,
			BOOL bInheritHandles, unsigned long dwCreationFlags,
			void *lpEnvironment, const char *lpCurrentDirectory,
			STARTUPINFOA *lpStartupInfo, PROCESS_INFORMATION *lpProcessInformation
		);
		BOOL CloseHandle(HANDLE hObject);
	]]
	
	win_exec = function(cmd)
		local si = ffi.new("STARTUPINFOA")
		si.cb = ffi.sizeof("STARTUPINFOA")
		local pi = ffi.new("PROCESS_INFORMATION")
		local buf = ffi.new("char[?]", #cmd + 1, cmd)
		local ok = ffi.C.CreateProcessA(nil, buf, nil, nil, false, 0, nil, nil, si, pi)
		if ok ~= 0 then
			ffi.C.CloseHandle(pi.hProcess)
			ffi.C.CloseHandle(pi.hThread)
		end
	end
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

function Platform.GetDesktop()
	return Platform.GetHome().."/Desktop/"
end

function Platform.FileExist(directory)
	return love.filesystem.getInfo(directory) and true or false
end

function Platform.GetExecutablePath()
    if love.filesystem.isFused() then
        return love.filesystem.getSource()
    end

    return nil
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
		win_exec(Path)
	else
		a = C.execv(Path, nil)
	end
end

return Platform