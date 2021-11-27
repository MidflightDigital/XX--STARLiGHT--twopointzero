return Def.ActorFrame{
    InitCommand=function(s)
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
    LoadActor("bottom")..{
        InitCommand=function(s) s:y(110) end,
    },
    LoadActor("glow")..{
        InitCommand=function(s) s:y(110)
        :diffuseshift():effectcolor1(color("1,1,1,0.75")):effectcolor2(color("1,1,1,1")):effectclock('beatnooffset') end,
    }
};