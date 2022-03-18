local t = Def.ActorFrame{};

t[#t+1] = StatsEngine()

local LoadingScreen = Var "LoadingScreen"

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
      t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/Towel"))(pn)..{
        InitCommand=function(s) s:draworder(2) end,
      };
    end
  else
    t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/SpeedKill"))();
    t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/Towel"))(pn)..{
      InitCommand=function(s) s:draworder(2) end,
    };
  end
end

t[#t+1] = Def.ActorFrame{
    InitCommand=function(s) s:draworder(2) end,
    Def.Sprite{
      Name="SFrame Light",
      Texture="stageframe/light_normal",
      InitCommand=function(s)
        s:xy(_screen.cx,SCREEN_TOP+16):visible(not GAMESTATE:IsDemonstration())
        if GAMESTATE:IsAnExtraStage() then
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
            if GAMESTATE:IsAnExtraStage() then
                s:Load(THEME:GetPathB("ScreenGameplay","decorations/stageframe/extra"))
            end
        end,
    };
    loadfile(THEME:GetPathB("ScreenGameplay","decorations/scoreframe/default.lua"))();
};
if not GAMESTATE:IsDemonstration() then
t[#t+1] = StandardDecorationFromFile("StageDisplay","StageDisplay")
end
for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = loadfile(THEME:GetPathB("ScreenGameplay","decorations/lifeframe"))(pn);
--options--
	t[#t+1] = loadfile(THEME:GetPathB("","_optionicon"))(pn) .. {
		InitCommand=function(s) s:player(pn):zoomx(1.8):zoomy(1.8):x(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200):draworder(1) end,
		OnCommand=function(self)
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y(IsUsingWideScreen() and SCREEN_TOP+172 or SCREEN_TOP+142);
			else
				self:y(IsUsingWideScreen() and SCREEN_BOTTOM-145 or SCREEN_BOTTOM-130);
			end;
		end;
	};
end

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
  t[#t+1] = Def.ActorFrame{
    InitCommand=function(s) s:y(_screen.cy-346):draworder(-1)
      if IsUsingWideScreen() then
        s:x(pn==PLAYER_1 and _screen.cx-494 or _screen.cx+494)
      else
        s:x(pn==PLAYER_1 and _screen.cx-320 or _screen.cx+320)
      end
    end,
    OnCommand=function(s) s:zoom(0):sleep(0.3):bounceend(0.2):zoom(1) end,
    OffCommand=function(s) s:linear(0.2):zoom(0) end,
    Def.BitmapText{
      Font="_russell square 24px";
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
          self:settext("+" .. compare):diffuse(color("#0a7cfc")):strokecolor(Color.Black)--blue, feel free to change it to whatever you want
          elseif(compare==0) then --if you are tied with your high score
          self:settext("+" .. compare):diffuse(color("#ffffff")):strokecolor(Color.Black)--white, you can change this            
          else --if you are doing worse than your high score
          self:settext(compare):diffuse(color("#ed0972")):strokecolor(Color.Black)--hot pink, you can change this too
          end;
        else --if you don't have a high score, this will only show the deduction
          self:settext(rpm):diffuse(color("#ed0972")):strokecolor(Color.Black)--hot pink, you can change this too
        end;
      end;
    };
  };
end;

t[#t+1] = StandardDecorationFromFileOptional("Help","Help");
t[#t+1] = Def.Sound{
  File=THEME:GetPathS("","MusicWheel expand"),
  Name="sound",
  SupportPan=true
};

return t
