local t = Def.ActorFrame{};
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local xPosPlayer = {
  P1 = -320,
  P2 = -20
};

function TopRecord(pn) --�^�ǳ̰��������Ӭ���
	local SongOrCourse, StepsOrTrail;
	local myScoreSet = {
		["HasScore"] = 0;
		["SongOrCourse"] =0;
		["topscore"] = 0;
		["topW1"]=0;
		["topW2"]=0;
		["topW3"]=0;
		["topW4"]=0;
		["topW5"]=0;
		["topMiss"]=0;
		["topOK"]=0;
		["topEXScore"]=0;
		["topMAXCombo"]=0;
		["topDate"]=0;
		};

	if GAMESTATE:IsCourseMode() then
		SongOrCourse = GAMESTATE:GetCurrentCourse();
		StepsOrTrail = GAMESTATE:GetCurrentTrail(pn);
	else
		SongOrCourse = GAMESTATE:GetCurrentSong();
		StepsOrTrail = GAMESTATE:GetCurrentSteps(pn);
	end;

	local profile, scorelist;

	if SongOrCourse and StepsOrTrail then
		local st = StepsOrTrail:GetStepsType();
		local diff = StepsOrTrail:GetDifficulty();
		local courseType = GAMESTATE:IsCourseMode() and SongOrCourse:GetCourseType() or nil;

		if PROFILEMAN:IsPersistentProfile(pn) then
			-- player profile
			profile = PROFILEMAN:GetProfile(pn);
		else
			-- machine profile
			profile = PROFILEMAN:GetMachineProfile();
		end;

		scorelist = profile:GetHighScoreList(SongOrCourse,StepsOrTrail);
		assert(scorelist);
		local scores = scorelist:GetHighScores();
		assert(scores);
		-- local topscore=0;
		-- local topW1=0;
		-- local topW2=0;
		-- local topW3=0;
		-- local topW4=0;
		-- local topW5=0;
		-- local topMiss=0;
		-- local topOK=0;
		-- local topEXScore=0;
		-- local topMAXCombo=0;
		if scores[1] then
			myScoreSet["SongOrCourse"]=1;
			myScoreSet["HasScore"] = 1;
			myScoreSet["topscore"] = scores[1]:GetScore();
			myScoreSet["topW1"]  = scores[1]:GetTapNoteScore("TapNoteScore_W1");
			myScoreSet["topW2"]  = scores[1]:GetTapNoteScore("TapNoteScore_W2");
			myScoreSet["topW3"]  = scores[1]:GetTapNoteScore("TapNoteScore_W3");
			myScoreSet["topW4"]  = scores[1]:GetTapNoteScore("TapNoteScore_W4")+scores[1]:GetTapNoteScore("TapNoteScore_W5");
			myScoreSet["topW5"]  = scores[1]:GetTapNoteScore("TapNoteScore_W5");
			myScoreSet["topMiss"]  = scores[1]:GetHoldNoteScore("HoldNoteScore_LetGo")+scores[1]:GetTapNoteScore("TapNoteScore_Miss");
			myScoreSet["topOK"]  = scores[1]:GetHoldNoteScore("HoldNoteScore_Held");
			myScoreSet["topMAXCombo"]  = scores[1]:GetMaxCombo();
			myScoreSet["topDate"]  = scores[1]:GetDate() ;
			--myScoreSet["topEXScore"]  = scores[1]:GetTapNoteScore("TapNoteScore_W1")*3+scores[1]:GetTapNoteScore("TapNoteScore_W2")*2+scores[1]:GetTapNoteScore("TapNoteScore_W3")+scores[1]:GetHoldNoteScore("HoldNoteScore_Held")*3;
			if (StepsOrTrail:GetRadarValues( pn ):GetValue( "RadarCategory_TapsAndHolds" ) >=0) then --If it is not a random course
				if scores[1]:GetGrade() ~= "Grade_Failed" then
					myScoreSet["topEXScore"] = scores[1]:GetTapNoteScore("TapNoteScore_W1")*3+scores[1]:GetTapNoteScore("TapNoteScore_W2")*2+scores[1]:GetTapNoteScore("TapNoteScore_W3")+scores[1]:GetHoldNoteScore("HoldNoteScore_Held")*3;
				else
					myScoreSet["topEXScore"] = (StepsOrTrail:GetRadarValues( pn ):GetValue( "RadarCategory_TapsAndHolds" )*3+StepsOrTrail:GetRadarValues( pn ):GetValue( "RadarCategory_Holds" )*3)*scores[1]:GetPercentDP();
				end
			else --If it is Random Course then the scores[1]:GetPercentDP() value will be -1
				if scores[1]:GetGrade() ~= "Grade_Failed" then
					myScoreSet["topEXScore"]  = scores[1]:GetTapNoteScore("TapNoteScore_W1")*3+scores[1]:GetTapNoteScore("TapNoteScore_W2")*2+scores[1]:GetTapNoteScore("TapNoteScore_W3")+scores[1]:GetHoldNoteScore("HoldNoteScore_Held")*3;
				else
					myScoreSet["topEXScore"]  = 0;
				end
			end
			myScoreSet["topMAXCombo"]  = scores[1]:GetMaxCombo();
			myScoreSet["topDate"]  = scores[1]:GetDate() ;
		else
			myScoreSet["SongOrCourse"]=1;
			myScoreSet["HasScore"] = 0;
		end;
	else
		myScoreSet["HasScore"] = 0;
		myScoreSet["SongOrCourse"]=0;

	end
	return myScoreSet;

