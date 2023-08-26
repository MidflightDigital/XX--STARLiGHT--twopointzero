local t = Def.ActorFrame{
};
local p = {
	red = color("1,0,0,0.812"),
	green = color("0,1,0,0.812"),
	blue = color("0,0,1,0.812"),
	yellow = color("1,1,0,0.812"),
	pink = color("1,0,1,0.812"),
	cyan = color("0,1,1,0.812")
}
local colorPatterns =
{
	--first pattern block: YRPBCG with different start indices
	{[0]=p.yellow, p.red, p.pink, p.blue, p.cyan, p.green},
	--second pattern block: GCBPRY with different start indices
	{[0]=p.pink, p.red, p.yellow, p.green, p.cyan, p.blue}
}
local curPattern = 1
local curPatternIdx = 0
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:fov(120);
	end;
	Def.ActorFrame{
		OnCommand=function(self)
			self:finishtweening()
			local seed = math.random(1,13);
			--seed breakdown:
			--8-13: pattern 1, increasing start color
			--2-7: pattern 2, increasing start color
			--1: rainbow
			if seed > 1 then
				if seed > 7 then
					curPattern = 1
					curPatternIdx = seed - 8
				else
					curPattern = 2
					curPatternIdx = seed - 2
				end
				self:diffuse(colorPatterns[curPattern][curPatternIdx])
				self:queuecommand("Animate")
			else
				self:rainbow();
				self:effectperiod(120);
			end;
		end;
		AnimateCommand = function(s)
			--bump the current color to the next color in the pattern
			curPatternIdx = (curPatternIdx + 1) % #(colorPatterns[curPattern])
			s:linear(20)
			:diffuse(colorPatterns[curPattern][curPatternIdx])
			:queuecommand("Animate")
		end;
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/back"),
			InitCommand=function(s) s:FullScreen() end,
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/honeyleft"),
			InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT,_screen.cy):diffuse(Alpha(Color.White,0.1)):blend(Blend.Add):zoom(1.7) end,
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/honeyright"),
			InitCommand=function(s) s:halign(1):xy(SCREEN_RIGHT,_screen.cy):diffuse(Alpha(Color.White,0.1)):blend(Blend.Add):zoom(1.7) end,
		};
	};
	Def.ActorFrame{
		InitCommand=function(s) s:Center():blend(Blend.Add):diffusealpha(0.6) end,
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/stars"),
			InitCommand=function(s) s:diffusealpha(0.3):fadetop(0.5):fadebottom(0.5):zoom(2.25) end,
			OnCommand=function(self)
				self:finishtweening()
				local w = DISPLAY:GetDisplayWidth() / self:GetWidth();
				local h = DISPLAY:GetDisplayHeight() / self:GetHeight();
				self:customtexturerect(0,0,w*1,h*1);
				self:texcoordvelocity(-0.02,0);
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/flash"),
			InitCommand=function(s) s:xy(-200,-50):diffusealpha(0.5):zoom(2.25):spin():effectmagnitude(0,0,50) end,
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/left flash"),
			InitCommand=function(s) s:zoom(2.25):queuecommand("Anim") end,
			AnimCommand=function(s) s:finishtweening():diffusealpha(0):sleep(4):accelerate(0.2):diffusealpha(1):sleep(0.5):linear(1):diffusealpha(0):queuecommand('Anim') end,
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/right flash"),
			InitCommand=function(s) s:zoom(2.25):queuecommand("Anim") end,
			AnimCommand=function(s) s:finishtweening():diffusealpha(0):sleep(2):accelerate(0.2):diffusealpha(1):sleep(0.5):linear(1):diffusealpha(0):sleep(2):queuecommand('Anim') end,
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/round grid"),
			InitCommand=function(s) s:setsize(1920,1080):diffusealpha(0.5):blend(Blend.Add) end,
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/middle flash"),
			InitCommand=function(s) s:xy(_screen.cx,-240):zoomx(SCREEN_WIDTH):fadetop(0.5):fadebottom(0.5):blend(Blend.Add):queuecommand("Anim") end,
			AnimCommand=function(s) s:finishtweening():diffusealpha(0):linear(2):diffusealpha(0.55):addy(SCREEN_HEIGHT):diffusealpha(0):addy(-SCREEN_HEIGHT):sleep(4):queuecommand("Anim") end,
		};
	};
};

t[#t+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:Center():zoom(0.4):zbuffer(false):zwrite(false)
	end;
	Def.ActorFrame{
		Def.ActorFrame{
			InitCommand=function(s) s:rotationx(12):rotationz(22) end,
			Def.Model{
				Materials="SuperNovaFogBall.txt",
				Meshes="SuperNovaFogBall.txt",
				Bones="SuperNovaFogBall.txt",
				InitCommand=function(s) s:diffusealpha(0.25):blend(Blend.Add):zoom(45):spin():effectmagnitude(0,80,0) end,
			};
			Def.Model{
				Materials="2ndSuperNovaFogBall.txt",
				Meshes="2ndSuperNovaFogBall.txt",
				Bones="2ndSuperNovaFogBall.txt",
				InitCommand=function(s) s:diffusealpha(0.25):blend(Blend.Add):zoom(45):spin():effectmagnitude(0,-80,0) end,
			};
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/ring.png"),
			InitCommand=function(s) s:blend(Blend.Add):diffusealpha(0.5):rotationx(75):rotationy(-60):zoom(5):spin():effectmagnitude(0,0,75) end,
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/ring.png"),
			InitCommand=function(s) s:blend(Blend.Add):diffusealpha(0.5):rotationx(85):rotationy(-15):zoom(5):spin():effectmagnitude(0,0,75) end,
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/ring 2.png"),
			InitCommand=function(s) s:blend(Blend.Add):diffusealpha(0.5):rotationx(83):rotationy(-10):zoom(5):spin():effectmagnitude(0,0,-75) end,
		};
	};
};

t[#t+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:fov(120);
	end;
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/meter 1 (stretch).png"),
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy+20):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):blend(Blend.Add):rotationz(180) end,
		OnCommand=function(self)
			self:finishtweening()
			local w = DISPLAY:GetDisplayWidth() / self:GetWidth();
			local h = DISPLAY:GetDisplayHeight() / self:GetHeight();
			self:customtexturerect(0,0,w*0.5,h*0.5);
			self:texcoordvelocity(-0.2,0);
		end;
	};
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/meter 1 (stretch).png"),
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-20):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):blend(Blend.Add) end,
		OnCommand=function(self)
			self:finishtweening()
			local w = DISPLAY:GetDisplayWidth() / self:GetWidth();
			local h = DISPLAY:GetDisplayHeight() / self:GetHeight();
			self:customtexturerect(0,0,w*0.5,h*0.5);
			self:texcoordvelocity(-0.2,0);
		end;
	};
};

t[#t+1] = Def.ActorFrame{
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/scan"),
		InitCommand=function(s) s:FullScreen():blend(Blend.Add):diffusealpha(0.25) end,
	};
}

return t;
