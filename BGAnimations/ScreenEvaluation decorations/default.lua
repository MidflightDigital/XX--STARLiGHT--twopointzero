local t = LoadFallbackB();
local jk = LoadModule "Jacket.lua"

t[#t+1] = StandardDecorationFromFile("StageDisplay","StageDisplay");

local screen = Var("LoadingScreen")

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

if GAMESTATE:HasEarnedExtraStage() == false and not has_value(List,GAMESTATE:GetCurrentSong():GetDisplayMainTitle()) then
    t[#t+1] = Def.Sound{
      File=GetMenuMusicPath "results",
        OnCommand=function(self)
            self:play()
        end;
    }
end;

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
                self:Load(jk.GetSongGraphicPath(song,"Jacket")):zoomto(378,378)
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
      Font="_avenirnext lt pro bold 25px",
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
      Font="_avenirnext lt pro bold 25px",
		  InitCommand = function(s) s:y(20):maxwidth(400):playcommand("Set") end,
      SetCommand = function(self)
        if not GAMESTATE:IsCourseMode() then
			    local song = GAMESTATE:GetCurrentSong()
          self:settext(song and song:GetDisplayArtist() or "")
        end
		  end,
	  };
  };
};

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
  local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
  local Score = pss:GetScore()
  local EXScore = SN2Scoring.ComputeEXScoreFromData(SN2Scoring.GetCurrentScoreData(pss));
  local seconds = pss:GetSurvivalSeconds()
  local short_plr = ToEnumShortString(pn)
  local profileID = GetProfileIDForPlayer(pn)
  local pPrefs = ProfilePrefs.Read(profileID)
  local ex_score = pPrefs.ex_score

  local function FindText(pss)
    return string.format("%02d STAGE",pss:GetSongsPassed())
  end

  t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluation","decorations/grade"))(pn)

  t[#t+1] = Def.ActorFrame{
    Name="Scores",
    InitCommand=function(s) s:y(_screen.cy-2):zoom(0)
      if pn == PLAYER_1 then
        s:x(IsUsingWideScreen() and _screen.cx-500 or _screen.cx-440)
      elseif pn == PLAYER_2 then
        s:x(IsUsingWideScreen() and _screen.cx+500 or _screen.cx+440)
      end
    end,
    OnCommand=function(s) s:zoom(0):sleep(0.3):bounceend(0.2):zoom(2) end,
    OffCommand=function(s) s:linear(0.2):zoom(0) end,
    Def.RollingNumbers{
      Font="_avenirnext lt pro bold 46px",
      OnCommand=function(s)
        s:strokecolor(Color.Black):visible(not ex_score)
        :Load("RollingNumbersEvaluation"):targetnumber(Score)
      end,
    };
    Def.RollingNumbers{
      Font="_avenirnext lt pro bold 46px",
      OnCommand=function(s)
        s:strokecolor(Color.Black):visible(ex_score)
        :Load("RollingNumbersEXScore"):targetnumber(EXScore)
      end,
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold 25px";
      InitCommand=function(s) s:xy(120,26):strokecolor(Color.Black):halign(1):zoom(0.5) end,
      OnCommand=function(self)
        self:hibernate(0.6)
        local short = ToEnumShortString(pn)
        local steps = GAMESTATE:GetCurrentSteps(pn)
        local song=GAMESTATE:GetCurrentSong()
        if song then
          local st=GAMESTATE:GetCurrentStyle():GetStepsType();
  
          if PROFILEMAN:IsPersistentProfile(pn) then
            profile = PROFILEMAN:GetProfile(pn)
          else
            profile = PROFILEMAN:GetMachineProfile()
          end;
  
          scorelist = profile:GetHighScoreList(song,steps)
          local scores = scorelist:GetHighScores()
          local HS = 0
  
          if scores[2] then
            HS = SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[2])
          end;
          local adjHS = Score-HS
          if adjHS > 0 then
            self:settextf("+".."%7d",adjHS)
            self:diffuse(color("0.3,0.7,1,1"))
          else
            self:settextf("%7d",adjHS)
            self:diffuse(color("1,0.3,0.5,1"))
          end
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
        Font="_avenirnext lt pro bold 42px";
        OnCommand=function(self)
          self:y(46)
          self:settext(SecondsToMMSS(seconds)):strokecolor(Color.Black)
        end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold 36px";
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
        Font="_handel gothic itc std Bold 32px";
        OnCommand=function(self)
          self:y(-40)
          self:uppercase(true):settext(GAMESTATE:GetCurrentStyle():GetName()):strokecolor(Color.Black)
        end;
      };
      Def.BitmapText{
        Font="_handel gothic itc std Bold 32px";
        OnCommand=function(self)
          local diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty();
          self:uppercase(true):settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff)))
          :diffuse(CustomDifficultyToColor(diff)):strokecolor(Color.Black)
        end;
      };
      Def.BitmapText{
        Font="_handel gothic itc std Bold 32px";
        OnCommand=function(self)
          self:y(36)
          local meter = GAMESTATE:GetCurrentSteps(pn):GetMeter();
          self:settext(meter):strokecolor(Color.Black)
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
      Font="_avenirnext lt pro bold 25px";
      InitCommand=function(self)
        self:xy(pn=="PlayerNumber_P2" and SCREEN_RIGHT-110 or SCREEN_LEFT+120,_screen.cy-314)
        self:settext(PROFILEMAN:GetProfile(pn):GetDisplayName())
      end;
    }
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
	t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluation","decorations/frame"))(GAMESTATE:GetMasterPlayerNumber(),PLAYER_1,EvalPane1)..{
    InitCommand=function(s)
      s:xy(IsUsingWideScreen() and _screen.cx-500 or _screen.cx-360,_screen.cy+250)
    end,
	};
	--P2 Frame
	t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluation","decorations/frame"))(GAMESTATE:GetMasterPlayerNumber(),PLAYER_2,EvalPane2)..{
		InitCommand=function(s)
      s:xy(IsUsingWideScreen() and _screen.cx+500 or _screen.cx+360,_screen.cy+250)
    end,
  };
