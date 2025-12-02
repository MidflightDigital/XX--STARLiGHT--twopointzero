local wheel = ThemePrefs.Get("WheelType");
return Def.ActorFrame{
    loadfile(THEME:GetPathG("MusicWheelItem","Portal NormalPart/"..wheel.."/default.lua"))()
}

