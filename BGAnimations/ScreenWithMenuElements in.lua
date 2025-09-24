return Def.Actor{
	StartTransitioningMessageCommand=function(self)
		local screen = Var('LoadingScreen')
		if screen then
			self:sleep(THEME:GetMetric(screen, 'InTransitionSeconds'))
		end
	end,
}