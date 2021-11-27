return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(color("0,0,0,1")) end,
		OnCommand=function(s) s:linear(0.4):diffusealpha(0) end,
	};
}
