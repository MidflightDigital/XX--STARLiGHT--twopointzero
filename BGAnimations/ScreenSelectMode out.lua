local t = Def.ActorFrame {
	Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(color("0,0,0,0")) end,
		StartTransitioningCommand=function(s) s:sleep(0.3):linear(0.2):diffusealpha(1) end,
	};
};

return t;
