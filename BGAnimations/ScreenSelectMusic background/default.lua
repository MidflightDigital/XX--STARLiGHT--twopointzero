return Def.ActorFrame {
	loadfile(THEME:GetPathB("","ScreenWithMenuElements background/default.lua"))()..{
		Condition=not IsAnExtraStage(),
	},
    Def.Sprite{
		Texture='EXMovie.mp4',
		Condition=IsAnExtraStage(),
        InitCommand=function(s) s:Center() end,
    }
}