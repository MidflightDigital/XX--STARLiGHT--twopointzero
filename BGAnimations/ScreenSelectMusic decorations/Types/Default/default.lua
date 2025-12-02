local numwh = THEME:GetMetric("MusicWheel","NumWheelItems")+2
local SongAttributes = LoadModule('SongAttributes.lua')
local Radar = LoadModule('DDR Groove Radar.lua')
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local Arrows = Def.ActorFrame{};
for i=1,2 do
	Arrows[#Arrows+1] = Def.ActorFrame{
		Name="Arrow";
		InitCommand=function(s) s:draworder(1):xy(i==1 and _screen.cx-155 or _screen.cx+155,_screen.cy+264):rotationy(i==1 and 0 or 180):zoom(0.9) end,
		OnCommand=function(s)
			s:diffusealpha(0):addx(i==1 and -100 or 100)
			:sleep(0.6):decelerate(0.3):addx(i==1 and 100 or -100):diffusealpha(1)
		end,
		CurrentSongChangedMessageCommand=function(s)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
                    s:bounce():effectmagnitude(i==2 and -10 or 10,0,0):effectperiod(0.5):effectclock("music")
                else
                    s:bounce():effectmagnitude(i==2 and -10 or 10,0,0):effectoffset(0.2):effectclock("beatnooffset")
                end
            else
                s:bounce():effectmagnitude(i==2 and -10 or 10,0,0):effectperiod(1):effectclock("music")
            end
        end,
		OffCommand=function(s) s:sleep(0.2):accelerate(0.2):addx(i==1 and -100 or 100):diffusealpha(0) end,
		StartSelectingStepsMessageCommand=function(s)
			s:finishtweening():accelerate(0.3):addx(i==1 and -100 or 100):diffusealpha(0)
		end,
		SongUnchosenMessageCommand=function(s) s:finishtweening():decelerate(0.3):addx(i==1 and 100 or -100):diffusealpha(1) end,
		NextSongMessageCommand=function(s)
			if i==2 then s:stoptweening():x(_screen.cx+175):decelerate(0.5):x(_screen.cx+155) end
		end, 
		PreviousSongMessageCommand=function(s)
			if i==1 then s:stoptweening():x(_screen.cx-175):decelerate(0.5):x(_screen.cx-155) end
		end,
		Def.Sprite{ Texture=THEME:GetPathG("","_shared/arrows/base");};
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/arrows/color");
			InitCommand=function(s) s:diffuse(color("#00f0ff")) end,
			NextSongMessageCommand=function(s)
				if i==2 then
					s:stoptweening():diffuse(color("#ff00ea")):sleep(0.5):diffuse(color("#00f0ff"))
				end
			end, 
			PreviousSongMessageCommand=function(s)
				if i==1 then
					s:stoptweening():diffuse(color("#ff00ea")):sleep(0.5):diffuse(color("#00f0ff"))
				end
			end, 
		};
	};
end;


local PlayerFrames = Def.ActorFrame{}

