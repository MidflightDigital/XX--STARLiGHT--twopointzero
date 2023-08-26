return Def.ActorFrame{
	OffCommand=function(s) s:finishtweening() end,
	Def.Sprite{
		 Texture="bg.png",
		 InitCommand=function(s) s:valign(1):xy(_screen.cx,SCREEN_BOTTOM):setsize(SCREEN_WIDTH,744) end,
	};
	Def.Sprite{
		Texture="bg top.png",
		InitCommand=function(s) s:valign(0):xy(_screen.cx,SCREEN_TOP):zoom(1.5) end,
	};
	Def.Sprite{
		Texture="hills2 (stretch)",
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-308):zoom(1.5)
			:customtexturerect(0,0,1,1):texcoordvelocity(0.2,0)
		end,
	};
	Def.Sprite{
		Texture="hill2 hl (stretch)",
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-338):zoom(1.5)
			:customtexturerect(0,0,1,1):texcoordvelocity(0.2,0)
		end,
	};
	Def.Sprite{
		Texture="hills1 (stretch)",
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-308):diffusealpha(0.5):zoom(1.5)
			:customtexturerect(0,0,1.5,1):texcoordvelocity(0.2,0)
		end,
	};

	Def.ActorFrame{
		InitCommand=function(s) s:zoom(1.5):xy(-400,-200) end,
		--ripples-------------------
		Def.Sprite{
		Texture="bgrp01",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx,_screen.cy+180):blend(Blend.Add):diffusealpha(0) end,
			OnCommand=function(s) s:queuecommand("Animate") end,
			AnimateCommand=function(s) s:finishtweening():zoom(1):diffusealpha(0):sleep(0.5):linear(0.65):zoom(1.3)
				:diffusealpha(0.5):decelerate(1.5):zoom(1.6):diffusealpha(0):sleep(5.5):queuecommand("Animate")
			end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(0.6):xy(_screen.cx,_screen.cy+180):blend(Blend.Add):diffusealpha(0) end,
			OnCommand=function(s) s:queuecommand("Animate") end,
			AnimateCommand=function(s) s:finishtweening():zoom(0.6):diffusealpha(0):rotationz(0):sleep(0.5)
				:linear(0.65):rotationz(230):zoom(0.9):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(1.2)
				:diffusealpha(0):sleep(5.5):queuecommand("Animate")
			end,
		};
		Def.Sprite{
			Texture="bgrp02",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+280,_screen.cy-180):blend(Blend.Add):diffusealpha(0) end,
			OnCommand=function(s) s:queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):sleep(2.5):linear(0.65):zoom(1.2):diffusealpha(1)
				:decelerate(1.5):zoom(1.4):diffusealpha(0):sleep(9.5):queuecommand("Animate")
			end,
		};
		Def.Sprite{
			Texture="bgrp03",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+280,_screen.cy-180):blend(Blend.Add):diffusealpha(0):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):sleep(3.5):linear(0.65):zoom(1.4):diffusealpha(0.5)
				:decelerate(1.5):zoom(1.8):diffusealpha(0):sleep(8.5):queuecommand("Animate")
			end,
		};
		Def.Sprite{
			Texture="bgrp03",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx-280,_screen.cy-50):blend(Blend.Add):diffusealpha(0):sleep(1.2):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.4):diffusealpha(1):decelerate(1.5):zoom(1.8):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="ripple00A",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+500,_screen.cy):blend(Blend.Add):diffusealpha(0):sleep(3.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.2):diffusealpha(0.3):decelerate(1.5):zoom(1.5):diffusealpha(0):sleep(6):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+500,_screen.cy):blend(Blend.Add):diffusealpha(0):sleep(3.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(1.35):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(1.7):diffusealpha(0):sleep(6):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="ripple00B",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx-100,_screen.cy+90):blend(Blend.Add):diffusealpha(0):sleep(7.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.15):diffusealpha(0.5):decelerate(1.5):zoom(1.3):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx-100,_screen.cy+90):blend(Blend.Add):diffusealpha(0):sleep(7.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(1.35):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(1.5):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="ripple00B",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx-470,_screen.cy-250):diffuse(Alpha(Color.Green,0)):blend(Blend.Add):sleep(0.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.4):diffusealpha(0.5):decelerate(1.5):zoom(1.8):diffusealpha(0):sleep(6):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx-470,_screen.cy-250):blend(Blend.Add):diffusealpha(0):sleep(0.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(1.4):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(1.8):diffusealpha(0):sleep(6):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="ripple00B",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+470,_screen.cy+250):diffuse(Alpha(Color.Green,0)):blend(Blend.Add):sleep(4.2):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.4):diffusealpha(0.5):decelerate(1.5):zoom(1.8):diffusealpha(0):sleep(6):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+470,_screen.cy+250):blend(Blend.Add):diffusealpha(0):sleep(4.2):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(1.4):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(1.8):diffusealpha(0):sleep(6):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="ripple00C",
			InitCommand=function(s) s:zoom(1):x(_screen.cx+560,_screen.cy+250):blend(Blend.Add):diffusealpha(0):sleep(6.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.15):diffusealpha(0.5):decelerate(1.5):zoom(1.3):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(0.6):xy(_screen.cx+560,_screen.cy+250):blend(Blend.Add):diffusealpha(0):sleep(6.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(0.6):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(0.7):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(0.9):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="ripple00C",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx-450,_screen.cy+150):blend(Blend.Add):diffusealpha(0):sleep(1.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.15):diffusealpha(0.5):decelerate(1.5):zoom(1.3):diffusealpha(0):sleep(6):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(0.6):xy(_screen.cx-450,_screen.cy+150):blend(Blend.Add):diffusealpha(0):sleep(1.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(0.6):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(0.7):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(0.9):diffusealpha(0):sleep(6):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="ripple00C",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx-180,_screen.cy-190):blend(Blend.Add):diffusealpha(0):sleep(0.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.15):diffusealpha(0.5):decelerate(1.5):zoom(1.3):diffusealpha(0):sleep(5):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(0.6):xy(_screen.cx-180,_screen.cy-190):blend(Blend.Add):diffusealpha(0):sleep(0.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(0.6):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(0.7):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(0.9):diffusealpha(0):sleep(5):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp001",
			InitCommand=function(s) s:zoom(1.5):xy(_screen.cx+200,_screen.cy+200):blend(Blend.Add):diffusealpha(0):sleep(11.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1.5):diffusealpha(0):linear(0.65):zoom(1.65):diffusealpha(0.5):decelerate(1.5):zoom(1.8):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(1.5):xy(_screen.cx+200,_screen.cy+200):blend(Blend.Add):diffusealpha(0):sleep(11.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1.5):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(2.05):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(2.8):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp001",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+410,_screen.cy-200):blend(Blend.Add):diffusealpha(0):sleep(2.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.65):zoom(1.15):diffusealpha(0.5):decelerate(1.5):zoom(1.3):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+410,_screen.cy-200):blend(Blend.Add):diffusealpha(0):sleep(2.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(1.15):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(1.3):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp001",
			InitCommand=function(s) s:zoom(1.6):xy(_screen.cx-450,_screen.cy+170):blend(Blend.Add):diffusealpha(0):sleep(4.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1.6):diffusealpha(0):linear(0.65):zoom(1.85):diffusealpha(0.5):decelerate(1.5):zoom(2.0):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rp00A1",
			InitCommand=function(s) s:zoom(1.6):xy(_screen.cx-450,_screen.cy+170):blend(Blend.Add):diffusealpha(0):sleep(4.5):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1.6):diffusealpha(0):rotationz(0):linear(0.65):rotationz(230):zoom(1.85):diffusealpha(0.2):decelerate(1.5):rotationz(490):zoom(2.0):diffusealpha(0):sleep(12):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rpshadle001",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx+370,_screen.cy+220):blend(Blend.Add):diffusealpha(0):sleep(0.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(1):diffusealpha(0):linear(0.33):zoom(1.15):diffusealpha(1):decelerate(0.55):zoom(1.3):diffusealpha(0):sleep(7):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="rpshadle001",
			InitCommand=function(s) s:zoom(1):xy(_screen.cx-400,_screen.cy+260):blend(Blend.Add):diffusealpha(0):sleep(2.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:zoom(0.55):diffusealpha(0):linear(0.33):zoom(0.75):diffusealpha(1):decelerate(0.55):zoom(0.95):diffusealpha(0):sleep(7):queuecommand("Animate") end,
		};
		--bubbles-----------------

		Def.Sprite{
			Texture="BubbleTileA",
			InitCommand=function(s) s:zoom(0.5):xy(_screen.cx-270,SCREEN_BOTTOM+20):blend(Blend.Add):sleep(2.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:y(SCREEN_BOTTOM+20):accelerate(2.5):y(SCREEN_TOP-20):sleep(5):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="BubbleTileB",
			InitCommand=function(s) s:zoom(0.5):xy(_screen.cx+210,SCREEN_BOTTOM+20):blend(Blend.Add):sleep(1.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:y(SCREEN_BOTTOM+20):accelerate(3.5):y(SCREEN_TOP-20):sleep(8):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="BubbleTileB",
			InitCommand=function(s) s:zoom(0.3):xy(_screen.cx+140,SCREEN_BOTTOM+20):blend(Blend.Add):sleep(6.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:y(SCREEN_BOTTOM+20):accelerate(3.5):y(SCREEN_TOP-20):sleep(9):queuecommand("Animate") end,
		};
		--lines--------------------------

		Def.Sprite{
			Texture="WaveRepeatA2",
			InitCommand=function(s) s:zoom(1):diffusealpha(0):sleep(3.2):queuecommand("Animate") end,
			AnimateCommand=function(s) s:xy(_screen.cx-160,_screen.cy-290):zoomx(1.5):diffusealpha(0):linear(0.99):diffusealpha(0.33):x(_screen.cx-140):decelerate(1.65):diffusealpha(0):x(_screen.cx-120):sleep(15):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="WaveRepeatA3",
			InitCommand=function(s) s:zoom(1):diffusealpha(0):sleep(7.2):queuecommand("Animate") end,
			AnimateCommand=function(s) s:xy(_screen.cx+200,_screen.cy-310):zoom(0.75):diffusealpha(0):linear(0.99):diffusealpha(0.33):x(_screen.cx+250):zoomx(0.95):decelerate(1.65):diffusealpha(0):x(_screen.cx+300):zoomx(1.15):sleep(15):queuecommand("Animate") end,
		};
	};
};
