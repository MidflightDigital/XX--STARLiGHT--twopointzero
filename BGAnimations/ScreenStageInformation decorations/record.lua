local t = Def.ActorFrame{};

local xPosPlayer = {
    P1 = SCREEN_LEFT+280,
    P2 = SCREEN_RIGHT-280
}

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do

t[#t+1] = Def.ActorFrame{
  InitCommand=function(self)
    local short = ToEnumShortString(pn)
    self:x(xPosPlayer[short]):y(_screen.cy+180)
  end;
  OnCommand=function(self)
    if pn == PLAYER_1 then
      self:addx(-800):sleep(1.2):decelerate(0.2):addx(800)
    else
      self:addx(800):sleep(1.2):decelerate(0.2):addx(-800)
    end;
    --[[local profileID = GetProfileIDForPlayer(pn)
    local pPrefs = ProfilePrefs.Read(profileID)
    if pPrefs.guidelines == true then
      pPrefs.guidelines = false
    else
      pPrefs.guidelines = false
    end]]
  end;
  LoadActor("score")..{
    InitCommand=function(s) s:zoomx(pn=='PlayerNumber_P2' and -1 or 1) end,
  };
  Def.Sprite{
    Texture="BEST SCORE.png",
    InitCommand=function(s)
      s:xy(pn==PLAYER_1 and -200 or 200,-60)
    end
  };
  Def.BitmapText{
    Name="ScoreNumber";
    Font="ScoreDisplayNormal Text";
    InitCommand=function(self)
      self:xy(pn=='PlayerNumber_P2' and 46 or -46,-32)
    end;
    BeginCommand=function(s) s:playcommand("Set") end,
    SetCommand=function(self)
      self:settext("")

      local song=GAMESTATE:GetCurrentSong()
      if song then
        local steps = GAMESTATE:GetCurrentSteps(pn);
        local st=GAMESTATE:GetCurrentStyle():GetStepsType();

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

        self:strokecolor(Color.Black)
        self:diffusealpha(1)

        if topscore ~= 0 then
          self:settext(commify(topscore))
        else
          self:settext("0,000,000")
        end
      end
    end;
  };
  Def.BitmapText{
    Font="_avenirnext lt pro bold/42px";
    InitCommand=function(self)
      self:y(14)
      self:playcommand("Set")
      self:zoomy(0.75);
    end;
    SetCommand=function(s)
      s:maxwidth(434);
      s:settext(PROFILEMAN:GetProfile(pn):GetDisplayName())
    end;
  };
  Def.BitmapText{
    Font="CFBPMDisplay";
    InitCommand=function(self)
      self:y(60):diffuse(color("#d5feff"))
      self:playcommand("Set")
      self:zoomy(0.75);
    end;
    SetCommand=function(s)
      s:maxwidth(390);
      local song = GAMESTATE:GetCurrentSong()
      if song then
        local steps = GAMESTATE:GetCurrentSteps(pn)
        local sart = steps:GetAuthorCredit()
        if sart ~= "" then
          s:settext("stepchart by "..steps:GetAuthorCredit())
        else
          s:settext("")
        end
      end
    end;
  };
  Def.BitmapText{
    Font="_avenirnext lt pro bold/20px";
    Name="Difficulty Label";
    InitCommand=function(self)
      self:x(pn=='PlayerNumber_P2' and 200 or -200):y(-80):zoom(0.75)
      self:playcommand("Set")
    end;
    SetCommand=function(s)
      local diff;
      if GAMESTATE:IsCourseMode() then
        diff = GAMESTATE:GetCurrentTrail(pn):GetDifficulty();
      else
        diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty();
      end;
      s:maxwidth(270);
      s:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff))):uppercase(true):diffuse(CustomDifficultyToColor(diff))
    end;
  };
  Def.ActorFrame{
    InitCommand=function(s) s:xy(pn=='PlayerNumber_P2' and -200 or 220,-32) end,
    LoadActor(THEME:GetPathG("Player","Badge FullCombo"))..{
      InitCommand=function(s) s:xy(6,6):zoom(0.75) end,
      BeginCommand=function(s) s:playcommand("Set") end,
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
    };
    Def.Quad{
      InitCommand=function(self)
        self:zoom(0.1)
      end;
      BeginCommand=function(s) s:playcommand("Set") end,
      SetCommand=function(self)
        local song = GAMESTATE:GetCurrentSong();
        local steps = GAMESTATE:GetCurrentSteps(pn);
        if song then
          local st = GAMESTATE:GetCurrentStyle():GetStepsType()
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
  
          local topscore=0;
          if scores[1] then
            topscore = SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[1])
            topscore2 = scores[1];
          end;
          assert(topscore);
          if scores[1] then
            local misses = topscore2:GetTapNoteScore("TapNoteScore_Miss")+topscore2:GetTapNoteScore("TapNoteScore_CheckpointMiss")
            local boos = topscore2:GetTapNoteScore("TapNoteScore_W5")
            local goods = topscore2:GetTapNoteScore("TapNoteScore_W4")
            local greats = topscore2:GetTapNoteScore("TapNoteScore_W3")
            local perfects = topscore2:GetTapNoteScore("TapNoteScore_W2")
            local marvelous = topscore2:GetTapNoteScore("TapNoteScore_W1")
            if (misses+boos) == 0 and topscore > 0 and (marvelous+perfects)>0 then
              self:addx(-14)
            end;
          end;
          if scores[1] then
            local topgrade = scores[1]:GetGrade();
            local tier = SN2Grading.ScoreToGrade(topscore, diff)
            assert(topgrade);
            if scores[1]:GetScore()>1  then
              if topgrade == 'Grade_Failed' then
                self:Load(THEME:GetPathB("","ScreenEvaluationNormal decorations/grade/GradeDisplayEval Failed"));
              else
                self:Load(THEME:GetPathB("ScreenEvaluationNormal decorations/grade/GradeDisplayEval",ToEnumShortString(tier)));
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
    };
  }
}
end;

return t;
