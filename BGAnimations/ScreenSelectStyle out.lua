return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:FullScreen() end,
		OnCommand=function(s) s:diffusealpha(0):sleep(2) end,
	};
	Def.Sound{
		File=THEME:GetPathS("","ScreenSelectStyle out.ogg"),
		OnCommand=function(s) s:queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
}
