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

t[#t+1] = StandardDecorationFromFileOptional("Help","Help");
t[#t+1] = Def.Sound{
  File=THEME:GetPathS("","MusicWheel expand"),
  Name="sound",
  SupportPan=true
};

return t
