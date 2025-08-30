local jk = LoadModule "Jacket.lua"
local outDelay = THEME:GetMetric('ScreenGameplay', 'OutTransitionSeconds')

local List = {
	'Tohoku EVOLVED',
	'COVID',
	'Outbreak'
}

local function get_UI_video_path()
	local path = THEME:GetCurrentThemeDirectory() .. 'BGAnimations/ScreenWithMenuElements background/' .. ThemePrefs.Get('MenuBG') .. '/'
	
	local files = FILEMAN:GetDirListing( path, false, true )
	
	for i,v in ipairs(files) do
		local p = string.lower(v)
		
		if string.match(p, '.avi') or string.match(p, '.mp4') then
			return v
		end
	end
	
	return false
end

local t = Def.ActorFrame{};

t[#t+1] = StatsEngine()

local LoadingScreen = Var "LoadingScreen"
local lastAnnouncer = ANNOUNCER:GetCurrentAnnouncer()

if getenv("RiskyMode") == 1 then
	if SN3Debug then SCREENMAN:SystemMessage("Risky+ Enabled!") end
	for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
		t[#t+1] = Def.ActorFrame{
			OnCommand=function(s)
				local screen = SCREENMAN:GetTopScreen()
				Battery = screen:GetLifeMeter(pn)
			end,
			JudgmentMessageCommand=function(self, params)
				if params.Player ~= pn then return end
				if params.TapNoteScore or params.HoldNoteScore then
					local Tap = params.TapNoteScore
					if Tap == "TapNoteScore_W3" or Tap == "TapNoteScore_W4" then
						Battery:ChangeLives(-1)
					end
				end
			end,
		}
	end
end

t[#t+1] = Def.ActorFrame {
	OffCommand=function(s)
		local st = STATSMAN:GetCurStageStats()
		
		-- delay before shutter close
		s:sleep(BeginOutDelay())
		
		if st:AllFailed() then
			s:queuecommand('SetFail')
		else
			--- Cleared / Send Notes Ended
			s:queuecommand('SetOff')
		end
	end,
	
	Def.Sound {
		File=THEME:GetPathS('', 'swoosh'),
		SetOffCommand=function(s) s:play() end,
	},
	Def.Sound {
		File=THEME:GetPathS('', '_failed'),
		SetFailCommand=function(s) s:sleep(0.4):queuecommand('Play') end,
		PlayCommand=function(s) s:play() end,
	},
	Def.Sound {
		File=GetMenuMusicPath 'stage',
		NextCourseSongMessageCommand=function(s) s:sleep(0.45):queuecommand('Play') end,
		PlayCommand=function(s) s:play() end,
	},
	Def.Actor {
		SetOffCommand=function(s) s:sleep(0.2):queuecommand('ApplauseCleared') end,
		SetFailCommand=function(s) s:sleep(0.2):queuecommand('ApplauseFailed') end,
		NextCourseSongMessageCommand=function(s) s:sleep(0.2):queuecommand('ApplauseStage') end,
		ApplauseClearedCommand=function(s) SOUND:PlayOnce(THEME:GetPathS( '', '_applause cleared' )) end,
		ApplauseFailedCommand=function(s) SOUND:PlayOnce(THEME:GetPathS( '', '_applause failed' )) end,
		ApplauseStageCommand=function(s) SOUND:PlayOnce(THEME:GetPathS( '', '_applause stage' )) end,
	},
	Def.Actor {
		OffCommand=function(s)
			-- don't play applause cleared/failed immediately
			ANNOUNCER:SetCurrentAnnouncer('')
			s:sleep(BeginOutDelay()):queuecommand('Play')
		end,
		PlayCommand=function()
			local st = STATSMAN:GetCurStageStats()
			if lastAnnouncer then
				ANNOUNCER:SetCurrentAnnouncer(lastAnnouncer)
			end
			
			if st:AllFailed() then
				SOUND:PlayAnnouncer('gameplay failed')
			else
				SOUND:PlayAnnouncer('gameplay cleared')
			end
		end,
		-- CancelCommand doesn't seem to work, so...
		CancelMessageCommand=function()
			if lastAnnouncer then
				ANNOUNCER:SetCurrentAnnouncer(lastAnnouncer)
			end
		end,
	},
	Def.Actor {
		NextCourseSongMessageCommand=function(s) s:stoptweening() end,
		CurrentSongChangedMessageCommand=function(s)
			if GAMESTATE:IsCourseMode() then
				local curStage = GAMESTATE:GetLoadingCourseSongIndex()+1
				
				-- play ready announcer from stage 2 and up (Course Mode)
				if curStage > 1 then
					s:sleep(BeginReadyDelay()):queuecommand('Play')
				end
			end
		end,
		PlayCommand=function(s) SOUND:PlayAnnouncer('gameplay ready') end,
	},
	Def.Actor {
		NextCourseSongMessageCommand=function(s) s:sleep(2):queuecommand('Play') end,
		PlayCommand=function(s)
			local curStage = GAMESTATE:GetLoadingCourseSongIndex()+1
			local stageName = 'stage ' .. curStage
			local maxStages = GAMESTATE:GetCurrentCourse():GetEstimatedNumStages()
		
			if curStage == maxStages then
				stageName = 'stage final'
			end
			
			SOUND:PlayAnnouncer(stageName)
		end,
	},
};

t[#t+1] = Def.Actor{
    AfterStatsEngineMessageCommand = function(_,params)
      local pn = params.Player
      --So there's settings in StepMania for enabling/disabling fail for Beginner/Easy difficulties.
      --They don't do anything normally.
      --Yeah I don't know why we need to do this but we do and it's absolutely fucking stupid.
      if PREFSMAN:GetPreference("FailOffForFirstStageEasy") == false and GAMESTATE:GetCurrentSteps(pn):GetDifficulty() == 'Difficulty_Easy' then
        if GAMESTATE:GetCurrentStage() == 0 or CustStageCheck() == 1 or GAMESTATE:GetCurrentStage() == 13 then
          GAMESTATE:SetFailTypeExplicitlySet()
        end
      end
      if PREFSMAN:GetPreference("FailOffInBeginner") == false and GAMESTATE:GetCurrentSteps(pn):GetDifficulty() == 'Difficulty_Beginner' then
        GAMESTATE:SetFailTypeExplicitlySet()
      end
      local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

			
			-- Lets NOT do this as it just messes up Stats.xml with theme-specific scores. Instead we should 
			-- display different scores depending on the ThemePrefs.Get("ConvertScoresAndGrades") setting
      -- local aScore = params.Data.AScoring
      -- pss:SetScore(aScore.Score)
      -- pss:SetCurMaxScore(aScore.MaxScore)

      
      local fast, slow = 0, 0

      local fastSlow = params.Data.FastSlowRecord
      if fastSlow then
        fast = fastSlow.Fast
        slow = fastSlow.Slow
      end

      local short = ToEnumShortString(pn)
      setenv("numFast"..short, fast)
      setenv("numSlow"..short, slow)
    end,
};



for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	local playerPrefs = ProfilePrefs.Read(GetProfileIDForPlayer(pn))
  if GAMESTATE:GetPlayMode()=="PlayMode_Oni" then
    local trailHasSpeedMod = false;
    local trailHasAppearanceMode = false;
    local curTrail = GAMESTATE:GetCurrentTrail(pn):GetTrailEntries()
    local temp = #curTrail

    if curTrail[1] then
      for i=1,temp do
        local modString = curTrail[temp]:GetNormalModifiers()
        if string.find(modString,"x") or string.find(modString,"X") then
          trailHasSpeedMod = true;
        end
        if string.find(modString,"Hidden") or string.find(modString,"Sudden") or string.find(modString,"Stealth") then
          trailHasAppearanceMode = true;
        end
      end
    end
    if not trailHasSpeedMod then
      t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/SpeedKill"))();
    end
    if not trailHasAppearanceMode then
		t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/Towel"))(pn);
    end
  else
    t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/SpeedKill"))();
    t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/Towel"))(pn);
  end
  t[#t+1] = Def.ActorFrame{
    InitCommand=function(s) s:y(_screen.cy-346):draworder(-1)
      if IsUsingWideScreen() then
        s:x(pn==PLAYER_1 and _screen.cx-494 or _screen.cx+494)
      else
        s:x(pn==PLAYER_1 and _screen.cx-320 or _screen.cx+320)
      end
	  if GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current'):Reverse() == 1 then
		s:y(_screen.cy-246)
	  else
		s:y(_screen.cy-346)
	  end
	  s:visible(playerPrefs.targetscore ~= "Off")
    end,
    OnCommand=function(s) s:zoom(0):sleep(0.3):bounceend(0.2):zoom(1) end,
    OffCommand=function(s) s:linear(0.2):zoom(0) end,
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px";
      JudgmentMessageCommand=function(self)
        self:y(256)
        local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
        local steps = GAMESTATE:GetCurrentSteps(pn);
        local song = GAMESTATE:GetCurrentSong();
        local st=GAMESTATE:GetCurrentStyle():GetStepsType();
        local profile = PROFILEMAN:GetProfile(pn);
        scorelist = profile:GetHighScoreList(song,steps);
        local scores = scorelist:GetHighScores();
        local topscore = 0;
        if scores[1] then
          topscore = 10*math.round(SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[1])/10)
        else
          topscore = 0
        end;
        local amount_of_steps = (pss:GetPossibleDancePoints()) / 3;-- overall amount of steps
        local current_possible_p =pss:GetCurrentPossibleDancePoints();--best possible EX score at your current point in the song
        local points = pss:GetActualDancePoints();--current EX score
        local score_per_step = 1000000 / amount_of_steps; --Amount of SN score per step
        local w1=pss:GetTapNoteScores('TapNoteScore_W1');--current marvelous count
        local w2=pss:GetTapNoteScores('TapNoteScore_W2');--current perfect count
        local w3=pss:GetTapNoteScores('TapNoteScore_W3');--current great count
        local w4=pss:GetTapNoteScores('TapNoteScore_W4');--current good count
        local w5=pss:GetTapNoteScores('TapNoteScore_W5');--current miss count
        local miss=pss:GetTapNoteScores('TapNoteScore_Miss');--current miss count
        local hd=pss:GetHoldNoteScores('HoldNoteScore_Held')--current held count
        local nh=pss:GetHoldNoteScores('HoldNoteScore_LetGo')--current not held count
        local mh=pss:GetHoldNoteScores('HoldNoteScore_MissedHold')--current missed hold count
        local perfect_deduction = w2*10;--what is subtracted from a perfect
        local great_deduction = (score_per_step*w3) - (((score_per_step * 0.6) - 10)*w3);--what is subtracted from a great
        local good_deduction = (score_per_step*w4) - (((score_per_step * 0.2) - 10)*w4);--what is subtracted from a good
        local good_deduction1 = (score_per_step*w5) - (((score_per_step * 0.2) - 10)*w5);--apparently there's a w5 that wasn't being accounted for
        local miss_deduction = score_per_step*(miss+nh+mh);--what is subtracted from a miss, not held and missed hold
        local pm = (perfect_deduction + great_deduction + good_deduction + good_deduction1 + miss_deduction) * -1;--overall deduction
        local rpm = round(pm/10) * 10;--round deduction to tenth place
        local currentscore = 1000000 - (rpm * -1);--determine what the current score is
        local compare = currentscore - topscore;--compares your performance to your high score
        if (topscore > 0) then --if you have a high score
          if(compare>0) then --if you want to only see the deduction instead of comparing to your high score, change the variable compare to rpm
          self:settext('+'..compare):diffuse(color("#0a7cfc")):strokecolor(Color.Black)--blue, feel free to change it to whatever you want
          else
          self:settext('-'..compare):diffuse(color("#ed0972")):strokecolor(Color.Black)--hot pink, you can change this too
          end;
        else--if you don't have a high score, this will only show the deduction
          self:settext(rpm):diffuse(color("#ed0972")):strokecolor(Color.Black)--hot pink, you can change this too
        end;
      end;
    };
  };
