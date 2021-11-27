local t = Def.ActorFrame{
	Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:xy(_screen.cx,_screen.cy)
			SCREENMAN:GetTopScreen():GetChild("Header"):visible(false)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:zbuffer(true):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1)
			:sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1)
			:SetDrawByZPosition(true)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
		end
    };
}

for pn in EnabledPlayers() do
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_Difficulty"))(pn)..{
		InitCommand=function(s) s:diffusealpha(0):draworder(40)
			:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,_screen.cy-230)
		end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
		OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
	};
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler"))(pn)..{
		InitCommand=function(s) s:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,_screen.cy+126) end,
	}
	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
		t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/InfoPanel"))(pn)..{
			InitCommand=function(s) s:visible(false):y(_screen.cy+240) end,
		};
	end
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_ShockArrow/default.lua"))(pn)..{
		InitCommand=function(s)
			s:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,_screen.cy+126):zoom(0.5)
		end,
		SetCommand=function(s)
			local song = GAMESTATE:GetCurrentSong()
			if song then
				local steps = GAMESTATE:GetCurrentSteps(pn)
				if steps then
					if steps:GetRadarValues(pn):GetValue('RadarCategory_Mines') >= 1 then
						s:queuecommand("Anim")
					else
						s:queuecommand("Hide")
					end
				else
					s:queuecommand("Hide")
				end
			else
				s:queuecommand("Hide")
			end
		end,
		CurrentSongChangedMessageCommand=function(s) s:stoptweening():queuecommand("Set") end,
		["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
		OffCommand=function(s) s:queuecommand("Hide") end,	
	}
end


return Def.ActorFrame{
	SongChosenMessageCommand=function(self)
		self:AddChildFromPath(THEME:GetPathB("ScreenSelectMusic","overlay/TwoPartDiff"));
	end;
	Def.ActorFrame{
		Name="SongInfo/Jacket",
		InitCommand=function(s) s:xy(IsUsingWideScreen() and _screen.cx-100 or _screen.cx+20,_screen.cy-396):zoom(IsUsingWideScreen() and 1 or 0.9) end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
		OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
		loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/ADeco/BannerHandler.lua"))();
		loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/ADeco/BPM.lua"))()..{
			InitCommand=function(s) s:xy(140,48) end,
		};
	};
	t;
	Def.Sprite{
		Texture="Stager",
		InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT,SCREEN_TOP+170) end,
		OnCommand=function(s) s:draworder(144):stoptweening():addx(-400):decelerate(0.2):addx(400) end,
		OffCommand=function(s) s:decelerate(0.2):addx(-400) end,
	};
	StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
		InitCommand=function(s)
			s:xy(SCREEN_LEFT+160,SCREEN_TOP+180)
		end,
	};
}