local jk = LoadModule "Jacket.lua"
local outDelay = THEME:GetMetric('ScreenGameplay', 'OutTransitionSeconds')

local List = {
	'Tohoku EVOLVED',
	'COVID',
	'Outbreak'
}

local beepTimerSec = 9

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
		File=THEME:GetPathS('', '_gameplay break time'),
		CourseBreakTimeMessageCommand=function(s) s:play() end,
		NextCourseSongMessageCommand=function(s) s:stop() end,
	},
	Def.Sound {
		Condition=IsARankingCourse(),
		File=THEME:GetPathS('', 'MenuTimer tick'),
		CourseBreakTimeMessageCommand=function(s)
			local sec = THEME:GetMetric('ScreenGameplay', 'BreakTimeSeconds')
			beepTimerSec = 9
			s:sleep(sec-7):queuecommand('Play')
		end,
		PlayCommand=function(s)
			if beepTimerSec >= 0 then
				beepTimerSec = beepTimerSec-1
				s:play():sleep(1):queuecommand('Play')
			else
				SOUND:PlayOnce(THEME:GetPathS('', '_swoosh out'))
			end
		end,
		NextCourseSongMessageCommand=function(s) s:stoptweening() end,
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
		ChangeCourseSongInMessageCommand=function(s)
			ANNOUNCER:SetCurrentAnnouncer('')
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
		PlayCommand=function()
			if lastAnnouncer then
				ANNOUNCER:SetCurrentAnnouncer(lastAnnouncer)
				SOUND:PlayAnnouncer('gameplay ready')
			end
		end,
	},
	Def.Actor {
		NextCourseSongMessageCommand=function(s) s:sleep(2):queuecommand('Play') end,
		PlayCommand=function(s)
			if lastAnnouncer then
				ANNOUNCER:SetCurrentAnnouncer(lastAnnouncer)
				
				local curStage = GAMESTATE:GetLoadingCourseSongIndex()+1
				local stageName = 'stage ' .. curStage
				local maxStages = GAMESTATE:GetCurrentCourse():GetEstimatedNumStages()
			
				if curStage == maxStages then
					stageName = 'stage final'
				end
				
				SOUND:PlayAnnouncer(stageName)
				s:sleep(0.03):queuecommand('Mute')
			end
		end,
		MuteCommand=function()
			--- mute the announcer until next gameplay ready
			ANNOUNCER:SetCurrentAnnouncer('')
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

t[#t+1] = LoadFont('_stagegameplay') .. {
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
	Def.ActorFrame {
		AnOnCommand=function(s) s:linear(0.8):diffusealpha(1) end,
		AnOffCommand=function(s) s:linear(0.4):diffusealpha(0) end,
		SetFailCommand=function(s) s:diffuse(color("1,0.2,0.2,0")):playcommand('AnOn'):sleep(outDelay-1.4):linear(0.4):diffusecolor(color('1,1,1,1')) end,
		SetOffCommand=function(s) s:linear(0.4):diffusealpha(1) end,
		CourseBreakTimeMessageCommand=function(s) s:sleep(2):diffusealpha(1) end,
		
		LoadActor(THEME:GetPathB('ScreenWithMenuElements', 'background/default.lua')),
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
			s:GetChild('Actual Jacket'):Load(jk.GetSongGraphicPath(GetSong())):setsize(620,620):scaletoclipped(620,620)
		end,
		NextCourseSongMessageCommand=function(s)
			s:GetChild('Actual Jacket'):Load(jk.GetSongGraphicPath(GetSong())):setsize(620,620):scaletoclipped(620,620)
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
			s:Load(jk.GetSongGraphicPath(GetSong())):setsize(620,620):scaletoclipped(620,620)
			s:finishtweening():zoom(1):sleep(1.25):diffusealpha(0.75):decelerate(0.5):zoom(4):diffusealpha(0)
		end,
	},
	Def.Sprite { Name='Blend Jacket2',
		InitCommand=function(s) s:blend(Blend.Add):diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s)
			s:Load(jk.GetSongGraphicPath(GetSong())):setsize(620,620):scaletoclipped(620,620)
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
	LoadActor('../ScreenStageInformation decorations/star') .. {
		InitCommand=function(s) s:Center():diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s) s:sleep(2.2):linear(0.05):diffusealpha(1):linear(0.2):diffusealpha(0) end,
	},
	Def.Quad {
		InitCommand=function(s) s:diffusealpha(0):Center():setsize(SCREEN_WIDTH,SCREEN_HEIGHT):diffusealpha(0):blend(Blend.Add) end,
		NextCourseSongMessageCommand=function(s) s:sleep(2.2):linear(0.05):diffusealpha(0.25):linear(0.2):diffusealpha(0) end,
	},
	LoadActor('../ScreenStageInformation decorations/arrow') .. {
		InitCommand=function(s) s:Center():diffusealpha(0) end,
		NextCourseSongMessageCommand=function(s) s:x(SCREEN_RIGHT+636):sleep(2):diffusealpha(1):linear(0.4):x(-636):sleep(0):diffusealpha(0) end,
	},
	LoadActor('../ScreenStageInformation decorations/arrow') .. {
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

t[#t+1] = LoadActor( 'btime' ) .. {
	Condition=IsARankingCourse(),
	InitCommand=function(s) s:Center():addy(-290):diffusealpha(0) end,
	CourseBreakTimeMessageCommand=function(s) s:diffusealpha(0):sleep(2):diffusealpha(1) end,
	NextCourseSongMessageCommand=function(s) s:diffusealpha(0) end,
};

local function bt_numbers()
	local v = {}
	
	for i=1, 10 do
		v[#v+1] = LoadActor( 'bt_' .. 10-(i-1) .. '.png' );
	end
	
	return v
end

local bt_sec = THEME:GetMetric('ScreenGameplay', 'BreakTimeSeconds')
local bBreakTime = false

t[#t+1] = Def.ActorFrame {
	Condition=IsARankingCourse(),
	InitCommand=function(s) s:Center():addy(126):diffusealpha(0) end,
	CourseBreakTimeMessageCommand=function(s)
		bBreakTime = true
		s:sleep(2):diffusealpha(1)
	end,
	NextCourseSongMessageCommand=function(s) s:diffusealpha(0) end,
	CodeMessageCommand=function(s, p)
		if (p.Name == 'Start') and GAMESTATE:IsSideJoined(p.PlayerNumber) and bBreakTime then
			bBreakTime = false
			s:queuecommand('Update')
		end
	end,
	
	Def.Quad {
		InitCommand=function(s) s:y(-456-22):zoomto(608,460):MaskSource() end,
	},
	Def.Quad {
		InitCommand=function(s) s:y(456-22):zoomto(608,460):MaskSource() end,
	},
	LoadActor( 'bt_back_dark' ),
	Def.ActorScroller {
		SecondsPerItem=0.2,
		InitCommand=function(s)
			s:x(152):SetNumItemsToDraw(2):SetSecondsPauseBetweenItems(0.8):SetLoop(true):MaskDest()
		end,
		TransformFunction=function(s,o,i,n) s:y(460*o) end,
		OnCommand=function(s)
			s:SetCurrentAndDestinationItem(10-(bt_sec%10))
		end,
		StartCommand=function(s) s:SetDestinationItem(bt_sec) end,
		CourseBreakTimeMessageCommand=function(s)
			s:sleep(3):queuecommand('Start')
		end,
		NextCourseSongMessageCommand=function(s) s:finishtweening():SetCurrentAndDestinationItem(10-(bt_sec%10)) end,
		UpdateCommand=function(s) s:SetCurrentAndDestinationItem(10) end,
		
		children = bt_numbers()
	},
	Def.ActorScroller {
		SecondsPerItem=0.2,
		InitCommand=function(s)
			s:x(-152):SetNumItemsToDraw(2):SetSecondsPauseBetweenItems(9.8):SetLoop(true):MaskDest()
		end,
		TransformFunction=function(s,o,i,n) s:y(460*o) end,
		OnCommand=function(s) s:SetCurrentAndDestinationItem(10-(math.floor(bt_sec/10))) end,
		StartCommand=function(s) s:SetDestinationItem(10) end,
		CourseBreakTimeMessageCommand=function(s)
			s:sleep(3+(bt_sec%10)):queuecommand('Start')
		end,
		NextCourseSongMessageCommand=function(s) s:finishtweening():SetCurrentAndDestinationItem(10-(math.floor(bt_sec/10))) end,
		UpdateCommand=function(s) s:SetCurrentAndDestinationItem(10) end,
		
		children = bt_numbers()
	},
};

t[#t+1] = Def.Quad {
	InitCommand=function(s) s:FullScreen():diffusealpha(0) end,
	CancelMessageCommand=function(s)
		local delay = THEME:GetMetric('ScreenGameplay', 'CancelTransitionSeconds')
		SOUND:PlayOnce(THEME:GetPathS('Common', 'Back'))
		s:diffuse(color('0,0,0,0')):linear(delay):diffusealpha(1)
	end,
	CourseBreakTimeMessageCommand=function(s)
		s:diffuse(color('1,1,1,0')):linear(1):diffusealpha(1):sleep(1):linear(1):diffusealpha(0)
	end,
};

return t