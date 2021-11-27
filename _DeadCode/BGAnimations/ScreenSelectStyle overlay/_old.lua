local t = Def.ActorFrame {
  OnCommand=function(self)
    if not FILEMAN:DoesFileExist("Save/ThemePrefs.ini") then
      Trace("ThemePrefs doesn't exist; creating file")
      ThemePrefs.ForceSave()
    end
    if SN3Debug then
      SCREENMAN:SystemMessage("Saving ThemePrefs.")
    end
    ThemePrefs.Save()
    ThemePrefs.Set("WheelType",ThemePrefs.Get("WheelType"))
    THEME:ReloadMetrics()
  end;
};

local mus_path = THEME:GetCurrentThemeDirectory().."/Sounds/ScreenSelectMusic music (loop).redir"
--update the select music redir here...
if ThemePrefs.Get("MenuMusic") ~= CurrentMenuMusic then
  if not CurrentMenuMusic and FILEMAN:DoesFileExist(mus_path) then
    CurrentMenuMusic = ThemePrefs.Get("MenuMusic")
  else
    local f = RageFileUtil.CreateRageFile()
    local worked = f:Open(mus_path, 10)
    if worked then
      f:Write(GetMenuMusicPath("common",true))
      f:Close()
    elseif SN3Debug then
      SCREENMAN:SystemMessage("Couldn't open select music redir")
    end
    f:destroy()
	CurrentMenuMusic = ThemePrefs.Get("MenuMusic")
    THEME:ReloadMetrics()
  end
end

CustStage = 1;

t[#t+1] = Def.ActorFrame {
  InitCommand=cmd(draworder,99);
  Name="Frames";
  LoadActor("Frame")..{
    Name="P1 Frame";
    InitCommand=cmd(x,SCREEN_LEFT;y,SCREEN_BOTTOM-172;halign,0;);
    BeginCommand=function(self)
      if GAMESTATE:GetNumPlayersEnabled() == 2 then
        self:visible(false)
      else
        self:visible(true)
      end;
    end;
    OffCommand=cmd(smooth,0.2;diffusealpha,0;);
    PlayerJoinedMessageCommand=function(self,param)
      if param.Player == PLAYER_1 then
        self:queuecommand("Off")
      end;
      if param.Player == PLAYER_2 then
        self:queuecommand("Off")
      end;
    end;
  };
  LoadActor("Frame")..{
    Name="P2 Frame";
    InitCommand=cmd(x,SCREEN_RIGHT;y,SCREEN_BOTTOM-172;halign,0;zoomx,-1);
    BeginCommand=function(self)
      if GAMESTATE:GetNumPlayersEnabled() == 2 then
        self:visible(false)
      else
        self:visible(true)
      end;
    end;
    OffCommand=cmd(smooth,0.2;diffusealpha,0;);
    PlayerJoinedMessageCommand=function(self,param)
      if param.Player == PLAYER_1 then
        self:queuecommand("Off")
      end;
      if param.Player == PLAYER_2 then
        self:queuecommand("Off")
      end;
    end;
  };
};

t[#t+1] = Def.ActorFrame {
  InitCommand=cmd(draworder,99);
  Name="Badges";
  LoadActor(THEME:GetPathG("","_shared/P1 BADGE"))..{
    Name="P1 Badge";
    InitCommand=cmd(visible,false;x,SCREEN_LEFT+114;y,SCREEN_BOTTOM-174);
    OnCommand=function(self)
      if GAMESTATE:GetNumPlayersEnabled() == 2 then
        self:visible(false)
      else
        self:visible(true)
      end;
    end;
    OffCommand=cmd(smooth,0.2;diffusealpha,0;);
    PlayerJoinedMessageCommand=function(self)
      self:queuecommand("Off")
    end;
  };
  LoadActor(THEME:GetPathG("","_shared/P2 BADGE"))..{
    Name="P2 Badge";
    InitCommand=cmd(visible,false;x,SCREEN_RIGHT-114;y,SCREEN_BOTTOM-174);
    OnCommand=function(self)
      if GAMESTATE:GetNumPlayersEnabled() == 2 then
        self:visible(false)
      else
        self:visible(true)
      end;
    end;
    OffCommand=cmd(smooth,0.2;diffusealpha,0;);
    PlayerJoinedMessageCommand=function(self)
      self:queuecommand("Off")
    end;
  };
};

