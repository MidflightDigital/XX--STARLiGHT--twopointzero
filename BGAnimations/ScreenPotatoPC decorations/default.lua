return Def.ActorFrame{
	Def.Sprite{
		Texture="DDR_Interface-THEMEHDWarning",
		InitCommand = function(s) s:Center() end,
	};
	Def.Quad{
		InitCommand = function(s) s:FullScreen():diffuse(Color.Black) end;
		OnCommand = function(s) s:linear(0.7):diffusealpha(0):linear(0)
			:sleep(7):linear(0.7):diffusealpha(1)
		end;
	};
}

