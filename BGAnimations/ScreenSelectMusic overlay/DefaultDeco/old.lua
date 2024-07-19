local numwh = THEME:GetMetric("MusicWheel","NumWheelItems")+2
local SongAttributes = LoadModule "SongAttributes.lua"
local Radar = LoadModule "DDR Groove Radar.lua"
local Arrows = Def.ActorFrame{};
for i=1,2 do
	Arrows[#Arrows+1] = Def.ActorFrame{
		Name="Arrow";
		InitCommand=function(s) s:xy(i==1 and _screen.cx-155 or _screen.cx+155,_screen.cy+264):rotationy(i==1 and 0 or 180):zoom(0.9) end,
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
			s:accelerate(0.3):addx(i==1 and -100 or 100):diffusealpha(0)
		end,
		NextSongMessageCommand=function(s)
			if i==2 then s:stoptweening():x(_screen.cx+175):decelerate(0.5):x(_screen.cx+155) end
		end, 
		PreviousSongMessageCommand=function(s)
			if i==1 then s:stoptweening():x(_screen.cx-175):decelerate(0.5):x(_screen.cx-155) end
		end,
		quadButton(1)..{
			InitCommand=function(s) s:setsize(60,60):visible(false) end,
			TopPressedCommand=function(s)
				SOUND:PlayOnce(THEME:GetPathS("",""..ThemePrefs.Get("WheelType").."_MusicWheel change"))
				local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
				if i==2 then
					s:queuecommand("NextSong")
					mw:Move(1)
					mw:Move(0)
				else
					mw:Move(-1)
					mw:Move(0)
				end
			end,
		};
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


local t = Def.ActorFrame{};

for pn in EnabledPlayers() do
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s) s:xy(pn==PLAYER_1 and (IsUsingWideScreen() and _screen.cx-566 or _screen.cx-420) or (IsUsingWideScreen() and _screen.cx+566 or _screen.cx+420),_screen.cy-200):zoom(0) end,
		OnCommand=function(s) s:sleep(0.3):bounceend(0.25):zoom(1) end,
		OffCommand=function(s) s:sleep(0.5):bouncebegin(0.25):zoom(0) end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
		["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
		Def.Sprite{
			Texture="RadarBase.png",
			InitCommand=function(s) s:y(10):blend(Blend.Add):zoom(1.35):diffuse(ColorMidTone(PlayerColor(pn))):diffusealpha(0.75) end,
		};
		Radar.create_ddr_groove_radar("radar",0,20,pn,350,Alpha(PlayerColor(pn),0.25));
		Def.BitmapText{
			Font="_avenirnext lt pro bold/42px",
			InitCommand=function(s) s:shadowlengthy(5):y(-180) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() then
					if GAMESTATE:GetCurrentSteps(pn) then
						s:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())))
						s:diffuse(CustomDifficultyToColor(ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())))
					end
				else
					s:settext("")
				end
			end,
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/46px",
			InitCommand=function(s) s:y(200):strokecolor(Color.Black) end,
			SetCommand=function(s)
				local song = GAMESTATE:GetCurrentSong()
				local topscore = 0
				if song then
					local steps = GAMESTATE:GetCurrentSteps(pn)
					if steps then
						local profile, scorelist;
						if PROFILEMAN:IsPersistentProfile(pn) then
							profile = PROFILEMAN:GetProfile(pn)
						else
							profile = PROFILEMAN:GetMachineProfile()
						end
						scorelist = profile:GetHighScoreList(song,steps)
						local scores = scorelist:GetHighScores()
						if scores[1] then
							if ThemePrefs.Get("ConvertScoresAndGrades") then
								topscore = SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[1])
							else
								topscore = scores[1]:GetScore()
							end
						end
					end
					if topscore ~= 0 then
						local scorel3 = topscore%1000
						local scorel2 = (topscore/1000)%1000
						local scorel1 = (topscore/1000000)%1000000
						s:visible(true):settextf("%01d"..",".."%03d"..",".."%03d",scorel1,scorel2,scorel3)
					else
						s:visible(false)
					end;
				else
					s:settext(""):visible(false)
				end
			end,
		};
		Def.BitmapText{
			Font="ScreenSelectMusic difficulty",
			InitCommand=function(s) s:zoom(1):y(20):shadowlengthy(5) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() then
					if GAMESTATE:GetCurrentSteps(pn) then
						local meter = GAMESTATE:GetCurrentSteps(pn):GetMeter()
						s:settext(IsMeterDec(meter))
					else
						s:settext("")
					end
				else
					s:settext("")
				end
			end,
		};
		Def.BitmapText{
			Font="CFBPMDisplay",
			InitCommand=function(s) s:y(150):diffuse(color("#dff0ff")):strokecolor(color("#00baff")):maxwidth(200) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() then
					if GAMESTATE:GetCurrentSteps(pn) then
						if GAMESTATE:GetCurrentSteps(pn):GetAuthorCredit() ~= "" then
							s:settext(GAMESTATE:GetCurrentSteps(pn):GetAuthorCredit())
						else
							s:settext("")
						end
					else
						s:settext("")
					end
				else
					s:settext("")
				end
			end,
		};
	}

	for diff in ivalues(Difficulty) do
		t[#t+1] = Def.ActorFrame{
			InitCommand=function(s) s:y((Difficulty:Reverse()[diff]*46)+220):x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6):addx(pn==PLAYER_1 and -100 or 100) end,
			OnCommand=function(s) s:sleep(0.3):decelerate(0.25):addx(pn==PLAYER_1 and 100 or -100) end,
			OffCommand=function(s) s:sleep(0.5):decelerate(0.25):addx(pn==PLAYER_1 and -100 or 100) end,
			CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
			["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:finishtweening():queuecommand("Set") end,
			SetCommand=function(s)
				s:decelerate(0.2)
				local song = GAMESTATE:GetCurrentSong()
				if song then
					local st = GAMESTATE:GetCurrentStyle():GetStepsType()
					if song:GetOneSteps(st,diff) then
						if song:GetOneSteps(st,diff) == GAMESTATE:GetCurrentSteps(pn) then
							s:x(pn==PLAYER_1 and SCREEN_LEFT+20 or SCREEN_RIGHT-20)
						else
							s:x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
						end
					else
						s:x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
					end
				else
					s:x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
				end
			end,
			quadButton(1)..{
				InitCommand=function(s)
					s:setsize(100,40):visible(false)
				end,
				TopPressedCommand=function(s)
					local song = GAMESTATE:GetCurrentSong()
					local st=GAMESTATE:GetCurrentStyle():GetStepsType()
					if song then
					  if song:HasStepsTypeAndDifficulty(st,diff) then
						local steps = song:GetOneSteps(st,diff)
						GAMESTATE:SetCurrentSteps(pn,steps)
						SOUND:PlayOnce(THEME:GetPathS("","ScreenSelectMusic difficulty harder"))
					  end
					end
				end
			};
			Def.Quad{
				InitCommand=function(s) s:setsize(5,36):x(pn==PLAYER_1 and 4 or -4):diffusealpha(0) end,
				SetCommand=function(s)
					local song = GAMESTATE:GetCurrentSong()
					if song then
						local st = GAMESTATE:GetCurrentStyle():GetStepsType()
						if song:GetOneSteps(st,diff) then
							s:diffuse(CustomDifficultyToColor(ToEnumShortString(diff)))
						end
					else
						s:diffusealpha(0)
					end
				end,
			},
			Def.BitmapText{
				Font="_avenirnext lt pro bold/25px",
				InitCommand=function(s) s:x(pn==PLAYER_1 and 14 or -14):diffuse(Color.Black):strokecolor(color("#dedede")):halign(pn==PLAYER_1 and 0 or 1) end,
				SetCommand=function(s)
					local song = GAMESTATE:GetCurrentSong()
					if song then
						local st = GAMESTATE:GetCurrentStyle():GetStepsType()
						if song:GetOneSteps(st,diff) then
							local meter = song:GetOneSteps(st,diff):GetMeter()
							s:settext(IsMeterDec(meter))
						else
							s:settext("")
						end
					else
						s:settext("")
					end
				end,
			};
		}
	end
	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
		t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/InfoPanel"))(pn)..{
			InitCommand=function(s) s:y(_screen.cy-190) end,
		};
	end
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_ShockArrow/default.lua"))(pn)..{
		InitCommand=function(s)
			s:xy(pn==PLAYER_1 and _screen.cx-340 or _screen.cx+340,_screen.cy+50):zoom(0.6)
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
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s) s:xy(pn==PLAYER_1 and _screen.cx-280 or _screen.cx+280,_screen.cy-360)
			:zoom(0):halign(pn==PLAYER_1 and 1 or 0)
		end,
		OnCommand=function(s) s:sleep(0.3):bounceend(0.25):zoom(1) end,
		OffCommand=function(s) s:sleep(0.5):bouncebegin(0.25):zoom(0) end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
		["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
		["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
		CurrentCourseChangedMessageCommand=function(s) s:queuecommand("Set") end,
		Def.ActorFrame{
			Name="FC Ring",
			InitCommand=function(s) s:xy(20,20) end,
			SetCommand=function(self)
				local st=GAMESTATE:GetCurrentStyle():GetStepsType();
				local song=GAMESTATE:GetCurrentSong();
				if song then
					local steps = GAMESTATE:GetCurrentSteps(pn);
			  
					if PROFILEMAN:IsPersistentProfile(pn) then
						profile = PROFILEMAN:GetProfile(pn);
						else
						profile = PROFILEMAN:GetMachineProfile();
					end;
					local scorelist = profile:GetHighScoreList(song,steps);
					assert(scorelist);
					local scores = scorelist:GetHighScores();
					assert(scores);
					local topscore;
					if scores[1] then
						topscore = scores[1];
						assert(topscore);
						local misses = topscore:GetTapNoteScore("TapNoteScore_Miss")+topscore:GetTapNoteScore("TapNoteScore_CheckpointMiss")
						local boos = topscore:GetTapNoteScore("TapNoteScore_W5")
						local goods = topscore:GetTapNoteScore("TapNoteScore_W4")
						local greats = topscore:GetTapNoteScore("TapNoteScore_W3")
						local perfects = topscore:GetTapNoteScore("TapNoteScore_W2")
						local marvelous = topscore:GetTapNoteScore("TapNoteScore_W1")
						if (misses+boos) == 0 and scores[1]:GetScore() > 0 and (marvelous+perfects)>0 then
							if (greats+perfects) == 0 then
								self:diffuse(GameColor.Judgment["JudgmentLine_W1"]);
								self:glowblink();
								self:effectperiod(0.20);
							elseif greats == 0 then
								self:diffuse(GameColor.Judgment["JudgmentLine_W2"]);
								self:glowshift();
							elseif (misses+boos+goods) == 0 then
								self:diffuse(GameColor.Judgment["JudgmentLine_W3"]);
								self:stopeffect();
							elseif (misses+boos) == 0 then
								self:diffuse(GameColor.Judgment["JudgmentLine_W4"]);
								self:stopeffect();
							end;
							self:diffusealpha(1);
						else
							self:diffusealpha(0);
						end;
					else
						self:diffusealpha(0);
					end;
				else
					self:diffusealpha(0);
				end;
			end;
			Def.Sprite{
				Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/grade/ring"),
				InitCommand=function(self) self:zoom(0.3):spin():effectmagnitude(0,0,170) end;
			},
			Def.Sprite{
				Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/grade/lines"),
				InitCommand=function(self) self:zoom(0.3):spin():effectmagnitude(0,0,170) end;
			},
		};
		Def.Quad{
		  SetCommand=function(self)
			local song = GAMESTATE:GetCurrentSong()
			local steps = GAMESTATE:GetCurrentSteps(pn)
	  
			local profile, scorelist;
			local text = "";
			if song and steps then
			  local st = steps:GetStepsType();
			  local diff = steps:GetDifficulty();
	  
			  if PROFILEMAN:IsPersistentProfile(pn) then
				profile = PROFILEMAN:GetProfile(pn);
			  else
				profile = PROFILEMAN:GetMachineProfile();
			  end;
	  
			  scorelist = profile:GetHighScoreList(song,steps)
			  assert(scorelist);
			  local scores = scorelist:GetHighScores();
			  assert(scores);
			  local topscore=0;
			  if scores[1] then
				topscore = SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[1])
			  end;
	  
			  local tier
			  if scores[1] then
				local tier = scores[1]:GetGrade();
				if ThemePrefs.Get("ConvertScoresAndGrades") == true then
					tier = SN2Grading.ScoreToGrade(topscore, diff)
				end
				if scores[1]:GetScore()>1  then
				  self:LoadBackground(THEME:GetPathB("ScreenEvaluationNormal decorations/grade/GradeDisplayEval",ToEnumShortString(tier)));
				  self:diffusealpha(1):zoom(0.2)
				end;
			  else
				self:diffusealpha(0)
			  end;
			else
			  self:diffusealpha(0)
			end;
		  end;
		};
	};
