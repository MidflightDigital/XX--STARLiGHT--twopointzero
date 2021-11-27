local t = LoadFallbackB();

t[#t+1] = Def.Sound{
	File=THEME:GetPathS("","Profile_In"),
	OnCommand=function(s) s:play() end,
};

return t
