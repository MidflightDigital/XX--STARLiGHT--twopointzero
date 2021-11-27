return Def.ActorFrame {
	Def.Sprite{
		Texture="Choice Oni A.png";
		OnCommand=function(s) s:addy(SCREEN_HEIGHT):sleep(0.1):decelerate(0.2):addy(-SCREEN_HEIGHT) end,
		OffCommand=function(s) s:accelerate(0.2):addy(SCREEN_HEIGHT) end,
		GainFocusCommand=function(self)
			self:Load(THEME:GetPathG("","ScreenSelectPlayCourseMode scroller/Choice Oni A.png"))
			self:stoptweening():linear(0.05):x(50)
		end;
		LoseFocusCommand=function(self)
			self:Load(THEME:GetPathG("","ScreenSelectPlayCourseMode scroller/Choice Oni B.png"))
			self:stoptweening():linear(0.05):x(60)
		end;
	};
	Def.Sprite{
		Texture=THEME:GetPathG("","_shared/garrows/_selectarrowg"),
		InitCommand=function(s) s:x(-350):zoomx(-1) end,
		OffCommand=function(s) s:decelerate(0.2):addx(-SCREEN_WIDTH) end,
		GainFocusCommand=function(s) s:stoptweening():stopeffect():diffusealpha(0):linear(0.05):diffusealpha(1):x(-350):bob():effectmagnitude(10,0,0):effectperiod(0.7) end,
		LoseFocusCommand=function(s) s:stoptweening():linear(0.05):diffusealpha(0):x(-400) end,
	};
};