for pn in EnabledPlayers() do
	local t = Def.ActorFrame{
		CurrentSongChangedMessageCommand=function(s) s:queuecommand('Set') end,
		CurrentCourseChangedMessageCommand=function(s) s:queuecommand('Set') end,
		['CurrentSteps'..ToEnumShortString(pn)..'ChangedMessageCommand']=function(s) s:queuecommand('Set') end,
		['CurrentTrail'..ToEnumShortString(pn)..'ChangedMessageCommand']=function(s) s:queuecommand('Set') end,
		SetCommand=function(self)
			local c = self:GetChildren()
			local c2 = self:GetChild('SongStats'):GetChildren()
		
			local song = GAMESTATE:GetCurrentSong()
			local steps = GAMESTATE:GetCurrentSteps(pn)
			if not (song and steps) then
				c.Grade:visible(false)
				c2.Score:visible(false)
				c2.DiffName:visible(false)
				c2.Meter:visible(false)
				c2.ChartArtist:visible(false)
				return
			end
			
			local difficulty = ToEnumShortString(steps:GetDifficulty())
			c2.DiffName:visible(true)
				:settext(THEME:GetString('CustomDifficulty', difficulty))
				:diffuse(CustomDifficultyToColor(difficulty))
			c2.Meter:visible(true)
				:settext(IsMeterDec(steps:GetMeter()))
			
			local credits = steps:GetAuthorCredit()
			if credits == '' then
				c2.ChartArtist:visible(false)
			else
				c2.ChartArtist:visible(true):settext(credits)
			end
				
			local profile
			if PROFILEMAN:IsPersistentProfile(pn) then
				profile = PROFILEMAN:GetProfile(pn)
			else
				profile = PROFILEMAN:GetMachineProfile()
			end
			local scores = profile:GetHighScoreList(song, steps):GetHighScores()
			local score = scores[1]
			
			if not score then
				c.Grade:visible(false)
				c2.Score:visible(false)
				return
			end
			c.Grade:visible(true)
			c2.Score:visible(true)
			
			self:playcommand('SetScore', { Stats = score, Steps = steps })
		end,
	}
	PlayerFrames[#PlayerFrames+1] = t
	
	t[#t+1] = Def.ActorFrame{
		Name='SongStats',
		InitCommand=function(s) s:xy(pn==PLAYER_1 and (IsUsingWideScreen() and _screen.cx-566 or _screen.cx-420) or (IsUsingWideScreen() and _screen.cx+566 or _screen.cx+420),_screen.cy-200):zoom(0) end,
		OnCommand=function(s) s:sleep(0.3):bounceend(0.25):zoom(1) end,
		OffCommand=function(s) s:sleep(0.5):bouncebegin(0.25):zoom(0) end,
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/RadarBase.png"),
			InitCommand=function(s) s:y(10):blend(Blend.Add):zoom(1.35):diffuse(ColorMidTone(PlayerColor(pn))):diffusealpha(0.75) end,
		},
		Radar.create_ddr_groove_radar("radar",0,20,pn,350,Alpha(PlayerColor(pn),0.25)),
		Def.BitmapText{
			Name="DiffName",
			Font="_avenirnext lt pro bold/42px",
			InitCommand=function(s) s:shadowlengthy(5):y(-180) end,
		},
		ScoreAndGrade.CreateScoreRollingActor{
			Name='Score',
			Font='_avenirnext lt pro bold/46px',
			Load='RollingNumbersSongData',
			InitCommand=function(self)
				self:y(200):strokecolor(Color.Black)
			end,
		},
		Def.BitmapText{
			Name="Meter",
			Font="ScreenSelectMusic difficulty",
			InitCommand=function(s) s:zoom(1):y(20):shadowlengthy(5) end,
		},
		Def.BitmapText{
			Name="ChartArtist",
			Font="CFBPMDisplay",
			InitCommand=function(s) s:y(150):diffuse(color("#dff0ff")):strokecolor(color("#00baff")):maxwidth(200) end,
		},
	}
	t[#t+1] = LoadActor("_Diff",pn)..{
		InitCommand=function(s) s:y(_screen.cy-280):x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6):addx(pn==PLAYER_1 and -100 or 100) end,
		OnCommand=function(s) s:sleep(0.3):decelerate(0.25):addx(pn==PLAYER_1 and 100 or -100) end,
		OffCommand=function(s) s:sleep(0.5):decelerate(0.25):addx(pn==PLAYER_1 and -100 or 100) end,
	}
	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
		t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/InfoPanel"))(pn)..{
			InitCommand=function(s) s:y(_screen.cy-190) end,
		};
	end
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/_ShockArrow/default.lua"))(pn)..{
		InitCommand=function(s)
			s:xy(pn==PLAYER_1 and _screen.cx-340 or _screen.cx+340,_screen.cy+50):zoom(0.6)
		end,
		OffCommand=function(s) s:queuecommand("Hide") end,
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
	}
	t[#t+1] = ScoreAndGrade.CreateGradeActor{
		Name='Grade',
		Big=true,
		InitCommand=function(self)
			self:halign(pn==PLAYER_1 and 1 or 0)
			if IsUsingWideScreen() then
				self:x(pn==PLAYER_1 and _screen.cx-280 or _screen.cx+280):y(_screen.cy-360)
			else
				self:x(pn==PLAYER_1 and _screen.cx-260 or _screen.cx+260):y(_screen.cy-320)
			end
			self:GetChild('FullCombo'):zoom(1.5):addy(50)
		end,
		OnCommand=function(s) s:zoom(0):sleep(0.3):bounceend(0.25):zoom(0.2) end,
		OffCommand=function(s) s:sleep(0.5):bouncebegin(0.25):zoom(0) end,
	}
end

