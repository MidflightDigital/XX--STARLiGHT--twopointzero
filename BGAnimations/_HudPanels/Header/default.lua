local screen = Var"LoadingScreen"
local HeaderText = THEME:GetMetric(screen,"HeaderText");

local yoffsetted = {
    "ScreenSelectMusic",
	"OFSelectMusic",
    "ScreenEvaluationNormal",
    "ScreenEvaluationCourse"
}

local text = Def.ActorFrame{}

if HeaderText then
    text[#text+1] = Def.Sprite{
        Texture="text/"..HeaderText..".png",
        InitCommand=function(s)
            if screen == "OFSelectMusic" then
                s:y(-1)
            else
                s:y(10)
            end
            if GAMESTATE:IsAnExtraStage() and screen == "ScreenSelectMusic" then
				s:diffuse(color("#f900fe"))
			else
				s:diffuse(Color.White)
			end
        end,
        OnCommand=function(s)
			s:diffusealpha(0):sleep(0.25):linear(0.05)
			:diffusealpha(0.5):linear(0.05):diffusealpha(0):linear(0.05)
			:diffusealpha(1):linear(0.05):diffusealpha(0):linear(0.05)
			:diffusealpha(0.5):decelerate(0.1):diffusealpha(1):queuecommand("Anim")
		end,
		AnimCommand=function(s) s:glowshift():effectcolor1(color("1,1,1,0.5")):effectcolor2(color("1,1,1,0")):effectperiod(1.5) end,
		OffCommand = function(s)
			s:linear(0.05):diffusealpha(0)
		end,
    }
end

return Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx,SCREEN_TOP-140):diffusealpha(0) end,
    OnCommand = function(s)
		s:smooth(0.3):y(SCREEN_TOP+68):diffusealpha(1)
	end,
	OffCommand = function(s)
		s:accelerate(0.3):y(SCREEN_TOP-140):diffusealpha(0)
	end,
	loadfile(THEME:GetPathB("","_HudPanels/Header/header/default.lua"))()..{
		InitCommand = function(s) s:valign(0) end,
	},
    text
}