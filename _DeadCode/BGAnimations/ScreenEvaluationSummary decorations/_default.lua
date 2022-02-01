local st = GAMESTATE:GetCurrentStyle():GetStepsType();

local mStages = STATSMAN:GetStagesPlayed();
local i = 0;
local t = Def.ActorFrame {};
local screen = Var("LoadingScreen")
if THEME:GetMetric(screen, "ShowHeader") then
	t[#t+1] = LoadActor(THEME:GetPathG(screen, "Header")) .. {
		Name = "Header",
	}
end

t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:xy(_screen.cx,_screen.cy-320) end,
	OnCommand=function(s) s:addy(-SCREEN_HEIGHT):sleep(0.2):decelerate(.2):addy(SCREEN_HEIGHT) end,
	OffCommand=function(s) s:decelerate(0.2):addy(-SCREEN_HEIGHT) end,
	Def.Sprite{
		OnCommand=function(self)
			local style = GAMESTATE:GetCurrentStyle():GetName()
			self:Load(THEME:GetPathB("","ScreenEvaluationSummary decorations/"..style))
			self:y(-40)
		end;
	};
	Def.Sprite{
		OnCommand=function(self)
			local style = GAMESTATE:GetCurrentStyle():GetStyleType()
			if style == 'StyleType_OnePlayerOneSide' then
				self:Load(THEME:GetPathB("","ScreenEvaluationSummary decorations/1Pad"))
			else
				self:Load(THEME:GetPathB("","ScreenEvaluationSummary decorations/2Pad"))
			end;
			self:y(30)
		end;
	};
};


for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = Def.ActorFrame{
    OnCommand=function(self)
      self:addx(pn=="PlayerNumber_P2" and 300 or -300)
      self:sleep(0.3):linear(0.2):addx(pn=="PlayerNumber_P2" and -300 or 300)
    end;
    OffCommand=function(self)
      self:linear(0.2):addx(pn=="PlayerNumber_P2" and 300 or -300)
    end;
    LoadActor("../ScreenEvaluationNormal overlay/player")..{
      InitCommand=function(self)
        self:zoomx(pn=="PlayerNumber_P2" and -1 or 1)
        self:x(pn=="PlayerNumber_P2" and SCREEN_RIGHT or SCREEN_LEFT)
        self:halign(0):y(_screen.cy-300)
      end;
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px";
      InitCommand=function(self)
        self:x(pn=="PlayerNumber_P2" and SCREEN_RIGHT-110 or SCREEN_LEFT+120)
        self:y(_screen.cy-304)
        if PROFILEMAN:IsPersistentProfile(pn) then
          self:settext(PROFILEMAN:GetProfile(pn):GetDisplayName())
        else
          self:settext(pn=="PlayerNumber_P2" and "PLAYER 2" or "PLAYER 1")
        end
      end;
    }
  }
end

local function StageCheck()
	if getenv("FixStage") == 1 then
		return 2
	else
		return 1
	end
end

-- Center
for i = StageCheck(), mStages do
	local ssStats;
	if getenv("FixStage") == 1 then
		ssStats = STATSMAN:GetPlayedStageStats( i-1 );
	else
		ssStats = STATSMAN:GetPlayedStageStats( i );
	end
	t[#t+1] = Def.ActorFrame {
		InitCommand=function(s) s:Center() end,
		BeginCommand=function(self)
			if mStages == 2 then
				self:addy(-25 + ((mStages - i) * 105));
			elseif mStages == 3 then
				self:addy(-50 + ((mStages - i) * 105));
			elseif mStages == 4 then
				self:addy(-100 + ((mStages - i) * 105));
			elseif mStages == 5 then
				self:addy(-210 + ((mStages - i) * 105));
			elseif mStages == 6 then
				self:addy(-210 + ((mStages - i) * 105));
			elseif mStages == 7 then
				self:addy(-210 + ((mStages - i) * 105));
			else
				self:addy(((mStages - i) * 112));
			end;
		end;

		LoadActor("line.png")..{
			InitCommand=function(s) s:diffusealpha(0):y(10) end,
			OnCommand=function(s) s:sleep(0.25):diffusealpha(1) end,
			OffCommand=function(s) s:diffusealpha(0) end,
		};

		-- banner
		Def.Sprite {
			BeginCommand=function(self)
				local sssong = ssStats:GetPlayedSongs()[1];
				self:x(-290);
				self:y(10);
				self:_LoadSCJacket(sssong)
				self:scaletoclipped(87,87)
			end;
			OnCommand=function(self)
				self:zoomy(0);
				self:sleep(0.25+(i-mStages)*-0.1);
				self:linear(0.2);
				self:zoomto(87,87);
			end;
			OffCommand=function(s) s:linear(0.25):zoomy(0) end,
		};

		-- Title
		LoadFont("_avenirnext lt pro bold/42px")..{
			InitCommand=function(s) s:maxwidth(400) end,
			BeginCommand=function(self)
				local sssong = ssStats:GetPlayedSongs()[1];
				local sssmaint = sssong:GetDisplayFullTitle();
				self:x(26);
				self:settext(sssmaint);
			end;
			OnCommand=function(self)
				self:zoomy(0);
				self:sleep(0.25+(i-mStages)*-0.1);
				self:linear(0.2);
				self:zoomy(1);
			end;
			OffCommand=function(s) s:diffusealpha(0) end,
		};
	};
