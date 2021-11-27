return Def.ActorFrame {
	Def.Quad{
		InitCommand=function(s)
			s:setsize(280,30):diffusealpha(0.5):fadeleft(0.1):faderight(0.1)
		end,
	};
	Def.Sprite{
		Texture="_shared/arrow.png",
		InitCommand=function(s) s:x(-180):zoom(1.1):rotationy(180) end,
	};
	Def.Sprite{
		Texture="_shared/arrow.png",
		InitCommand=function(s) s:x(180):zoom(1.1) end,
	};
};