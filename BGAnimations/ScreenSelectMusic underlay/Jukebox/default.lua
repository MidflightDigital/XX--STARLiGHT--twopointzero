return Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy-140):rotationx(-55):zoomx(1.4):diffusealpha(0) end,
    OnCommand=function(s) s:linear(0.5):diffusealpha(1) end,
    OffCommand=function(s) s:stoptweening():linear(0.5):diffusealpha(0) end,
    Def.Sprite{
      Texture="inner",
      InitCommand=function(s) s:spin():effectmagnitude(0,0,25) 
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/Jukebox/ex_inner"))
        end
      end,
    };
    Def.Sprite{
      Texture="outer",
      InitCommand=function(s) s:spin():effectmagnitude(0,0,-25)
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/Jukebox/ex_outer"))
        end
      end,
    };
}