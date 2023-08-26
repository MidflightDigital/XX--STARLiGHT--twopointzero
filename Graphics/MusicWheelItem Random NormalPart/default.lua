local wheel = ThemePrefs.Get("WheelType");
return Def.ActorFrame{
    loadfile(THEME:GetPathG("MusicWheelItem","Random NormalPart/"..wheel.."/default.lua"))()
};
