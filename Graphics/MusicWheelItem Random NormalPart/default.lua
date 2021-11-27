local t = Def.ActorFrame{}

local wheel = ThemePrefs.Get("WheelType");

t[#t+1] = LoadActor(wheel.."/default.lua")

return t;