end

t[#t+1] = Def.ActorFrame{
    Def.Sprite{
      Name="SFrame Light",
      Texture="stageframe/light_normal",
      InitCommand=function(s)
        s:xy(_screen.cx,SCREEN_TOP+16)
        if IsAnExtraStage() then
            s:Load(THEME:GetPathB("ScreenGameplay","decorations/stageframe/light_extra"))
        end
      end,
      OnCommand=function(s)
				s:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.75")):effectclock('beatnooffset')
			end
    };
    Def.Sprite{
        Name="StageFrame",
        Texture="stageframe/normal",
        InitCommand=function(s)
            s:xy(_screen.cx,SCREEN_TOP+52)
            if IsAnExtraStage() then
                s:Load(THEME:GetPathB("ScreenGameplay","decorations/stageframe/extra"))
            end
        end,
    };
    loadfile(THEME:GetPathB("ScreenGameplay","decorations/scoreframe/default.lua"))();
};

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/lifeframe"))(pn);
--options--
	t[#t+1] = loadfile(THEME:GetPathB("","_optionicon"))(pn) .. {
		InitCommand=function(s) s:player(pn):zoomx(1.8):zoomy(1.8):x(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200) end,
		OnCommand=function(self)
			if GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current'):Reverse() == 1 then
				self:y(IsUsingWideScreen() and SCREEN_TOP+172 or SCREEN_TOP+142);
			else
				self:y(IsUsingWideScreen() and SCREEN_BOTTOM-145 or SCREEN_BOTTOM-130);
			end;
		end;
	};
