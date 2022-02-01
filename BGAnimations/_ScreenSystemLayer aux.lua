local t = Def.ActorFrame {};
local bOpen = false;
local function GetTime(self)
  -- Painfully ugly, sorry.
  local c = self:GetChildren();
  local tTime = { Hour = nil, Minute = nil, Second = nil, Append = nil};
  
  if Hour() then tTime.Hour = Hour() else tTime.Hour = 0 end;
  if Minute() then tTime.Minute = Minute() else tTime.Minute = 0 end;
  if Second() then tTime.Second = Second() else tTime.Second = 0 end;
  
  if( Hour() < 12 ) then 
    tTime.Append = "AM" 
  else 
    tTime.Append = "PM" 
  end;
  
  if( Hour() == 0 ) then
    tTime.Hour = 12;
  end;
  
  c.Time:settextf("%02i:%02i:%02i %s",tTime.Hour,tTime.Minute,tTime.Second,tTime.Append);
end;


local function CreditsText()
	local text = LoadFont("_avenirnext lt pro bold/20px") .. {
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM-16):zoom(1.3):strokecolor(color("0,0,0,1")):playcommand("Refresh") end,
		RefreshCommand=function(self)
		--Other coin modes
			if GAMESTATE:IsEventMode() then self:settext('') return end
			if GAMESTATE:GetCoinMode()=='CoinMode_Free' then self:settext('FREE PLAY') return end
			if GAMESTATE:GetCoinMode()=='CoinMode_Home' then self:settext('HOME MODE') return end
		--Normal pay
			local coins=GAMESTATE:GetCoins()
			local coinsPerCredit=PREFSMAN:GetPreference('CoinsPerCredit')
			local credits=math.floor(coins/coinsPerCredit)
			local remainder=math.mod(coins,coinsPerCredit)
			local s='CREDIT:'
			if credits > 1 then
				s='CREDITS:'..credits
			elseif credits == 1 then
				s=s..credits
			else
				s=s..0
			end
			self:halign(0.5)
			self:settext(s)
		end;
		UpdateVisibleCommand=function(self)
			local screen = SCREENMAN:GetTopScreen();
			local bShow = true;
			if screen then
				local sClass = screen:GetName();
				bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" );
			end;

			self:visible( bShow );
		end;
		CoinInsertedMessageCommand=function(s) s:stoptweening():playcommand("Refresh") end,
		RefreshCreditTextMessageCommand=function(s) s:stoptweening():playcommand("Refresh") end,
		PlayerJoinedMessageCommand=function(s) s:stoptweening():playcommand("Refresh") end,
		ScreenChangedMessageCommand=function(s) s:stoptweening():playcommand("Refresh") end,
	};
	return text;
end;

local function PlayerText( pn )
	local text = LoadFont(Var "LoadingScreen","credits") .. {
		InitCommand=function(self)
			self:name("Credits" .. PlayerNumberToString(pn))
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen");
		end;
		UpdateTextCommand=function(s)
			--s:settext(PROFILEMAN:GetProfile(pn):GetDisplayName())
			s:settext("")
		end;
		UpdateVisibleCommand=function(self)
			local screen = SCREENMAN:GetTopScreen();
			local bShow = true;
			if screen then
				local sClass = screen:GetName();
				bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" );
			end

			self:visible( bShow );
		end
	};
	return text;
end;

t[#t+1] = Def.ActorFrame {
  --CreditsText();
	PlayerText( PLAYER_1 );
  PlayerText( PLAYER_2 );
  Def.ActorFrame {
    LoadActor(THEME:GetPathB("","_frame 3x3"),"rounded black",96,12) .. {
      Name="Background";
    };
    LoadFont("Common Normal") ..  {
      Text="Test";
      Name="Time";
      InitCommand=function(s) s:zoom(0.675) end,
    };
    --
    BeginCommand=function(self)
      self:SetUpdateFunction( GetTime );
      self:SetUpdateRate( 1/30 );
    end;
  };
  ToggleConsoleDisplayMessageCommand=function(self)   
    bOpen = not bOpen;
    if bOpen then self:playcommand("Show") else self:playcommand("Hide") end
  end;
  InitCommand=function(s) s:xy(SCREEN_RIGHT-50,10):visible(false) end,
  ShowCommand=function(s) s:finishtweening():visible(true) end,
  HideCommand=function(s) s:finishtweening():visible(false) end,
};
return t;
