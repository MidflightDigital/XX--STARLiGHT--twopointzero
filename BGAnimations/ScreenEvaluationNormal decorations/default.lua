local dim_vol = 1
local jk = LoadModule('Jacket.lua')
local screen = Var('LoadingScreen')
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

-- Timing mode
local TimingMode = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini") or "Unknown"
if TimingMode == "Original" then TimingMode = "StepMania" end


local t = LoadFallbackB();

t[#t+1] = StandardDecorationFromFileOptional("StageDisplay","StageDisplay");

t[#t+1] = Def.Actor {
    OffCommand=function(s)
		  if GAMESTATE:IsCourseMode() then
			  s:playcommand('FadeOut')
		  end
	end,
	FadeOutCommand=function(s)
		if dim_vol ~= 0 then
			SOUND:DimMusic(1-(1-dim_vol), math.huge)
			dim_vol = round(dim_vol - 0.001,3)
			s:sleep(0.001):queuecommand('Play')
		end
	end,
};

t[#t+1] = Def.Sound {
	File=THEME:GetPathS('_result', 'in'),
	OnCommand=function(s) s:play() end,
};

t[#t+1] = Def.Sound {
	File=THEME:GetPathS('_result', 'score'),
	OnCommand=function(s)
		local st = STATSMAN:GetCurStageStats()
		local pss_p1 = st:GetPlayerStageStats(PLAYER_1)
		local pss_p2 = st:GetPlayerStageStats(PLAYER_2)
		
		if pss_p1:GetScore() > 0 or pss_p2:GetScore() > 0 then
			s:sleep(0.2):queuecommand("Play")
		end
	end,
	PlayCommand=function(s) s:play() end,
};

t[#t+1] = Def.Actor{
    OnCommand=function(s)
      if GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()) > 1 then
        CustStage = CustStage + 1
      end
    end
};

local List = {
	"Tohoku EVOLVED",
	"COVID"
};

--[[local dim_vol = 1

t[#t+1] = Def.Sound {
	Condition=not GetExtraStage() and not has_value(List,GAMESTATE:GetCurrentSong():GetDisplayMainTitle()),
	File=GetMenuMusicPath "results",
	OnCommand=function(s) s:play() end,
	OffCommand=function(s)
		if THEME:GetMetric('ScreenEvaluation', 'NextScreen') ~= 'ScreenEvaluationSummary' then
			s:sleep(0.2):queuecommand('Play')
		end
	end,
	PlayCommand=function(s)
		if dim_vol ~= 0 then
			s:get():volume(1-(1-dim_vol))
			dim_vol = round(dim_vol - 0.001,3)
			s:sleep(0.001):queuecommand('Play')
		end
	end
};--]]

--BannerArea
t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:xy(_screen.cx,IsUsingWideScreen() and _screen.cy-184 or _screen.cy-230):zoom(IsUsingWideScreen() and 1 or 0.8) end,
  Def.ActorFrame{
    OnCommand=function(s) s:zoomy(0):sleep(0.3):bounceend(0.175):zoomy(1) end,
    OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
    Def.Sprite{
        Texture=THEME:GetPathG("","_shared/_jacket back"),
        InitCommand=function(s)
          if GAMESTATE:IsCourseMode() then
            s:Load(THEME:GetPathG("","_shared/_banner back"))
          end
        end,
    };
    Def.Sprite{
      InitCommand=function(self)
        local song;
        if GAMESTATE:IsCourseMode() then
            song = GAMESTATE:GetCurrentCourse()
        else
            song = GAMESTATE:GetCurrentSong();
        end
        if song then
            if GAMESTATE:IsCourseMode() then
                self:Load(song:GetBannerPath()):zoomto(512,160)
            else
                self:Load(jk.GetSongGraphicPath(song,"Jacket")):scaletofit(-189,-189,189,189)
            end
        end;
      end;
    };
  };
  --TitleBox
  Def.ActorFrame{
    InitCommand=function(s)
      if GAMESTATE:IsCourseMode() then
        s:y(150)
      else
        s:y(250)
      end
    end,
	  OnCommand=function(s) s:zoomy(0):sleep(0.3):bounceend(0.175):zoomy(1) end,
	  OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
	  Def.Sprite{
      Texture=THEME:GetPathG("","_shared/titlebox"),
    };
	  Def.BitmapText{
      Font="_avenirnext lt pro bold/25px",
		  InitCommand = function(s) s:maxwidth(400):playcommand("Set") end,
      SetCommand = function(s)
        local SongOrCourse;
        if GAMESTATE:IsCourseMode() then
          s:settext(GAMESTATE:GetCurrentCourse() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle() or "")
        else
          s:settext(GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSong():GetDisplayFullTitle() or ""):y(-8)
        end	
      end;
	  };
	  Def.BitmapText{
      Font="_avenirnext lt pro bold/25px",
		  InitCommand = function(s) s:y(20):maxwidth(400):playcommand("Set") end,
      SetCommand = function(self)
        if not GAMESTATE:IsCourseMode() then
			    local song = GAMESTATE:GetCurrentSong()
          self:settext(song:GetDisplayArtist() ~= "Unknown artist" and song:GetDisplayArtist() or "")
        end
		  end,
	  };
  };
};

