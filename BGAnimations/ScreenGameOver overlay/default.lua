return Def.ActorFrame{
  Def.Sprite{
    Texture="bg",
    InitCommand=function(s) s:Center():zoom(1.2)
      SOUND:StopMusic()
      setenv("Credits",false)
    end,
    OnCommand=function(s) s:smooth(5):zoom(1) end,
  };
  Def.Sprite{
    Texture="comet",
    InitCommand=function(s) s:Center():diffusealpha(0):blend(Blend.Add) end,
    OnCommand=function(s) s:sleep(0.4):smooth(2):diffusealpha(0.75) end,
  };
  Def.Sprite{
    Texture="planet",
    InitCommand=function(s) s:Center():zoom(1.3):diffusealpha(0):rotationz(80):blend(Blend.Add) end,
    OnCommand=function(s) s:sleep(0.4):smooth(2):diffusealpha(0.75):zoom(1):rotationz(0) end,
  };
  Def.ActorFrame{
    InitCommand=function(s) s:Center() end,
    Def.Sprite{
      Texture="text",
      Name="Actual",
      OnCommand=function(s) s:diffusealpha(0):zoom(1.2):sleep(0.2):linear(0.5)
        :diffusealpha(1):accelerate(0.1):zoomy(1.1):linear(0.1):zoom(1)
      end,
    };
    Def.Sprite{
      Texture="text",
      Name="Back",
      InitCommand=function(s) s:blend(Blend.Add) end,
      OnCommand=function(s) s:diffusealpha(0):zoom(0.3):linear(1):zoom(1)
        :diffusealpha(0.5):sleep(0):zoomx(1.3):linear(0.1):zoomx(2.3):zoomy(2):diffusealpha(0)
      end,
    };
    Def.Sprite{
      Texture="text",
      InitCommand=function(s) s:blend(Blend.Add) end,
      OnCommand=function(s) s:diffusealpha(0):zoom(2):linear(1):zoom(0.75):diffusealpha(0.5):linear(0):diffusealpha(0) end,
    };
  };
  Def.Quad{
    InitCommand=function(s) s:diffuse(Color.Black):FullScreen() end,
    OnCommand=function(s) s:decelerate(0.5):diffusealpha(0):sleep(3.2):smooth(0.1):diffusealpha(1) end,
  };
  Def.Sprite{
    Texture="ty.png",
    InitCommand=function(s) s:Center():diffusealpha(0) end,
    OnCommand=function(s) s:sleep(3.7):diffusealpha(1) end,
  };
  Def.Sound{
    File="go.ogg",
    OnCommand=function(s) s:play() end,
  };
};