t[#t+1] = Def.ActorFrame{
  InitCommand=cmd(draworder,99);
  Def.Sprite{
    Name="P1 Messages";
    InitCommand=cmd(visible,false;x,SCREEN_LEFT+294;y,SCREEN_BOTTOM-170);
    OnCommand=function(self)
      if GAMESTATE:GetNumPlayersEnabled() == 2 then
        self:visible(false)
      else
        self:queuecommand("Set")
      end;
    end;
    SetCommand=function(self)
      local GetP1 = GAMESTATE:IsPlayerEnabled(PLAYER_1);
      if GetP1 == true and GAMESTATE:GetMasterPlayerNumber() == PLAYER_1 then
        self:visible(true)
        self:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P1here"));
      elseif GetP1 == false and GAMESTATE:PlayersCanJoin() and GAMESTATE:GetMasterPlayerNumber() == PLAYER_2 then
        self:visible(true)
        self:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P1CanJoin"));
      elseif GetP1 == false and GAMESTATE:GetMasterPlayerNumber() == PLAYER_2  then
        if GAMESTATE:GetCoins() ~= GAMESTATE:GetCoinsNeededToJoin() and GAMESTATE:IsEventMode() == false then
          self:visible(true)
          self:Load(THEME:GetPathB("","ScreenSelectStyle overlay/credit"));
        end;
      elseif GAMESTATE:GetNumPlayersEnabled() == 2 then
        self:visible(false)
      end;
    end;
    OffCommand=cmd(smooth,0.2;diffusealpha,0);
    CoinsChangedMessageCommand=function(self)
      self:queuecommand("Set");
    end;
    PlayerJoinedMessageCommand=function(self)
      self:queuecommand("Off")
    end;
  };
  Def.Sprite{
    Name="P2 Messages";
    InitCommand=cmd(visible,false;x,SCREEN_RIGHT-294;y,SCREEN_BOTTOM-170);
    OnCommand=function(self)
      if GAMESTATE:GetNumPlayersEnabled() == 2 then
        self:visible(false)
      else
        self:queuecommand("Set")
      end;
    end;
    SetCommand=function(self)
      local GetP2 = GAMESTATE:IsPlayerEnabled(PLAYER_2);
      if GetP2 == true and GAMESTATE:GetMasterPlayerNumber() == PLAYER_2 then
        self:visible(true)
        self:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P2here"));
      elseif GetP2 == false and GAMESTATE:GetMasterPlayerNumber() == PLAYER_1  then
        if GAMESTATE:GetCoins() ~= GAMESTATE:GetCoinsNeededToJoin()  and GAMESTATE:IsEventMode() == false then
          self:visible(true)
          self:Load(THEME:GetPathB("","ScreenSelectStyle overlay/credit"));
        else
          self:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P2CanJoin"));
          self:visible(true)
        end;
      elseif GAMESTATE:GetNumPlayersEnabled() == 2 then
        self:visible(false)
      end;
    end;
    OffCommand=cmd(smooth,0.2;diffusealpha,0);
    CoinsChangedMessageCommand=function(self)
      self:queuecommand("Set");
    end;
    PlayerJoinedMessageCommand=function(self)
      self:queuecommand("Off")
    end;
  };
};

t[#t+1] = Def.ActorFrame{
  InitCommand=cmd(draworder,200;xy,SCREEN_CENTER_X,SCREEN_CENTER_Y+280);
  Def.ActorFrame{
    InitCommand=cmd(x,-264;zoomx,0.5;zoomy,0.5;diffusealpha,0);
    OnCommand=cmd(smooth,0.3;zoomx,1;zoomy,1;diffusealpha,1;);
    OffCommand=cmd(smooth,0.2;addx,-50;diffusealpha,0;);
    LoadActor(THEME:GetPathG("","_shared/garrows/_selectarrowg")) .. {
      MenuLeftP1MessageCommand=cmd(smooth,0.1;addx,-20;smooth,0.1;addx,20;);
      MenuLeftP2MessageCommand=cmd(smooth,0.1;addx,-20;smooth,0.1;addx,20;);
    };
    LoadActor(THEME:GetPathG("","_shared/garrows/_selectarrowr")) .. {
      OnCommand=cmd(diffusealpha,0;);
      MenuLeftP1MessageCommand=cmd(diffusealpha,1;smooth,0.1;addx,-20;smooth,0.1;addx,20;diffusealpha,0);
      MenuLeftP2MessageCommand=cmd(diffusealpha,1;smooth,0.1;addx,-20;smooth,0.1;addx,20;diffusealpha,0);
    };
  };
  Def.ActorFrame{
    InitCommand=cmd(x,264;zoomx,-0.5;zoomy,0.5;diffusealpha,0);
    OnCommand=cmd(smooth,0.3;zoomx,-1;zoomy,1;diffusealpha,1;);
    OffCommand=cmd(smooth,0.2;addx,50;diffusealpha,0;);
    LoadActor(THEME:GetPathG("","_shared/garrows/_selectarrowg")) .. {
      MenuRightP1MessageCommand=cmd(smooth,0.1;addx,-20;smooth,0.1;addx,20;);
      MenuRightP2MessageCommand=cmd(smooth,0.1;addx,-20;smooth,0.1;addx,20;);
    };

    LoadActor(THEME:GetPathG("","_shared/garrows/_selectarrowr")) .. {
      OnCommand=cmd(diffusealpha,0);
      MenuRightP1MessageCommand=cmd(diffusealpha,1;smooth,0.1;addx,-20;smooth,0.1;addx,20;diffusealpha,0);
      MenuRightP2MessageCommand=cmd(diffusealpha,1;smooth,0.1;addx,-20;smooth,0.1;addx,20;diffusealpha,0);
    };
  }
};

