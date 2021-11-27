return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:FullScreen() end,
		OnCommand=function(s) s:diffusealpha(1):linear(0.3):diffusealpha(0) end,
	}
}