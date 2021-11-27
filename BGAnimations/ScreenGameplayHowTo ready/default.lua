local t = Def.ActorFrame{
	Def.Sprite{
		Texture="htp",
		OnCommand=function(s) s:zoom(1.2):x(SCREEN_LEFT-1000):y(SCREEN_CENTER_Y):sleep(0.116):linear(0.217):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):linear(0.2):zoom(1):sleep(1):linear(0.083):diffusealpha(0):zoomy(0) end,
	};
	--Right
	Def.Sprite{
		Texture="htp",
		OnCommand=function(s) s:zoom(1.2):x(SCREEN_RIGHT+1000):y(SCREEN_CENTER_Y):sleep(0.116):linear(0.217):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):linear(0.2):zoom(1):sleep(1):linear(0.083):diffusealpha(0):zoomy(0) end,
	};
	--Glow
	Def.Sprite{
		Texture="htp",
		OnCommand=function(s) s:diffusealpha(0):xy(_screen.cx,_screen.cy):sleep(0.283):diffusealpha(0.5):zoom(1.2):linear(0.017):diffusealpha(1):linear(0.133):diffusealpha(0):zoom(1) end,
	};
};

return t;
