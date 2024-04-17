local jk = LoadModule"Jacket.lua"

return Def.ActorFrame{
    loadfile(THEME:GetPathG("MusicWheelItem","Song NormalPart/"..ThemePrefs.Get("WheelType").."/default.lua"))(jk)..{
        Condition=not GAMESTATE:IsCourseMode(),
    }
} 
