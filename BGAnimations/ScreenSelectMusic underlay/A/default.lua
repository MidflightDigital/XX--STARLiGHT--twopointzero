return Def.ActorFrame{
    Def.Sprite{
      Texture="ADeco",
      InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT,_screen.cy):blend(Blend.Add):diffusealpha(1) end,
      OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
      OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
    };
    Def.Sprite{
      Texture="ADeco",
      InitCommand=function(s) s:zoomx(-1):halign(0):xy(SCREEN_RIGHT,_screen.cy):blend(Blend.Add):diffusealpha(1) end,
      OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
      OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
    };
};