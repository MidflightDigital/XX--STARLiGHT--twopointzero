--the version of getenv/setenv exported by fallback is not actually the same as
--operations on the Env() table. however, it is advertised as being the same.
--these overrides make it actually the same.
function getenv(name)
	local env = GAMESTATE:Env()
	return env[name]
end

function math.average(t)
	local sum = 0
	for _,v in pairs(t) do -- Get the sum of all numbers in t
	  sum = sum + v
	end
	return sum / #t
end

function IsMeterDec(meter)
	if meter % 1 == 0 then
		return meter
	else
		return string.format("%.1f",meter)
	end
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

-- iterates over a numerically-indexed table (haystack) until a desired value (needle) is found
-- if found, return the index (number) of the desired value within the table
-- if not found, return nil
function FindInTable(needle, haystack)
	for i = 1, #haystack do
		if needle == haystack[i] then
			return i
		end
	end
	return nil
end

function VideoRenderer()

	-- opengl is a valid VideoRenderer for all platforms right now
	-- so start by assuming it is the only choice.
	-- If there is a method available to Lua to get available renderers
	-- from the engine, I haven't found it yet.
	local choices = { "opengl" }
	local values  = { "opengl" }

	-- Windows also has d3d as a VideoRenderer on SM 5.1, and SM 5.3
	-- features a modern OpenGL based backend (glad) on all supported
	-- platforms. The convention(?) there is to list both available
	-- backends in Preferences.ini, but only use the first
	local architecture = HOOKS:GetArchName():lower()
	if _VERSION == "Lua 5.3" then
		table.insert(choices, "glad")
		values = { "opengl,glad", "glad,opengl" }
	elseif architecture:match("windows") then
		table.insert(choices, "d3d")
		values = { "opengl,d3d", "d3d,opengl" }
	end

	return {
		Name = _VERSION == "Lua 5.3" and "VideoRendererSM5.3" or "VideoRenderer",
		Choices = choices,
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local pref = PREFSMAN:GetPreference("VideoRenderers")

			-- Multiple comma-delimited VideoRenderers may be listed, but
			-- we only want the first because that's the one actually in use.
			-- Split the string on commas, get the first match found, and
			-- immediately break from the loop.
			for renderer in pref:gmatch("(%w+),?") do
				pref = renderer
				break
			end

			if not pref then return end

			local i = FindInTable(pref, self.Choices) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #list do
				if list[i] then
					PREFSMAN:SetPreference("VideoRenderers", values[i])
					break
				end
			end
		end,
	}
end