end

t[#t+1] = StandardDecorationFromFileOptional("Help","Help");

t[#t+1] = Def.BitmapText{
	Font='_stagegameplay',
	Name='StageDisplay',
	InitCommand=function(s) s:xy(SCREEN_CENTER_X,76):maxwidth(140):zoom(1.2) end,
	CurrentSongChangedMessageCommand=function(s)
		local text = 'EVENT'
		
		if LoadingScreen == 'ScreenGameplayHowTo' then
			text = 'HOW TO PLAY'
		elseif not GAMESTATE:IsEventMode() or GAMESTATE:IsCourseMode() then
			if IsFinalStage() then
				text = 'FINAL'
			elseif IsExtraStage1() then
				text = 'EXTRA'
			elseif IsExtraStage2() then
				text = 'ENCORE EXTRA'
			else
				text = ToEnumShortString(GetCurrentStage())
			end
		end
		
		s:settext(text)
	end,
};

t[#t+1] = Def.Sound{
  File=THEME:GetPathS("","MusicWheel expand"),
  Name="sound",
  SupportPan=true
};

local function GetTimeSigs()
	local td = GetSong():GetTimingData()
	local timeSigs = split('=', td:GetTimeSignatures()[1])
	local n = timeSigs[2]
	local d = timeSigs[3]
	
	return {n,d}
end

t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:Center() end,
	CurrentSongChangedMessageCommand=function(s) s:finishtweening():diffusealpha(0):sleep(BeginReadyDelay()):diffusealpha(1):queuecommand('Ready') end,
	ReadyCommand=function(s) s:sleep(SongMeasureSec()):queuecommand('GoIn') end,
	GoInCommand=function(s) s:sleep(SongMeasureSec()):queuecommand('GoOut') end,
	
	Def.ActorFrame {
		CurrentSongChangedMessageCommand=function(s) s:SetUpdateRate(1) end,
		ReadyCommand=function(s) s:SetUpdateRate(2/SongMeasureSec()) end,
	
		Def.ActorFrame {
			InitCommand=function(s) s:zoom(0.75) end,
			
			Def.ActorFrame {
				InitCommand=function(s) s:diffusealpha(0) end,
				ReadyCommand=function(s) s:diffusealpha(0):zoom(1.2):sleep(0.2):linear(0.1):diffusealpha(1):accelerate(0.1):zoomy(1.1):linear(0.1):zoom(1) end,
				GoInCommand=function(s) s:linear(0.1):zoomy(0):diffusealpha(0) end,
				
				Def.Sprite {
					Texture='ready',
				},
				Def.Sprite {
					Texture='ready',
					InitCommand=function(s) s:diffusealpha(0):blend(Blend.Add) end,
					ReadyCommand=function(s) s:diffuseblink():effectcolor1(color('1,1,1,0')):effectcolor2(color('1,1,1,0.2')):effectclock('beat'):effectperiod((GetSong():GetTimingData():GetBPMAtBeat(4) >= 240 and 2 or 1)*(GetTimeSigs()[1]/GetTimeSigs()[2])):diffusealpha(1) end,
					GoInCommand=function(s) s:stopeffect():diffusealpha(0) end,
				},
			},
			Def.Sprite {
				Texture='ready',
				InitCommand=function(s) s:diffusealpha(0):blend(Blend.Add) end,
				ReadyCommand=function(s) s:diffusealpha(0):zoom(0.3):linear(0.3):zoom(1):diffusealpha(0.5):sleep(0):zoomx(1.3):linear(0.1):zoomx(2.3):zoomy(2):diffusealpha(0) end,
			},
			Def.Sprite {
				Texture='ready',
				InitCommand=function(s) s:diffusealpha(0):blend(Blend.Add) end,
				ReadyCommand=function(s) s:diffusealpha(0):zoom(2):linear(0.3):zoom(0.75):diffusealpha(0.5):linear(0):diffusealpha(0) end,
			},
		},
		Def.ActorFrame {
			InitCommand=function(s) s:diffusealpha(0) end,
			GoInCommand=function(s) s:diffusealpha(0):zoom(1.2):sleep(0.2):linear(0.1):diffusealpha(1):accelerate(0.1):zoomy(1.1):linear(0.1):zoom(1) end,
			GoOutCommand=function(s) s:linear(0.1):zoomy(0):diffusealpha(0) end,
			
			Def.Sprite {
				Texture='go.png',
			},
			Def.Sprite {
				Texture='go.png',
				InitCommand=function(s) s:diffusealpha(0):blend(Blend.Add) end,
				GoInCommand=function(s) s:diffuseblink():effectcolor1(color('1,1,1,0')):effectcolor2(color('1,1,1,0.2')):effectclock('beat'):effectperiod((GetSong():GetTimingData():GetBPMAtBeat(4) >= 240 and 2 or 1)*(GetTimeSigs()[1]/GetTimeSigs()[2])):diffusealpha(1) end,
				GoOutCommand=function(s) s:stopeffect():diffusealpha(0) end,
			},
		},
		Def.Sprite {
			Texture='go.png',
			InitCommand=function(s) s:diffusealpha(0):blend(Blend.Add) end,
			GoInCommand=function(s) s:diffusealpha(0):zoom(0.3):sleep(0):linear(0.3):zoom(1):diffusealpha(0.5):sleep(0):zoomx(1.3):linear(0.1):zoomx(2.3):zoomy(2):diffusealpha(0) end,
		},
		Def.Sprite {
			Texture='go.png',
			InitCommand=function(s) s:diffusealpha(0):blend(Blend.Add) end,
			GoInCommand=function(s) s:diffusealpha(0):zoom(2):sleep(0):linear(0.3):zoom(0.75):diffusealpha(0.5):linear(0):diffusealpha(0) end,
		},
	},
};

