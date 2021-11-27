local t = Def.ActorFrame{}

local jk = LoadModule"Jacket.lua"

t[#t+1] = LoadActor(ThemePrefs.Get("WheelType").."/default.lua",jk)

return t;
