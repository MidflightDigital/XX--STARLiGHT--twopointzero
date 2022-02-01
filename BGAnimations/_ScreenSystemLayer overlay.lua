local function CreditsText()
	local text = LoadFont("_avenirnext lt pro bold/20px") .. {
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM-16):zoom(1):strokecolor(color("0,0,0,1")):playcommand("Refresh") end,
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
	local text = Def.ActorFrame{
		InitCommand=function(self)
			self:name("Credits" .. PlayerNumberToString(pn))
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen");
		end;
		UpdateVisibleCommand=function(self)
			local screen = SCREENMAN:GetTopScreen();
			local bShow = true;
			if screen then
				local sClass = screen:GetName();
				bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" );
			end

			self:visible( bShow );
		end,
		LoadFont(Var "LoadingScreen","credits") .. {
			InitCommand=function(s) s:maxwidth(325):strokecolor(Color.Black) end,
			UpdateTextCommand=function(s)
				local pname = PROFILEMAN:GetProfile(pn):GetDisplayName()
				local Dir = ""
				if ProductID() == "StepMania 5.3" then
					Dir = FILEMAN:GetDirListing("/Appearance/Themes/STARLiGHT/Other/Names/")
				else
					Dir = FILEMAN:GetDirListing("/Themes/STARLiGHT/Other/Names/")
				end
				for _,v in ipairs(Dir) do
					if string.match(v,"(%w+)") == pname then
						s:settext("")
					else
						s:settext(pname)
					end
				end
			end;
		};
		Def.Sprite{
			InitCommand=function(s) s:xy(40,-10) end,
			UpdateTextCommand=function(s)
				local pname = PROFILEMAN:GetProfile(pn):GetDisplayName()
				local Dir = ""
				if ProductID() == "StepMania 5.3" then
					Dir = FILEMAN:GetDirListing("/Appearance/Themes/STARLiGHT/Other/Names/")
				else
					Dir = FILEMAN:GetDirListing("/Themes/STARLiGHT/Other/Names/")
				end
				local image = ""
				for _,v in ipairs(Dir) do
					if string.match(v,"(%w+)") == pname then
						if ProductID() == "StepMania 5.3" then
							image = "/Appearance/Themes/STARLiGHT/Other/Names/"..v
						else
							image = "/Themes/STARLiGHT/Other/Names/"..v
						end
					end
				end
				if image ~= "" then
					s:Load(image):visible(true):zoom(0.5)
				else
				s:visible(false)
			end
		end;
		};
	};
	return text;
end;

local t = Def.ActorFrame {}

t[#t+1] = Def.ActorFrame {
	CreditsText();
	PlayerText( PLAYER_1 );
	PlayerText( PLAYER_2 );
};

return t;
