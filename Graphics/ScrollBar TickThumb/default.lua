return LoadActor("TickThumb")..{
	InitCommand=function(s)
		if GAMESTATE:IsCourseMode() == false then
			if ThemePrefs.Get("WheelType") == "A" or ThemePrefs.Get("WheelType") == "Wheel" then
				s:visible(true)
		else
				s:visible(false)
			end
		else
			s:visible(false)
		end
	end,
	OnCommand=function(s) s:x(5):zoomy(0):linear(0.3):zoomy(1):queuecommand("Repeat") end,
	RepeatCommand=function(s) s:glowshift():effectclock('beatnooffset'):effectcolor1(Alpha(Color.White,0)):effectcolor2(Color.White) end,
	OffCommand=function(s) s:stoptweening():linear(0.3):zoomy(0) end,
};