return Def.ActorFrame{
    Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:xy(_screen.cx,_screen.cy+254):draworder(-1)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:fov(60):vanishpoint(_screen.cx,_screen.cy+254)
			mw:SetDrawByZPosition(true)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
		end,
		StartSelectingStepsMessageCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
		end,
    };
	Def.Actor{
		OnCommand=function(s)
			if SCREENMAN:GetTopScreen() then
				local wheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetChild("MusicWheelItem")
				for i=1,numwh do
					local inv = numwh-math.floor(i-numwh/2+0.5)+1
					if i == 9 then
						wheel[i]:zoom(0):sleep(0.3):decelerate(0.4):zoom(1)
					elseif i == 2 or i == 3 or i == 4 then
						wheel[i]:addx(-SCREEN_WIDTH):sleep(0.3):decelerate(0.4):addx(SCREEN_WIDTH)
					elseif i == 6 or i == 7 or i == 8 then
						wheel[i]:addx(SCREEN_WIDTH):sleep(0.3):decelerate(0.4):addx(-SCREEN_WIDTH)
					end
				end
			end
		end,
	};
	SongUnchosenMessageCommand=function(s) 
		s:sleep(0.2):queuecommand("Remove")
	end,
	PlayerFrames,
	Arrows,

	Def.ActorFrame{
		Name = "Group Label",
		InitCommand=function(s)
			s:xy(SCREEN_LEFT,_screen.cy+80):diffusealpha(0)
		end,
		CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
		SetCommand=function(s)
			s:finishtweening()
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			local so = ToEnumShortString(GAMESTATE:GetSortOrder())
			if not mw then return end
			if mw:GetSelectedSection() ~= "" and GAMESTATE:GetCurrentSong() then
				if so == "Group" or so == "Title" then
					s:linear(0.15):diffusealpha(1)
				else
					s:linear(0.15):diffusealpha(0)
				end

				if so == "Group" then
					s:GetChild("Label"):diffuse(SongAttributes.GetGroupColor(mw:GetSelectedSection()))
					s:GetChild("Text"):strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(mw:GetSelectedSection())))
					:settext(THEME:GetString("ScreenSelectMusic","GLabelGROUP").."/"..SongAttributes.GetGroupName(mw:GetSelectedSection()))
				elseif so == "Title" then
					s:GetChild("Text"):strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(GAMESTATE:GetCurrentSong():GetGroupName())))
					:settext(THEME:GetString("ScreenSelectMusic","GLabelFrom")..": "..SongAttributes.GetGroupName(GAMESTATE:GetCurrentSong():GetGroupName()))
				elseif so  == "Preferred" then
					s:GetChild("Text"):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(GAMESTATE:GetCurrentSong())))
					:settext(SongAttributes.GetGroupName(mw:GetSelectedSection()))
					s:GetChild("Label"):diffuse(SongAttributes.GetMenuColor(GAMESTATE:GetCurrentSong()))
				else
					s:GetChild("Label"):diffuse(SongAttributes.GetGroupColor(GAMESTATE:GetCurrentSong():GetGroupName()))
					s:GetChild("Text"):settext("")
				end
				s:GetChild("Label"):linear(0.15):cropright(0)
				s:GetChild("Text"):linear(0.15):cropright(0)
			else
				s:GetChild("Label"):linear(0.15):cropright(1)
				s:GetChild("Text"):linear(0.15):cropright(1)
			end
		end,
		Def.Sprite{
			Name="Label",
			Texture="GLabel",
			InitCommand=function(s) s:halign(0) end,
			OffCommand=function(s) s:sleep(0.3):linear(0.15):cropright(1) end,
		};
		Def.BitmapText{
			Name="Text",
			Font="_avenirnext lt pro bold/20px",
			InitCommand=function(s) s:halign(0):x(10):maxwidth(290) end,
			OffCommand=function(s) s:sleep(0.3):linear(0.15):cropright(1) end,
		};
	};

	loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Types/Default/BPM.lua"))(0.5)..{
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy+120) end,
		StartSelectingStepsMessageCommand=function(self)
			self:sleep(0.3):decelerate(0.3):diffusealpha(0):queuecommand("Hide")
		end;
		HideCommand=function(s) s:visible(false) end,
		SongUnchosenMessageCommand=function(self)
			self:visible(true):linear(0.3):diffusealpha(1)
		end;
	};
	loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Types/Default/BannerHandler"))()..{
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-150):diffusealpha(1):draworder(1):zoomy(0) end,
  		OnCommand=function(s) s:zoomy(0):sleep(0.3):bounceend(0.175):zoomy(1) end,
  		OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
	};
	loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/_CDTITLE.lua"))(_screen.cx+160,_screen.cy-20)..{
		InitCommand=function(s)
			s:visible(ThemePrefs.Get("CDTITLE")):draworder(1):diffusealpha(0)
		end,
		OnCommand=function(s) s:sleep(0.4):decelerate(0.4):diffusealpha(1) end,
		OffCommand=function(s) s:sleep(0.2):decelerate(0.2):diffusealpha(0) end,
	},
	LoadActor("../../_shared/TwoPartDiff")..{
		InitCommand=function(s) s:draworder(1) end,
	},
	loadfile(THEME:GetPathG("ScreenWithMenuElements","Header/default.lua"))()..{
		InitCommand=function(s) s:draworder(2) end,
	};
	StandardDecorationFromFileOptional("Help","Help");
	StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
		InitCommand=function(s)
			s:xy(_screen.cx,SCREEN_TOP+104):draworder(2)
		end,
	};
};