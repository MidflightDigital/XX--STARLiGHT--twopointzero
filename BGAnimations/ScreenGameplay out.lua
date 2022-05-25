local screen = Var 'LoadingScreen'

return Def.Actor {
	StartTransitioningMessageCommand=function(s)
		if screen ~= 'ScreenDemonstration' then
			local delay = THEME:GetMetric('ScreenGameplay', 'OutTransitionSeconds')
			s:sleep(delay+BeginOutDelay())
		else
			s:sleep(0)
		end
	end,
}