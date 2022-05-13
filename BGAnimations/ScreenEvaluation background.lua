local function bgMovie()
	local t 
	local maxStages = PREFSMAN:GetPreference("SongsPerPlay")
	
	if not GAMESTATE:IsEventMode() and not GAMESTATE:IsCourseMode() and (GetCurTotalStageCost() > maxStages) then
		t = LoadActor( THEME:GetPathB('ScreenSelectMusic', 'background/EXMovie.mp4') ) .. {
			InitCommand=function(s) s:Center() end,
			OnCommand=function(s) s:play() end,
		}
	else
		t = LoadActor( 'ScreenWithMenuElements background' )
	end
	
	return t
end

return bgMovie()