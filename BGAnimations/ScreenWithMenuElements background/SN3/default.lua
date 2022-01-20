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
			InitCommand=cmd(FullScreen);
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/honeyleft"),
			InitCommand=cmd(CenterY;halign,0;x,SCREEN_LEFT;diffuse,color("1,1,1,0.1");blend,Blend.Add;zoom,1.7);
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/honeyright"),
			InitCommand=cmd(CenterY;halign,1;x,SCREEN_RIGHT;diffuse,color("1,1,1,0.1");blend,Blend.Add;zoom,1.7);
		};
	};
	Def.ActorFrame{
	InitCommand=cmd(Center;blend,Blend.Add;;diffusealpha,0.6);
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/stars"),
			InitCommand=cmd(diffusealpha,0.3;fadetop,0.5;fadebottom,0.5;zoom,2.25);
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
			InitCommand=cmd(y,-50;x,-200;diffusealpha,0.5;zoom,2.25);
			OnCommand=cmd(spin;effectmagnitude,0,0,50);
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/left flash"),
			InitCommand=function(s) s:zoom(2.25) end,
			OnCommand=function(s) s:playcommand("Anim") end,
			AnimCommand=cmd(finishtweening;diffusealpha,0;sleep,4;accelerate,0.2;diffusealpha,1;sleep,0.5;linear,1;diffusealpha,0;queuecommand,'Anim');
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/right flash"),
			InitCommand=function(s) s:zoom(2.25) end,
			OnCommand=function(s) s:playcommand("Anim") end,
			AnimCommand=cmd(finishtweening;diffusealpha,0;sleep,2;accelerate,0.2;diffusealpha,1;sleep,0.5;linear,1;diffusealpha,0;sleep,2;queuecommand,'Anim');
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/round grid"),
			InitCommand=cmd(setsize,1920,1080;diffusealpha,0.5;blend,Blend.Add;);
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/middle flash"),
			InitCommand=cmd(y,-240;CenterX;zoomx,SCREEN_WIDTH;fadetop,0.5;fadebottom,0.5);
			OnCommand=function(s) s:playcommand("Anim") end,
			AnimCommand=cmd(finishtweening;diffusealpha,0;blend,Blend.Add;;linear,2;diffusealpha,0.55;addy,SCREEN_HEIGHT;queuecommand,"Queue");
			QueueCommand=cmd(diffusealpha,0;addy,-SCREEN_HEIGHT;sleep,4;queuecommand,"Anim");
		};
	};
};

t[#t+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:Center():zoom(0.4):zbuffer(false):zwrite(false)
	end;
	Def.ActorFrame{
		Def.ActorFrame{
			InitCommand=cmd(rotationx,12;rotationz,22);
			LoadActor("SuperNovaFogBall.txt")..{
				InitCommand=cmd(diffusealpha,0.25;blend,Blend.Add;zoom,45;spin;effectmagnitude,0,80,0);
			};
			LoadActor("2ndSuperNovaFogBall.txt")..{
				InitCommand=cmd(diffusealpha,0.25;blend,Blend.Add;zoom,45;spin;effectmagnitude,0,-80,0);
			};
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/ring.png"),
			InitCommand=cmd(queuecommand,"Anim");
			AnimCommand=cmd(finishtweening;blend,Blend.Add;diffusealpha,0.5;rotationx,75;rotationy,-60;zoom,5;spin;effectmagnitude,0,0,75);
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/ring.png"),
			InitCommand=cmd(queuecommand,"Anim");
			AnimCommand=cmd(finishtweening;blend,Blend.Add;diffusealpha,0.5;rotationx,85;rotationy,-15;zoom,5;spin,effectmagnitude,0,0,75);
		};
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/ring 2.png"),
			InitCommand=cmd(queuecommand,"Anim");
			AnimCommand=cmd(finishtweening;blend,Blend.Add;diffusealpha,1;rotationx,83;rotationy,10;zoom,5;spin,effectmagnitude,0,0,-75);
		};
	};
};

t[#t+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:fov(120);
	end;
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/meter 1 (stretch).png"),
		InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y+20;zoomtowidth,SCREEN_WIDTH;zoomtoheight,SCREEN_HEIGHT);
		OnCommand=function(self)
			self:finishtweening()
			local w = DISPLAY:GetDisplayWidth() / self:GetWidth();
			local h = DISPLAY:GetDisplayHeight() / self:GetHeight();
			self:customtexturerect(0,0,w*0.5,h*0.5);
			self:rotationz(180)
			self:texcoordvelocity(-0.2,0);
			self:blend(Blend.Add);
		end;
	};
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/meter 1 (stretch).png"),
		InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-20;zoomtowidth,SCREEN_WIDTH;zoomtoheight,SCREEN_HEIGHT);
		OnCommand=function(self)
			self:finishtweening()
			local w = DISPLAY:GetDisplayWidth() / self:GetWidth();
			local h = DISPLAY:GetDisplayHeight() / self:GetHeight();
			self:customtexturerect(0,0,w*0.5,h*0.5);
			self:texcoordvelocity(-0.2,0);
			self:blend(Blend.Add);
		end;
	};
};

t[#t+1] = Def.ActorFrame{
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN3/scan"),
		InitCommand=cmd(FullScreen;blend,Blend.Add;;diffusealpha,0.25);
	};
}

return t;
