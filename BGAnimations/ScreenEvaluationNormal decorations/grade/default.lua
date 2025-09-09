local args = {...}
local pn = args[1]
local stats = args[2]
local steps = args[3]
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local function m(metric)
	metric = metric:gsub('PN', ToEnumShortString(pn))
	return THEME:GetMetric(Var('LoadingScreen'), metric)
end

local GradeOnCommand = m('GradePNOnCommand')
local GradeOffCommand = m('GradePNOffCommand')
function RingOnCommand(self)
	self:zoom(0):sleep(0.5):linear(0.2):zoom(0.8)
end
function RingOffCommand(self)
	self:linear(0.2):zoom(0)
end

return ScoreAndGrade.CreateGradeActor{
	Big=true,
	InitCommand=function(self)
		local c = self:GetChildren()
		c.Grade:xy(m('GradePNX'), m('GradePNY'))		
		c.FullCombo:xy(m('RingPNX'), m('RingPNY')):fov(120):bob():effectmagnitude(0,0,20)
		
		self:playcommand('SetScore', { Stats = stats, Steps = steps })
	end,
	OnCommand=function(self)
		local c = self:GetChildren()
		GradeOnCommand(c.Grade)
		RingOnCommand(c.FullCombo)
	end,
	OffCommand=function(self)
		local c = self:GetChildren()
		GradeOffCommand(c.Grade)
		RingOffCommand(c.FullCombo)
	end,
}