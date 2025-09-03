local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local t = Def.ActorFrame{}

local args = {...}
local pn = args[1]

local short_plr = ToEnumShortString(pn)

local profileID = GetProfileIDForPlayer(pn)
local pPrefs = ProfilePrefs.Read(profileID)
local ex_score = pPrefs.ex_score

	local function base_x()
		if pn == PLAYER_1 then
			if IsUsingWideScreen() then
					return _screen.cx-500
			else
				return _screen.cx-440
			end
		elseif pn == PLAYER_2 then
			if IsUsingWideScreen() then
				return _screen.cx+500
			else
				return _screen.cx+440
			end
		else
			error("Pass a valid player number, dingus.",2)
		end
	end

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local steps = GAMESTATE:GetCurrentSteps(pn)

local Combo = pss:MaxCombo()

local Marvelous = pss:GetTapNoteScores("TapNoteScore_W1")
local Perfect = pss:GetTapNoteScores("TapNoteScore_W2")
local Great = pss:GetTapNoteScores("TapNoteScore_W3")
local Good = pss:GetTapNoteScores("TapNoteScore_W4")
local Almost = pss:GetTapNoteScores("TapNoteScore_W5")
local Ok = pss:GetHoldNoteScores("HoldNoteScore_Held")
local RealMiss = pss:GetTapNoteScores("TapNoteScore_Miss")
local LetGo = pss:GetHoldNoteScores("HoldNoteScore_LetGo")
local Miss = RealMiss + LetGo

local seconds = pss:GetSurvivalSeconds()

local function FindText(pss)
	return string.format("%02d STAGE", pss:GetSongsPassed())
end

-- Timing mode
local TimingMode = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini") or "Unknown"
local NoBads = (TimingMode == "DDR Modern" and true or false)

t[#t+1] = Def.ActorFrame{
	Def.Sprite{
		Texture="judgments.png",
		InitCommand=function(s) s:y(22)
			if NoBads then
				if ex_score then
					s:Load(THEME:GetPathB("ScreenEvaluationNormal","decorations/judgments ex.png"))
				end
			else
				if ex_score then
					s:Load(THEME:GetPathB("ScreenEvaluationNormal","decorations/judgments ex almost.png"))
				else
					s:Load(THEME:GetPathB("ScreenEvaluationNormal","decorations/judgments almost.png"))
				end
			end
		end,
	},
	Def.ActorFrame{
		Name="Marvelous Line",
		InitCommand=function(s) s:xy(-104,-99) end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			OnCommand=function(self)
				self:x(155)
				self:settextf(Marvelous):halign(1):strokecolor(Color.Black)
			end,
		},
	},
	Def.ActorFrame{
		Name="Perfect Line",
		InitCommand=function(s) s:xy(-104,-60) end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			OnCommand=function(self)
				self:x(155)
				self:settextf(Perfect):halign(1):strokecolor(Color.Black)
			end,
		},
	},
	Def.ActorFrame{
		Name="Great Line",
		InitCommand=function(s) s:xy(-104,-20) end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			OnCommand=function(self)
				self:x(155)
				self:settextf(Great):halign(1):strokecolor(Color.Black)
			end,
		},
	},
	Def.ActorFrame{
		Name="Good Line",
		InitCommand=function(s) s:xy(-104,20) end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			OnCommand=function(self)
				self:x(155)
				self:settextf(Good):halign(1):strokecolor(Color.Black)
			end,
		},
	},
	Def.ActorFrame{
		Name="Almost Line",
		InitCommand=function(s) s:xy(-104,60) if NoBads then s:visible(false) end end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			OnCommand=function(self)
				self:x(155)
				self:settextf(Almost):halign(1):strokecolor(Color.Black)
			end,
		},
	},
	Def.ActorFrame{
		Name="Miss Line",
		InitCommand=function(s) s:xy(-104, (NoBads and 60 or 99)) end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			OnCommand=function(self)
				self:x(155)
				self:settextf(Miss):halign(1):strokecolor(Color.Black)
			end,
		},
	},
	Def.ActorFrame{
		Name="Combo Line",
		InitCommand=function(s) s:xy(-104, (NoBads and 99 or 139)) end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			OnCommand=function(self)
				self:x(155)
				self:settextf(Combo):halign(1):strokecolor(Color.Black)
			end,
		},
	},
	Def.BitmapText{
		Name="EXScore",
		Font="_avenirnext lt pro bold/36px",
		InitCommand=function(s) s:xy(260,-74) end,
		OnCommand=function(self)
			if ex_score then
				local score = ScoreAndGrade.GetScore(pss, steps, false)
				self:settextf(commify(score))
			else
				local exscore = ScoreAndGrade.GetScore(pss, steps, true)
				self:settextf(exscore)
			end
			self:halign(1):strokecolor(Color.Black)
		end,
	},
	Def.BitmapText{
		 Name="Fast Line",
		Font="_avenirnext lt pro bold/36px",
		InitCommand=function(s) s:xy(260,-7) end,
		OnCommand=function(self)
			local FastNum = getenv("numFast"..ToEnumShortString(pn))
			self:settextf(FastNum):halign(1):strokecolor(Color.Black)
		end,
	},
	Def.BitmapText{
		Font="_avenirnext lt pro bold/36px",
		Name="Slow Line",
		InitCommand=function(s) s:xy(260,64) end,
		OnCommand=function(self)
			local FastNum = getenv("numSlow"..ToEnumShortString(pn))
			self:settextf(FastNum):halign(1):strokecolor(Color.Black)
		end,
	},
	Def.ActorFrame{
		Name="Hold Line",
		InitCommand=function(s) s:xy(260,132) end,
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			OnCommand=function(self)
				self:settextf(Ok):halign(1):strokecolor(Color.Black)
			end,
		},
	}
}

return t
