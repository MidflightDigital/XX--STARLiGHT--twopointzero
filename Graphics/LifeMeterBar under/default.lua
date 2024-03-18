return Def.ActorFrame{
	Def.Sprite{
		Texture="back",
		InitCommand=function(s)
			if GAMESTATE:IsDemonstration() then
				s:zoomto(680,51)
			else
				s:zoomto(656,44)
			end
			s:x(-12)
		end,
	}
};
