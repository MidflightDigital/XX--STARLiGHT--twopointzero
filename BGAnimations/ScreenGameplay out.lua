return Def.Actor {
	StartTransitioningMessageCommand=function(s)
		local screen = Var 'LoadingScreen'
		
		if screen ~= 'ScreenDemonstration' then
			local delay = THEME:GetMetric( 'ScreenGameplay', 'OutTransitionSeconds' )
			s:sleep(delay+BeginOutDelay())
		else
			s:sleep(0)
		end
	end,
}