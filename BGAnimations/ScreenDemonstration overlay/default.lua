local jk = LoadModule "Jacket.lua"

return Def.ActorFrame{
	InitCommand=function(s)
		setenv("JoinP1",0)
		setenv("JoinP2",0)
	end,
	StorageDevicesChangedMessageCommand=function(self, params)
		if GAMESTATE:GetCoins() >= GAMESTATE:GetCoinsNeededToJoin() then
			if MEMCARDMAN:GetCardState(PLAYER_1) == 'MemoryCardState_checking' then
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGSReset"):StartTransitioningScreen("SM_GoToNextScreen")
			elseif MEMCARDMAN:GetCardState(PLAYER_2) == 'MemoryCardState_checking' then
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGSReset"):StartTransitioningScreen("SM_GoToNextScreen")
			end
		end
	end;
	Def.ActorFrame{
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_TOP+36):zoom(IsUsingWideScreen() and 1 or 0.9) end,
		Def.Sprite{
			Texture="header",
			InitCommand=function(s) s:y(20) end,
		};
		Def.Sprite{
			Texture="DEMONSTRATION",
			InitCommand=function(s) s:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.5")):effectperiod(2) end,
		};
	};
	
	Def.ActorFrame{
		InitCommand=function(s) s:xy(_screen.cx,IsUsingWideScreen() and _screen.cy-210 or _screen.cy-60) end,
		Def.ActorFrame {
			InitCommand=function(s) s:y(260) end,
			Def.Sprite{
				Texture="titlebox",
			};
			-- Title
			Def.BitmapText{
				Font="_avenirnext lt pro bold/20px";
				InitCommand=function(s) s:maxwidth(300):y(-8):playcommand("Update") end,
				CurrentSongChangedMessageCommand=function(s) s:playcommand("Update") end,
				UpdateCommand=function(self)
					local title;
					local song = GAMESTATE:GetCurrentSong();
					if song then
						if song:GetDisplaySubTitle() == ""  then
							title = song:GetDisplayFullTitle();
						else
							title = song:GetDisplayFullTitle();
						end;
					else
						title = "???";
					end;
					self:settext(title);
				end;
			};
			-- Artist
			Def.BitmapText{
				Font="_avenirnext lt pro bold/20px";
				InitCommand=function(s) s:y(16):maxwidth(300):playcommand("Update") end,
				CurrentSongChangedMessageCommand=function(s) s:playcommand("Update") end,
				UpdateCommand=function(self)
					local artist;
					local song = GAMESTATE:GetCurrentSong();
					if song then
						artist = song:GetDisplayArtist();
					else
						artist = "???";
					end;
					self:settext(artist);
				end;
			};
		};
		Def.ActorFrame{
			Def.Sprite{
				Texture="_jacket back",
			};
			Def.Sprite {
				Name="Song Jacket";
				InitCommand=function(s) s:diffusealpha(1) end,
				OnCommand=function(self)
					local song = GAMESTATE:GetCurrentSong();
					if song then
						self:Load(jk.GetSongGraphicPath(song,"Jacket"))
						self:setsize(378,378);
					else
						self:diffusealpha(0);
					end;
				end;
				OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
			};
		};
	};
	Def.Sprite{
		InitCommand=function(s) s:draworder(100):xy(_screen.cx,_screen.cy+340):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#B4FF01")) end,
		BeginCommand=function(s) s:queuecommand("Set") end,
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
	Def.Actor{
		CoinInsertedMessageCommand=function(s)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenLogo"):StartTransitioningScreen("SM_GoToNextScreen")
		end,
	};
	loadfile(THEME:GetPathG("","ScreenWithMenuElements footer"))();
};
