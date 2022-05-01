local screen = Var 'LoadingScreen'

return Def.BitmapText {
	Font='_stagetext',
	BeginCommand=function(s) s:playcommand('Set') end,
	CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand('Set') end,
	SetCommand=function(s, params)
		if getenv('FixStage') == 1 then
			s:settextf('%s STAGE',THEME:GetString('CustStageSt',CustStageCheck()))
		else
			s:settextf('%s STAGE',THEME:GetString('Stage',ToEnumShortString(GetCurrentStage())))
		end
		
		if IsAnExtraStage() and screen == "ScreenSelectMusicExtra" then
			s:diffuse(color('#FFFFFF')):strokecolor(Alpha(color('#f900fe'),0.5))
		else
			s:diffuse(color('#dff0ff')):strokecolor(Alpha(color('#00baff'),0.5))
		end
	end,
}
