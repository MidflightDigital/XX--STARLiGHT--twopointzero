return Def.ActorFrame {
	LoadActor( THEME:GetPathB('ScreenSelectMusicExtra', 'background/EXMovie.mp4') ) .. {
		Condition=GetExtraStage(),
		InitCommand=function(s) s:Center() end,
		OnCommand=function(s) s:play() end,
	},
	LoadActor( 'ScreenWithMenuElements background' ) .. {
		Condition=not GetExtraStage(),
	},
}