local screen = Var 'LoadingScreen'

return Def.Actor {
	StartTransitioningMessageCommand=function(s)
		s:sleep(THEME:GetMetric(screen, 'OutTransitionSeconds'))
	end,
}