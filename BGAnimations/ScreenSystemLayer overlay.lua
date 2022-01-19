local function CreditsText()
	local text = LoadFont("_avenirnext lt pro bold/20px") .. {
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM-16):strokecolor(Color.Black):playcommand("Refresh") end,
		RefreshCommand=function(self)
		--Other coin modes
			if GAMESTATE:IsEventMode() then self:settext('EVENT MODE') return end
			if GAMESTATE:GetCoinMode()=='CoinMode_Free' then self:settext('FREE PLAY') return end
			if GAMESTATE:GetCoinMode()=='CoinMode_Home' then self:settext('HOME MODE') return end
			if GAMESTATE:GetCoinMode()=='CoinMode_Pay' then self:settext("SUS MODE") return end
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
 	PlayerText( PLAYER_1 );
	PlayerText( PLAYER_2 );
	CreditsText();
};

-- Text
t[#t+1] = Def.ActorFrame {
	Def.Quad {
		InitCommand=function(s) s:zoomto(SCREEN_WIDTH,30):align(0,0):y(SCREEN_TOP):diffuse(color("0,0,0,0")) end,
		OnCommand=function(s) s:finishtweening():diffusealpha(0.85) end,
		OffCommand=function(s) s:sleep(3):linear(0.5):diffusealpha(0) end,
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/25px";
		Name="Text";
		InitCommand=function(s) s:maxwidth(750):align(0,0):xy(SCREEN_LEFT+10,SCREEN_TOP+10):shadowlength(1):diffusealpha(0) end,
		OnCommand=function(s) s:finishtweening():diffusealpha(1):zoom(0.5) end,
		OffCommand=function(s) s:sleep(3):linear(0.5):diffusealpha(0) end,
	};
	SystemMessageMessageCommand = function(self, params)
		self:GetChild("Text"):settext( params.Message );
		self:playcommand( "On" );
		if params.NoAnimate then
			self:finishtweening();
		end
		self:playcommand( "Off" );
	end;
	HideSystemMessageMessageCommand = function(s) s:finishtweening() end,
};

return t;