t[#t+1] = Def.ActorFrame {
	CurrentSongChangedMessageCommand=function(s)s:queuecommand('AnOff') end,
	NextCourseSongMessageCommand=function(s) s:queuecommand('AnOn') end,
	OffCommand=function(s)
		local st = STATSMAN:GetCurStageStats()
		
		-- delay before shutter close
		s:sleep(BeginOutDelay())
		
		if st:AllFailed() then
			s:queuecommand('SetFail')
		else
			--- Cleared / Send Notes Ended
			s:queuecommand('SetOff')
		end
	end,
	
	Def.Sprite {
		Condition=IsAnExtraStage(),
		Texture=THEME:GetPathB('ScreenSelectMusicExtra', 'background/EXMovie.mp4'),
		BeginCommand=function(s)
			s:Center():zoom(round(THEME:GetMetric('Common','ScreenHeight')/s:GetHeight()),3)
		end,
		AnOffCommand=function(s) s:play():diffusealpha(1):linear(0.4):diffusealpha(0):queuecommand('Pause') end,
		PauseCommand=function(s) s:pause() end,
	},
	Def.Sprite {
		Condition=get_UI_video_path(),
		Texture=get_UI_video_path(),
		BeginCommand=function(s)
			s:diffusealpha(0):pause():Center():zoom(round(THEME:GetMetric('Common','ScreenHeight')/s:GetHeight()),3)
		end,
		AnOnCommand=function(s) s:play():diffusealpha(0):linear(0.8):diffusealpha(1) end,
		AnOffCommand=function(s)
			if not IsAnExtraStage() then
				s:play():diffusealpha(1):linear(0.4):diffusealpha(0):queuecommand('Pause')
			end
		end,
		PauseCommand=function(s) s:pause() end,
		SetFailCommand=function(s) s:diffuse(color("1,0.2,0.2,0")):playcommand('AnOn'):sleep(outDelay-1.4):linear(0.4):diffusecolor(color('1,1,1,1')) end,
		SetOffCommand=function(s) s:play():linear(0.4):diffusealpha(1) end,
	},
	loadfile(THEME:GetPathB('ScreenWithMenuElements', 'background/default.lua'))() .. {
		Condition=not get_UI_video_path(),
		InitCommand=function(s) s:SetSize(SCREEN_WIDTH,SCREEN_HEIGHT) end,
		AnOnCommand=function(s) s:linear(0.8):diffusealpha(1) end,
		AnOffCommand=function(s) s:linear(0.4):diffusealpha(0) end,
		SetFailCommand=function(s) s:diffuse(color("1,0.2,0.2,0")):playcommand('AnOn'):sleep(outDelay-1.4):linear(0.4):diffusecolor(color('1,1,1,1')) end,
		SetOffCommand=function(s) s:linear(0.4):diffusealpha(1) end,
	},
};

