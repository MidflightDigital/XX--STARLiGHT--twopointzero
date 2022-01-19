local t = LoadFallbackB();

local screen = Var("LoadingScreen")

t[#t+1] = Def.ActorFrame {
  Def.Sound{
	  File=THEME:GetPathS("","Profile_In"),
		OnCommand=function(s) s:play() end,
	};
};

return t
