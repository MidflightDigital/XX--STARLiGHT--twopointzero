local t = Def.ActorFrame{
	OffCommand=function(s) s:stoptweening() end,
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
		self:fov(130);
	end;
	Def.ActorFrame{
		Def.Sprite{
			Texture="BG",
			InitCommand=function(s) s:FullScreen() end,
			OnCommand=function(self)
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
		};
	};
	Def.ActorFrame{
		InitCommand=function(s) s:Center():spin():effectmagnitude(0,0,-4) end,
		Def.Sprite{
			Texture="line",
			InitCommand=function(s) s:x(-550):zoomto(SCREEN_WIDTH*3,SCREEN_HEIGHT*10):rotationy(-80):customtexturerect(0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96):blend(Blend.Add) end,
			OnCommand=function(s) s:diffusealpha(0.4):texcoordvelocity(1.5,-0.02):effectperiod(4) end,
		};
		Def.Sprite{
			Texture="line",
			InitCommand=function(s) s:xy(550,0):zoomto(SCREEN_WIDTH*3,SCREEN_HEIGHT*10):diffuse(ColorLightTone(color("#FFFFFF"))):rotationy(80):customtexturerect(0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96):blend(Blend.Add) end,
			OnCommand=function(s) s:diffusealpha(0.4):texcoordvelocity(-1.5,-0.02):effectperiod(4) end,
		};
		Def.Sprite{
			Texture="decoration01",
			InitCommand=function(s) s:x(-330):zoomto(SCREEN_WIDTH*30,SCREEN_HEIGHT*30):diffuse(ColorLightTone(color("#FFFFFF"))):rotationy(-85):customtexturerect(0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96):blend(Blend.Add) end,
			OnCommand=function(s) s:diffusealpha(0.4):texcoordvelocity(0.35,-0.02):effectperiod(4) end,
		};
		Def.Sprite{
			Texture="decoration01",
			InitCommand=function(s) s:x(330):zoomto(SCREEN_WIDTH*30,SCREEN_HEIGHT*30):diffuse(ColorLightTone(color("#FFFFFF"))):rotationy(85):customtexturerect(0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96):blend(Blend.Add) end,
			OnCommand=function(s) s:diffusealpha(0.4):texcoordvelocity(-0.35,-0.02):effectperiod(4) end,
		};
	};
	Def.ActorFrame{
		InitCommand=function(s) s:Center() end,
		Def.Model{
			Materials = "BoxBody.txt";
    		Meshes = "BoxBody.txt";
    		Bones = "BoxBody.txt";
			InitCommand=function(s) s:zbuffer(true):z(-1000):zoom(40):rotationy(75):diffusealpha(0.5):spin():effectmagnitude(35,10,20):blend(Blend.Add) end,
		};
		Def.Model{
			Materials = "BoxBody.txt";
    		Meshes = "BoxBody.txt";
    		Bones = "BoxBody.txt";
			InitCommand=function(s) s:zbuffer(true):z(-1000):zoom(50):rotationy(75):diffuse(ColorLightTone(color("#FFFFFF"))):spin():effectmagnitude(55,30,10):blend(Blend.Add) end,
		};
		Def.Model{
			Materials = "BoxBody.txt";
    		Meshes = "BoxBody.txt";
    		Bones = "BoxBody.txt";
			InitCommand=function(s) s:zbuffer(true):z(-1000):zoom(70):rotationy(75):diffuse(ColorLightTone(color("#FFFFFF"))):spin():effectmagnitude(18,75,75):blend(Blend.Add) end,
		};
		Def.Sprite{
			Texture="decoration02",
			InitCommand=function(s) s:blend(Blend.Add):diffusealpha(0):zoom(0):queuecommand("Animate") end,
			AnimateCommand=function(s) s:x(0):diffusealpha(0):sleep(0):zoom(0):diffusealpha(0):linear(1):zoom(1):diffusealpha(0.5):linear(1.7):x(-900):diffusealpha(0):sleep(4):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="decoration02",
			InitCommand=function(s) s:blend(Blend.Add):rotationz(45):diffusealpha(0):zoom(0):sleep(0.4):queuecommand("Animate") end,
			AnimateCommand=function(s) s:xy(0,0):diffusealpha(0):sleep(0):zoom(0):diffusealpha(0):linear(1):zoom(1):diffusealpha(0.5):linear(1.7):xy(-450,-450):diffusealpha(0):sleep(4):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="decoration02",
			InitCommand=function(s) s:blend(Blend.Add):rotationz(90):diffusealpha(0):zoom(0):sleep(0.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:y(0):diffusealpha(0):sleep(0):zoom(0):diffusealpha(0):linear(1):zoom(1):diffusealpha(0.5):linear(1.7):y(-900):diffusealpha(0):sleep(4):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="decoration02",
			InitCommand=function(s) s:blend(Blend.Add):rotationz(136):diffusealpha(0):zoom(0):sleep(1.2):queuecommand("Animate") end,
			AnimateCommand=function(s) s:xy(0,0):diffusealpha(0):sleep(0):zoom(0):diffusealpha(0):linear(1):zoom(1):diffusealpha(0.5):linear(1.7):xy(450,450):diffusealpha(0):sleep(4):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="decoration02",
			InitCommand=function(s) s:blend(Blend.Add):rotationz(180):diffusealpha(0):zoom(0):sleep(1.6):queuecommand("Animate") end,
			AnimateCommand=function(s) s:x(0):diffusealpha(0):sleep(0):zoom(0):diffusealpha(0):linear(1):zoom(1):diffusealpha(0.5):linear(1.7):x(900):diffusealpha(0):sleep(4):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="decoration02",
			InitCommand=function(s) s:blend(Blend.Add):rotationz(225):diffusealpha(0):zoom(0):sleep(2):queuecommand("Animate") end,
			AnimateCommand=function(s) s:xy(0,0):diffusealpha(0):sleep(0):zoom(0):diffusealpha(0):linear(1):zoom(1):diffusealpha(0.5):linear(1.7):xy(450,450):diffusealpha(0):sleep(4):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="decoration02",
			InitCommand=function(s) s:blend(Blend.Add):rotationz(270):diffusealpha(0):zoom(0):sleep(2.4):queuecommand("Animate") end,
			AnimateCommand=function(s) s:y(0):diffusealpha(0):sleep(0):zoom(0):diffusealpha(0):linear(1):zoom(1):diffusealpha(0.5):linear(1.7):y(900):diffusealpha(0):sleep(4):queuecommand("Animate") end,
		};
		Def.Sprite{
			Texture="decoration02",
			InitCommand=function(s) s:blend(Blend.Add):rotationz(315):diffusealpha(0):zoom(0):sleep(2.8):queuecommand("Animate") end,
			AnimateCommand=function(s) s:xy(0,0):diffusealpha(0):sleep(0):zoom(0):diffusealpha(0):linear(1):zoom(1):diffusealpha(0.5):linear(1.7):xy(-450,450):diffusealpha(0):sleep(4):queuecommand("Animate") end,
		};
	};
};

return t;
