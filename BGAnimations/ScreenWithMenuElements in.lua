return Def.Actor {
	StartTransitioningMessageCommand=function(s)
		s:sleep(THEME:GetMetric(Var 'LoadingScreen', 'InTransitionSeconds'))
	end,
}