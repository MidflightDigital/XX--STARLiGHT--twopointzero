return Def.Sprite{
    Texture="top",
     InitCommand=function(s) s:y(-6)
        if GAMESTATE:IsCourseMode() == false then
            if ThemePrefs.Get("WheelType") == "A" or ThemePrefs.Get("WheelType") == "Wheel" then
                s:visible(true)
            else
                s:visible(false)
            end
        else
            s:visible(false)
        end
    end,
}