end;

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
t[#t+1] = Def.ActorFrame{
  InitCommand=function(self)
    local short = ToEnumShortString(pn)
    self:x(xPosPlayer[short]):halign(0)
  end;
  CurrentSongChangedMessageCommand=function(s) s:queuecommand('Set') end,
  CurrentTrailP1ChangedMessageCommand=function(s) s:queuecommand('Set') end,
  CurrentStepsP1ChangedMessageCommand=function(s) s:queuecommand('Set') end,
  CurrentCourseChangedMessageCommand=function(s) s:queuecommand('Set') end,
  SetCommand=function(s)
    local c = s:GetChildren()
    
    local song = GAMESTATE:GetCurrentSong()
    local steps = GAMESTATE:GetCurrentSteps(pn)
    if not (song and steps) then
      c.Score:visible(false)
      c.Grade:visible(false)
      return
    end
    
    local profile
    if PROFILEMAN:IsPersistentProfile(pn) then
      profile = PROFILEMAN:GetProfile(pn)
    else
      profile = PROFILEMAN:GetMachineProfile()
    end

    local scores = profile:GetHighScoreList(song, steps):GetHighScores()
    local score = scores[1]
    if not score or score:GetScore() == 0 then
      c.Score:visible(false)
      c.Grade:visible(false)
      return
    end
    c.Score:visible(true)
    c.Grade:visible(true)
    
    s:playcommand('SetGrade', { Highscore = score, Steps = steps })
  end,
  Def.Sprite{
    Texture="Player 1x2";
    InitCommand=function(s) s:xy(260,-80):pause():setstate(0) end,
    BeginCommand=function(self)
      if pn == PLAYER_1 then
        self:setstate(0)
      else
        self:setstate(1)
      end;
    end;
  };
  Def.Sprite{
    Texture="Judge Inner",
    InitCommand=function(s) s:xy(230,5) end,
  };
  ScoreAndGrade.GetGradeActor{
    Big = true
  }..{
    Name='Grade',
    InitCommand=function(s)
      s:xy(400,-30):zoom(0.2)
      s:GetChild('FullCombo'):zoom(1.5)
    end,
  },
  ScoreAndGrade.GetScoreActorRolling{
    Font = '_avenirnext lt pro bold/25px',
    Load = 'RollingNumbersSongData',
  }..{
    Name='Score',
    InitCommand=function(s) s:xy(400,15):zoom(0.8):strokecolor(Color.Black) end,
  },
  Def.ActorFrame{
    InitCommand=function(s) s:xy(325,6):halign(1) end,
    CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
    CurrentTrailP1ChangedMessageCommand=function(s) s:queuecommand("Set") end,
    CurrentStepsP1ChangedMessageCommand=function(s) s:queuecommand("Set") end,
    CurrentCourseChangedMessageCommand=function(s) s:queuecommand("Set") end,
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px";
      InitCommand=function(s) s:xy(-65,-66):zoom(0.5) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        myScoreSet = TopRecord(pn);
        local temp = myScoreSet["topDate"];
        if (myScoreSet["SongOrCourse"]==1) then
          if (myScoreSet["HasScore"]==1) then
            self:settext( temp);
            self:diffusealpha(1);
          else
            self:diffusealpha(0);
          end
        else
          self:diffusealpha(0);
        end
      end;
    };
    Def.RollingNumbers{
      File = THEME:GetPathF("","_avenirnext lt pro bold/20px");
      InitCommand=function(s) s:halign(1):y(-50):zoom(0.75) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        self:Load("RollingNumbersJudgment");
        myScoreSet = TopRecord(pn)
        if (myScoreSet["SongOrCourse"]==1) then
          if (myScoreSet["HasScore"]==1) then
            local topscore = myScoreSet["topMAXCombo"];
            self:targetnumber(topscore)
          else
            self:targetnumber(0);
          end;
        end;
      end;
    };
    Def.RollingNumbers{
      File = THEME:GetPathF("","_avenirnext lt pro bold/20px");
      InitCommand=function(s) s:halign(1):y(-35):zoom(0.75) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        self:Load("RollingNumbersJudgment");
        myScoreSet = TopRecord(pn)
        if (myScoreSet["SongOrCourse"]==1) then
          if (myScoreSet["HasScore"]==1) then
            local topscore = myScoreSet["topW1"];
            self:targetnumber(topscore)
          else
            self:targetnumber(0);
          end;
        end;
      end;
    };
    Def.RollingNumbers{
      File = THEME:GetPathF("","_avenirnext lt pro bold/20px");
      InitCommand=function(s) s:halign(1):y(-18):zoom(0.75) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        self:Load("RollingNumbersJudgment");
        myScoreSet = TopRecord(pn)
        if (myScoreSet["SongOrCourse"]==1) then
          if (myScoreSet["HasScore"]==1) then
            local topscore = myScoreSet["topW2"];
            self:targetnumber(topscore)
          else
            self:targetnumber(0);
          end;
        end;
      end;
    };
    Def.RollingNumbers{
      File = THEME:GetPathF("","_avenirnext lt pro bold/20px");
      InitCommand=function(s) s:halign(1):zoom(0.75) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        self:Load("RollingNumbersJudgment");
        myScoreSet = TopRecord(pn)
        if (myScoreSet["SongOrCourse"]==1) then
          if (myScoreSet["HasScore"]==1) then
            local topscore = myScoreSet["topW3"];
            self:targetnumber(topscore)
          else
            self:targetnumber(0);
          end;
        end;
      end;
    };
    Def.RollingNumbers{
      File = THEME:GetPathF("","_avenirnext lt pro bold/20px");
      InitCommand=function(s) s:halign(1):y(16):zoom(0.75) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        self:Load("RollingNumbersJudgment");
        myScoreSet = TopRecord(pn)
        if (myScoreSet["SongOrCourse"]==1) then
          if (myScoreSet["HasScore"]==1) then
            local topscore = myScoreSet["topW4"];
            self:targetnumber(topscore)
          else
            self:targetnumber(0);
          end;
        end;
      end;
    };
    Def.RollingNumbers{
      File = THEME:GetPathF("","_avenirnext lt pro bold/20px");
      InitCommand=function(s) s:halign(1):y(32):zoom(0.75) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        self:Load("RollingNumbersJudgment");
        myScoreSet = TopRecord(pn)
        if (myScoreSet["SongOrCourse"]==1) then
          if (myScoreSet["HasScore"]==1) then
            local topscore = myScoreSet["topOK"];
            self:targetnumber(topscore)
          else
            self:targetnumber(0);
          end;
        end;
      end;
    };
    Def.RollingNumbers{
      File = THEME:GetPathF("","_avenirnext lt pro bold/20px");
      InitCommand=function(s) s:halign(1):y(48):zoom(0.75) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        self:Load("RollingNumbersJudgment");
        myScoreSet = TopRecord(pn)
        if (myScoreSet["SongOrCourse"]==1) then
          if (myScoreSet["HasScore"]==1) then
            local topscore = myScoreSet["topMiss"];
            self:targetnumber(topscore)
          else
            self:targetnumber(0);
          end;
        end;
      end;
    };
  };
};

end;

return t;
