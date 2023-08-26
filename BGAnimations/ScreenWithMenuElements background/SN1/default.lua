local t = Def.ActorFrame{
	FOV=130;
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
t[#t+1] = Def.ActorFrame{
	--My god you are amazing kenp.
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
	Def.ActorFrame{
		Def.Sprite{
			Texture="_bg",
			InitCommand=function(s) s:clearzbuffer(0):Center():zoom(8):spin():effectmagnitude(0,0,-1.5):diffuse(color("0.75,0.75,0.75,1")) end,
		};
	};
	Def.ActorFrame{
	InitCommand=function(s) s:spin():effectmagnitude(-1.5,2,-1.5):Center():zoom(0.5) end,
		Def.Model{
			Materials="SuperNOVABG.txt",
			Meshes="SuperNOVABG.txt",
			Bones="SuperNOVABG.txt",
			InitCommand=function(s) s:clearzbuffer(0):rotationx(-90):rotationz(-90):diffuse(Alpha(Color.White,0.75)):blend(Blend.Add):zoom(8) end,
		};
		Def.ActorFrame{
			InitCommand=function(s) s:zoom(20):x(SCREEN_WIDTH/2) end,
			Def.Model{
				Materials="SuperNovaBallFog (DoubleFaced).txt",
				Meshes="SuperNovaBallFog (DoubleFaced).txt",
				Bones="SuperNovaBallFog (DoubleFaced).txt",
				InitCommand=function(s) s:diffuse(Alpha(Color.White,0.5)):blend(Blend.Add):spin():effectmagnitude(10,100,10) end,
			};
			Def.Model{
				Materials="SuperNovaFogBall (DoubleFaced).txt",
				Meshes="SuperNovaFogBall (DoubleFaced).txt",
				Bones="SuperNovaFogBall (DoubleFaced).txt",
				InitCommand=function(s) s:diffuse(Alpha(Color.White,0.5)):blend(Blend.Add):zoom(0.9):spin():effectmagnitude(10,100,10) end,
			};
			Def.Model{
				Materials="SuperNovaBallLine (DoubleFaced).txt",
				Meshes="SuperNovaBallLine (DoubleFaced).txt",
				Bones="SuperNovaBallLine (DoubleFaced).txt",
				InitCommand=function(s) s:diffuse(color("0.8,0.8,0.8,1")):blend(Blend.Add):rotationx(-200):rotationz(-90):rotationy(-60):spin():effectmagnitude(100,100,100) end,
			};
			Def.Model{
				Materials="SuperNovaBallLine (DoubleFaced).txt",
				Meshes="SuperNovaBallLine (DoubleFaced).txt",
				Bones="SuperNovaBallLine (DoubleFaced).txt",
				InitCommand=function(s) s:diffuse(color("0.8,0.8,0.8,1")):blend(Blend.Add):rotationx(200):rotationz(90):rotationy(60):spin():effectmagnitude(-100,-100,-100) end,
			};
			Def.Model{
				Materials="SuperNovaBall (DoubleFaced).txt",
				Meshes="SuperNovaBall (DoubleFaced).txt",
				Bones="SuperNovaBall (DoubleFaced).txt",
				InitCommand=function(s) s:diffuse(color("0.6,0.6,0.6,1")):blend(Blend.Add):spin():effectmagnitude(10,100,10) end,
			};
		};
	};
	Def.ActorFrame{
		Def.Model{
			Materials="SuperNOVALine.txt",
			Meshes="SuperNOVALine.txt",
			Bones="SuperNOVALine.txt",
			InitCommand=function(s) s:diffuse(color("0.4,0.4,0.4,1")):blend(Blend.Add):Center():rotationx(-200):rotationz(90):rotationy(60):zoom(12):spin():effectmagnitude(100,100,100) end,
		};
		Def.Model{
			Materials="SuperNOVALine.txt",
			Meshes="SuperNOVALine.txt",
			Bones="SuperNOVALine.txt",
			InitCommand=function(s) s:diffuse(color("0.4,0.4,0.4,1")):blend(Blend.Add):Center():rotationx(200):rotationz(-90):rotationy(60):zoom(12):spin():effectmagnitude(-100,-100,-100) end,
		};
	};
};

return t;
