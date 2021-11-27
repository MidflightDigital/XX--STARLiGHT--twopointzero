local max_stages = PREFSMAN:GetPreference( "SongsPerPlay" );

if GAMESTATE:IsEventMode() then
	max_stages = "Unlimited";
end;


return Def.ActorFrame {
-- Load of Music play frame --
    Def.Sprite{
		Texture="MusicPlay",
	    InitCommand=function(s) s:xy(-35,215):zoom(1.5) end,
		OnCommand=function(s) s:zoomy(0):sleep(0.5):linear(0.2):zoomy(1.5) end,
		OffCommand=function(s) s:linear(0.2):zoomy(0):diffusealpha(1) end,
	};
	Def.Sprite{
		Texture="MusicPlay",
	    InitCommand=function(s) s:x(-35,375):zoomx(1.5):zoomy(-1.5):diffusealpha(0.5):diffusetopedge(Alpha(Color.White)) end,
		OnCommand=function(s) s:zoomy(0):sleep(0.5):linear(0.2):zoomy(-1.5) end,
		OffCommand=function(s) s:linear(0.2):zoomy(0):diffusealpha(0) end,
	};
	Def.Sprite{
		Texture="Normal Play/bg dark",
		OnCommand=function(s) s:x(-45,-25):ztest(0) end,
		OffCommand=function(s) s:sleep(0.2):linear(0.07):addx(2000):diffusealpha(0) end,
	};
	Def.Sprite{
		Texture="Normal Play/bg dark",
	    InitCommand=function(s) s:blend('BlendMode_Add'):diffusealpha(0):x(-45,-25) end,
		OnCommand=function(s) s:diffusealpha(1):sleep(1.2) end,
		AnimateCommand=function(s) s:diffuseshift():effectperiod(2) end,
		GainFocusCommand=function(s) s:stoptweening():diffusealpha(1):playcommand("Animate") end,
		LoseFocusCommand=function(s) s:stoptweening():diffusealpha(0) end,
		OffCommand=function(s) s:sleep(0.2):linear(0.07):addx(-2000):diffusealpha(0) end,
	};
	Def.Sprite{
		Texture="Normal Play/char.png",
		InitCommand=function(s) s:diffusealpha(0):x(-38,-25) end,
		OnCommand=function(s) s:diffusealpha(1) end,
		OffCommand=function(s) s:sleep(0.2):linear(0.07):addx(2000):diffusealpha(0) end,
	};
    Def.Sprite{
		Texture="MaxStage_"..max_stages,
	    InitCommand=function(s) s:xy(150,170):zoom(1.5) end,
		OnCommand=function(s) s:zoomy(0):sleep(0.5):linear(0.2):zoomy(1.5) end,
		OffCommand=function(s) s:linear(0.2):zoomy(0):diffusealpha(1) end,
	};
	Def.Sprite{
		Texture="_selectarrow",
	    InitCommand=function(s) s:xy(300,250):zoomx(-1.0) end,
		OnCommand=function(s) s:zoomy(0):sleep(0.5):linear(0.2):zoomy(0.9):playcommand("Animate") end,
		AnimateCommand=function(s) s:bob():effectmagnitude(10,0,0):effectperiod(0.7) end,
		GainFocusCommand=function(s) s:stoptweening():linear(0.2):zoomx(-0.9):zoomy(0.9):playcommand("Animate") end,
		LoseFocusCommand=function(s) s:stoptweening():linear(0.1):zoom(0) end,
		OffCommand=function(s) s:diffusealpha(0) end,
	};
}
