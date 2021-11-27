local screen2 = Var "LoadingScreen"

return Def.BitmapText{
	Font="_stagetext";
	BeginCommand=function(s) s:playcommand("Set") end,
	CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
	SetCommand=function(self, params)
		local Stage = GAMESTATE:GetCurrentStage();
		local StageIndex = GAMESTATE:GetCurrentStageIndex();
		local screen = SCREENMAN:GetTopScreen();
		if screen and screen.GetStageStats then
			local ss = screen:GetStageStats();
			Stage = ss:GetStage();
			StageIndex = ss:GetStageIndex();
		end
		if getenv("FixStage") == 1 then
			self:settextf("%s STAGE",THEME:GetString("CustStageSt",CustStageCheck()))
		else
			self:settextf("%s STAGE",THEME:GetString("Stage",ToEnumShortString(Stage)));
		end
		if GAMESTATE:IsAnExtraStage() and screen2 == "ScreenSelectMusicExtra" then
			self:diffuse(color("#FFFFFF"))
			self:strokecolor(Alpha(color("#f900fe"),0.5));
		else
			self:diffuse(color("#dff0ff"));
			self:strokecolor(Alpha(color("#00baff"),0.5));
		end
		
	end;
};
