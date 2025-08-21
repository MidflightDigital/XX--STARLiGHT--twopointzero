local pn = ...
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local t = Def.ActorFrame {};
-- Holy fcuk yes it's finally working (inefficient as it may be)
local function RivalScore(pn,rival)
	local t=Def.ActorFrame {
		SetCommand=function(s)      
      local c = s:GetChildren()
			
			local SongOrCourse, StepsOrTrail
			if GAMESTATE:IsCourseMode() then
				SongOrCourse = GAMESTATE:GetCurrentCourse()
				StepsOrTrail = GAMESTATE:GetCurrentTrail(pn)
			else
				SongOrCourse = GAMESTATE:GetCurrentSong()
				StepsOrTrail = GAMESTATE:GetCurrentSteps(pn)
			end;
      if not (SongOrCourse and StepsOrTrail) then
        c.Score:visible(false)
        c.GradeFrame:visible(false)
        return
      end
			
      
      local profile
      if PROFILEMAN:IsPersistentProfile(pn) then
        profile = PROFILEMAN:GetProfile(pn)
      else
        profile = PROFILEMAN:GetMachineProfile()
      end;
      local scores = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()
      local score = scores[rival]
      if not score then
        c.Score:visible(false)
        c.GradeFrame:visible(false)
        return
      end
      
      s:playcommand('SetGrade', { Highscore = score, Steps = StepsOrTrail })
    end;
		OnCommand=function(s) s:playcommand("Set") end,
		CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(s) s:playcommand("Set") end,
		["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
		["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/25px",
			Text=THEME:GetString("ScreenEvaluation","RIVAL"..rival),
			InitCommand=function(s) s:halign(1):x(-130):maxwidth(140):strokecolor(Alpha(Color.Black,0.4)) end,
		},
		Def.BitmapText{
			Font='_avenirnext lt pro bold/25px',
			InitCommand=function(s) s:zoom(1):halign(0):x(-110):strokecolor(Color.Black) end,
			OnCommand=function(self)
				local SongOrCourse, StepsOrTrail;
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
					assert(scorelist)
					local scores = scorelist:GetHighScores();
					local topscore=0;
					if scores[rival] then
						topscore = scores[rival]:GetScore();
					end;
					assert(topscore);
					if topscore ~= 0  then
						self:settext(scores[rival]:GetName());
					else
						self:settext("");
					end;
				end;
			end;
		};
		ScoreAndGrade.GetScoreActor{	
			Font='_avenirnext lt pro bold/25px'
		}..{
			Name='Score',
			InitCommand=function(s) s:x(215):zoom(1):halign(1):strokecolor(Color.Black) end,
		},
		ScoreAndGrade.GetGradeActor{}..{
			Name='GradeFrame',
			InitCommand=function(s) s:x(245):zoom(1.1) end,
		}

	};
	return t;
end

t[#t+1] = Def.Sprite{
	Texture="ScoreFrame.png",
};

for i=1,6 do
	t[#t+1] = RivalScore(pn,i)..{
		InitCommand=function(s)
			s:y((i*43)-150)
		end
	}
end


return t;