local function FindText(pss)
  return string.format('%02d STAGE', pss:GetSongsPassed())
end

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
  local function m(metric)
    metric = metric:gsub('PN', ToEnumShortString(pn))
    return THEME:GetMetric(Var('LoadingScreen'),metric)
  end
  
  local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
  local steps = GAMESTATE:GetCurrentSteps(pn)

  local seconds = pss:GetSurvivalSeconds()
  local short_plr = ToEnumShortString(pn)
  local profileID = GetProfileIDForPlayer(pn)
  local pPrefs = ProfilePrefs.Read(profileID)
  local showEXScore = pPrefs.ex_score

  t[#t+1] = ScoreAndGrade.GetGradeActor{
      Big = true,
      ActorConcat = {
        Grade = {
          OnCommand = m('GradePNOnCommand'),
          OffCommand = m('GradePNOffCommand')
        }
      }
    }..{
    InitCommand = function(s)
      local c = s:GetChildren()
      c.Grade:xy(m('GradePNX'), m('GradePNY'))		
      c.FullCombo:xy(m('RingPNX'), m('RingPNY'))
      
      s:playcommand('SetGrade', { Highscore = pss, Steps = steps })
    end,
  }

  t[#t+1] = Def.ActorFrame{
    Name='Scores',
    InitCommand=function(s) s:y(_screen.cy-2):zoom(0)
      if pn == PLAYER_1 then
        s:x(IsUsingWideScreen() and _screen.cx-500 or _screen.cx-440)
      elseif pn == PLAYER_2 then
        s:x(IsUsingWideScreen() and _screen.cx+500 or _screen.cx+440)
      end
      
      s:playcommand('SetGrade', { Highscore = pss, Steps = steps })
    end,
    OnCommand=function(s) s:zoom(0):sleep(0.3):bounceend(0.2):zoom(2) end,
    OffCommand=function(s) s:linear(0.2):zoom(0) end,
    ScoreAndGrade.GetScoreActorRolling{
      Font = '_avenirnext lt pro bold/46px',
      Load = showEXScore and 'RollingNumbersEXScore' or 'RollingNumbersEvaluation',
      ShowEXScore = showEXScore,
    }..{
      InitCommand=function(s) s:strokecolor(Color.Black) end,
    },
    Def.BitmapText{
      Font='_avenirnext lt pro bold/25px';
      InitCommand=function(s) s:xy(120,26):strokecolor(Color.Black):halign(1):zoom(0.5) end,
      OnCommand=function(s)
        s:hibernate(0.6)
        local song = GAMESTATE:GetCurrentSong()
        if not song then s:visible(false); return end
  
        local profile, compareIndex
        if PROFILEMAN:IsPersistentProfile(pn) then
          profile = PROFILEMAN:GetProfile(pn)
          compareIndex = pss:GetPersonalHighScoreIndex() == 0 and 2 or 1
        else
          profile = PROFILEMAN:GetMachineProfile()
          compareIndex = pss:GetMachineHighScoreIndex() == 0 and 2 or 1
        end
        
        local scores = profile:GetHighScoreList(song, steps):GetHighScores()
        local compareHS = scores[compareIndex]
        if not compareHS then s:visible(false); return end
        s:visible(true)
        
        local compareScore = ScoreAndGrade.GetScore(compareHS, steps, showEXScore)
        local currentScore = ScoreAndGrade.GetScore(pss, steps, showEXScore)
        local delta = currentScore - compareScore
        if delta > 0 then
          s:settextf('+%7d', delta)
          s:diffuse(color('0.3,0.7,1,1'))
        else
          s:settextf('-%7d', math.abs(delta))
          s:diffuse(color('1,0.3,0.5,1'))
        end
      end;
    };
  };

  if pss:GetMachineHighScoreIndex() == 0 or pss:GetPersonalHighScoreIndex() == 0 then
    t[#t+1] = Def.Sprite{
      Texture="Record.png",
      InitCommand=function(s)
        s:y(_screen.cy-56):zoom(0)
        if pn == PLAYER_1 then
          s:x(IsUsingWideScreen() and _screen.cx-500 or _screen.cx-440)
        elseif pn == PLAYER_2 then
          s:x(IsUsingWideScreen() and _screen.cx+500 or _screen.cx+440)
        end
      end,
      OnCommand=function(self)
        self:sleep(0.3):bounceend(0.2):zoom(1)
        self:glowblink():effectcolor1(color("1,1,1,0")):effectcolor2(color("1,1,1,0.2")):effectperiod(0.2)
      end;
      OffCommand=function(s) s:linear(0.2):zoom(0) end,
    };
  end;

  if GAMESTATE:IsCourseMode() then
    --Course StepsDisplay
    t[#t+1] = Def.ActorFrame{
      InitCommand=function(s) 
        s:xy(pn==PLAYER_2 and (IsUsingWideScreen() and _screen.cx+494 or _screen.cx+260) or (IsUsingWideScreen() and _screen.cx-494 or _screen.cx-260),_screen.cy-346)
        :draworder(-1)
      end,
      OnCommand=function(s) s:zoom(0):sleep(0.3):bounceend(0.2):zoom(0.8) end,
      OffCommand=function(s) s:linear(0.2):zoom(0) end,
      Def.Sprite{ Texture="info", InitCommand=function(s) s:diffuse(PlayerColor(pn)) end},
      Def.BitmapText{
        Font="_avenirnext lt pro bold/42px";
        OnCommand=function(self)
          self:y(46)
          self:settext(SecondsToMMSS(seconds)):strokecolor(Color.Black)
        end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/36px";
        InitCommand=function(s) s:y(-40):zoom(1.8):diffuse(color("#FFFFFF")):diffusebottomedge(color("#7c7c7c")):strokecolor(color("0,0,0,1")) end,
        OnCommand=function(self)
          self:settext(FindText(pss))
        end;
      };
      Def.Quad{
        InitCommand=function(s) s:setsize(300,28):y(4) end,
      };
      Def.Sprite{
        Texture="Bars 1x2.png";
        InitCommand=function(s) s:y(4):pause():setstate(0) end,
        OnCommand=function(self)
          self:setstate(pn=="PlayerNumber_P2" and 1 or 0):cropright(1):sleep(0.7):decelerate(0.7):cropright(math.max(0,1-pss:GetPercentDancePoints()))
        end;
      };
    };
  else
    --Normal StepsDisplay
    t[#t+1] = Def.ActorFrame{
      InitCommand=function(s) 
        s:xy(pn==PLAYER_2 and (IsUsingWideScreen() and _screen.cx+494 or _screen.cx+260) or (IsUsingWideScreen() and _screen.cx-494 or _screen.cx-260),_screen.cy-346)
        :draworder(-1)
      end,
      OnCommand=function(s) s:zoom(0):sleep(0.3):bounceend(0.2):zoom(1) end,
      OffCommand=function(s) s:linear(0.2):zoom(0) end,
      Def.BitmapText{
        Font="_handel gothic itc std Bold/32px";
        OnCommand=function(self)
          self:y(-40)
          self:uppercase(true):settext(GAMESTATE:GetCurrentStyle():GetName()):strokecolor(Color.Black)
        end;
      };
      Def.BitmapText{
        Font="_handel gothic itc std Bold/32px";
        OnCommand=function(self)
          local diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty();
          self:uppercase(true):settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff)))
          :diffuse(CustomDifficultyToColor(diff)):strokecolor(Color.Black)
        end;
      };
      Def.BitmapText{
        Font="_handel gothic itc std Bold/32px";
        OnCommand=function(self)
          self:y(36)
          local meter = GAMESTATE:GetCurrentSteps(pn):GetMeter();
							self:settext(IsMeterDec(meter)):strokecolor(Color.Black)
        end;
      };
    };
  end

  --NameTag
  t[#t+1] = Def.ActorFrame{
    OnCommand=function(self)
      self:addx(pn==PLAYER_2 and 300 or -300)
      self:sleep(0.3):linear(0.2):addx(pn==PLAYER_2 and -300 or 300)
    end;
    OffCommand=function(self)
      self:linear(0.2):addx(pn==PLAYER_2 and 300 or -300)
    end;
    Def.Sprite{
      Texture="player",
      InitCommand=function(self)
        self:zoomx(pn==PLAYER_2 and -1 or 1)
        self:x(pn==PLAYER_2 and SCREEN_RIGHT or SCREEN_LEFT)
        self:halign(0):y(_screen.cy-310)
      end;
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px";
      InitCommand=function(self)
		local name = PROFILEMAN:GetProfile(pn):GetDisplayName()
		
		if name == '' then
			name = pn=="PlayerNumber_P2" and "PLAYER 2" or "PLAYER 1"
		end
        self:xy(pn=="PlayerNumber_P2" and SCREEN_RIGHT-134 or SCREEN_LEFT+134,_screen.cy-310)
        self:settext(name)
      end;
    };
    -- Timing mode
    Def.Sprite{
      Texture="player",
      InitCommand=function(self)
        self:zoomx(pn==PLAYER_2 and -0.75 or 0.75):zoomy(0.66)
        self:x(pn==PLAYER_2 and SCREEN_RIGHT or SCREEN_LEFT)
        self:halign(0):y(_screen.cy-362)
      end;
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px";
      InitCommand=function(self)
        self:xy(pn=="PlayerNumber_P2" and SCREEN_RIGHT-100 or SCREEN_LEFT+100,_screen.cy-363)
        -- Whenever OutFox supports split timing modes, update this
        self:settext(TimingMode)
      end;
    };
  }
