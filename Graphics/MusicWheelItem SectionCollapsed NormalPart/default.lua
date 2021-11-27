local t = Def.ActorFrame{}

local wheel = ThemePrefs.Get("WheelType");
t[#t+1] = Def.ActorFrame{
    LoadActor(wheel.."/default.lua")
} 

return t;
