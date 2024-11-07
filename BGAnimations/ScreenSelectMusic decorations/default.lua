local Deco = Def.ActorFrame{};
if not GAMESTATE:IsCourseMode() then
	Deco[#Deco+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Types/"..ThemePrefs.Get("WheelType").."/default.lua"))();
end;

local jk = LoadModule"Jacket.lua"

local op = Def.ActorFrame{};

if THEME:GetMetric("ScreenSelectMusic","UseOptionsList") then
	op[#op+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/_OptionsList/default.lua"))();
end

return Def.ActorFrame{
	Def.Actor{
		OnCommand=function(s) 
			setenv("OPList",0)
		end,
	};
	PlayerJoinedMessageCommand=function(self,param)
		SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectMusic"):StartTransitioningScreen("SM_GoToNextScreen")
  	end;
	CodeMessageCommand=function(s,p)
		if p.PlayerNumber == PLAYER_1 then
			if p.Name == "OpenOL" then
				SCREENMAN:GetTopScreen():OpenOptionsList(PLAYER_1)
			end
		end
		if p.PlayerNumber == PLAYER_2 then
			if p.Name == "OpenOL" then
				SCREENMAN:GetTopScreen():OpenOptionsList(PLAYER_2)
			end
		end
	end,
	OffCommand=function(s)
		LoadFromProfilePrefs()
		s:sleep(1):queuecommand("Dim")
	end,
	DimCommand=function(s) SOUND:DimMusic(0,math.huge) end,
	Def.Sound{
		File=THEME:GetPathS("","_swoosh in"),
		OnCommand=function(s) s:play() end,
	},
	Def.Sound{
		Name="MWChange",
		File=THEME:GetPathS("","MusicWheel/dance/Default/change.ogg"),
		IsAction=true,
	};
	Deco;
	loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/InputHandler.lua"))();
	op;
	Def.Sound{
		File=THEME:GetPathS("","_swoosh out"),
		OffCommand=function(s) s:sleep(1):queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
	Def.Sound{
		File=THEME:GetPathB("ScreenSelectMusic","decorations/_shared/bruh.ogg"),
		OffCommand=function(s)
			local song = GAMESTATE:GetCurrentSong()
			local gettitle = song:GetDisplayMainTitle()
			if gettitle == "BroGamer" then
				if PROFILEMAN:IsPersistentProfile(PLAYER_1) or PROFILEMAN:IsPersistentProfile(PLAYER_2) then
					if PROFILEMAN:GetSongNumTimesPlayed(song, 'ProfileSlot_Player1') >= 10 or PROFILEMAN:GetSongNumTimesPlayed(song, 'ProfileSlot_Player2') >=10 then
						SCREENMAN:SystemMessage("You've played BroGamer "..PROFILEMAN:GetSongNumTimesPlayed(song, 'ProfileSlot_Player1').." times. Please seek help.")
						s:sleep(0.5):queuecommand("Bruh")
					end
				end
			end
		end,
		BruhCommand=function(s)
			s:play()
		end,
	};
}
