LoadFromProfilePrefs()
return Def.ActorFrame{
	Def.Sound{
		File=THEME:GetPathS("","_swoosh out"),
		StartTransitioningCommand=function(s) s:sleep(1):queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
	StartTransitioningCommand=function(s) s:sleep(1):queuecommand("Dim") end,
	DimCommand=function(s) SOUND:DimMusic(0,math.huge) end,
};
