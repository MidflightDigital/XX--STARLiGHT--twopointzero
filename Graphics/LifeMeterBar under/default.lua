return Def.Sprite{
	Texture="back",
	InitCommand=function(s)
		if GAMESTATE:IsDemonstration() then
			s:zoomto(680,51)
		else
			s:zoomto(656,44):skewx(0.05)
		end
		s:x(-12)
	end,
};
