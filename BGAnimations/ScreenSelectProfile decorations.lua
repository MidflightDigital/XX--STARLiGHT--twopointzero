local t = LoadFallbackB();

local screen = Var("LoadingScreen")

if THEME:GetMetric(screen, "ShowHeader") then
	t[#t+1] = loadfile(THEME:GetPathG(screen, "Header"))()..{
		Name = "Header",
	}
end

t[#t+1] = Def.ActorFrame {
  Def.Sound{
	  File=THEME:GetPathS("","Profile_In"),
		OnCommand=function(s) s:play() end,
	};
};

return t
