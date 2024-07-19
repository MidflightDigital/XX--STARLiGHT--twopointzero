-- Relative amount of meteors to create
local starriness = 0.4

-- Scale based on how much sky is visible
local nMeteors = ((_screen.h > 1080) and (_screen.h+260)/49 or _screen.w/64) * starriness

-- Definition of a meteor

local function meteor()
	local m = Def.ActorFrame {
		OnCommand = function(s) s:sleep(math.random()*2):queuecommand("Animate") end,
		AnimateCommand = function(s)
			-- Random size between half- and full-size, weighted toward full
			s:zoom(1.2 + 0.7 * math.sqrt(math.random()))
			-- Appear somewhere random
			:xy(math.random(_screen.w)+180,math.random(_screen.h))
			-- Move in the direction of the arrow, slowing down when
			-- it starts to burn out.  (Note: this is slightly
			-- below the 42° angle of the arrow, because I like the
			-- resultant "falling" effect.)
			:linear(0.4):addx(-100):addy(100)
			:linear(0.2):addx(-60):addy(60)
			-- Wait a random amount of time
			:sleep(math.random()*8)
			-- and start again
			:queuecommand("Animate")
		end,
	}

	m[#m+1] = Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/OLD/meteor-arrow"),
		InitCommand=function(s) s:blend(Blend.Add) end,
		AnimateCommand=function(s)
			-- Start partially visible
			s:diffusealpha(0)
			-- Come into sight
			:linear(0.15):diffusealpha(0.7)
			-- Let the glow brighten (see below)
			:sleep(0.2)
			-- Burn out
			:linear(0.15):diffusealpha(0)
		end,
	}

	m[#m+1] = Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/OLD/meteor-glow"),
		InitCommand=function(s) s:blend(Blend.Add) end,
		AnimateCommand=function(s)
			-- Glow is almost white, with a chance of being tinted slightly.
			-- Invisible to start with.
			s:diffuse(HSVA(360*math.random(), 0.4*math.random(), 1, 0))
			-- Don't start to glow until the meteor's fully visible
			:sleep(0.15)
			-- Flare up!
			:linear(0.2):diffusealpha(0.7)
			-- Burn out
			:linear(0.15):diffusealpha(0)
		end,
	}

	return m
end

local t = Def.ActorFrame{
	Def.Sprite{
		Texture="background",
		OnCommand=function(s) s:Center():setsize(IsUsingWideScreen() and SCREEN_WIDTH or 1920,SCREEN_HEIGHT) end,
	};
	Def.Quad{
        InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):Center()
            :diffuse(color("#81ffff88")):blend(Blend.Multiply)
        end,
    },
	Def.Sprite{
		Texture="darken",
		InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):Center():diffusealpha(0.6) end,
	}
};

-- Add meteors
for _ = 1, nMeteors do
	t[#t+1] = meteor()
end

t[#t+1] = ClearZ
return t;
