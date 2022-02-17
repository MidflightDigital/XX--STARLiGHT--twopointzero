return Def.ActorFrame{
    loadfile(THEME:GetPathB("ScreenSelectMusic","underlay/Banner/Header"))();
    Def.Sprite{
      Texture=THEME:GetPathG("ScreenWithmenuElements","Header/old.png"),
      InitCommand=function(s) 
        s:xy(_screen.cx,SCREEN_TOP+130):zoom(0.94)
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathG("ScreenWithmenuElements","Header/extra_old.png"))
        end
      end,
      OnCommand=function(s)s :addx(-SCREEN_WIDTH):linear(0.2):addx(SCREEN_WIDTH) end,
      OffCommand=function(s)s :linear(0.2):addx(SCREEN_WIDTH) end,
    };
    StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
      InitCommand=function(s) s:zoom(1.25):xy(_screen.cx,SCREEN_TOP+130) end,
    };
    Def.Sprite{
      Texture="../Default/wheelunder",
      InitCommand=function(s) 
        s:xy(_screen.cx,_screen.cy-210)
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/Default/extra_wheelunder"))
        end
      end,
      OnCommand=function(s) s:zoomtoheight(310):zoomtowidth(0):linear(0.2):zoomtowidth(SCREEN_WIDTH) end,
      OffCommand=function(s) s:sleep(0.3):decelerate(0.3):zoomtowidth(0) end,
    };
  };