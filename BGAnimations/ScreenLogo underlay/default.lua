
setenv("FixStage",0)

return Def.ActorFrame{
  StorageDevicesChangedMessageCommand=function(self, params)
		MemCardInsert()
	end;
  Def.Sprite{
    Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/stars"),
    InitCommand=function(s) s:diffusealpha(0.3):fadetop(0.5):fadebottom(0.5):zoom(2.25) end,
    OnCommand=function(self)
      self:finishtweening()
      local w = DISPLAY:GetDisplayWidth() / self:GetWidth();
      local h = DISPLAY:GetDisplayHeight() / self:GetHeight();
      self:customtexturerect(0,0,w*1,h*1);
      self:texcoordvelocity(-0.02,0);
    end;
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  };
  Def.Sprite{
    Texture="Common Scanlines",
    InitCommand=function(s) s:FullScreen():diffusealpha(0.1) end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  };
  Def.Quad{
    InitCommand=function(s) s:FullScreen():diffuse(Color.Black) end,
    OnCommand=function(s) s:sleep(2):linear(0.1):diffusealpha(0) end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  },
  Def.Sprite{
    Texture="darken",
    InitCommand=function(s) s:Center() end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  },
  Def.ActorFrame{
    InitCommand=function(s) s:xy(SCREEN_LEFT+280,_screen.cy) end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
    Def.ActorFrame{
      InitCommand=function(s) s:xy(100,450):zoom(1.3):diffusealpha(0) end,
      OnCommand=function(s) s:sleep(2.6):decelerate(0.3):diffusealpha(1) end,
      StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
      Def.Sprite{
        Texture=THEME:GetPathB("","_Dancer/panels.png"),
      };
      Def.Sprite{
        Texture=THEME:GetPathB("","_Dancer/panels.png"),
        InitCommand=function(s) s:blend(Blend.Add):diffuseshift():effectcolor1(Alpha(Color.White,0.3))
          :effectcolor2(Alpha(Color.White,0)):effectperiod(5) 
        end,
        OffCommand=function(s) s:stoptweening() end,
      };
    };
    
    Def.Sprite{
      Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/EXOverlay/guy.png"),
      InitCommand=function(s) s:xy(200,50):diffusealpha(0):addy(1000) end,
      OnCommand=function(s) s:sleep(2.5):decelerate(0.3):addy(-1000):diffusealpha(1) end,
    },
    Def.Sprite{
      Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/EXOverlay/girl.png"),
      InitCommand=function(s) s:xy(0,0):diffusealpha(0):addy(-1000) end,
      OnCommand=function(s) s:sleep(2.5):decelerate(0.3):addy(1000):diffusealpha(1) end,
    },
    
  },
  Def.Sprite{
    Texture=THEME:GetPathB("","_Logo/white_XX.png"),
    InitCommand=function(s) s:xy(SCREEN_LEFT-400,_screen.cy):zoom(1.3) end,
    OnCommand=function(s) s:sleep(1):decelerate(0.3):x(_screen.cx):sleep(0.3):diffusealpha(0) end,
  };
  Def.ActorFrame{
    Name="XX",
    InitCommand=function(s) s:Center():diffusealpha(0):zoom(1.3) end,
    OnCommand=function(s) s:sleep(1.5):linear(0.01):diffusealpha(0.75):linear(0.01):diffusealpha(0.2):linear(0.01)
      :diffusealpha(0.8):linear(0.01):diffusealpha(0.2)
      :linear(0.1):diffusealpha(1):sleep(0.4):decelerate(0.5):zoom(1.15)
      if Branding() == "project_" then
        s:xy(SCREEN_RIGHT-420,_screen.cy+70)
      else
        s:xy(SCREEN_RIGHT-350,_screen.cy+70)
      end
    end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
    Def.Sprite{ Texture=THEME:GetPathB("","_Logo/XX.png") },
    Def.Sprite{
      Texture=THEME:GetPathB("","_Logo/XX.png"),
      InitCommand=function(s) s:blend(Blend.Add):diffuseshift():effectcolor1(Alpha(Color.White,0.3))
        :effectcolor2(Alpha(Color.White,0)):effectperiod(5) 
      end,
      OffCommand=function(s) s:stoptweening() end,
    },
  },
  Def.Sprite{
    Texture=THEME:GetPathB("","_Logo/"..Branding().."main.png"),
    InitCommand=function(s) s:xy(_screen.cx+130,_screen.cy-70):diffusealpha(0):zoom(1.23) end,
    OnCommand=function(s) s:sleep(2.2):linear(0.2):diffusealpha(1):zoom(1.15):y(_screen.cy+15)
      if Branding() == "project_" then
        s:x(_screen.cx+146)
      else
        s:x(_screen.cx+118) 
      end
    end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  },
  Def.Sprite{
    Texture=THEME:GetPathB("","_Logo/starlight.png"),
    InitCommand=function(s) s:xy(_screen.cx+180,_screen.cy+120):diffusealpha(0):zoom(1.23) end,
    OnCommand=function(s) s:sleep(2.3):linear(0.2):diffusealpha(1):zoom(1.15)
      if Branding() == "project_" then
        s:xy(_screen.cx+244,_screen.cy+120) 
      else
        s:xy(_screen.cx+218,_screen.cy+150) 
      end
    end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  },
  Def.Sprite{
    Texture=THEME:GetPathB("","_Logo/"..Branding().."xxlogo.png"),
    InitCommand=function(s) s:zoom(1.15):xy(SCREEN_RIGHT-650,_screen.cy+70):diffusealpha(0):blend(Blend.Add) end,
    OnCommand=function(s) s:sleep(2.6):diffusealpha(1):linear(1):diffusealpha(0):zoom(1.5):sleep(0):zoom(1.15):queuecommand("Anim") end,
    AnimCommand=function(s) s:diffusealpha(0):sleep(1):linear(0.75):diffusealpha(0.3):sleep(0.1):linear(0.4):diffusealpha(0):queuecommand("Anim") end,
    OffCommand=function(s) s:stoptweening() end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  },
  Def.BitmapText{
    Font='_avenirnext lt pro bold/36px',
    Text='The neXXt generation',
    InitCommand=function(s) s:Center():diffusealpha(0):zoomx(8) end,
    OnCommand=function(s) s:decelerate(0.2):diffusealpha(1):zoomx(1):sleep(0.7):linear(0.05):zoom(8):diffusealpha(0) end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  },
  Def.ActorFrame{
    InitCommand=function(s) s:Center() end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
    Def.Sprite{
      Texture=THEME:GetPathB("ScreenStageInformation","decorations/star"),
      InitCommand=function(s) s:diffusealpha(0) end,
      OnCommand=function(s) s:sleep(1.5):linear(0.05):diffusealpha(1):linear(0.2):diffusealpha(0) end,
    },
    Def.Quad{
      InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):diffusealpha(0):blend(Blend.Add) end,
      OnCommand=function(s) s:sleep(1.5):linear(0.05):diffusealpha(0.75):linear(0.2):diffusealpha(0) end,
    },
    Def.Sprite{
      Texture=THEME:GetPathB("ScreenStageInformation","decorations/arrow"),
      OnCommand=function(s) s:x(1700):sleep(1.4):linear(0.3):x(-1700) end,
    },
    Def.Sprite{
      Texture=THEME:GetPathB("ScreenStageInformation","decorations/arrow"),
      InitCommand=function(s) s:zoomx(-1) end,
      OnCommand=function(s) s:x(-1700):sleep(1.4):linear(0.3):x(1700) end,
    },
  },
  Def.Sprite{
    InitCommand=function(s) s:xy(_screen.cx+500,_screen.cy+360):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#B4FF01")) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
    OnCommand=function(s) s:diffusealpha(0):sleep(2.8):linear(0.4):diffusealpha(1) end,
    OffCommand=function(s) s:stoptweening() end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):diffusealpha(0) end,
    CoinInsertedMessageCommand=function(s) s:queuecommand("Set") end,
    SetCommand=function(s)
      local coinmode = GAMESTATE:GetCoinMode()
      if coinmode == 'CoinMode_Free' then
      s:Load(THEME:GetPathB("","ScreenTitleJoin underlay/_press start"))
      else
      if GAMESTATE:EnoughCreditsToJoin() == true then
        s:Load(THEME:GetPathB("","ScreenTitleJoin underlay/_press start"))
      else
        s:Load(THEME:GetPathB("","ScreenTitleJoin underlay/_insert coin"))
      end
      end
    end
  };
  loadfile(THEME:GetPathB("ScreenLogo","underlay/footer.lua"))();
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
          self:queuecommand("Anim")
        else
          SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectMode"):StartTransitioningScreen("SM_GoToNextScreen")
          MESSAGEMAN:Broadcast("StartPressedLogo")
        end
        SOUND:PlayOnce(THEME:GetPathS("","Common start"))
      end
    end;
    MenuRightCommand=function(s)
      SCREENMAN:GetTopScreen():SetNextScreenName("ScreenDemonstration"):StartTransitioningScreen("SM_GoToNextScreen")
      SCREENMAN:GetTopScreen():RemoveInputCallback(DDRInput(self))
    end,
    Def.Quad{
      InitCommand=function(s) s:FullScreen():diffuse(Color.Black):diffusealpha(0) end,
      AnimCommand=function(s) 
          s:linear(0.1):diffusealpha(1)
      end,
    },
  };
  Def.Actor{
    BeginCommand=function(s)
      s:queuecommand("Delay")
    end,
    DelayCommand=function(s) s:sleep(70):queuecommand("SetScreen") end,
    SetScreenCommand=function(s)
      SCREENMAN:GetTopScreen():SetNextScreenName("ScreenDemonstration"):StartTransitioningScreen("SM_GoToNextScreen")
      SCREENMAN:GetTopScreen():RemoveInputCallback(DDRInput(self))
    end,
  };
}

