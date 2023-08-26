local wheel = ThemePrefs.Get("WheelType");
return Def.ActorFrame{
    loadfile(THEME:GetPathG("MusicWheelItem","Roulette NormalPart/"..wheel.."/default.lua"))()
}

