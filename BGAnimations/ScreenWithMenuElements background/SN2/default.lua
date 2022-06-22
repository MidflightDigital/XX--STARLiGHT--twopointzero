local screen = Var 'LoadingScreen'

local t = Def.ActorFrame {};

local p = {
	red		= color('1,0,0,0.812'),
	green	= color('0,1,0,0.812'),
	blue	= color('0,0,1,0.812'),
	yellow	= color('1,1,0,0.812'),
	pink	= color('1,0,1,0.812'),
	cyan	= color('0,1,1,0.812')
}

local colorPatterns = {
	--first pattern block: YRPBCG with different start indices
	{[0]=p.yellow, p.red, p.pink, p.blue, p.cyan, p.green},
	--second pattern block: GCBPRY with different start indices
	{[0]=p.pink, p.red, p.yellow, p.green, p.cyan, p.blue}
}

local curPattern = 1
local curPatternIdx = 0

t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:fov(130) end,
	
	LoadActor( 'BG' ) .. {
		InitCommand=cmd(FullScreen),
		OnCommand=function(s)
			local seed = math.random(1,13)
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
				s:diffuse(colorPatterns[curPattern][curPatternIdx]):queuecommand('Animate')
			else
				s:rainbow():effectperiod(120)
			end;
		end,
		AnimateCommand = function(s)
			--bump the current color to the next color in the pattern
			curPatternIdx = (curPatternIdx + 1) % #(colorPatterns[curPattern])
			s:linear(20):diffuse(colorPatterns[curPattern][curPatternIdx]):queuecommand('Animate')
		end,
		CourseBreakTimeMessageCommand=function(s) s:finishtweening():playcommand('On') end,
		NextCourseSongMessageCommand=function(s)
			if not IsARankingCourse() then
				s:finishtweening():playcommand('On')
			end
		end,
		OffCommand=function(s)
			if screen == 'ScreenGameplay' then
				s:finishtweening():playcommand('On')
			end
		end,
	},
	Def.ActorFrame {
		InitCommand=cmd(Center;spin;effectmagnitude,0,0,-4),
		
		LoadActor( 'line' ) .. {
			InitCommand=cmd(x,-550;zoomto,SCREEN_WIDTH*3,SCREEN_HEIGHT*10;rotationy,-80;customtexturerect,0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96),
			OnCommand=cmd(diffusealpha,0.4;texcoordvelocity,1.5,-0.02;effectperiod,4;blend,'BlendMode_Add'),
			--bob;effectmagnitude,50,0,35;
		},
		LoadActor( 'line' ) .. {
			InitCommand=cmd(x,550;y,0;zoomto,SCREEN_WIDTH*3,SCREEN_HEIGHT*10;diffuse,ColorLightTone(color('#FFFFFF'));rotationy,80;customtexturerect,0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96),
			OnCommand=cmd(diffusealpha,0.4;texcoordvelocity,-1.5,-0.02;effectperiod,4;blend,'BlendMode_Add'),
			-- bob;effectmagnitude,50,0,35;
		},
		LoadActor( 'decoration01' ) .. {
			InitCommand=cmd(x,-330;zoomto,SCREEN_WIDTH*30,SCREEN_HEIGHT*30;diffuse,ColorLightTone(color('#FFFFFF'));rotationy,-85;customtexturerect,0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96),
			OnCommand=cmd(diffusealpha,0.4;texcoordvelocity,0.35,-0.02;effectperiod,4;blend,'BlendMode_Add'),
		},
		LoadActor( 'decoration01' ) .. {
			InitCommand=cmd(x,330;zoomto,SCREEN_WIDTH*30,SCREEN_HEIGHT*30;diffuse,ColorLightTone(color('#FFFFFF'));rotationy,85;customtexturerect,0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96),
			OnCommand=cmd(diffusealpha,0.4;texcoordvelocity,-0.35,-0.02;effectperiod,4;blend,'BlendMode_Add'),
			--bob;effectmagnitude,50,0,35;
		}
	},
	LoadActor( 'BoxBody' ) .. {
		InitCommand=cmd(zbuffer,true;Center;z,-1000;zoom,40;rotationy,75;rotationx,0;diffusealpha,0.5;spin;effectmagnitude,35,10,20;blend,'BlendMode_Add')
	},
	LoadActor( 'BoxBody' ) .. {
		InitCommand=cmd(zbuffer,true;Center;z,-1000;Center;zoom,50;rotationy,75;rotationx,0;diffuse,ColorLightTone(color('#FFFFFF'));spin;effectmagnitude,55,30,10;blend,'BlendMode_Add')
	},
	LoadActor( 'BoxBody' ) .. {
		InitCommand=cmd(zbuffer,true;Center;z,-1000;Center;zoom,70;rotationy,75;rotationx,0;diffuse,ColorLightTone(color('#FFFFFF'));spin;effectmagnitude,18,75,75;blend,'BlendMode_Add')
	},
	Def.ActorFrame {
		CourseBreakTimeMessageCommand=function(s) s:finishtweening():queuecommand('On') end,
		NextCourseSongMessageCommand=function(s)
			if not IsARankingCourse() then
				s:finishtweening():queuecommand('On')
			end
		end,
		OffCommand=function(s)
			if screen == 'ScreenGameplay' then
				s:finishtweening():queuecommand('On')
			end
		end,
		
		LoadActor( 'decoration02' ) .. {
			InitCommand=cmd(Center),
			OnCommand=cmd(diffusealpha,0;zoom,0;playcommand,'Animate'),
			AnimateCommand=cmd(diffusealpha,0;Center;sleep,0;zoom,0;diffusealpha,0;linear,1;zoom,1;blend,'BlendMode_Add';diffusealpha,0.5;linear,1.7;zoom,1;x,SCREEN_CENTER_X-900;y,SCREEN_CENTER_Y;diffusealpha,0;sleep,4;queuecommand,'Animate')
		},
		LoadActor( 'decoration02' ) .. {
			InitCommand=cmd(Center;rotationz,45),
			OnCommand=cmd(diffusealpha,0;zoom,0;sleep,0.4;playcommand,'Animate'),
			AnimateCommand=cmd(diffusealpha,0;Center;zoom,0;diffusealpha,0;linear,1;zoom,1;blend,'BlendMode_Add';diffusealpha,0.5;linear,1.7;zoom,1;x,SCREEN_CENTER_X-450;y,SCREEN_CENTER_Y-450;diffusealpha,0;sleep,4;queuecommand,'Animate'),
		},
		LoadActor( 'decoration02' ) .. {
			InitCommand=cmd(Center;rotationz,90),
			OnCommand=cmd(diffusealpha,0;zoom,0;sleep,0.8;playcommand,'Animate'),
			AnimateCommand=cmd(diffusealpha,0;Center;zoom,0;diffusealpha,0;linear,1;zoom,1;blend,'BlendMode_Add';diffusealpha,0.5;linear,1.7;zoom,1;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-900;diffusealpha,0;sleep,4;queuecommand,'Animate'),
		},
		LoadActor( 'decoration02' ) .. {
			InitCommand=cmd(Center;rotationz,135),
			OnCommand=cmd(diffusealpha,0;zoom,0;sleep,1.2;playcommand,'Animate'),
			AnimateCommand=cmd(diffusealpha,0;Center;zoom,0;diffusealpha,0;linear,1;zoom,1;blend,'BlendMode_Add';diffusealpha,0.5;linear,1.7;zoom,1;x,SCREEN_CENTER_X+450;y,SCREEN_CENTER_Y-450;diffusealpha,0;sleep,4;queuecommand,'Animate'),
		},
		LoadActor( 'decoration02' ) .. {
			InitCommand=cmd(Center;rotationz,180),
			OnCommand=cmd(diffusealpha,0;zoom,0;sleep,1.6;playcommand,'Animate'),
			AnimateCommand=cmd(diffusealpha,0;Center;zoom,0;diffusealpha,0;linear,1;zoom,1;blend,'BlendMode_Add';diffusealpha,0.5;linear,1.7;zoom,1;x,SCREEN_CENTER_X+900;y,SCREEN_CENTER_Y;diffusealpha,0;sleep,4;queuecommand,'Animate'),
		},
		LoadActor( 'decoration02' ) .. {
			InitCommand=cmd(Center;rotationz,225),
			OnCommand=cmd(diffusealpha,0;zoom,0;sleep,2.0;playcommand,'Animate'),
			AnimateCommand=cmd(diffusealpha,0;Center;zoom,0;diffusealpha,0;linear,1;zoom,1;blend,'BlendMode_Add';diffusealpha,0.5;linear,1.7;zoom,1;x,SCREEN_CENTER_X+450;y,SCREEN_CENTER_Y+450;diffusealpha,0;sleep,4;queuecommand,'Animate'),
		},
		LoadActor( 'decoration02' ) .. {
			InitCommand=cmd(Center;rotationz,270),
			OnCommand=cmd(diffusealpha,0;zoom,0;sleep,2.4;playcommand,'Animate'),
			AnimateCommand=cmd(diffusealpha,0;Center;zoom,0;diffusealpha,0;linear,1;zoom,1;blend,'BlendMode_Add';diffusealpha,0.5;linear,1.7;zoom,1;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+900;diffusealpha,0;sleep,4;queuecommand,'Animate'),
		},
		LoadActor( 'decoration02' ) .. {
			InitCommand=cmd(Center;rotationz,315),
			OnCommand=cmd(diffusealpha,0;zoom,0;sleep,2.8;playcommand,'Animate'),
			AnimateCommand=cmd(diffusealpha,0;Center;zoom,0;diffusealpha,0;linear,1;zoom,1;blend,'BlendMode_Add';diffusealpha,0.5;linear,1.7;zoom,1;x,SCREEN_CENTER_X-450;y,SCREEN_CENTER_Y+450;diffusealpha,0;sleep,4;queuecommand,'Animate'),
		},
	},
};

return t