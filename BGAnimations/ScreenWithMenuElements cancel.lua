local screen = Var 'LoadingScreen'

return Def.Actor {
	StartTransitioningMessageCommand=function(s)
		-- CancelCommand seems not working in gameplay, so...
		if screen == 'ScreenGameplay' then
			MESSAGEMAN:Broadcast('Cancel')
		end
		
		s:sleep(THEME:GetMetric(screen, 'CancelTransitionSeconds'))
	end,
}