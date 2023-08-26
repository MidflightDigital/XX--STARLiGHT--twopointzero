local wheel = ThemePrefs.Get("WheelType");
return Def.ActorFrame{
    loadfile(THEME:GetPathG("MusicWheelItem","SectionCollapsed NormalPart/"..wheel.."/default.lua"))()
} 
