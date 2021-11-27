local wt = ThemePrefs.Get("WheelType")

local t = Def.ActorFrame{
    Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            mw:xy(_screen.cx,_screen.cy-67.5):zoom(0.8)
			SCREENMAN:GetTopScreen():GetChild("Header"):visible(false)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:fov(90)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
		end
    }
};
local SongAttributes = LoadModule "SongAttributes.lua"

t[#t+1] = Def.ActorFrame{
	loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/PreviewDeco/songPreview.lua"))();
}

return t;
