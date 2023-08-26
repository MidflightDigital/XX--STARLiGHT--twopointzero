
return Def.ActorFrame{
	Def.Quad {	--- needed for course gameplay shutter
		InitCommand=function(s) s:FullScreen():diffuse(color('0,0,0,1')) end,
	},
	loadfile(THEME:GetPathB("ScreenWithMenuElements","background/"..ThemePrefs.Get("MenuBG").."/default.lua"))()
} 