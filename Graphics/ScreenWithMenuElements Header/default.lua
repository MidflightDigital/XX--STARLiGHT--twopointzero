local screen = Var "LoadingScreen"
local screenName = THEME:GetMetric(screen,"HeaderText");

local out = Def.ActorFrame {
	InitCommand = function(s)s:xy(_screen.cx,SCREEN_TOP-140):diffusealpha(0):zoom(0.7) end,
	OnCommand = function(s)
		s:smooth(0.3):y(SCREEN_TOP+68):diffusealpha(1):zoom(1)
	end,
	OffCommand = function(s)
		s:accelerate(0.3):y(SCREEN_TOP-140):diffusealpha(0):zoom(0.7)
	end,
	loadfile(THEME:GetPathG("ScreenWithMenuElements","Header/header/default.lua"))() .. {
		InitCommand = function(s) s:valign(0) end,
	};
};

if screenName then
	table.insert(out,Def.Sprite{
		Texture="text/"..screenName..".png",
		InitCommand=function(s)
			s:diffusealpha(0)
			if (screen == "ScreenEvaluationNormal" and not GAMESTATE:IsCourseMode()) or screen == "ScreenSelectMusic" then
				s:y(-3)
			else
				s:y(10)
			end
			if GAMESTATE:IsAnExtraStage() and screen == "ScreenSelectMusic" then
				s:diffuse(color("#f900fe"))
			else
				s:diffuse(Color.White)
			end
		end;
		OnCommand=function(s)
			if screen ~= "ScreenSelectProfilePrefs" then
				s:diffusealpha(0):sleep(0.25):linear(0.05)
				:diffusealpha(0.5):linear(0.05):diffusealpha(0):linear(0.05)
				:diffusealpha(1):linear(0.05):diffusealpha(0):linear(0.05)
				:diffusealpha(0.5):decelerate(0.1):diffusealpha(1):queuecommand("Anim")
			end
		end,
		AnimCommand=function(s) s:glowshift():effectcolor1(color("1,1,1,0.5")):effectcolor2(color("1,1,1,0")):effectperiod(1.5) end,
		OffCommand = function(s)
			if screen ~= "ScreenSelectProfile" then
				s:linear(0.05):diffusealpha(0)
			end
		end,
	})
end;

return out
