local t = Def.ActorFrame{}
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local xPosPlayer = {
	P1 = -320,
	P2 = -20,
};

function GetSongScoreData(pn)
	local data = {
		HasScore = false,
		Date     = nil,
		Score    = 0,
		EXScore  = 0,
		MAXCombo = 0,
		W1       = 0,
		W2       = 0,
		W3       = 0,
		W4       = 0,
		W5       = 0,
		Miss     = 0,
		OK       = 0,
	}

	local SongOrCourse, StepsOrTrail
	if GAMESTATE:IsCourseMode() then
		SongOrCourse = GAMESTATE:GetCurrentCourse()
		StepsOrTrail = GAMESTATE:GetCurrentTrail(pn)
	else
		SongOrCourse = GAMESTATE:GetCurrentSong()
		StepsOrTrail = GAMESTATE:GetCurrentSteps(pn)
	end
	if not (SongOrCourse and StepsOrTrail) then
		return data
	end

	local profile
	if PROFILEMAN:IsPersistentProfile(pn) then
		profile = PROFILEMAN:GetProfile(pn)
	else
		profile = PROFILEMAN:GetMachineProfile()
	end
	
	local scores = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()
	local score = scores[1]
	if not score then
		return data
	end
	
	data.HasScore  = true
	data.Date     = score:GetDate() 
	data.Score    = ScoreAndGrade.GetScore(score, StepsOrTrail, false)
	data.EXScore  = ScoreAndGrade.GetScore(score, StepsOrTrail, true)
	data.MAXCombo = score:GetMaxCombo()
	data.W1       = score:GetTapNoteScore('TapNoteScore_W1')
	data.W2       = score:GetTapNoteScore('TapNoteScore_W2')
	data.W3       = score:GetTapNoteScore('TapNoteScore_W3')
	data.W4       = score:GetTapNoteScore('TapNoteScore_W4')
	data.Miss     = score:GetTapNoteScore('TapNoteScore_W5') + score:GetTapNoteScore('TapNoteScore_Miss') + score:GetHoldNoteScore('HoldNoteScore_LetGo')
	data.OK       = score:GetHoldNoteScore('HoldNoteScore_Held')
	
	return data
end

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(self)
			local short = ToEnumShortString(pn)
			self:x(xPosPlayer[short]):halign(0)
		end,
		BeginCommand=function(s) s:playcommand('Set') end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand('Set') end,
		['CurrentSteps'..ToEnumShortString(pn)..'ChangedMessageCommand']=function(s) s:queuecommand('Set') end,
		['CurrentTrail'..ToEnumShortString(pn)..'ChangedMessageCommand']=function(s) s:queuecommand('Set') end,
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
			if not score then
				c.Score:visible(false)
				c.Grade:visible(false)
				return
			end
			c.Score:visible(true)
			c.Grade:visible(true)
			
			s:playcommand('SetScore', { Stats = score, Steps = steps })
		end,
		Def.Sprite{
			Texture='Player 1x2',
			InitCommand=function(s) s:xy(260,-80):pause():setstate(0) end,
			BeginCommand=function(self)
				if pn == PLAYER_1 then
					self:setstate(0)
				else
					self:setstate(1)
				end
			end,
		},
		Def.Sprite{
			Texture='Judge Inner',
			InitCommand=function(s) s:xy(230,5) end,
		},
		ScoreAndGrade.CreateGradeActor{
			Name='Grade',
			Big=true,
			InitCommand=function(self)
				self:xy(400,-30):zoom(0.2)
				self:GetChild('FullCombo'):zoom(1.5)
			end,
		},
		ScoreAndGrade.CreateScoreRollingActor{
			Name='Score',
			Font='_avenirnext lt pro bold/25px',
			Load='RollingNumbersSongData',
			InitCommand=function(self)
				self:xy(400,15):zoom(0.8):strokecolor(Color.Black)
			end,
		},
		Def.ActorFrame{
			InitCommand=function(s) s:xy(325,6):halign(1) end,
			SetCommand=function(self)
				local scoreData = GetSongScoreData(pn)
				self:playcommand('SetScoreFromData', scoreData)
			end,
			Def.BitmapText{
				Font='_avenirnext lt pro bold/25px';
				InitCommand=function(s) s:xy(-65,-66):zoom(0.5) end,
				SetScoreFromDataCommand=function(self, data)
					if not data.HasScore then
						self:visible(false)
						return
					end
					self:visible(true)
					self:settext(data.Date)
				end,
			},
			Def.RollingNumbers{
				File = THEME:GetPathF('','_avenirnext lt pro bold/20px'),
				InitCommand=function(s) s:Load('RollingNumbersJudgment'):halign(1):y(-50):zoom(0.75) end,
				SetScoreFromDataCommand=function(self, data)
					if not data.HasScore then
						self:targetnumber(0)
						return
					end
					self:targetnumber(data.MAXCombo)
				end,
			},
			Def.RollingNumbers{
				File = THEME:GetPathF('','_avenirnext lt pro bold/20px');
				InitCommand=function(s) s:Load('RollingNumbersJudgment'):halign(1):y(-35):zoom(0.75) end,
				SetScoreFromDataCommand=function(self, data)
					if not data.HasScore then
						self:targetnumber(0)
						return
					end
					self:targetnumber(data.W1)
				end,
			},
			Def.RollingNumbers{
				File = THEME:GetPathF('','_avenirnext lt pro bold/20px'),
				InitCommand=function(s) s:Load('RollingNumbersJudgment'):halign(1):y(-18):zoom(0.75) end,
				SetScoreFromDataCommand=function(self, data)
					if not data.HasScore then
						self:targetnumber(0)
						return
					end
					self:targetnumber(data.W2)
				end,
			},
			Def.RollingNumbers{
				File = THEME:GetPathF('','_avenirnext lt pro bold/20px'),
				InitCommand=function(s) s:Load('RollingNumbersJudgment'):halign(1):zoom(0.75) end,
				SetScoreFromDataCommand=function(self, data)
					if not data.HasScore then
						self:targetnumber(0)
						return
					end
					self:targetnumber(data.W3)
				end,
			},
			Def.RollingNumbers{
				File = THEME:GetPathF('','_avenirnext lt pro bold/20px'),
				InitCommand=function(s) s:Load('RollingNumbersJudgment'):halign(1):y(16):zoom(0.75) end,
				SetScoreFromDataCommand=function(self, data)
					if not data.HasScore then
						self:targetnumber(0)
						return
					end
					self:targetnumber(data.W4)
				end,
			},
			Def.RollingNumbers{
				File = THEME:GetPathF('','_avenirnext lt pro bold/20px'),
				InitCommand=function(s) s:Load('RollingNumbersJudgment'):halign(1):y(32):zoom(0.75) end,
				SetScoreFromDataCommand=function(self, data)
					if not data.HasScore then
						self:targetnumber(0)
						return
					end
					self:targetnumber(data.OK)
				end
			},
			Def.RollingNumbers{
				File = THEME:GetPathF('','_avenirnext lt pro bold/20px'),
				InitCommand=function(s) s:Load('RollingNumbersJudgment'):halign(1):y(48):zoom(0.75) end,
				SetScoreFromDataCommand=function(self, data)
					if not data.HasScore then
						self:targetnumber(0)
						return
					end
					self:targetnumber(data.Miss)
				end,
			},
		},
	}
end

return t
