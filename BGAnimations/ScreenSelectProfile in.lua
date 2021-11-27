return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(Color.Black) end,
		OnCommand=function(s)
			s:diffusealpha(1):sleep(0.1):linear(0.2):diffusealpha(0)
		end,
	}
};
