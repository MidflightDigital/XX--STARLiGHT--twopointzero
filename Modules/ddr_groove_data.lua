local st = ({...})[1]
local name = "DDRRadar" .. st
local env = GAMESTATE:Env()

if env[name] then
	return env[name]
elseif StarlightCache[name] then
	env[name] = StarlightCache[name]
	return StarlightCache[name]
end
local results = dofile(THEME:GetAbsolutePath("Other/ddr_groove_data.lua"))
StarlightCache[name] = results[st]
env[name] = results[st]
return results[st]
