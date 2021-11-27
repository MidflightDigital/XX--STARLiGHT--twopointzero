--It turns out that past tertu fucked this function up.
--It has been fixed in StepMania 5.1 and later but this theme supports 5.0.12.
function ThemeManager:GetAbsolutePath(sPath, optional)
	local sFinPath = self:GetCurrentThemeDirectory().."/"..sPath
	if not optional then
		assert(FILEMAN:DoesFileExist(sFinPath), "the theme element "..sPath.." is missing")
	end
	return sFinPath
end

--the version of getenv/setenv exported by fallback is not actually the same as
--operations on the Env() table. however, it is advertised as being the same.
--these overrides make it actually the same.
function getenv(name)
	local env = GAMESTATE:Env()
	return env[name]
end

function setenv(name, value)
	local env = GAMESTATE:Env()
	env[name] = value
end

local aspectRatioSuffix = {
	[math.floor(10000*4/3)] = "4_3",
	[math.floor(10000*1/1)] = "4_3",
	[math.floor(10000*5/4)] = "4_3",
	[math.floor(10000*16/9)] = "16_9",
}

setmetatable(aspectRatioSuffix,{__index=function() return " standard" end})
local suffix = aspectRatioSuffix[math.floor(10000*PREFSMAN:GetPreference("DisplayAspectRatio"))]

function IsUsingWideScreen()
	if suffix == "4_3" then
		return false
	else
		return true
	end
end

SN3Debug = FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."debug.txt")
if SN3Debug then
	print("STARLIGHT debug mode is enabled.")
end


if not LoadModule then
	local moduleCache = setmetatable({}, {__mode="kv"})
	
	function LoadModule(modName, ...)
		if type(modName) ~= 'string' then
			error("LoadModule: invalid module name "..tostring(modName), 2)
		end
		local modCode = moduleCache[modName]
		if not modCode then
			local modPath = THEME:GetCurrentThemeDirectory().."Modules/"..modName
			
			if not FILEMAN:DoesFileExist(modPath) then
				--if we're on 5.0/5.1, there are no fallback modules, so just fail
				--if we're on 5.3, we won't be using this implementation!
				error("LoadModule: no module named "..modName, 2)
			end
			local err
			modCode, err = loadfile(modPath)
			if modCode then
				moduleCache[modName] = modCode
			else
				error(('LoadModule: loading module %s failed: %s'):format(modName, err))
			end
		end
		return modCode(...)
	end
	
end

local function obf(st)
	return base64decode(st)
end;

local function asdf()
	return _G[obf('VG9FbnVtU2hvcnRTdHJpbmc=')](_G[obf('R0FNRVNUQVRF')][obf('R2V0Q29pbk1vZGU=')](_G[obf('R0FNRVNUQVRF')]));
end;