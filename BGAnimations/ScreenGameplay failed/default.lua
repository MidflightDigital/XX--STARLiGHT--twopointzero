return Def.ActorFrame{
	OnCommand=function(s) s:sleep(0.2):queuecommand("Play") end,
	PlayCommand=function(s) SOUND:PlayOnce(THEME:GetPathB("ScreenGameplay","failed/_failed.ogg")) end,
	loadfile(THEME:GetPathB("","ScreenWithMenuElements background"))()..{
		InitCommand=function(s) s:diffuse(color("0.6,0.6,1,1")) end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1):linear(0.3):diffuse(color("1,0.2,0.2,1")):sleep(4):linear(0.3):diffuse(color("1,1,1,1")):queuecommand("Finish") end,
		FinishCommand=function(s) s:finishtweening() end,
	};
	-- Failed
	loadfile(THEME:GetPathB("","_StageDoors"))()..{
		OnCommand=function(s) s:queuecommand("SetOff"):queuecommand("SetFail"):diffusealpha(1):queuecommand("AnOn"):sleep(4):queuecommand("AnOff"):sleep(2) end,
	};
	Def.Sprite{
		Texture="failed",
		InitCommand=function(s) s:Center() end,
		OnCommand=function(s) s:diffusealpha(0):zoomy(0):zoomx(4):linear(0.198):diffusealpha(1):zoomy(1):zoomx(1):sleep(2.604):linear(0.132):zoomy(0):zoomx(4):diffusealpha(0) end,
	};
};
