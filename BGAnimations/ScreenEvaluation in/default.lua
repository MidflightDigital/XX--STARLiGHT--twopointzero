return Def.ActorFrame {
	Def.Sound{
		File="in",
		StartTransitioningCommand=function(s) s:play() end,
	};
	Def.Sound{
		File="score",
		StartTransitioningCommand=function(s) s:sleep(0.2):playcommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
};
