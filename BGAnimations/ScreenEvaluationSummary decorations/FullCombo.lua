local t = Def.ActorFrame {
	Def.ActorFrame {
		InitCommand=function(s) s:pulse():effectperiod(1):effectmagnitude(0.9,1.2,0) end,
		OffCommand=function(s) s:bouncebegin(0.25):zoom(0) end,
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenGameplay","overlay/FullCombo/Fullcombo02"),
			InitCommand=function(s) s:spin():effectmagnitude(0,0,-150) end,
			OffCommand=function(s) s:spin():effectmagnitude(0,0,-300) end,
		};
	};
	Def.ActorFrame {
		InitCommand=function(s) s:pulse():effectperiod(2):effectmagnitude(0.9,1.2,0) end,
		OffCommand=function(s) s:bouncebegin(0.25):zoom(0) end,
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenGameplay","overlay/FullCombo/Fullcombo01"),
			InitCommand=function(s) s:spin():effectmagnitude(0,0,150) end,
			OffCommand=function(s) s:spin():effectmagnitude(0,0,300) end,
		};
	};
};
return t;