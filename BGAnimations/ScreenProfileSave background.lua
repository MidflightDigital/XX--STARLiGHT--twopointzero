return Def.ActorFrame {
	Def.Sprite{
		Texture=THEME:GetPathB('ScreenSelectMusicExtra', 'background/EXMovie.mp4'),
		Condition=GetExtraStage(),
		InitCommand=function(s) s:Center() end,
		OnCommand=function(s) s:play() end,
	},
	loadfile(THEME:GetPathB("","ScreenWithMenuElements background"))(){
		Condition=not GetExtraStage(),
	},
}