t[#t+1] = loadfile(THEME:GetPathB("","_StageDoors"))() .. {
	CurrentSongChangedMessageCommand=function(s) s:queuecommand('AnOff') end,
	NextCourseSongMessageCommand=function(s) s:queuecommand('AnOn') end,
	OffCommand=function(s)
		local st = STATSMAN:GetCurStageStats()
		
		-- delay before shutter close
		s:sleep(BeginOutDelay())
		
		if st:AllFailed() then
			s:queuecommand('SetFail')
		else
			--- Cleared / Send Notes Ended
			s:queuecommand('SetOff')
		end
		
		s:queuecommand('AnOn'):sleep(outDelay-1):queuecommand('AnOff')
	end,
};

--Jacket--
t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:Center() end,
	OffCommand=function(s) s:finishtweening():linear(0.2):diffusealpha(0) end,
	
	Def.ActorFrame {
		BeginCommand=function(s)
			s:GetChild('Actual Jacket'):Load(jk.GetSongGraphicPath(GetSong())):scaletofit(-310,-310,310,310)
		end,
		NextCourseSongMessageCommand=function(s)
			s:GetChild('Actual Jacket'):Load(jk.GetSongGraphicPath(GetSong())):scaletofit(-310,-310,310,310)
			s:finishtweening():diffusealpha(0):zoom(4):sleep(1):linear(0.2):diffusealpha(1):zoom(0.9):linear(0.1):zoom(1)
		end,
		CurrentSongChangedMessageCommand=function(s)
			s:sleep(BeginReadyDelay()):accelerate(0.125):zoom(4):diffusealpha(0)
		end,
		
		Def.Quad { InitCommand=function(s) s:diffuse(Color.Black) s:setsize(628,628) end, },
		Def.Sprite { Name='Actual Jacket', },
	},
	Def.Sprite { Name='Blend Jacket1',
		InitCommand=function(s) s:diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s)
			s:Load(jk.GetSongGraphicPath(GetSong())):scaletofit(-310,-310,310,310)
			s:finishtweening():zoom(1):sleep(1.25):diffusealpha(0.75):decelerate(0.5):zoom(4):diffusealpha(0)
		end,
	},
	Def.Sprite { Name='Blend Jacket2',
		InitCommand=function(s) s:blend(Blend.Add):diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s)
			s:Load(jk.GetSongGraphicPath(GetSong())):scaletofit(-310,-310,310,310)
			s:finishtweening():zoom(1):sleep(1.25):glowshift():effectcolor1(color('1,1,1,0.5')):effectcolor2(color('1,1,1,0.5')):decelerate(0.5):zoom(4):diffusealpha(0)
		end,
	},
};

