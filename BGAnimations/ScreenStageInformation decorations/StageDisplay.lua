local sStage = GAMESTATE:GetCurrentStage();
local tRemap = {
	Stage_1st		= 1,
	Stage_2nd		= 2,
	Stage_3rd		= 3,
	Stage_4th		= 4,
	Stage_5th		= 5,
	Stage_6th		= 6,
};

local Stage = Def.ActorFrame{
	Def.Sprite{
		OnCommand=function(s)
			if getenv("FixStage") == 1 then
				s:Load(THEME:GetPathG("", "_stages/" .. THEME:GetString("CustStageSt",CustStageCheck())..".png") );
			else
				if GAMESTATE:IsCourseMode() then
					if GAMESTATE:GetPlayMode() == 'PlayMode_Oni' then
						s:Load(THEME:GetPathG("", "_stages/oni.png") );
					elseif GAMESTATE:GetPlayMode() == 'PlayMode_Nonstop' then
						s:Load(THEME:GetPathG("", "_stages/nonstop.png") );
					end
				else
					s:Load(THEME:GetPathG("", "_stages/" .. ToEnumShortString(sStage)..".png") );
				end
			end
		end
	}
}

if tRemap[sStage] == PREFSMAN:GetPreference("SongsPerPlay") then
	sStage = "Stage_Final";
else
	sStage = sStage;
end;
----------------------------------------------------------------------------
return Def.ActorFrame {
	InitCommand=function(s) s:Center() end,
	Stage..{
		OnCommand=function(s) s:diffusealpha(0):sleep(0.8):linear(0.05):diffusealpha(1):sleep(2.5):linear(0.2):diffusealpha(0) end,
	};
	LoadActor("star")..{
		OnCommand=function(s) s:diffusealpha(0):sleep(0.8):linear(0.05):diffusealpha(1):linear(0.2):diffusealpha(0) end,
	};
	Def.Quad{
		InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):diffusealpha(0):blend(Blend.Add) end,
		OnCommand=function(s) s:diffusealpha(0):sleep(0.8):linear(0.05):diffusealpha(0.25):linear(0.2):diffusealpha(0) end,
	};
	LoadActor("arrow")..{
		OnCommand=function(s) s:x(1700):sleep(0.6):linear(0.4):x(-1700) end,
	};
	LoadActor("arrow")..{
		InitCommand=function(s) s:zoomx(-1) end,
		OnCommand=function(s) s:x(-1700):sleep(0.6):linear(0.4):x(1700) end,
	};
	--[[Stage..{
		OnCommand=function(s) s:zoom(1.5):addx(SCREEN_WIDTH):linear(0.2):addx(-SCREEN_WIDTH):sleep(1):linear(0.1):zoom(1) end,
	};
	]]--
};
