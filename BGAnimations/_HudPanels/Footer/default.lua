local screen = Var"LoadingScreen"
local FooterText = ...

local text = Def.ActorFrame{}

if FooterText then
    text[#text+1] = Def.Sprite{
        Texture="text/"..FooterText..".png",
        InitCommand=function(s)
            s:y(26):diffusealpha(0)
        end,
        OnCommand=function(s)
			s:sleep(0.25):linear(0.05):diffusealpha(0.5)
            :linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(1)
            :linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(0.5)
            :decelerate(0.1):diffusealpha(1):sleep(0.1):queuecommand("Anim")
		end,
		AnimCommand=function(s) s:glowshift():effectcolor1(color("1,1,1,0.5")):effectcolor2(color("1,1,1,0")):effectperiod(1.5) end,
		OffCommand = function(s)
			s:linear(0.05):diffusealpha(0)
		end,
    }
end

return Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM+140):diffusealpha(0) end,
    OnCommand = function(s)
		s:smooth(0.3):y(SCREEN_BOTTOM-68):diffusealpha(1)
	end,
	OffCommand = function(s)
		s:accelerate(0.3):y(SCREEN_BOTTOM+140):diffusealpha(0)
	end,
    Def.Sprite{ Texture="base",},
	Def.Sprite{
        Texture="side glow",
        OnCommand=function(s)
            s:cropleft(0.5):cropright(0.5):sleep(0.3):decelerate(0.4):cropleft(0):cropright(0):sleep(0.5):queuecommand("Anim")
        end,
        AnimCommand=function(s) s:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.5")):effectperiod(2) end,
    },
    Def.ActorFrame{
        OnCommand=function(s) 
            s:diffusealpha(0):sleep(0.3):decelerate(0.5):diffusealpha(1)
        end,
        Def.Sprite{
            Texture="arrow",
            InitCommand=function(s) s:xy(1,-36) end,
            OnCommand=function(s) s:addy(100):sleep(0.25):decelerate(0.4):addy(-100) end,
        };
    };
    text
}