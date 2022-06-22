local bBreakTime = false

local t = Def.ActorFrame {};

t[#t+1] = Def.Actor {
	ChangeCourseSongInMessageCommand=function(s)
		s:sleep(0.001)
		
		if IsARankingCourse() then
			MESSAGEMAN:Broadcast('CourseBreakTime')
		else
			s:queuecommand('Shutter')
		end
	end,
	CourseBreakTimeMessageCommand=function(s)
		local delay = THEME:GetMetric('ScreenGameplay', 'BreakTimeSeconds')
		bBreakTime = true
		s:sleep(delay+3):queuecommand('Shutter')
	end,
	ShutterCommand=function(s)
		local delay = THEME:GetMetric('ScreenGameplay', 'NextCourseSongDelay')
		bBreakTime = false
		MESSAGEMAN:Broadcast('NextCourseSong')
		s:sleep(delay)
	end,
	CodeMessageCommand=function(s, p)
		if (p.Name == 'Start') and GAMESTATE:IsSideJoined(p.PlayerNumber) and bBreakTime then
			bBreakTime = false
			local delay = THEME:GetMetric('ScreenGameplay', 'NextCourseSongDelay')
			s:finishtweening()
			MESSAGEMAN:Broadcast('NextCourseSong')
			s:sleep(delay)
		end
	end,
};

return t