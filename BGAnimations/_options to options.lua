return Def.ActorFrame{
	Def.Sound{
		File=THEME:GetPathS("","_swoosh in"),
		StartTransitioningCommand=function(s) s:play() end,
	};
};
