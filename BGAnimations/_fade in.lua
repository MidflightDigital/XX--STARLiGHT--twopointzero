return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(Color.Black) end,
		OnCommand=function(s) s:linear(0.297):diffusealpha(0) end,
	};
}