return Def.ActorFrame{
  OnCommand=function(s)
		SCREENMAN:GetTopScreen():SetPrevScreenName("ScreenSelectMusic")
	end,
	CodeMessageCommand = function(self,params)
		if params.Name == "Back" then
			GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
			SCREENMAN:GetTopScreen():Cancel()
		end
	end,
	Def.Quad{
		InitCommand=function(s) s:FullScreen() end,
		OnCommand=function(s) s:diffusealpha(0):sleep(0.75) end,
	};
	Def.Sound{
		File=THEME:GetPathS("","ScreenSelectPlayMode in.ogg"),
		OnCommand=function(s) s:queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	}
}
