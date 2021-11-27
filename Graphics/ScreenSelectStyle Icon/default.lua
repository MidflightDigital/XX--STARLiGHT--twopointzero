local t = Def.ActorFrame {};
local gc = Var("GameCommand");
local max_stages = PREFSMAN:GetPreference( "SongsPerPlay" );
--------------------------------------
t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:xy(_screen.cx+332,_screen.cy+12) end,
	GainFocusCommand=function(self)
		self:diffusealpha(0):zoomy(0):smooth(0.2):zoomy(1):diffusealpha(1)
	end;
	OnCommand=function(self)
		self:diffusealpha(0):zoomy(0)
		if (GAMESTATE:GetNumPlayersEnabled() > 1 and gc:GetName() == "Versus") or (gc:GetName() == "Single" and GAMESTATE:GetNumPlayersEnabled() == 1) then
			self:smooth(0.2):zoomy(1):diffusealpha(1)
		end;
	end;
	LoseFocusCommand=function(s) s:smooth(0.1):zoomy(0):diffusealpha(0) end,
	OffCommand=function(s) s:smooth(0.2):addy(300):diffusealpha(0) end,
	LoadActor( gc:GetName()..".png" );
	Def.BitmapText{
		Font="_avenir next demi bold 20px",
		InitCommand=function(s) s:diffuse(color("#dff0ff")):xy(1,-20):zoom(0.75)
			s:settext(THEME:GetString("ScreenSelectStyle", gc:GetName() == "Versus" and "2P" or "1P"))
		end,
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold 25px",
		Text=THEME:GetString("ScreenSelectStyle","Icon"..gc:GetName().."Description"),
		InitCommand=function(s) s:diffuse(color("#dff0ff")):xy(1,18) end,
	};
};

return t;
