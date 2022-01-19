return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:FullScreen() end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.1):diffusealpha(1):sleep(1) end,
	}
}
