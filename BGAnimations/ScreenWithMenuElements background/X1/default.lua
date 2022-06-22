local screen = Var 'LoadingScreen'

return Def.Sprite {
	Texture=THEME:GetPathB("ScreenWithMenuElements","background/X1/bg.mp4"),
	InitCommand=function(s) s:Center():zoom(1080/s:GetHeight()) end,
	CurrentSongChangedMessageCommand=function(s)
		if screen == 'ScreenGameplay' then
			s:position(0)
			s:rate(1)
			s:sleep(0.5):queuecommand('PauseMovie')
		end
	end,
	CourseBreakTimeMessageCommand=function(s) s:rate(1) end,
	PauseMovieCommand=function(s) s:rate(0) end,
	NextCourseSongMessageCommand=function(s) s:rate(1) end,
	OffCommand=function(s)
		if screen == 'ScreenGameplay' then
			local delay = THEME:GetMetric('ScreenGameplay', 'OutTransitionSeconds')
			s:sleep(delay+BeginOutDelay())
			s:rate(1)
		end
	end,
}