end;

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	for i = StageCheck(), mStages do
		local sStats;
		if getenv("FixStage") == 1 then
			sStats = STATSMAN:GetPlayedStageStats( i-1 );
		else
			sStats = STATSMAN:GetPlayedStageStats( i );
		end
	local pss = sStats:GetPlayerStageStats( pn );
	
	t[#t+1] = Def.ActorFrame {
		InitCommand=function(s) s:player(pn):Center() end,
		BeginCommand=function(self)
			if mStages == 2 then
				self:addy(-25 + ((mStages - i) * 105));
			elseif mStages == 3 then
				self:addy(-50 + ((mStages - i) * 105));
			elseif mStages == 4 then
				self:addy(-100 + ((mStages - i) * 105));
			elseif mStages == 5 then
				self:addy(-210 + ((mStages - i) * 105));
			elseif mStages == 6 then
				self:addy(-210 + ((mStages - i) * 105));
			elseif mStages == 7 then
				self:addy(-210 + ((mStages - i) * 105));
			else
				self:addy(((mStages - i) * 112));
			end;
		end;
		OffCommand=function(self)
			if pn == PLAYER_1 then
				self:linear(0.4);
				self:addx(-SCREEN_WIDTH);
			else
				self:linear(0.4);
				self:addx(SCREEN_WIDTH);
			end

		end;

		-- Label
		LoadActor( "total" ) .. {
			InitCommand=function(s) s:halign(0) end,
			OnCommand=function(self)
				if pn == PLAYER_1 then
					self:x(-SCREEN_WIDTH);
					self:sleep(0.05+(i-mStages)*-0.1);
					self:linear(0.4);
					self:x(-966);
					self:y(14);
					self:zoomy(1)
				else
					self:rotationy(180);
					self:x(SCREEN_WIDTH);
					self:sleep(0.05+(i-mStages)*-0.1);
					self:linear(0.4);
					self:x(966);
					self:y(14);
					self:zoomy(1)
				end
			end;
		};

		-- difficulty
		LoadActor("lamp") .. {
			InitCommand=function(s) s:halign(1) end,
			BeginCommand=function(self)
				local diff = pss:GetPlayedSteps()[1]:GetDifficulty();
				if sStats then
					self:diffuse(CustomDifficultyToColor(diff));
					self:visible(true);
				else
					self:visible(false);
				end
			end;
			OnCommand=function(self)
				if pn == PLAYER_1 then
					self:x(-SCREEN_WIDTH);
					self:sleep(0.05+(i-mStages)*-0.1);
					self:linear(0.4);
					self:x(-448);
					self:y(13);
					self:zoom(1)
				else
					self:rotationy(180);
					self:x(SCREEN_WIDTH);
					self:sleep(0.05+(i-mStages)*-0.1);
					self:linear(0.4);
					self:x(448);
					self:y(13);
					self:zoom(1)
				end
			end;
		};

		-- fullcombo
		LoadActor("FullCombo") .. {
			BeginCommand=function(self)
				self:x(pn=="PlayerNumber_P2" and 500 or -500)
				self:y(30);
				local grade = pss:GetGrade();
				if grade ~= "Grade_Tier08" then
					local fc_type = pss:FullComboType();
					if fc_type then
						self:diffuse(FullComboEffectColor[fc_type]);
						self:visible(true);
					else
						self:visible(false);
					end
				else
					self:visible(false);
				end;
			end;
			OnCommand=function(self)
				self:zoom(0);
				self:sleep(0.45+(i-mStages)*-0.1);
				self:linear(0.4);
				self:zoom(0.3);
			end;
		};

		-- grade
		Def.Sprite {
			InitCommand=function(s) s:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.8")):effectperiod(0.2) end,
			BeginCommand=function(self)
				local Grade = pss:GetFailed() and 'Grade_Failed' or SN2Grading.ScoreToGrade(pss:GetScore());
				self:Load(THEME:GetPathB("ScreenEvaluationNormal overlay/grade/GradeDisplayEval",ToEnumShortString(Grade)));
				if pn == PLAYER_1 then
					if pss:FullComboType() then
						self:addx(-560);
					else
						self:addx(-540);
					end;
				else
					if pss:FullComboType() then
						self:addx(560);
					else
						self:addx(540);
					end;
				end
				self:zoomx(0.25)
				self:y(10)
			end;
			OnCommand=function(self)
				self:zoomy(0);
				self:sleep(0.45+(i-mStages)*-0.1);
				self:linear(0.4);
				self:zoomy(0.25);
			end;
		};

		-- stage
		LoadFont("_avenirnext lt pro bold/25px")..{
			InitCommand=function(s) s:maxwidth(190):zoom(1.2) end,
			BeginCommand=function(self)
				if PROFILEMAN:IsPersistentProfile(PLAYER_1) or PROFILEMAN:IsPersistentProfile(PLAYER_2) then
					local pStage = sStats:GetStage();
					local stageText = StageToLocalizedString(pStage).." STAGE"
					self:settext(stageText);
				else
					local pStage = sStats:GetStage();
					self:settextf("%s STAGE",THEME:GetString("StageFix",StageToLocalizedString(pStage)))
				end
				if pn == PLAYER_1 then
					self:halign(1)
				else
					self:halign(0)
				end
			end;
			OnCommand=function(self)
				if pn == PLAYER_1 then
					self:x(-SCREEN_WIDTH);
					self:sleep(0.05+(i-mStages)*-0.1);
					self:linear(0.4);
					self:x(-675);
					self:y(-10);
				else
					self:x(SCREEN_WIDTH);
					self:sleep(0.05+(i-mStages)*-0.1);
					self:linear(0.4);
					self:x(675);
					self:y(-10);
				end
			end;
		};

		-- Score
		Def.RollingNumbers {
			File=THEME:GetPathF("","_avenirnext lt pro bold/36px");
			InitCommand=function(s) s:zoom(0.9):Load("RollingNumbersScore"):diffusealpha(0):diffuse(color("#ffffff")):strokecolor(color("#000000")) end,
			BeginCommand=function(self)
				local song = sStats:GetPlayedSongs()[1];
				local diff = pss:GetPlayedSteps()[1]:GetDifficulty();
				local steps = song:GetOneSteps( st, diff );
				local radar = steps:GetRadarValues(pn);
				local maxsteps = math.max(radar:GetValue('RadarCategory_TapsAndHolds')+radar:GetValue('RadarCategory_Holds')+radar:GetValue('RadarCategory_Rolls'),1);
				self:targetnumber(pss:GetScore());
				if pn == PLAYER_1 then
					self:halign(1)
				else
					self:halign(0);
				end
				self:y(8);
			end;
			OnCommand=function(self)
				if pn == PLAYER_1 then
					self:x(-SCREEN_WIDTH);
					self:sleep(0.05+(i-mStages)*-0.1);
					self:linear(0.4);
					self:x(-675);
					self:y(26);
				else
					self:x(SCREEN_WIDTH);
					self:sleep(0.05+(i-mStages)*-0.1);
					self:linear(0.4);
					self:x(675);
					self:y(26);
				end
			end;
		};
	};
	end;
end;

t[#t+1] = StandardDecorationFromFileOptional("Help","Help");

return t