t[#t+1] = LoadActor("StartJoinSSS")..{
  Name = "PressStartP1";
  InitCommand=function(self)
    self:x(SCREEN_LEFT+254):y(SCREEN_CENTER_Y+250)
    if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
      self:visible(false)
    else
      self:visible(true)
      self:queuecommand("Set")
    end;
  end;
  AnimateCommand=cmd(linear,0.25;zoomx,0.95;linear,0.25;zoomx,1;queuecommand,"Animate");
  OffCommand=cmd(stoptweening;linear,0.25;zoomy,0;diffusealpha,0);
  SetCommand=function(self)
    local GetP1 = GAMESTATE:IsPlayerEnabled(PLAYER_1);
    if GetP1 ~= true then
      if GAMESTATE:GetCoins() ~= GAMESTATE:GetCoinsNeededToJoin()   and GAMESTATE:IsEventMode() == false then
        self:zoom(0)
      else
        self:zoom(0):rotationz(-720):linear(0.35):rotationz(720):zoom(1):playcommand("Animate")
      end;
    end;
  end;
  CoinsChangedMessageCommand=function(self)
    self:queuecommand("Set");
  end;
  PlayerJoinedMessageCommand=function(self,param)
    if param.Player == PLAYER_1 then
      (cmd(linear,0.15;zoomy,0;))(self);
    end;
  end;
};

t[#t+1] = LoadActor("StartJoinSSS")..{
  Name = "PressStartP2";
  InitCommand=function(self)
    self:x(SCREEN_RIGHT-254):y(SCREEN_CENTER_Y+250)
    if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
      self:visible(false)
    else
      self:visible(true)
      self:queuecommand("Set")
    end;
  end;
  AnimateCommand=cmd(linear,0.25;zoomx,0.95;linear,0.25;zoomx,1;queuecommand,"Animate");
  OffCommand=cmd(stoptweening;linear,0.25;zoomy,0;diffusealpha,0);
  SetCommand=function(self)
    local GetP2 = GAMESTATE:IsPlayerEnabled(PLAYER_2);
    if GetP2 ~= true then
      if GAMESTATE:GetCoins() ~= GAMESTATE:GetCoinsNeededToJoin() and GAMESTATE:IsEventMode() == false then
        self:zoom(0)
      else
        self:zoom(0):rotationz(-720):linear(0.35):rotationz(720):diffusealpha(1):zoom(1):playcommand("Animate")
      end;
    end;
  end;
  CoinsChangedMessageCommand=function(self)
    self:queuecommand("Set");
  end;
  PlayerJoinedMessageCommand=function(self,param)
    if param.Player == PLAYER_2 then
      (cmd(linear,0.15;zoomy,0;))(self);
    end;
  end;
};

t[#t+1] = Def.Actor{
  PlayerJoinedMessageCommand=function(self)
    self:queuecommand("Delay1")
  end;
  Delay1Command=function(self)
    self:sleep(2)
    self:queuecommand("SetScreen")
  end;
  SetScreenCommand=function(self)
    GAMESTATE:SetCurrentStyle("versus")
    SCREENMAN:GetTopScreen():SetNextScreenName("ScreenProfileLoad"):StartTransitioningScreen("SM_GoToNextScreen")
  end;
};



return t
