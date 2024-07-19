local t = LoadFallbackB();

local screen = Var("LoadingScreen")

if THEME:GetMetric(screen, "ShowHeader") then
	t[#t+1] = loadfile(THEME:GetPathG(screen, "Header"))()..{
		Name = "Header",
	}
end

return t
