local pn = ...

return Def.ActorFrame{
    Def.Sprite{
        Texture="ShockArrowIcon",
        InitCommand=function(s) s:y(-50):diffusealpha(0):zoom(1.3) end,
        AnimCommand=function(s) s:finishtweening():zoom(1.3):linear(0.1):diffusealpha(0.8):zoom(0.9):diffusealpha(0.75):linear(0.05):diffusealpha(1):zoom(1) end,
        HideCommand=function(s) s:finishtweening():linear(0.1):diffusealpha(0) end,
    };
    Def.Sprite{
        Texture="ShockArrowText",
        InitCommand=function(s) s:xy(-100,50):diffusealpha(0) end,
        AnimCommand=function(s) s:finishtweening():x(-100):linear(0.1):diffusealpha(1):x(0):linear(0.05):zoom(1.1):linear(0.05):zoom(1) end,
        HideCommand=function(s) s:finishtweening():linear(0.1):diffusealpha(0) end,
    };
    Def.Sprite{
        Texture="ShockArrowText",
        InitCommand=function(s) s:xy(100,50):diffusealpha(0) end,
        AnimCommand=function(s) s:finishtweening():x(100):linear(0.1):diffusealpha(1):x(0):sleep(0):diffusealpha(0) end,
        HideCommand=function(s) s:finishtweening():linear(0.1):diffusealpha(0) end,
    };
}