local screen = Var 'LoadingScreen'

-- Relative amount of meteors to create
local starriness = 1

-- Scale based on how much sky is visible
local nMeteors = ((_screen.h > 1080) and (_screen.h+260)/49 or _screen.w/64) * starriness

-- Definition of a meteor

local function meteor()
	local m = Def.ActorFrame {
		InitCommand = function(s) s:valign(1) end,
		OnCommand = function(s) s:sleep(math.random()*2):queuecommand("Animate") end,
		CourseBreakTimeMessageCommand=function(s) s:finishtweening():playcommand('On') end,
		NextCourseSongMessageCommand=function(s)
			if not IsARankingCourse() then
				s:finishtweening():playcommand('On')
			end
		end,
		OffCommand=function(s)
			if screen == 'ScreenGameplay' then
				s:finishtweening():playcommand('On')
			end
		end,
		AnimateCommand = function(s)
			-- Random size between half- and full-size, weighted toward full
			s:zoom(0.5 + 0.5 * math.sqrt(math.random()))
			-- Appear somewhere random
			:xy(math.random(_screen.w)+40,math.random(_screen.h/2))
			-- Move in the direction of the arrow, slowing down when
			-- it starts to burn out.  (Note: this is slightly
			-- below the 42° angle of the arrow, because I like the
			-- resultant "falling" effect.)
			:linear(0.3):addx(-100):addy(100)
			:linear(0.15):addx(-60):addy(60)
			-- Wait a random amount of time
			:sleep(math.random()*5)
			-- and start again
			:queuecommand("Animate")
		end,
		
		LoadActor("../OLD/meteor-arrow") .. {
			AnimateCommand=function(s)
				-- Start partially visible
				s:diffusealpha(0)
				-- Come into sight
				:linear(0.15):diffusealpha(0.7)
				-- Let the glow brighten (see below)
				:sleep(0.15)
				-- Burn out
				:linear(0.15):diffusealpha(0)
			end,
		},
		LoadActor("../OLD/meteor-glow") .. {
			AnimateCommand=function(s)
				-- Glow is almost white, with a chance of being tinted slightly.
				-- Invisible to start with.
				s:diffuse(HSVA(360*math.random(), 0.4*math.random(), 1, 0))
				-- Don't start to glow until the meteor's fully visible
				:sleep(0.15)
				-- Flare up!
				:linear(0.15):diffusealpha(1)
				-- Burn out
				:linear(0.15):diffusealpha(0)
			end,
		},
	}

	return m
end

local t = Def.ActorFrame {};

t[#t+1] = Def.Sprite {
	Texture=THEME:GetPathB("ScreenWithMenuElements","background/OG/background.mp4"),
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
};

-- Add meteors
for _ = 1, nMeteors do
	t[#t+1] = meteor();
end

t[#t+1] = ClearZ;

return t