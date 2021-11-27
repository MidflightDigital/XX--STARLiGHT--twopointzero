return Def.ActorFrame{
	Def.Actor{
		OnCommand=function(s) s:sleep(4) end,
	};
	Def.Sound{
		File=THEME:GetPathB("ScreenGameplay","out/swoosh.ogg"),
		StartTransitioningCommand=function(s) s:sleep(3):queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
	Def.ActorFrame {
		loadfile(THEME:GetPathB("","ScreenWithMenuElements background"))()..{
			OnCommand=function(s) s:diffusealpha(0):sleep(3):linear(0.2):diffusealpha(1):queuecommand("Finish")
				GAMESTATE:SetTemporaryEventMode(false)
			end,
			FinishCommand=function(s) s:finishtweening() end,
		};
		-- Failed
		loadfile(THEME:GetPathB("","_StageDoors"))()..{
			InitCommand=function(s) s:diffusealpha(0) end,
			OnCommand=function(s) s:queuecommand("SetOff"):diffusealpha(0):sleep(3.2):diffusealpha(1):queuecommand("AnOn"):sleep(4):queuecommand("AnOff"):sleep(2) end,
		};
		Def.Sprite{
			Texture="enjoy",
			InitCommand=function(s) s:Center() end,
			OnCommand=function(s) s:diffusealpha(0):zoomy(0):zoomx(4):sleep(3):linear(0.198):diffusealpha(1):zoomy(1):zoomx(1):sleep(2.604):linear(0.132):zoomy(0):zoomx(4):diffusealpha(0) end,
		};
	};
};
