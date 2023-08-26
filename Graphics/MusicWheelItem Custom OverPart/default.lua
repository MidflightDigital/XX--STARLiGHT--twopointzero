local t = Def.ActorFrame{}

local wheel = ThemePrefs.Get("WheelType");

t[#t+1] = loadfile(THEME:GetPathG("MusicWheelItem","Custom OverPart/"..wheel.."/default.lua"))()

return t;