t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:Center():diffusealpha(0) end,
	NextCourseSongMessageCommand=function(s) s:sleep(2.2):linear(0.05):diffusealpha(1):sleep(2.5):linear(0.2):diffusealpha(0) end,
	
	Def.Sprite{
		NextCourseSongMessageCommand=function(s)
			if getenv('FixStage') == 1 then
				s:Load(THEME:GetPathG('', '_stages/' .. THEME:GetString('CustStageSt',CustStageCheck())..'.png') )
			else
				local curStage = 0
				local maxStages = PREFSMAN:GetPreference('SongsPerPlay')
				local stageName = 'stage event'
				
				if GAMESTATE:IsCourseMode() then
					curStage = GAMESTATE:GetLoadingCourseSongIndex()+1
					maxStages = GAMESTATE:GetCurrentCourse():GetEstimatedNumStages()
				else
					curStage = GAMESTATE:GetCurrentStageIndex()+1
				end
				
				if not GAMESTATE:IsEventMode() or GAMESTATE:IsCourseMode() then
					if curStage == maxStages then
						stageName = 'final'
					else
						stageName = FormatNumberAndSuffix(curStage)
					end
				end
				
				--- there are only 1st up to 5th stage display graphics for now
				if curStage <= 5 or stageName == 'final' then
					if FILEMAN:DoesFileExist(THEME:GetPathG('', '_stages/' .. stageName ..'.png')) then
						s:Load(THEME:GetPathG('', '_stages/' .. stageName ..'.png') )
					end
				end
			end
		end
	}
};

