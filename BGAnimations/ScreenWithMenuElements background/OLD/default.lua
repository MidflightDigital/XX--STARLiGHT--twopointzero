local screen = Var 'LoadingScreen'

-- Relative amount of meteors to create
local starriness = 1.0

-- Scale based on how much sky is visible
local nMeteors = ((_screen.h > 720) and (_screen.h+260)/49 or _screen.w/64) * starriness

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
		
		Def.Sprite {
			Texture="meteor-arrow",
			AnimateCommand = function(s)
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
		Def.Sprite{
			Texture="meteor-glow",
			AnimateCommand = function(s)
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
		}
	}

	return m
end


--
-- Screen ActorFrame starts here
--

local t = Def.ActorFrame{}

-- Diagonal of the screen (= diameter of the background rotation circle)
local d = math.sqrt(_screen.h^2 + _screen.w^2)

t[#t+1] = Def.Sprite {
	Texture="bg",
	-- Make sure the sky fills the entire screen, with room to rotate
	InitCommand = function(s) s:scaletocover(0,0,d,d):Center() end,
	OnCommand = function(s) s:queuecommand("Animate") end,
	AnimateCommand = function(s) s:rotationz(0):linear(720):rotationz(360):queuecommand("Animate") end,
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
}

-- Add meteors
for _ = 1, nMeteors do
	t[#t+1] = meteor()
end

t[#t+1] = Def.Sprite{
	Texture="violetwave",
	-- Continually scrolling texture
	InitCommand=function(s)
		local w = SCREEN_HEIGHT*1.333333 / s:GetWidth();
        s:customtexturerect(0,0,w*1.5,1):zoomtowidth(_screen.w)
		s:xy(_screen.cx,_screen.cy-215):texcoordvelocity(0.1,0)
	end,
}

t[#t+1] = Def.Sprite{
	Texture="bluewave",
	-- Also continually scrolling
	InitCommand = function(s)
		local w = SCREEN_HEIGHT*1.333333 / s:GetWidth();
        s:customtexturerect(0,0,w*1.5,1):zoomtowidth(_screen.w)
		s:diffusealpha(0.9)
		:valign(1):xy(_screen.cx,_screen.cy+170)
		:texcoordvelocity(0.2,0)
	end,
}

t[#t+1] = Def.Sprite{
	Texture="glow",
	InitCommand = function(s) s:zoomtowidth(_screen.w)
		:valign(1):xy(_screen.cx,_screen.cy+130)
	end,
}

t[#t+1] = Def.Sprite{
	Texture="ground",
	-- Make sure the ground graphic covers the entire ground :)
	InitCommand = function(s) s:valign(0)
		:zoomto(_screen.w,_screen.cy-130)
		:xy(_screen.cx,_screen.cy+130)
	end,
}

-- Mask for rotating reflection
t[#t+1] = Def.Quad {
	InitCommand = function(s) s:stretchto(0,0,_screen.w,_screen.cy+130):MaskSource(true) end,
}

-- Rotating reflection
t[#t+1] = Def.Sprite{
	Texture="bg",
	InitCommand = function(s) s:scaletocover(0,0,d,-d):xy(_screen.cx,_screen.cy+260)
		:diffusealpha(0.15):MaskDest()
	end,
	OnCommand = function(s) s:queuecommand("Animate") end,
	AnimateCommand = function(s) s:rotationz(0):linear(720):rotationz(360):queuecommand("Animate") end,
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
}

t[#t+1] = ClearZ


-- Ring animations came from the previous themer
t[#t+1] = Def.Sprite{
	Texture="ring1",
	InitCommand=function(s) s:diffusealpha(0) end,
	OnCommand=function(s) s:rotationz(0):zoom(0.5)
		:xy(math.random(_screen.w),math.random(_screen.h))
		:sleep(math.random(2)+1)
		:linear(0.5):rotationz(180):zoom(0.6):diffusealpha(0.5)
		:decelerate(0.5):rotationz(math.random(89)+270):zoom(0.65)
		:diffusealpha(0):queuecommand("On")
	end,
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
}
t[#t+1] = Def.Sprite{
	Texture="ring2",
	InitCommand=function(s) s:diffusealpha(0) end,
	OnCommand=function(s) s:rotationz(0):zoom(0.5)
		:xy(math.random(_screen.w),math.random(_screen.h))
		:sleep(math.random(3)):linear(0.5):rotationz(180)
		:zoom(0.6):diffusealpha(0.5):decelerate(0.5)
		:rotationz(math.random(89)+270):zoom(0.65)
		:diffusealpha(0):queuecommand("On")
	end,
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
}
t[#t+1] = Def.Sprite{
	Texture="ring3",
	InitCommand=function(s) s:diffusealpha(0) end,
	OnCommand=function(s) s:rotationz(0):zoom(0.5)
		:xy(math.random(_screen.w),math.random(_screen.h))
		:sleep(math.random(2)):linear(0.5):rotationz(180)
		:zoom(0.6):diffusealpha(0.5):decelerate(0.5)
		:rotationz(math.random(89)+270):zoom(0.65)
		:diffusealpha(0):queuecommand("On")
	end,
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
}
t[#t+1] = Def.Sprite{
	Texture="ring4",
	InitCommand=function(s) s:diffusealpha(0) end,
	OnCommand=function(s) s:rotationz(0):zoom(0.5)
		:xy(math.random(_screen.w),math.random(_screen.h))
		:sleep(math.random(3)+1):linear(0.5):rotationz(180)
		:zoom(0.6):diffusealpha(0.5):decelerate(0.5)
		:rotationz(math.random(89)+270):zoom(0.65)
		:diffusealpha(0):queuecommand("On")
	end,
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
}

return t
