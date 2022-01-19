local screen = Var "LoadingScreen"

local pf = ""
if GAMESTATE:IsAnExtraStage() and screen == "ScreenSelectMusicExtra" then
  pf = "ex "
end

local t = Def.ActorFrame{
  LoadActor(pf.."under mult.png")..{
    InitCommand=function(s) s:blend(Blend.Subtract):y(-10) end,
  };
  LoadActor(pf.."base");
  Def.ActorFrame{
    OnCommand=function(s) s:sleep(0.8):queuecommand("Anim") end,
    AnimCommand=function(s) s:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.75")):effectperiod(1.5) end,
    LoadActor(pf.."side glows.png")..{
      InitCommand=function(s) s:y(-40) end,
      OnCommand=function(s)
        if screen ~= "ScreenSelectProfilePrefs" then
          s:cropleft(0.5):cropright(0.5):sleep(0.3):decelerate(0.4):cropleft(0):cropright(0)
        end
      end,
    };
    LoadActor(pf.."center glows.png")..{
      InitCommand=function(s) s:y(-40) end,
      OnCommand=function(s) 
        if screen ~= "ScreenSelectProfilePrefs" then
          s:cropleft(0.5):cropright(0.5):sleep(0.3):decelerate(0.4):cropleft(0):cropright(0)
        end
      end,
    };
  };
  Def.ActorFrame{
    OnCommand=function(s)
      if screen ~= "ScreenSelectProfilePrefs" then
        s:diffusealpha(0):sleep(0.3):decelerate(0.5):diffusealpha(1)
      end
    end,
    LoadActor(pf.."arrow")..{
      InitCommand=function(s) s:y(-40) end,
      OnCommand=function(s)
        if screen ~= "ScreenSelectProfilePrefs" then
          s:addy(-100):sleep(0.25):decelerate(0.4):addy(100)
        end
      end,
    };
  };
};

return t