t[#t+1] = Def.ActorFrame {
	Def.Sprite{
		Texture='../ScreenStageInformation decorations/star',
		InitCommand=function(s) s:Center():diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s) s:sleep(2.2):linear(0.05):diffusealpha(1):linear(0.2):diffusealpha(0) end,
	},
	Def.Quad {
		InitCommand=function(s) s:diffusealpha(0):Center():setsize(SCREEN_WIDTH,SCREEN_HEIGHT):diffusealpha(0):blend(Blend.Add) end,
		NextCourseSongMessageCommand=function(s) s:sleep(2.2):linear(0.05):diffusealpha(0.25):linear(0.2):diffusealpha(0) end,
	},
	Def.Sprite{
		Texture='../ScreenStageInformation decorations/arrow',
		InitCommand=function(s) s:Center():diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s) s:x(SCREEN_RIGHT+636):sleep(2):diffusealpha(1):linear(0.4):x(-636):sleep(0):diffusealpha(0) end,
	},
	Def.Sprite{
		Texture='../ScreenStageInformation decorations/arrow',
		InitCommand=function(s) s:Center():zoomx(-1):diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s) s:x(-636):sleep(2):diffusealpha(1):linear(0.4):x(SCREEN_RIGHT+636):sleep(0):diffusealpha(0) end,
	},
};

t[#t+1] = Def.Sprite {
	InitCommand=function(s) s:Center():zoomy(0):zoomx(4):diffusealpha(0) end,
	OffCommand=function(s)
		local st = STATSMAN:GetCurStageStats()
		
		if not st:AllFailed() then
			if has_value(List,GetSong():GetDisplayMainTitle()) then
				s:Load(THEME:GetPathB('ScreenGameplay', 'decorations/PRAY FOR ALL'))
			else
				s:Load(THEME:GetPathB('ScreenGameplay', 'decorations/cleared'))
			end
			s:sleep(BeginOutDelay())
		else
			s:Load(THEME:GetPathB('ScreenGameplay', 'decorations/failed'))
		end
		s:queuecommand('Animate')
	end,
	AnimateCommand=function(s)
		s:sleep(0.5):linear(0.198):diffusealpha(1):zoom(1):sleep(outDelay-1.698):linear(0.132):zoomy(0):zoomx(4):diffusealpha(0)
	end
};

t[#t+1] = Def.Quad {
	InitCommand=function(s) s:FullScreen():diffuse(color('0,0,0,0')) end,
	CancelMessageCommand=function(s)
		local delay = THEME:GetMetric('ScreenGameplay', 'CancelTransitionSeconds')
		SOUND:PlayOnce(THEME:GetPathS('Common', 'Back'))
		s:linear(delay):diffusealpha(1)
	end,
};

return t