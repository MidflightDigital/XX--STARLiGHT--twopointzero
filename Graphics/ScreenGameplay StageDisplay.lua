local StageDisplay = Def.ActorFrame{
	BeginCommand=function(s) s:playcommand("Set") end,
	CurrentSongChangedMessageCommand=function(s) s:finishtweening():playcommand("Set") end,
};

function MakeBitmapText()
	return LoadFont("_stagegameplay") .. {
		InitCommand=function(s) s:maxwidth(180) end,
	};
end

if GAMESTATE:IsCourseMode() then
	StageDisplay[#StageDisplay+1] = MakeBitmapText() .. {
		Text="",
		SetCommand=function(self, _)
			local Stage1=tostring(GAMESTATE:GetAppropriateStageNum())
			self:settext(FormatNumberAndSuffix(Stage1))
		end,
		DoneLoadingNextSongMessageCommand=function(s) s:queuecommand("Set") end
	}
else
	for s in ivalues(Stage) do

	if s ~= 'Stage_Next' and s ~= 'Stage_Nonstop' and s ~= 'Stage_Oni' and s ~= 'Stage_Endless' and s ~= 'Stage_Demo' then
		StageDisplay[#StageDisplay+1] = MakeBitmapText() .. {
			SetCommand=function(self, params)
				local Stage = GAMESTATE:GetCurrentStage();
				local StageIndex = GAMESTATE:GetCurrentStageIndex()+1
				local screen = SCREENMAN:GetTopScreen()
				if GAMESTATE:IsEventMode() then
					self:settext(FormatNumberAndSuffix(StageIndex))
				else
					self:settext(StageToLocalizedString(Stage))
				end
			end;
		};
	end

	end
end

return StageDisplay;
