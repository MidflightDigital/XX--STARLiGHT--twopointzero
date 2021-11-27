return Def.Actor{
  OnCommand=function(s)
		SCREENMAN:GetTopScreen():SetPrevScreenName("ScreenSelectMusic")
	end,
	CodeMessageCommand = function(self,params)
		if params.Name == "Back" then
			GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
			SCREENMAN:GetTopScreen():Cancel()
		end
	end
}