else --If multiplayer
  local profileID1 = GetProfileIDForPlayer(PLAYER_1)
  local pPrefs1 = ProfilePrefs.Read(profileID1)
  local EvalPane1P = pPrefs1.evalpane1
	--P1 Frame
	t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluation","decorations/frame"))(PLAYER_1,PLAYER_1,EvalPane1P)..{
		InitCommand=function(s)
      s:xy(IsUsingWideScreen() and _screen.cx-500 or _screen.cx-360,_screen.cy+250)
    end,
  };
  local profileID2 = GetProfileIDForPlayer(PLAYER_2)
  local pPrefs2 = ProfilePrefs.Read(profileID2)
  local EvalPane2P = pPrefs2.evalpane1
	--P2 Frame
	t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluation","decorations/frame"))(PLAYER_2,PLAYER_2,EvalPane2P)..{
		InitCommand=function(s)
      s:xy(IsUsingWideScreen() and _screen.cx+500 or _screen.cx+360,_screen.cy+250)
    end,
  };

end;
  
if GAMESTATE:HasEarnedExtraStage() then
  t[#t+1] = loadfile(THEME:GetPathB("ScreenEvaluation","decorations/EXOverlay"))();
  --Outro Movie
  t[#t+1] = Def.ActorFrame{
    Def.Quad{
      InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0)) end,
      OffCommand=function(s) s:linear(0.3):diffusealpha(1):sleep(3) end,
    };
    Def.Sprite{
      Texture="movie.avi",
      InitCommand=function(s) s:Center():blend(Blend.Add):pause():diffusealpha(0) end,
      OffCommand=function(s) s:play():linear(0.3):diffusealpha(1) end,
    }
  }
end

return t;
