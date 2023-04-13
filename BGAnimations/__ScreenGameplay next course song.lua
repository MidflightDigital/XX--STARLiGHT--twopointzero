local t = Def.ActorFrame {};

t[#t+1] = Def.Actor {
	ChangeCourseSongInMessageCommand=function(self)
		self:sleep(BeginOutDelay()):queuecommand('Shutter')
	end,
	ShutterCommand=function(self)
		local delay = THEME:GetMetric('ScreenGameplay', 'NextCourseSongDelay')
		MESSAGEMAN:Broadcast('NextCourseSong')
		self:sleep(delay)
	end,
};

return t