local t = Def.ActorFrame{
    loadfile(THEME:GetPathB("","ScreenWithMenuElements background"))()..{
    OnCommand=function(s) s:diffusealpha(1):sleep(2.5):linear(0.2):diffusealpha(0):queuecommand("Finish") end,
    FinishCommand=function(s) s:finishtweening() end,
  };
  Def.Sound{
    File=THEME:GetPathB("","ScreenGameplay out/swoosh.ogg"),
    OnCommand=function(s) s:sleep(2.5):queuecommand("Play") end,
    PlayCommand=function(s) s:play() end,
  };
  loadfile(THEME:GetPathB("","_StageDoors"))()..{
		OnCommand=function(s) s:sleep(2.5):queuecommand("AnOff") end,
	};
};

return t;
