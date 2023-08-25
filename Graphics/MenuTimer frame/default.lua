local t = Def.ActorFrame{};
local screen = Var "LoadingScreen"

t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:x(-5):zoom(0.8) end,
  Def.ActorFrame{
    InitCommand=function(s) s:zoom(1.3):xy(10,25) end,
    Def.Sprite{
      Texture="1",
      InitCommand=function(s) s:rotationx(64):rotationy(-10) end,
      OnCommand=function(s) s:spin():effectmagnitude(0,0,100):blend(Blend.Add) end,
      OffCommand=function(s) s:stoptweening() end,
    };
    Def.Sprite{
      Texture="2",
      InitCommand=function(s) s:rotationx(70):rotationy(-18) end,
      OnCommand=function(s) s:spin():effectmagnitude(0,0,-100):blend(Blend.Add) end,
      OffCommand=function(s) s:stoptweening() end,
    };
    Def.Sprite{
      Texture="1",
      InitCommand=function(s) s:rotationx(60):rotationy(-10) end,
      OnCommand=function(s) s:spin():zoom(1):effectmagnitude(0,0,-50):blend(Blend.Add):diffusealpha(0.5) end,
      OffCommand=function(s) s:stoptweening() end,
    };
    Def.Sprite{
      Texture="2",
      InitCommand=function(s) s:rotationx(72):rotationy(-8) end,
      OnCommand=function(s) s:spin():zoom(1):effectmagnitude(0,0,50):blend(Blend.Add):diffusealpha(0.5) end,
      OffCommand=function(s) s:stoptweening() end,
    };
  };
  Def.ActorFrame{
    InitCommand=function(s) s:rotationx(60):rotationy(-20):zoom(1.3):xy(10,25) end,
    Def.Sprite{
      Texture= "timer ring",
      OnCommand=function(self)
        self:spin():effectmagnitude(0,0,100)
      end;
      OffCommand=function(s) s:stoptweening() end,
    };
    Def.Sprite{
      Texture= "timer ring",
      OnCommand=function(self)
        self:spin():effectmagnitude(0,0,-50):blend(Blend.Add):diffusealpha(0.5)
      end;
      OffCommand=function(s) s:stoptweening() end,
    };
    Def.ActorFrame{
      InitCommand=function(s) s:spin():effectmagnitude(5,10,8) end,
      LoadActor( "star" )..{
        InitCommand=function(s) s:rotationx(60):rotationy(20):diffusealpha(0.4) end,
        OnCommand=function(self)
          self:spin():effectmagnitude(0,0,-100):blend(Blend.Add)
        end;
        OffCommand=cmd(stoptweening;);
      };
    };
  }
  
};

return t;
