
return Def.ActorFrame{
  loadfile(THEME:GetPathB("","_Dancer/default.lua"))()..{
    InitCommand = function(s) s:xy(_screen.cx-540,_screen.cy+30) end,
    OnCommand=function(s) s:diffusealpha(0):linear(0.3):diffusealpha(1) end,
  };
  loadfile(THEME:GetPathB("","_Logo/default.lua"))()..{
    InitCommand=function(s) s:Center():zoom(2):diffusealpha(0) end,
    OnCommand=function(s) s:decelerate(0.5):diffusealpha(1):zoom(1) end,
  };
  Def.Sprite{
    Texture=THEME:GetPathB("","_Logo/xxlogo.png"),
    InitCommand=function(s) s:xy(_screen.cx+104,_screen.cy+16):blend(Blend.Add):diffusealpha(0) end,
    OnCommand=function(s) s:sleep(0.45):diffusealpha(1):linear(1):diffusealpha(0):zoom(1.5):sleep(0):zoom(1):queuecommand("Anim") end,
    AnimCommand=function(s) s:diffusealpha(0):sleep(1):linear(0.75):diffusealpha(0.3):sleep(0.1):linear(0.4):diffusealpha(0):queuecommand("Anim") end,
  };
  Def.Sprite{
    Texture="_press start",
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy+340):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#B4FF01")) end,
    OffCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  };

  Def.ActorFrame{
    OnCommand=function(self)
      SCREENMAN:GetTopScreen():AddInputCallback(DDRInput(self))
      GAMESTATE:Reset()
    end,
    StartReleaseCommand=function(self)
      if GAMESTATE:EnoughCreditsToJoin() then
        GAMESTATE:JoinInput(self.pn)
        if GAMESTATE:GetCoinMode() ~= "CoinMode_Home" then
          SCREENMAN:GetTopScreen():SetNextScreenName(Branch.StartGame()):StartTransitioningScreen("SM_GoToNextScreen")
        else
          SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectMode"):StartTransitioningScreen("SM_GoToNextScreen")
        end
        SOUND:PlayOnce(THEME:GetPathS("","Common start"))
        self:queuecommand("Anim")
      end
    end;
    MenuRightCommand=function(s)
      SCREENMAN:GetTopScreen():SetNextScreenName("ScreenDemonstration"):StartTransitioningScreen("SM_GoToNextScreen")
      SCREENMAN:GetTopScreen():RemoveInputCallback(DDRInput(self))
    end,
    Def.Quad{
      InitCommand=function(s) s:FullScreen():diffuse(Color.Black):diffusealpha(0) end,
      AnimCommand=function(s) 
          s:linear(0.2):diffusealpha(1):sleep(1)
      end,
    },
  };
  Def.Actor{
    BeginCommand=function(s)
      s:queuecommand("Delay")
    end,
    DelayCommand=function(s) s:sleep(20):queuecommand("SetScreen") end,
    SetScreenCommand=function(s)
      SCREENMAN:GetTopScreen():SetNextScreenName("ScreenDemonstration"):StartTransitioningScreen("SM_GoToNextScreen")
      SCREENMAN:GetTopScreen():RemoveInputCallback(DDRInput(self))
    end,
  };
}

