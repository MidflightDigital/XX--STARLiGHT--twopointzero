return Def.Sprite{
    Texture="A",
    InitCommand=function(s) s:zoomtoheight(1)
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