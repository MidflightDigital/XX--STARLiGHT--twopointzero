local pn = ...
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local t = Def.ActorFrame{}
-- Holy fcuk yes it's finally working (inefficient as it may be)
local function RivalScore(pn, rival)
	return Def.ActorFrame{
		OnCommand=function(s) s:playcommand("Set") end,
		CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(s) s:playcommand("Set") end,
		["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
		["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
		SetCommand=function(s)      
			local c = s:GetChildren()
			
			local SongOrCourse, StepsOrTrail
			if GAMESTATE:IsCourseMode() then
				SongOrCourse = GAMESTATE:GetCurrentCourse()
				StepsOrTrail = GAMESTATE:GetCurrentTrail(pn)
			else
				SongOrCourse = GAMESTATE:GetCurrentSong()
				StepsOrTrail = GAMESTATE:GetCurrentSteps(pn)
			end
			if not (SongOrCourse and StepsOrTrail) then
				c.Score:visible(false)
				c.GradeFrame:visible(false)
				c.ScoreName:visible(false)
				return
			end
			
			local profile
			if PROFILEMAN:IsPersistentProfile(pn) then
				profile = PROFILEMAN:GetProfile(pn)
			else
				profile = PROFILEMAN:GetMachineProfile()
			end
			local scores = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()
			local score = scores[rival]
			if not score then
				c.Score:visible(false)
				c.GradeFrame:visible(false)
				c.ScoreName:visible(false)
				return
			end
			c.Score:visible(true)
			c.GradeFrame:visible(true)
			c.ScoreName:visible(true)
			c.ScoreName:settext(score:GetName())
			
			s:playcommand('SetScore', { Stats = score, Steps = StepsOrTrail })
		end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/25px",
			Text=THEME:GetString("ScreenEvaluation","RIVAL"..rival),
			InitCommand=function(s) s:halign(1):x(-130):maxwidth(140):strokecolor(Alpha(Color.Black,0.4)) end,
		},
		Def.BitmapText{
			Name='ScoreName',
			Font='_avenirnext lt pro bold/25px',
			InitCommand=function(s) s:zoom(1):halign(0):x(-110):strokecolor(Color.Black) end,
		},
		ScoreAndGrade.CreateScoreActor{	
			Name='Score',
			Font='_avenirnext lt pro bold/25px',
			InitCommand=function(self)
				self:x(215):zoom(1):halign(1):strokecolor(Color.Black)
			end,
		},
		ScoreAndGrade.CreateGradeActor{
			Name='GradeFrame',
			InitCommand=function(self)
				self:x(245):zoom(1.1)
			end,
		}

	}
end

t[#t+1] = Def.Sprite{
	Texture="ScoreFrame.png",
}

for i=1,6 do
	t[#t+1] = RivalScore(pn,i)..{
		InitCommand=function(s)
			s:y((i*43)-150)
		end
	}
end

return t