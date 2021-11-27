local max_stages = PREFSMAN:GetPreference( "SongsPerPlay" );

if GAMESTATE:IsEventMode() then
	max_stages = "Unlimited";
end;


local t = Def.ActorFrame {
-- Load of Music play frame --
	Def.ActorFrame{
		GainFocusCommand=function(s) s:diffuse(Color.White) end,
		LoseFocusCommand=function(s) s:diffuse(color("0.5,0.5,0.5,1")) end,
		Def.Sprite{
			Texture="Normal Play/box",
	  		InitCommand=function(s) s:y(192) end,
			OnCommand=function(s) s:diffusealpha(0):zoomy(0):sleep(0.2):smooth(0.2):zoomy(1):diffusealpha(1) end,
		};
	};
};

t[#t+1] = Def.ActorFrame{
	Def.ActorFrame{
		InitCommand=function(s) s:y(-28) end,
		Def.Sprite{
			OnCommand=function(s) s:diffusealpha(1):sleep(1.2) end,
			GainFocusCommand=function(self)
				self:Load(THEME:GetPathG("","ScreenSelectPlayMode icon/Normal Play/bgframe"))
			end;
			LoseFocusCommand=function(self)
				self:Load(THEME:GetPathG("","ScreenSelectPlayMode icon/Normal Play/bg dark"))
			end;
		};
		Def.Sprite{
			InitCommand=function(s) s:y(-25) end,
			GainFocusCommand=function(self)
				self:Load(THEME:GetPathG("","ScreenSelectPlayMode icon/Normal Play/char.png"))
			end;
			LoseFocusCommand=function(self)
				self:Load(THEME:GetPathG("","ScreenSelectPlayMode icon/Normal Play/chardark.png"))
			end;
		};
	};
	Def.Sprite{
		Texture="MaxStage_"..max_stages,
		InitCommand=function(s) s:y(176) end,
		OnCommand=function(s) s:diffusealpha(0):sleep(0.2):smooth(0.2):diffusealpha(1) end,
		GainFocusCommand=function(s) s:diffuse(Color.White) end,
		LoseFocusCommand=function(s) s:diffuse(color("0.5,0.5,0.5,1")) end,
	};
	Def.ActorFrame{
		InitCommand=function(s) s:x(300,240):zoomx(-1.0) end,
		OnCommand=function(s) s:zoomy(0):sleep(0.2):linear(0.2):zoomy(1):queuecommand("Animate") end,
		AnimateCommand=function(s) s:bob():effectmagnitude(10,0,0):effectperiod(0.7) end,
		GainFocusCommand=function(s) s:finishtweening():linear(0.2):zoomx(-1):zoomy(1):queuecommand("Animate") end,
		LoseFocusCommand=function(s) s:stoptweening():linear(0.1):zoom(0) end,
		OffCommand=function(s) s:diffusealpha(0) end,
		Def.Sprite{
			Texture=THEME:GetPathG("","ScreenSelectPlayMode icon/_selectarrowg"),
		};
		Def.Sprite{
		Texture=THEME:GetPathG("","ScreenSelectPlayMode icon/_selectarrowr"),
			InitCommand=function(s) s:diffusealpha(0):draworder(100) end,
			GainFocusCommand=function(s) s:diffusealpha(0) end,
			LoseFocusCommand=function(s) s:diffusealpha(1):sleep(0.4):diffusealpha(0) end,
		};
	};
}

return t;
