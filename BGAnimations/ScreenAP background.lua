local t = Def.ActorFrame{
	--I scared the shit out of myself with this so I'm disabling it.
	--[[Def.Sound{
		SupportsRateChanging=true,
		File=THEME:GetPathS("","uhhh"),
		OnCommand=function(s) s:play() end,
	};]]
	Def.Sound{
		SupportsRateChanging=true,
		File=THEME:GetPathS("","AP"),
		OnCommand=function(s) s:play() end,
	};
	Def.ActorFrame{
		InitCommand=function(s) s:diffusealpha(0) end,
		OnCommand=function(s) s:sleep(0.5):decelerate(1):diffusealpha(0.7) end,
		Def.ActorFrame{
			InitCommand=function(s) s:blend(Blend.Add):spin():effectmagnitude(0,0,-2) end,
			LoadActor("ScreenWithMenuElements background/NG2/Node-BG.png")..{
				InitCommand=function(s) s:setsize(1920*2,1080*2):xy(_screen.cx-200,_screen.cy+40):diffusealpha(0.2):pulse():effectperiod(50) end,
			};
		};
		Def.ActorFrame{
			InitCommand=function(s) s:blend(Blend.Add):spin():effectmagnitude(0,0,6) end,
			LoadActor("ScreenWithMenuElements background/NG2/Node-BG.png")..{
				InitCommand=function(s) s:setsize(1920*2,1080*2):xy(_screen.cx+500,_screen.cy-180):diffusealpha(0.2):pulse():effectperiod(100) end,
			};
		};
		LoadActor("ScreenWithMenuElements background/NG2/Node-BG.png")..{
			InitCommand=function(s) s:blend(Blend.Add):setsize(1920*2,1080*2):rotationz(120):Center():diffusealpha(0.2):spin():effectmagnitude(0,0,-2) end,
		};
	};
	LoadActor("ScreenWithMenuElements background/Default/background.avi")..{
		InitCommand=function(s) s:Center()
			:setsize(IsUsingWideScreen() and SCREEN_WIDTH or 1920,SCREEN_HEIGHT)
			:diffuse(Alpha((Color.Red),0))
		end,
		OnCommand=function(s) s:sleep(0.2):decelerate(1):diffusealpha(0.5) end,
	};
	Def.Sprite{
		Texture=THEME:GetPathG("","sus.png");
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM-200):zoom(0.4):diffusealpha(0) end,
		OnCommand=function(s) s:sleep(1):linear(0.6):diffusealpha(0.05) end,
	};
	LoadFont("_avenirnext lt pro bold 36px")..{
		Text=base64decode(THEME:GetString("ap","m"));
		InitCommand=function(s) s:Center():wrapwidthpixels(SCREEN_WIDTH/1.5):diffusealpha(0) end,
		OnCommand=function(s) s:sleep(0.5):decelerate(1):diffusealpha(0.9) end,
	};

};

return t;