end

return Def.ActorFrame{
	Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:xy(_screen.cx,_screen.cy+254)
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
	Def.ActorFrame{
		InitCommand=function(s)
			s:xy(SCREEN_LEFT,_screen.cy+80):diffusealpha(0)
		end,
		SetCommand=function(s)
			s:stoptweening()
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			local so = ToEnumShortString(GAMESTATE:GetSortOrder())
			if not mw then return end
			if mw:GetSelectedSection() ~= "" and GAMESTATE:GetCurrentSong() and (so == "Group" or so == "Title") then
				s:linear(0.15):diffusealpha(1)
			else
				s:linear(0.15):diffusealpha(0)
			end
		end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
		Def.Sprite{ Texture="GLabel",
			InitCommand=function(s) s:halign(0) end,
			SetCommand=function(s)
				local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
				local so = ToEnumShortString(GAMESTATE:GetSortOrder())
				if not mw then return end
				if mw:GetSelectedSection() ~= "" and GAMESTATE:GetCurrentSong() then
					if so == "Group" then
						s:diffuse(SongAttributes.GetGroupColor(mw:GetSelectedSection()))
					else
						s:diffuse(SongAttributes.GetGroupColor(GAMESTATE:GetCurrentSong():GetGroupName()))
					end
				end
				if mw:GetSelectedSection() ~= "" and GAMESTATE:GetCurrentSong() then
					s:linear(0.15):cropright(0)
				else
					s:linear(0.15):cropright(1)
				end
			end,
			OffCommand=function(s) s:sleep(0.3):linear(0.15):cropright(1) end,
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/20px",
			InitCommand=function(s) s:halign(0):x(10):maxwidth(290) end,
			SetCommand=function(s)
				local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
				local so = ToEnumShortString(GAMESTATE:GetSortOrder())
				if not mw then return end
				if mw:GetSelectedSection() ~= "" and GAMESTATE:GetCurrentSong() then
					if so == "Group" then
						s:strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(mw:GetSelectedSection())))
						s:settext(THEME:GetString("ScreenSelectMusic","GLabelGROUP").."/"..SongAttributes.GetGroupName(mw:GetSelectedSection()))
					elseif so == "Title" then
						s:strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(GAMESTATE:GetCurrentSong():GetGroupName())))
						s:settext(THEME:GetString("ScreenSelectMusic","GLabelFrom")..": "..SongAttributes.GetGroupName(GAMESTATE:GetCurrentSong():GetGroupName()))
					else
						s:settext("")
					end
				end
				if mw:GetSelectedSection() ~= "" and GAMESTATE:GetCurrentSong() then
					s:linear(0.15):cropright(0)
				else
					s:linear(0.15):cropright(1)
				end
			end,
			OffCommand=function(s) s:sleep(0.3):linear(0.15):cropright(1) end,
		};
	};
	loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/DefaultDeco/BPM.lua"))(0.5)..{
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy+120) end,
		StartSelectingStepsMessageCommand=function(self)
			self:sleep(0.3):decelerate(0.3):diffusealpha(0):queuecommand("Hide")
		end;
		HideCommand=function(s) s:visible(false) end,
		SongUnchosenMessageCommand=function(self)
			self:visible(true):linear(0.3):diffusealpha(1)
		end;
	};
	Arrows;
	loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/DefaultDeco/BannerHandler"))()..{
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-150):diffusealpha(1):draworder(1):zoomy(0) end,
  		OnCommand=function(s) s:zoomy(0):sleep(0.3):bounceend(0.175):zoomy(1) end,
  		OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
	};
	t;
	Def.Sprite{
		Name="SongLength",
		Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
		InitCommand=function(s) s:animate(0):zoom(0.75):xy(_screen.cx-260,_screen.cy-40):zoomy(0) end,
		OnCommand=function(s) s:zoomy(0):sleep(0.3):bounceend(0.175):zoomy(0.75) end,
  		OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
		SetCommand=function(s,p)
			local song = GAMESTATE:GetCurrentSong()
			if song then
				if song:IsLong() then
					s:setstate(0)
					s:visible(true)
				elseif song:IsMarathon() then
					s:setstate(1)
					s:visible(true)
				else
					s:visible(false)
				end
			else
				s:visible(false)
			end
		end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
	};
	loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_CDTITLE.lua"))(_screen.cx+160,_screen.cy-20)..{
		InitCommand=function(s)
			s:visible(ThemePrefs.Get("CDTITLE")):draworder(1):diffusealpha(0)
		end,
		OnCommand=function(s) s:sleep(0.4):decelerate(0.4):diffusealpha(1) end,
		OffCommand=function(s) s:sleep(0.2):decelerate(0.2):diffusealpha(0) end,
	},
	LoadActor("../TwoPartDiff")..{
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
