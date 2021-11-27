local caution = Def.ActorFrame{
	
}

return Def.ActorFrame{
	--Yeah I know.
	--[[OnCommand=function(s) s:sleep(0.1):queuecommand("Dim1") end,
	Dim1Command=function(s) SOUND:DimMusic(0.75,math.huge) s:sleep(0.1):queuecommand("Dim2") end,
	Dim2Command=function(s) SOUND:DimMusic(0.5,math.huge) s:sleep(0.1):queuecommand("Dim3") end,
	Dim3Command=function(s) SOUND:DimMusic(0.25,math.huge) s:sleep(0.1):queuecommand("Dim4") end,
	Dim4Command=function(s) SOUND:DimMusic(0,math.huge) end,]]
	loadfile(THEME:GetPathB("","_StageDoors"))()..{
		OnCommand=function(s)
			if PROFILEMAN:IsPersistentProfile(PLAYER_1) or PROFILEMAN:IsPersistentProfile(PLAYER_2) then
				s:visible(false)
			else
				if ThemePrefs.Get("ShowHTP") == true then
					local song = SONGMAN:FindSong("Lesson by DJ")
					if song then
						s:visible(true):queuecommand("AnOn"):sleep(2)
					else
						s:visible(false)
					end
				else
					s:visible(false)
				end
			end
		end,
	};
	Def.ActorFrame{
		InitCommand=function(s) s:Center() end,
		OnCommand=function(s) s:diffusealpha(0):Center():zoomy(0):sleep(0.1):diffusealpha(1):linear(0.066):zoom(1) end,
		OffCommand=function(s) s:linear(0.134):zoomy(0) end,
		Def.Sprite{
			Texture="frame_mult",
			InitCommand=function(s) s:diffusealpha(1):blend(Blend.Multiply) end,
		};
		Def.Sprite{
			Texture="frame_add",
			InitCommand=function(s) s:blend(Blend.Add):diffusealpha(0.1) end,
		};
		Def.Sprite{
			Texture="frame_glow",
			InitCommand=function(s) s:blend(Blend.Add):diffuse(color("0.8,0.8,0.2,0.5")):sleep(0.184):queuecommand("Animate") end,
			AnimateCommand=function(s) s:diffusealpha(.5):linear(1.5):diffusealpha(.2):queuecommand("Animate") end,
			OffCommand=function(s) s:stoptweening() end,
		};
		Def.Sprite{
			Texture="frame_glow",
			InitCommand=function(s) s:blend(Blend.Add):diffuse(color("0.8,0.8,0.2,0.5")):sleep(0.184):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(.2):linear(1):zoom(1.2):diffusealpha(0):sleep(0.5):queuecommand("Animate") end,
			OffCommand=function(s) s:stoptweening():diffusealpha(0) end,
		};
	};
	Def.Sprite{
		Texture="text",
		OnCommand=function(s) s:diffusealpha(0):Center():zoomy(0):sleep(0.1):diffusealpha(1):linear(0.066):zoom(1):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+24) end,
		OffCommand=function(s) s:linear(0.134):zoomy(0) end,
	};
	Def.Sprite{
		Texture="text",
		OnCommand=function(s) s:diffusealpha(0):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+24):sleep(0.184):queuecommand("Animate") end,
		OffCommand=function(s) s:stoptweening():diffusealpha(0) end,
		AnimateCommand=function(s) s:zoom(1):diffusealpha(0.3):linear(1):zoom(1.2):diffusealpha(0):sleep(0.5):queuecommand("Animate") end,
	};
	Def.Sprite{
		Texture="flare",
		OnCommand=function(s) s:diffusealpha(0):zoomx(1.75):zoomy(0.75):sleep(0.034):diffusealpha(1):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-10):linear(0.066):zoom(1):addy(-4):linear(0.084):y(SCREEN_CENTER_Y-80):queuecommand("Animate") end,
		AnimateCommand=function(s) s:zoomy(1):diffusealpha(.5):linear(1):zoomy(1.53):linear(.5):diffusealpha(0):queuecommand("Animate") end,
		OffCommand=function(s) s:stoptweening():diffusealpha(0) end,
	};
	Def.Sprite{
		Texture="flare",
		OnCommand=function(s) s:diffusealpha(0):zoomx(1.75):zoomy(0.75):sleep(0.034):diffusealpha(1):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+10):linear(0.066):zoom(1):addy(-4):linear(0.084):y(SCREEN_CENTER_Y+130):queuecommand("Animate") end,
		AnimateCommand=function(s) s:zoomy(1):diffusealpha(.5):linear(1):zoomy(1.53):linear(.5):diffusealpha(0):queuecommand("Animate") end,
		OffCommand=function(s) s:stoptweening():diffusealpha(0) end,
	};
	Def.Sprite{
		Texture="caution",
		OnCommand=function(s) s:diffusealpha(0):zoomx(1.75):zoomy(0.75):sleep(0.034):diffusealpha(1):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-8):linear(0.066):zoom(1):addy(-4):linear(0.084):y(SCREEN_CENTER_Y-120) end,
		OffCommand=function(s) s:linear(0.084):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-8):sleep(0.0):linear(0.001):zoomx(1.75):zoomy(0.75):diffusealpha(0) end,
	};
	Def.Sprite{
		Texture="caution",
		InitCommand=function(s) s:blend(Blend.Add):diffusealpha(0):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-120):sleep(0.184):queuecommand("Animate") end,
		OffCommand=function(s) s:stoptweening():diffusealpha(0) end,
		AnimateCommand=function(s) s:zoom(1):diffusealpha(0.7):linear(1):zoom(1.2):diffusealpha(0):sleep(0.5):queuecommand("Animate") end,
	};
};
