local StageDisplay = Def.ActorFrame{
	BeginCommand=function(s) s:playcommand("Set") end,
	CurrentSongChangedMessageCommand=function(s) s:finishtweening():playcommand("Set") end,
};

local screen2 = Var "LoadingScreen"

for s in ivalues(Stage) do

if s ~= 'Stage_Next' and s ~= 'Stage_Nonstop' and s ~= 'Stage_Oni' and s ~= 'Stage_Endless' then
	StageDisplay[#StageDisplay+1] = Def.BitmapText{
		Font="_stagetext",
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
			if GAMESTATE:IsAnExtraStage() and screen2 == "ScreenSelectMusic" then
				self:diffuse(color("#f900fe"))
				self:strokecolor(Alpha(color("#f900fe"),0.15));
			else
				self:diffuse(color("#dff0ff"));
				self:strokecolor(Alpha(color("#00baff"),0.15));
			end
			
		end;
	};
end

end

return StageDisplay;
