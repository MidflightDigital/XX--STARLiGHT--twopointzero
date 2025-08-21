local pn = ({...})[1]
-- the only arg is arg 1, the player number
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local function m(metric)
	metric = metric:gsub('PN', ToEnumShortString(pn))
	return THEME:GetMetric(Var('LoadingScreen'),metric)
end

return ScoreAndGrade.GetGradeActor{
		Big = true,
		ActorConcat = {
			Grade = {
				OnCommand = m('GradePNOnCommand'),
				OffCommand = m('GradePNOffCommand')
			}
		}
	}..{
	InitCommand = function(s)
		local c = s:GetChildren()
		c.Grade:xy(m('GradePNX'), m('GradePNY'))		
		c.FullCombo:xy(m('RingPNX'), m('RingPNY'))
		
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
		local steps = GAMESTATE:GetCurrentSteps(pn)
		s:playcommand('SetGrade', { Highscore = pss, Steps = steps })
	end,
}