local SongAttributes = LoadModule "SongAttributes.lua"
local Radar = LoadModule "DDR Groove Radar.lua"

local PS = Def.ActorFrame{};
for pn in EnabledPlayers() do
  PS[#PS+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Banner/TwoPart.lua"))(pn);
  PS[#PS+1] = Def.ActorFrame{
    InitCommand=function(s) s:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,IsUsingWideScreen() and _screen.cy+220 or _screen.cy-240) end,
    CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
		["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
    loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/RadarHandler"))(pn);
    Radar.create_ddr_groove_radar("radar",0,0,pn,125,Alpha(PlayerColor(pn),0.25))..{
			OnCommand=function(s) s:zoom(0):rotationz(-360):decelerate(0.4):zoom(1):rotationz(0) end,
      OffCommand=function(s) s:sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
    };
    Def.BitmapText{
		Font="_avenirnext lt pro bold/42px",
      	InitCommand=function(s) s:shadowlengthy(5):y(-170):zoom(0) end,
      	OnCommand=function(s) s:sleep(0.3):bounceend(0.25):zoom(0.75) end,
		OffCommand=function(s) s:sleep(0.5):bouncebegin(0.25):zoom(0) end,
		SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSteps(pn) then
					s:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())))
					s:diffuse(CustomDifficultyToColor(ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())))
				else
					s:settext("")
				end
			end,
	};
    Def.BitmapText{
			Font="CFBPMDisplay",
			InitCommand=function(s) s:y(130):diffuse(color("#dff0ff")):strokecolor(color("#00baff")):maxwidth(200) end,
			OnCommand=function(s) s:diffusealpha(0):zoomx(3):sleep(0.3):decelerate(0.3):diffusealpha(1):zoomx(1) end,
			OffCommand=function(s) s:accelerate(0.3):zoomx(3):diffusealpha(0) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSteps(pn) then
          local sa = GAMESTATE:GetCurrentSteps(pn):GetAuthorCredit()
					s:settext(sa ~= "" and sa or "" )
				else
					s:settext("")
				end
			end,
		};
    Def.BitmapText{
		Name="Score",
			Font="_avenirnext lt pro bold/36px",
			InitCommand=function(s) s:y(220):strokecolor(Color.Black) end,
			OnCommand=function(s) s:diffusealpha(0):zoomx(3):sleep(0.3):decelerate(0.3):diffusealpha(1):zoomx(1) end,
			OffCommand=function(s) s:accelerate(0.3):zoomx(3):diffusealpha(0) end,
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
    Def.Quad{
    	InitCommand=function(s) s:y(170):zoom(0.15) end,
		OnCommand=function(s) s:diffusealpha(0):sleep(0.3):decelerate(0.3):diffusealpha(1) end,
		OffCommand=function(s) s:accelerate(0.3):diffusealpha(0) end,
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
				  self:diffusealpha(1):zoom(0.15)
				end;
			  else
				self:diffusealpha(0)
			  end;
			else
			  self:diffusealpha(0)
			end;
		  end;
		};
		Def.ActorFrame{
			Name="FC Ring",
			InitCommand=function(s) s:xy(20,180) end,
			OnCommand=function(s) s:diffusealpha(0):zoomx(3):sleep(0.3):decelerate(0.3):diffusealpha(1):zoomx(1) end,
			OffCommand=function(s) s:accelerate(0.3):zoomx(3):diffusealpha(0) end,
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
								self:GetChild("color"):diffuse(GameColor.Judgment["JudgmentLine_W1"])
								:glowblink():effectperiod(0.20)
							elseif greats == 0 then
								self:GetChild("color"):diffuse(GameColor.Judgment["JudgmentLine_W2"]):glowshift()
							elseif (misses+boos+goods) == 0 then
								self:GetChild("color"):diffuse(GameColor.Judgment["JudgmentLine_W3"]):stopeffect();
							elseif (misses+boos) == 0 then
								self:GetChild("color"):diffuse(GameColor.Judgment["JudgmentLine_W4"]):stopeffect();
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
				Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/grade/star.png"),
				InitCommand=function(self) self:zoom(0.3):spin():effectmagnitude(0,0,170) end;
			},
			Def.Sprite{
				Name="color",
				Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/grade/colorstar.png"),
				InitCommand=function(self) self:zoom(0.3):spin():effectmagnitude(0,0,170) end;
			},
		};
  };
  PS[#PS+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_ShockArrow/default.lua"))(pn)..{
    InitCommand=function(s)
        s:xy(pn==PLAYER_1 and _screen.cx-340 or _screen.cx+340,_screen.cy):zoom(0.5)
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
  Def.Actor{
    Name="WheelActor",
    BeginCommand=function(s)
		local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      	mw:xy(_screen.cx,_screen.cy+240):draworder(-1)
	end,
	OnCommand=function(s)
		local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
		mw:diffusealpha(0):sleep(0.4):linear(0.1):diffusealpha(1):SetDrawByZPosition(true)
	end,
	OffCommand=function(s)
		local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
    	mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
    end,
  };
  Def.ActorFrame{
    InitCommand=function(self)
      self:xy(_screen.cx,SCREEN_BOTTOM+604):valign(1)
    end;
    StartSelectingStepsMessageCommand=function(self)
      self:stoptweening():decelerate(0.5):y(SCREEN_BOTTOM)
    end;
    SongUnchosenMessageCommand=function(self)
      self:stoptweening():decelerate(0.25):y(SCREEN_BOTTOM+604)
    end;
    OffCommand=function(self)
      self:stoptweening():decelerate(0.25):y(SCREEN_BOTTOM+604)
    end;
    Def.Quad{
      InitCommand=function(self)
        self:valign(1):setsize(SCREEN_WIDTH,604):y(4)
        :diffuse(color("0,0,0,0.5")):diffusebottomedge(color("0.5,0.3,1,0.5")):blend(Blend.Multiply)
      end;
    };
    Def.Sprite{
      Texture="backerthing",
      InitCommand=function(s) s:valign(1):y(0) end,
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px",
      Text="&MENULEFT;&MENURIGHT; TO SELECT DIFFICULTY  &MENUUP;&MENUDOWN; TO CANCEL  &START; TO CONFIRM",
      InitCommand=function(s) s:y(-70):strokecolor(Color.Black) end,
    };
  };
  
  Def.Quad{
    InitCommand=function(s) s:MaskSource():xy(_screen.cx,_screen.cy-118):setsize(612,112) end,
  };
  Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx+10,_screen.cy-8):MaskDest():ztestmode("ZTestMode_WriteOnPass") end,
    OnCommand=function(s) s:addy(-100):sleep(0.3):decelerate(0.2):addy(100) end,
    OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
    CurrentSongChangedMessageCommand = function(s) s:queuecommand("Set") end,
    CurrentCourseChangedMessageCommand = function(s) s:queuecommand("Set") end,
    ChangedLanguageDisplayMessageCommand = function(s) s:queuecommand("Set") end,
    SetCommand=function(s)
      local song = GAMESTATE:GetCurrentSong()
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      if not mw then return end
      if song then
        s:GetChild("Title"):visible(true):settext(song:GetDisplayFullTitle())
        :diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
        s:GetChild("Artist"):visible(true):settext(song:GetDisplayArtist()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
      elseif mw:GetSelectedType('WheelItemDataType_Section') then
        s:GetChild("Title"):visible(true):settext(SongAttributes.GetGroupName(mw:GetSelectedSection()))
        :diffuse(SongAttributes.GetGroupColor(mw:GetSelectedSection())):strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(mw:GetSelectedSection())))
        s:GetChild("Artist"):visible(false):settext("")
      else
        s:GetChild("Title"):visible(true):settext("")
        s:GetChild("Artist"):visible(false):settext("")
      end
    end,
    Def.Sprite{
      Texture="songbox.png",
      InitCommand=function(s)
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathB("ScreenSelectMusic","decorations/Banner/extra_songbox"))
        end
      end,
    };
    Def.BitmapText{
      Name="Title",
      Font="_avenir next demi bold/20px";
      InitCommand=function(s) s:maxwidth(480):strokecolor(Alpha(Color.Black,0.5)):y(-35) end,
    };
    Def.BitmapText{
      Name="Artist",
      Font="_avenir next demi bold/20px";
      InitCommand=function(s) s:maxwidth(480):y(-10):strokecolor(Alpha(Color.Black,0.5)) end,
    };
    loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Default/BPM"))(0.5)..{
      InitCommand=function(s) s:y(18) end,
    };
    loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_CDTITLE.lua"))(320,-10)..{
      InitCommand=function(s)
        s:visible(ThemePrefs.Get("CDTITLE"))
      end,
    }
  };
  PS;
  StandardDecorationFromFileOptional("Help","Help")..{
	StartSelectingStepsMessageCommand=function(self)
		self:diffusealpha(0)
	end;
	  SongUnchosenMessageCommand=function(self)
		self:diffusealpha(1)
	end;
  }
}