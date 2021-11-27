return Def.ActorFrame{
	InitCommand=function(s) s:draworder(1000) end,
	Def.Sound{
		File=THEME:GetPathS("","Common back"),
		StartTransitioningCommand=function(s) s:play() end,
	};
	Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(color("0,0,0,1")) end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.3):diffusealpha(1):sleep(0.7) end,
	};
};
