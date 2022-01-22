local t = Def.ActorFrame{};

CustStage = 1;

for i=1,2 do
  t[#t+1] = Def.ActorFrame{
    InitCommand=function(s)
      s:xy(i==1 and SCREEN_LEFT or SCREEN_RIGHT,SCREEN_BOTTOM-172)
    end,
    OffCommand=function(s) s:smooth(0.2):diffusealpha(0) end,
    PlayerJoinedMessageCommand=function(s,p)
      if p.Player then
        s:queuecommand("Off")
      end
    end,
    OffCommand=function(s) s:smooth(0.2):diffusealpha(0) end,
    Def.Sprite{
      Texture="Frame";
      InitCommand=function(s)
        s:zoomx(i==1 and 1 or -1):halign(0)
      end,
    };
    Def.Sprite{
      Texture=THEME:GetPathG("","_shared/P"..i.." BADGE");
      InitCommand=function(s)
        s:x(i==1 and 100 or -100)
      end,
    };
    Def.Sprite{
      Name="Messages",
      InitCommand=function(s) s:xy(i==1 and 260 or -260,2):zoom(0.8):queuecommand("Set") end,
      SetCommand=function(s)
        local GetP1 = GAMESTATE:IsPlayerEnabled(PLAYER_1)
        local GetP2 = GAMESTATE:IsPlayerEnabled(PLAYER_2)
        local masterPlayer = GAMESTATE:GetMasterPlayerNumber()
        if i == 1 then
          if GetP1 == true and GAMESTATE:GetNumPlayersEnabled() == 1 then
            s:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P1here"));
          elseif GetP1 == false and GAMESTATE:PlayersCanJoin() and GAMESTATE:GetMasterPlayerNumber() == PLAYER_2 then
            s:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P1CanJoin"));
          elseif GetP1 == false and GAMESTATE:GetMasterPlayerNumber() == PLAYER_2  then
            if GAMESTATE:GetCoins() ~= GAMESTATE:GetCoinsNeededToJoin() and GAMESTATE:IsEventMode() == false then
              s:Load(THEME:GetPathB("","ScreenSelectStyle overlay/credit"));
            end;
          else
            s:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P1here"));
          end;
        elseif i == 2 then
          if GetP2 == true and GAMESTATE:GetNumPlayersEnabled() == 1 then
            s:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P2here"));
          elseif GetP2 == false and GAMESTATE:GetMasterPlayerNumber() == PLAYER_1  then
            if GAMESTATE:GetCoins() ~= GAMESTATE:GetCoinsNeededToJoin()  and GAMESTATE:IsEventMode() == false then
              s:Load(THEME:GetPathB("","ScreenSelectStyle overlay/credit"));
            else
              s:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P2CanJoin"));
            end;
          else
            s:Load(THEME:GetPathB("","ScreenSelectStyle overlay/P2here"));
          end
        end
      end,
    };
  };

  t[#t+1] = Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy+280):draworder(200) end,
    Def.Sprite{
      Texture=THEME:GetPathG("","_shared/garrows/_selectarroww");
      InitCommand=function(s)
        s:x(i==1 and -264 or 264):zoomx(i==1 and 0.5 or -0.5):zoomy(0.5):diffusealpha(0):diffuse(color("#5bec19"))
      end,
      OnCommand=function(s) s:smooth(0.3):zoomx(i==1 and 1 or -1):zoomy(1):diffusealpha(1) end,
      OffCommand=function(s) s:smooth(0.2):addx(i==1 and-50 or 50):diffusealpha(0) end,
      MenuLeftP2MessageCommand=function(s) s:queuecommand("MenuLeftP1") end,
      MenuLeftP1MessageCommand=function(s)
        if i==1 then
          s:diffuse(color("#f51a32"))
          s:smooth(0.1):addx(-20):smooth(0.1):addx(20):sleep(0)
          s:diffuse(color("#5bec19"))
        end
      end,
      MenuRightP1MessageCommand=function(s)
        if i==2 then
          s:diffuse(color("#f51a32"))
          s:smooth(0.1):addx(20):smooth(0.1):addx(-20)
          s:diffuse(color("#5bec19"))
        end
      end,
      MenuRightP2MessageCommand=function(s) s:queuecommand("MenuRightP1") end,
    };
  };
end

--[[t[#t+1] = Def.Actor{
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
};]]

t[#t+1] = Def.ActorFrame{
  OnCommand=function(s)
		SOUND:DimMusic(1,math.huge)
	end,
  Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0)) end,
		OnCommand=function(s)
			if getenv("FixStage") == 1 then
				s:diffusealpha(1):linear(0.2):diffusealpha(0):sleep(0.55)
			else
				s:diffusealpha(0):sleep(0.75)
			end
		end,
    OffCommand=function(s) s:sleep(2) end,
	};
	Def.Sound{
		File=THEME:GetPathS("","ScreenSelectStyle in.ogg"),
		OnCommand=function(s) s:sleep(0.2):queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
  Def.Sound{
		File=THEME:GetPathS("","ScreenSelectStyle out.ogg"),
		OffCommand=function(s) s:queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
}

return t
