local screen = Var "LoadingScreen"

local ShowLine = {
	"ScreenSelectMusic",
	"ScreenEvaluationNormal",
}

return Def.ActorFrame {
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
	Def.ActorFrame{
		Name="Text Area",
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
		Def.Sprite{
			Condition=has_value(ShowLine,screen),
			Texture="line.png",
			InitCommand=function(s) s:y(20):zoomy(0.5) end,
		};
		Def.BitmapText{
			Font="_avenir next demi bold/28px header",
			InitCommand=function(s)
				if THEME:HasString(screen,"HeaderText") then
					if GAMESTATE:IsCourseMode() and screen == "ScreenEvaluation" then
						s:settext(string.upper(THEME:GetString(screen,"CourseHeaderText")))
					else
						s:settext(string.upper(THEME:GetString(screen,"HeaderText")))
					end
				else
					s:settext(string.upper(screen))
				end
				s:diffusealpha(0):x(3):maxwidth(300):maxheight(60):wrapwidthpixels(300):max_dimension_use_zoom(true)
				if (screen == "ScreenEvaluationNormal" and not GAMESTATE:IsCourseMode()) or screen == "ScreenSelectMusic" then
					s:y(-2)
				else
					s:y(8)
				end
				if screen == "ScreenSelectMusic" then
					s:zoom(0.97):wrapwidthpixels(320)
				end
				if GAMESTATE:IsAnExtraStage() and screen == "ScreenSelectMusic" then
					s:diffuse(color("#f900fe"))
				else
					s:DiffuseAndStroke(color("#dff0ff"),color("#00baff"))
				end
			end,
			
		};
	};
};
