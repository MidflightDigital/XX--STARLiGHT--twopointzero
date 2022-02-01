local t = Def.ActorFrame{};

t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:xy(_screen.cx,SCREEN_TOP+100) end,
  Def.Sprite{
    Texture="bluething",
    InitCommand=function(s) 
      s:xy(68,34)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/Header/extra_bluething"))
      end
    end,
    OnCommand=function(s) s:addx(SCREEN_WIDTH):decelerate(0.2):addx(-SCREEN_WIDTH) end,
    OffCommand=function(s) s:decelerate(0.2):addx(-SCREEN_WIDTH) end,
  };
  Def.Sprite{
    Texture="star",
    InitCommand=function(s)
      s:xy(-138,64)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/Header/extra_star"))
      end
    end,
    OnCommand=function(s) s:addx(SCREEN_WIDTH):sleep(0.1):decelerate(0.24):addx(-SCREEN_WIDTH) end,
    OffCommand=function(s) s:sleep(0.1):decelerate(0.24):addx(-SCREEN_WIDTH) end,
  };
  Def.Sprite{
    Texture="star",
    InitCommand=function(s)
      s:xy(318,-60)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/Header/extra_star"))
      end
    end,
    OnCommand=function(s) s:addx(SCREEN_WIDTH):sleep(0.25):decelerate(0.22):addx(-SCREEN_WIDTH) end,
    OffCommand=function(s) s:sleep(0.25):decelerate(0.22):addx(-SCREEN_WIDTH-200) end,
  };
  LoadActor("arrow")..{
    InitCommand=function(s) s:zoom(0.4):xy(-768,-56) end,
    OnCommand=function(s) s:addx(SCREEN_WIDTH):sleep(0.2):decelerate(0.28):addx(-SCREEN_WIDTH) end,
    OffCommand=function(s) s:sleep(0.2):decelerate(0.28):addx(-SCREEN_WIDTH) end,
  };
  LoadActor("arrow")..{
    InitCommand=function(s) s:zoom(0.6):xy(628,-26) end,
    OnCommand=function(s) s:addx(SCREEN_WIDTH):sleep(0.25):decelerate(0.18):addx(-SCREEN_WIDTH) end,
    OffCommand=function(s) s:sleep(0.25):decelerate(0.18):addx(-SCREEN_WIDTH) end,
  };
  LoadActor("arrow")..{
    InitCommand=function(s) s:xy(-476,-10) end,
    OnCommand=function(s) s:addx(SCREEN_WIDTH):sleep(0.3):decelerate(0.2):addx(-SCREEN_WIDTH) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.2):addx(-SCREEN_WIDTH) end,
  };
  Def.Sprite{
    Texture="text",
    InitCommand=function(s) 
      s:xy(0,-50)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/Header/extra_text"))
      end
    end,
    OnCommand=function(s) s:diffusealpha(0):sleep(0.5):decelerate(0.2):diffusealpha(1) end,
    OffCommand=function(s) s:decelerate(0.2):diffusealpha(0) end,
  };
};

return t;
