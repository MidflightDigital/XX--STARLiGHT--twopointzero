-- BeforeLoadingNextCourseSongMessageCommand
-- StartCommand
-- ChangeCourseSongInMessageCommand
-- ChangeCourseSongOutMessageCommand
-- FinishCommand

local jk = LoadModule"Jacket.lua"


local sStage = GAMESTATE:GetCurrentStage();
local tRemap = {
	Stage_1st		= 1,
	Stage_2nd		= 2,
	Stage_3rd		= 3,
	Stage_4th		= 4,
	Stage_5th		= 5,
	Stage_6th		= 6,
};

if tRemap[sStage] == PREFSMAN:GetPreference("SongsPerPlay") then
	sStage = "Stage_Final";
else
	sStage = sStage;
end;

local simage = Def.Sprite{
	InitCommand=function(s)
		if GAMESTATE:GetPlayMode() == 'PlayMode_Oni' then
			s:Load(THEME:GetPathG("", "_stages/oni.png") );
		elseif GAMESTATE:GetPlayMode() == 'PlayMode_Nonstop' then
			s:Load(THEME:GetPathG("", "_stages/nonstop.png") );
		end
	end
};

return Def.ActorFrame {
	loadfile(THEME:GetPathB("","ScreenWithMenuElements background"))()..{
		InitCommand=function(s) s:diffusealpha(0) end,
		ChangeCourseSongInMessageCommand=function(s) s:linear(0.2):diffusealpha(1) end,
		FinishCommand=function(s) s:sleep(1):linear(0.2):diffusealpha(0):queuecommand("Tween") end,
		TweenCommand=function(s) s:finishtweening() end,
	};
	loadfile(THEME:GetPathB("","_StageDoors"))()..{
		ChangeCourseSongInMessageCommand=function(s) s:playcommand("AnOn") end,
		FinishCommand=function(s) s:sleep(1):queuecommand("AnOff") end,
	};
	Def.Sound{
		File=GetMenuMusicPath "stage",
		ChangeCourseSongInMessageCommand=function(s) s:queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
	Def.ActorFrame{
		InitCommand=function(s) s:Center():diffusealpha(0):zoom(4) end,
		ChangeCourseSongInMessageCommand=function(s)
			s:sleep(2.5):linear(0.2):diffusealpha(1):zoom(0.9):linear(0.1):zoom(1)
		end,
		FinishCommand=function(s) s:sleep(2):accelerate(0.1):zoom(5):diffusealpha(0) end,
		Def.Quad{
			InitCommand=function(s) s:diffuse(Color.Black)
				s:setsize(628,628)
			end,
		};
		Def.Sprite{
			BeforeLoadingNextCourseSongMessageCommand=function(self)
				local song = SCREENMAN:GetTopScreen():GetNextCourseSong()
				self:Load(jk.GetSongGraphicPath(song)):setsize(620,620)
			end;
		};
	};
	Def.ActorFrame{
		InitCommand=function(s) s:Center() end,
		simage..{
			ChangeCourseSongInMessageCommand=function(s) s:diffusealpha(0):sleep(0.4):linear(0.05):diffusealpha(1):sleep(2.5):linear(0.2):diffusealpha(0) end,
		};
		Def.Sprite{
			Texture="ScreenStageInformation in/star",
			ChangeCourseSongInMessageCommand=function(s) s:diffusealpha(0):sleep(0.4):linear(0.05):diffusealpha(1):linear(0.2):diffusealpha(0) end,
		};
		Def.Quad{
			InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):diffusealpha(0):blend(Blend.Add) end,
			ChangeCourseSongInMessageCommand=function(s) s:diffusealpha(0):sleep(0.4):linear(0.05):diffusealpha(0.25):linear(0.2):diffusealpha(0) end,
		};
		Def.Sprite{
			Texture="ScreenStageInformation in/arrow",
			ChangeCourseSongInMessageCommand=function(s) s:x(1700):sleep(0.2):linear(0.4):x(-1700) end,
		};
		Def.Sprite{
			Texture="ScreenStageInformation in/arrow",
			InitCommand=function(s) s:zoomx(-1) end,
			ChangeCourseSongInMessageCommand=function(s) s:x(-1700):sleep(0.2):linear(0.4):x(1700) end,
		};
	};
	-- Ready
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenGameplay","ready/ready"),
		InitCommand=function(s) s:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):diffusealpha(0) end,
		ChangeCourseSongInMessageCommand=function(s) s:diffusealpha(0) end,
		FinishCommand = function(s) s:sleep(2.2):diffusealpha(0):zoomx(4):zoomy(0):accelerate(0.09):zoomx(1):zoomy(1):diffusealpha(1):sleep(1):accelerate(0.132):zoomx(4):zoomy(0):diffusealpha(0) end,
	};
	--go
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenGameplay","go/go"),
		InitCommand=function(s) s:Center():diffusealpha(0) end,
		ChangeCourseSongInMessageCommand=function(s) s:diffusealpha(0) end,
		FinishCommand = function(s) s:sleep(3.5):diffusealpha(0):zoomx(4):zoomy(0):accelerate(0.132):zoomx(1):zoomy(1):diffusealpha(1):sleep(1):accelerate(0.132):zoomx(4):zoomy(0):diffusealpha(0) end,
	};
};
