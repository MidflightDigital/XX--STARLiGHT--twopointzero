return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(Color.Black):diffusealpha(0) end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.297):diffusealpha(1) end,
	};
}