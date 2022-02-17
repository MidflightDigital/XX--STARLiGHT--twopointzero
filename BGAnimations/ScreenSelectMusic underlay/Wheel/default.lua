return Def.ActorFrame{
    Def.Sprite{
        Texture="MusicWheelWheelUnder.png",
      InitCommand=function(s) s:halign(1):xy(SCREEN_RIGHT,_screen.cy):diffusealpha(0.5)
        if GAMESTATE:IsAnExtraStage() then
          s:diffuse(color("#f900fe"))
        end
      end,
      OnCommand=function(s) s:addx(1100):sleep(0.5):decelerate(0.2):addx(-1100) end,
      OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(1100) end,
    };
    Def.Quad{
      InitCommand=function(s) s:setsize(834,66):xy(_screen.cx+370,_screen.cy+22):diffuse(color("0,0,0,0.5")) end,
      OnCommand=function(s) s:addx(1100):sleep(0.5):decelerate(0.2):addx(-1100) end,
      OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(1100) end,
    }
  };