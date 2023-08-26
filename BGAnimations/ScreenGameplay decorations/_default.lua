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
		NextCourseSongMessageCommand=function(s)
			local course = GAMESTATE:GetCurrentCourse()
			if course:IsA20DanCourse() then
				s:hibernate(61)
			end
			s:sleep(0.45):queuecommand('Play')
		end,
		PlayCommand=function(s) s:play() end,
	},
	Def.Actor {
		SetOffCommand=function(s) s:sleep(0.2):queuecommand('ApplauseCleared') end,
		SetFailCommand=function(s) s:sleep(0.2):queuecommand('ApplauseFailed') end,
		NextCourseSongMessageCommand=function(s)
			local course = GAMESTATE:GetCurrentCourse()
			if course:IsA20DanCourse() then
				s:hibernate(61)
			end
			s:sleep(0.2):queuecommand('ApplauseStage')
		end,
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

      local aScore = params.Data.AScoring
      pss:SetScore(aScore.Score)
      pss:SetCurMaxScore(aScore.MaxScore)

      
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
end

t[#t+1] = Def.ActorFrame{
    Def.Sprite{
      Name="SFrame Light",
      Texture="stageframe/light_normal",
      InitCommand=function(s)
        s:xy(_screen.cx,SCREEN_TOP+16):visible(not GAMESTATE:IsDemonstration())
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
            s:xy(_screen.cx,SCREEN_TOP+52):visible(not GAMESTATE:IsDemonstration())
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
	Condition=not GAMESTATE:IsDemonstration(),
	InitCommand=function(s) s:Center() end,
	CurrentSongChangedMessageCommand=function(s)
		s:finishtweening():diffusealpha(0):sleep(BeginReadyDelay()):diffusealpha(1):queuecommand('Ready')
	end,
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
	NextCourseSongMessageCommand=function(s)
		local course = GAMESTATE:GetCurrentCourse()
		if course:IsA20DanCourse() then
			s:hibernate(61)
		end
		s:queuecommand('AnOn')
	end,
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
		Condition=not get_UI_video_path() ,
		InitCommand=function(s) s:SetSize(SCREEN_WIDTH,SCREEN_HEIGHT) end,
		AnOnCommand=function(s) s:linear(0.8):diffusealpha(1) end,
		AnOffCommand=function(s) s:linear(0.4):diffusealpha(0) end,
		SetFailCommand=function(s) s:diffuse(color("1,0.2,0.2,0")):playcommand('AnOn'):sleep(outDelay-1.4):linear(0.4):diffusecolor(color('1,1,1,1')) end,
		SetOffCommand=function(s) s:linear(0.4):diffusealpha(1) end,
	},
};

local Time = 0
local OldTime = 0
local function updateTime(self)
	Time = self:GetSecsIntoEffect()
	if not PREFSMAN:GetPreference("Vsync") and Time - OldTime < 1/60 then
        return
    else
        OldTime = Time
	end
	
	local seconds = Time%60

	local timeDisplay = string.format("%02d",seconds)

	self:GetChild("Timer"):settext(60-timeDisplay)
end

--Dan Course Break Time
t[#t+1] = Def.ActorFrame{
	Def.Sprite {
		Texture=THEME:GetPathB("ScreenGameplay","decorations/[DDR XX CLASS] 60 SECOND BREAK.mp4"),
		BeginCommand=function(s) s:pause():diffusealpha(0):Center():setsize(1920,1080) end,
		NextCourseSongMessageCommand=function(s)
			local course = GAMESTATE:GetCurrentCourse()
			if course:IsA20DanCourse() then
				s:play():diffusealpha(0):sleep(0.5):linear(0.3):diffusealpha(1):sleep(61.5):linear(0.2):diffusealpha(0):queuecommand("Pause")
			end
		end,
		PauseCommand=function(s) s:pause() end,
	};
	Def.Sound{
		File=THEME:GetPathB("ScreenGameplay","decorations/[DDR XX CLASS] 60 SECOND BREAK.ogg"),
		NextCourseSongMessageCommand=function(s)
			local course = GAMESTATE:GetCurrentCourse()
			if course:IsA20DanCourse() then
				s:sleep(1):queuecommand("Play")
			end
		end,
		PlayCommand=function(s) s:play():sleep(61):queuecommand("Pause") end,
		PauseCommand=function(s) s:stop() end,
	};
	Def.ActorFrame{
		InitCommand=function(s) s:zoom(3.5):Center() end,
		NextCourseSongMessageCommand=function(s)
			local course=GAMESTATE:GetCurrentCourse()
			if course:IsA20DanCourse() then
				s:sleep(2.2):queuecommand("StartTimer")
			end
		end,
		StartTimerCommand=function(s) s:play():effectperiod(math.huge):SetUpdateFunction(updateTime):sleep(60):queuecommand("Stop") end,
		StopCommand=function(s)
			s:stopeffect()
		end,
		Def.BitmapText{
			Name="Timer",
			File="Combo/combo good",
			Text="60",
			InitCommand=function(s) s:diffusealpha(0) end,
			NextCourseSongMessageCommand=function(s)
				local course=GAMESTATE:GetCurrentCourse()
				if course:IsA20DanCourse() then
					s:sleep(0.5):diffusealpha(1):queuecommand("Stop")
				end
			end,
			StopCommand=function(s) s:sleep(61):diffusealpha(0) end,
		};
	};
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenGameplay","decorations/BreakTime.png"),
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-320):diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s)
			local course=GAMESTATE:GetCurrentCourse()
			--hide the timer because it's borked
			if course:IsA20DanCourse() then
				s:sleep(0.5):diffusealpha(1):queuecommand("Stop")
			end
		end,
		StopCommand=function(s) s:sleep(61):diffusealpha(0) end,
	}
}

t[#t+1] = loadfile(THEME:GetPathB("","_StageDoors"))() .. {
	CurrentSongChangedMessageCommand=function(s) s:queuecommand('AnOff') end,
	NextCourseSongMessageCommand=function(s)
		local course = GAMESTATE:GetCurrentCourse()
		if course:IsA20DanCourse() then
			s:sleep(61)
		end
		s:queuecommand('AnOn')
	end,
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
	NextCourseSongMessageCommand=function(s)
		local course = GAMESTATE:GetCurrentCourse()
		if course:IsA20DanCourse() then
			s:hibernate(61)
		end
	end,
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
	NextCourseSongMessageCommand=function(s)
		local course = GAMESTATE:GetCurrentCourse()
		if course:IsA20DanCourse() then
			s:hibernate(61)
		end
		s:sleep(2.2):linear(0.05):diffusealpha(1):sleep(2.5):linear(0.2):diffusealpha(0)
	end,
	
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
	NextCourseSongMessageCommand=function(s)
		local course = GAMESTATE:GetCurrentCourse()
		if course:IsA20DanCourse() then
			s:hibernate(61)
		end
	end,
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

--Dan Course White Fade
t[#t+1] = Def.Quad {
	BeginCommand=function(s) s:FullScreen():diffuse(color('1,1,1,0')) end,
	NextCourseSongMessageCommand=function(s)
		local course=GAMESTATE:GetCurrentCourse()
		if course:IsA20DanCourse() then
			s:diffusealpha(0):linear(0.5):diffusealpha(1):sleep(0.5):linear(0.5):diffusealpha(0)
		end
	end
};

return t