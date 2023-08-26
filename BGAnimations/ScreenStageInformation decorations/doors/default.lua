local t = Def.ActorFrame{
};

local pf = ""
if GAMESTATE:IsAnExtraStage() and screen == "ScreenSelectMusicExtra" then
  pf = "ex "
end


--Top
t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:CenterX():y(SCREEN_TOP):valign(0) end,
  AnOnCommand=function(s) s:y(SCREEN_TOP-500):sleep(0.2):decelerate(0.2):y(SCREEN_TOP) end,
  AnOffCommand=function(s) s:decelerate(0.2):y(SCREEN_TOP-500) end,
  Def.Sprite{
    Texture=pf.."mult",
    InitCommand=function(s) s:valign(0):blend('BlendMode_WeightedMultiply'):diffusealpha(0.25) end,
  };
  Def.Sprite{
    Texture=pf.."base",
    InitCommand=function(s) s:valign(0) end,
    AnOnCommand=function(s) s:diffuse(color("0.5,0.5,0.5,1")):sleep(0.5):decelerate(1):diffuse(color("1,1,1,1")) end,
  };
  Def.Sprite{
    Texture="mid base",
    InitCommand=function(s) s:y(120) end,
  };
  Def.Sprite{
    Texture=pf.."mid progress",
    InitCommand=function(s) s:y(120):cropright(1) end,
    AnOnCommand=function(s) s:cropright(1):sleep(0.5):decelerate(2):cropright(0) end,
  };
  Def.Sprite{
    Texture=pf.."side lasers.png",
    InitCommand=function(s) s:valign(0):cropbottom(1) end,
    AnOnCommand=function(s) s:sleep(0.5):decelerate(2):cropbottom(0) end,
  };
  Def.Sprite{
    Texture=pf.."Initializing.png",
    InitCommand=function(s) s:y(80):diffusealpha(0) end,
    AnOnCommand=function(s) s:diffusealpha(0):sleep(0.5):linear(0.05):diffusealpha(0.5):linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(1):linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(0.5):decelerate(0.1):diffusealpha(1) end,
  };
  Def.Sprite{
    Texture=pf.."Starlight.png",
    InitCommand=function(s) s:y(160):diffusealpha(0) end,
    AnOnCommand=function(s) s:sleep(1.5):decelerate(0.5):diffusealpha(1) end,
  };
};

--Top
t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:CenterX():y(SCREEN_BOTTOM):valign(1) end,
  AnOnCommand=function(s) s:y(SCREEN_BOTTOM+500):sleep(0.2):decelerate(0.2):y(SCREEN_BOTTOM) end,
  AnOffCommand=function(s) s:decelerate(0.2):y(SCREEN_BOTTOM+500) end,
  Def.Sprite{
    Texture=pf.."mult",
    InitCommand=function(s) s:rotationz(180):valign(0):blend('BlendMode_WeightedMultiply'):diffusealpha(0.25) end,
  };
  Def.Sprite{
    Texture=pf.."base",
    InitCommand=function(s) s:valign(0):rotationz(180) end,
    AnOnCommand=function(s) s:diffuse(color("0.5,0.5,0.5,1")):sleep(0.5):decelerate(1):diffuse(Color.White) end,
  };
  Def.Sprite{
    Texture="mid base",
    InitCommand=function(s) s:y(-120):rotationz(180) end,
  };
  Def.Sprite{
    Texture=pf.."mid progress",
    InitCommand=function(s) s:y(-120):cropright(1):rotationz(180) end,
    AnOnCommand=function(s) s:cropleft(1):sleep(0.5):decelerate(2):cropleft(0) end,
  };
  Def.Sprite{
    Texture=pf.."side lasers.png",
    InitCommand=function(s) s:valign(0):cropbottom(1):rotationz(180) end,
    AnOnCommand=function(s) s:sleep(0.5):decelerate(2):cropbottom(0) end,
  };
  Def.Sprite{
    Texture=pf.."dance.png",
    InitCommand=function(s) s:y(-160):diffusealpha(0) end,
    AnOnCommand=function(s) s:diffusealpha(0):sleep(0.5):linear(0.05):diffusealpha(0.5):linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(1)
      :linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(0.5):decelerate(0.1):diffusealpha(1)
    end,
  };
  Def.Sprite{
    Texture=pf.."prep.png",
    InitCommand=function(s) s:y(-80):diffusealpha(0) end,
    AnOnCommand=function(s) s:diffusealpha(0):sleep(0.5):linear(0.05):diffusealpha(0.5):linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(1)
      :linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(0.5):decelerate(0.1):diffusealpha(1)
    end,
  };
};

return t;
