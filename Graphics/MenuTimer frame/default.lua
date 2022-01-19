local t = Def.ActorFrame{};
local screen = Var "LoadingScreen"

t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:x(-5):zoom(0.8) end,
  Def.ActorFrame{
    
    Def.Sprite{
      Texture="1",
      OnCommand=function(s) s:spin():effectmagnitude(0,0,100):blend(Blend.Add) end,
      OffCommand=function(s) s:stoptweening() end,
    };
    Def.Sprite{
      Texture="2",
      OnCommand=function(s) s:spin():effectmagnitude(0,0,-100):blend(Blend.Add) end,
      OffCommand=function(s) s:stoptweening() end,
    };
    Def.Sprite{
      Texture="1",
      OnCommand=function(s) s:spin():zoom(1):effectmagnitude(0,0,-50):blend(Blend.Add):diffusealpha(0.5) end,
      OffCommand=function(s) s:stoptweening() end,
    };
    Def.Sprite{
      Texture="2",
      OnCommand=function(s) s:spin():zoom(1):effectmagnitude(0,0,50):blend(Blend.Add):diffusealpha(0.5) end,
      OffCommand=function(s) s:stoptweening() end,
    };
  };
  LoadActor( "timer ring" )..{
    OnCommand=function(self)
      self:spin():effectmagnitude(0,0,100)
    end;
    OffCommand=function(s) s:stoptweening() end,
  };
  LoadActor( "timer ring" )..{
    OnCommand=function(self)
      self:spin():effectmagnitude(0,0,-50):blend(Blend.Add):diffusealpha(0.5)
    end;
    OffCommand=function(s) s:stoptweening() end,
  };
};

return t;
