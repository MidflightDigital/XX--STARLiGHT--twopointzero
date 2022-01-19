return Def.ActorFrame{
	StorageDevicesChangedMessageCommand=function(self, params)
		MemCardInsert()
	end;
	Def.Sprite{
		Texture="EX",
		InitCommand = function(s) s:Center() end,
	};
	Def.Quad{
		InitCommand = function(s) s:FullScreen():diffuse(Color.Black) end;
		OnCommand = function(s) s:linear(0.7):diffusealpha(0):linear(0)
			:sleep(7):linear(0.7):diffusealpha(1)
		end;
	};
}

