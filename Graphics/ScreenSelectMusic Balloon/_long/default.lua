local function xPos()
    local x = 189
    if ThemePrefs.Get("WheelType") == "Jukebox" or ThemePrefs.Get("WheelType") == "Wheel" then
        x = 240
    end
    return x
end


return Def.ActorFrame{
    LoadActor("_long")..{
        InitCommand=function(s) s:align(0,0):cropbottom(0.5)
            if ThemePrefs.Get("WheelType") == "Jukebox" then
                s:xy(-xPos(),-60)
            elseif ThemePrefs.Get("WheelType") == "Wheel" then
                s:xy(-xPos(),-80)
            else
                s:xy(-xPos(),-189)
            end
        end,
        ShowCommand=function(s) s:finishtweening():diffusealpha(0):x(-300):decelerate(0.1):x(-xPos()):diffusealpha(1) end,
        HideCommand=function(s) s:finishtweening():linear(0.1):x(-300):diffusealpha(0) end,
    },
    LoadActor("_long")..{
        InitCommand=function(s) s:align(1,1):croptop(0.5)
            if ThemePrefs.Get("WheelType") == "Jukebox" then
                s:xy(xPos(),66)
            elseif ThemePrefs.Get("WheelType") == "Wheel" then
                s:xy(xPos(),80)
            else
                s:xy(xPos(),189)
            end
        end,
        ShowCommand=function(s) s:finishtweening():diffusealpha(0):x(300):decelerate(0.1):x(xPos()):diffusealpha(1) end,
        HideCommand=function(s) s:finishtweening():linear(0.1):x(300):diffusealpha(0) end,
    },
}