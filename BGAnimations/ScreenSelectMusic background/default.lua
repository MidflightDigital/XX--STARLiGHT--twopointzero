return Def.ActorFrame {
	LoadActor( '../ScreenWithMenuElements background' ) .. {
		Condition=not IsAnExtraStage(),
	},
    LoadActor( 'EXMovie.mp4' ) .. {
		Condition=IsAnExtraStage(),
        InitCommand=function(s) s:Center() end,
    }
}