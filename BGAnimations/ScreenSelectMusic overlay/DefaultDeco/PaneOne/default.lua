local pn = ({...})[1] --only argument to file

local t = Def.ActorFrame{
  InitCommand=function(s)
    s:xy(pn=="PlayerNumber_P2" and SCREEN_RIGHT-454 or SCREEN_LEFT+454,RadarY()-10):zoomx(pn=="PlayerNumber_P2" and -1 or 1)
  end;
};

t[#t+1] = Def.ActorFrame{
  LoadActor("Judge Pane")..{
    InitCommand=function(s) s:zoomx(pn=="PlayerNumber_P2" and -1 or 1) end,
  };
  LoadActor("BEST SCORE")..{
    InitCommand=function(s) s:xy(pn==PLAYER_2 and -2 or 2,-78) end,
  };
  LoadActor("Judge Inner")..{
    InitCommand=function(s)
      s:xy(-25,9)
    end,
  };
  Def.ActorFrame{
    InitCommand=function(s) s:x(pn==PLAYER_2 and -156 or 156) end,
    CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
    ["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
    ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
    CurrentCourseChangedMessageCommand=function(s) s:queuecommand("Set") end,
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
  
          local topgrade;
          if scores[1] then
            topgrade = scores[1]:GetGrade();
            local tier = SN2Grading.ScoreToGrade(topscore, diff)
            assert(topgrade);
            if scores[1]:GetScore()>1  then
              self:LoadBackground(THEME:GetPathB("ScreenEvaluationNormal overlay/grade/GradeDisplayEval",ToEnumShortString(tier)));
              self:diffusealpha(1):zoom(0.25):y(-15)
            end;
          else
            self:LoadBackground(THEME:GetPathB("ScreenSelectMusic","overlay/2014Deco/PaneOne/NO PLAY"));
            self:diffusealpha(1):zoom(1):y(0)
          end;
        else
          self:diffusealpha(0)
        end;
      end;
    };
    LoadFont("_avenirnext lt pro bold 25px")..{
      Name="Score";
      InitCommand=function(s) s:y(35) end,
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        self:settext("")
  
        local st=GAMESTATE:GetCurrentStyle():GetStepsType()
        local song=GAMESTATE:GetCurrentSong()
        local steps = GAMESTATE:GetCurrentSteps(pn)
        if song then
          local diff = steps:GetDifficulty();
          if song:HasStepsTypeAndDifficulty(st,diff) then
            local steps = song:GetOneSteps(st,diff)
  
            if PROFILEMAN:IsPersistentProfile(pn) then
              profile = PROFILEMAN:GetProfile(pn)
            else
              profile = PROFILEMAN:GetMachineProfile()
            end;
  
            scorelist = profile:GetHighScoreList(song,steps)
            local scores = scorelist:GetHighScores()
            local topscore = 0
  
            if scores[1] then
              topscore = SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[1])
            end;
  
            self:diffusealpha(1)
  
            if topscore ~= 0 then
				self:settext(commify(topscore))
            else
              self:settext("")
            end;
          end;
        end;
      end;
    };
  };
};

function TopRecord(pn) --�^�ǳ̰��������Ӭ���
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

	local song = GAMESTATE:GetCurrentSong();
	local steps = GAMESTATE:GetCurrentSteps(pn);

	local profile, scorelist;

	if song and steps then
		local st = steps:GetStepsType();
		local diff = steps:GetDifficulty();

		if PROFILEMAN:IsPersistentProfile(pn) then
			-- player profile
			profile = PROFILEMAN:GetProfile(pn);
		else
			-- machine profile
			profile = PROFILEMAN:GetMachineProfile();
		end;

		scorelist = profile:GetHighScoreList(song,steps);
		assert(scorelist);
		local scores = scorelist:GetHighScores();
		assert(scores);
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

t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:xy(0,-60) end,
  Def.BitmapText{
    Font="_avenirnext lt pro bold 25px";
    InitCommand=function(s) s:zoom(0.6) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
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
}

t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:xy(70,9) end,
  CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
  ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
  ["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
  CurrentCourseChangedMessageCommand=function(s) s:queuecommand("Set") end,
  Def.RollingNumbers{
    File = THEME:GetPathF("","_avenirnext lt pro bold 20px");
    InitCommand=function(s) s:halign(1):y(-50):zoom(0.75) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
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
    File = THEME:GetPathF("","_avenirnext lt pro bold 20px");
    InitCommand=function(s) s:halign(1):y(-35):zoom(0.75) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
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
    File = THEME:GetPathF("","_avenirnext lt pro bold 20px");
    InitCommand=function(s) s:halign(1):y(-18):zoom(0.75) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
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
    File = THEME:GetPathF("","_avenirnext lt pro bold 20px");
    InitCommand=function(s) s:halign(1):zoom(0.75) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
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
    File = THEME:GetPathF("","_avenirnext lt pro bold 20px");
    InitCommand=function(s) s:halign(1):y(16):zoom(0.75) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
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
    File = THEME:GetPathF("","_avenirnext lt pro bold 20px");
    InitCommand=function(s) s:halign(1):y(32):zoom(0.75) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
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
    File = THEME:GetPathF("","_avenirnext lt pro bold 20px");
    InitCommand=function(s) s:halign(1):y(48):zoom(0.75) end,
    BeginCommand=function(s) s:queuecommand("Set") end,
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

return t;