end;

local mp = GAMESTATE:GetMasterPlayerNumber()
local profileID
local pPrefs
local EvalPane1 = 2
local EvalPane2 = 0

  -- If single player
if #GAMESTATE:GetEnabledPlayers() == 1 then
  profileID = GetProfileIDForPlayer(mp)
  pPrefs = ProfilePrefs.Read(profileID)
  EvalPane1 = pPrefs.evalpane1
  EvalPane2 = pPrefs.evalpane2
	--P1 Frame
	t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/frame"))(GAMESTATE:GetMasterPlayerNumber(),PLAYER_1,EvalPane1)..{
    InitCommand=function(s)
      s:xy(IsUsingWideScreen() and _screen.cx-500 or _screen.cx-360,_screen.cy+250)
    end,
	};
	--P2 Frame
	t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/frame"))(GAMESTATE:GetMasterPlayerNumber(),PLAYER_2,EvalPane2)..{
		InitCommand=function(s)
      s:xy(IsUsingWideScreen() and _screen.cx+500 or _screen.cx+360,_screen.cy+250)
    end,
  };
else --If multiplayer
  local profileID1 = GetProfileIDForPlayer(PLAYER_1)
  local pPrefs1 = ProfilePrefs.Read(profileID1)
  local EvalPane1P = pPrefs1.evalpane1
	--P1 Frame
	t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/frame"))(PLAYER_1,PLAYER_1,EvalPane1P)..{
		InitCommand=function(s)
      s:xy(IsUsingWideScreen() and _screen.cx-500 or _screen.cx-360,_screen.cy+250)
    end,
  };
  local profileID2 = GetProfileIDForPlayer(PLAYER_2)
  local pPrefs2 = ProfilePrefs.Read(profileID2)
  local EvalPane2P = pPrefs2.evalpane1
	--P2 Frame
	t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/frame"))(PLAYER_2,PLAYER_2,EvalPane2P)..{
		InitCommand=function(s)
      s:xy(IsUsingWideScreen() and _screen.cx+500 or _screen.cx+360,_screen.cy+250)
    end,
  };

end;
  
if GetExtraStage() then
  t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/EXOverlay"))();
  --Outro Movie
  t[#t+1] = Def.ActorFrame{
    Def.Quad{
      InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0)) end,
      OffCommand=function(s) s:linear(0.3):diffusealpha(1):sleep(3) end,
    };
    Def.Sprite{
      Texture="movie.mp4",
      InitCommand=function(s) s:Center():blend(Blend.Add):pause():diffusealpha(0) end,
      OffCommand=function(s) s:play():linear(0.3):diffusealpha(1) end,
    }
  }
end

if GAMESTATE:IsCourseMode() then
  local course = GAMESTATE:GetCurrentCourse()
  if course:IsA20DanCourse() then
    t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/DanOverlay"))();
  end
end

return t;
