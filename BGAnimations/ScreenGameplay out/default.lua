-- normal and rave are handled in normal/default.lua
-- extra stages are in extra1 and extra2.

local List = {
	"Tohoku EVOLVED",
	"COVID"
};

local StartDelay = 3
local EndDelay;
local silent = false

if GAMESTATE:GetCurrentSong() then
	silent = has_value(List,GAMESTATE:GetCurrentSong():GetDisplayMainTitle())
end

if silent then
	EndDelay = 6
else
	EndDelay = 4
end

return Def.ActorFrame{
	Def.Sound{
		File="cheer",
		StartTransitioningCommand=function(s) s:sleep(StartDelay):queuecommand("Play") end,
		PlayCommand=function(s)
			if silent then return else return s:play() end
		end
	};
	Def.Sound{
		File="swoosh",
		StartTransitioningCommand=function(s) s:sleep(StartDelay):queuecommand("Play") end,
		PlayCommand=function(s)
			if silent then return else return s:play() end
		end
	};
	loadfile(THEME:GetPathB("ScreenWithMenuElements","background"))()..{
		StartTransitioningCommand=function(s)
			s:diffusealpha(0):sleep(3):linear(0.2):diffusealpha(1):sleep(EndDelay):queuecommand("Finish")
		end,
		FinishCommand=function(s) s:finishtweening() end,
	};
	loadfile(THEME:GetPathB("","_StageDoors"))()..{
		InitCommand=function(s) s:diffusealpha(0) end,
		OnCommand=function(s)
			s:queuecommand("SetOff"):diffusealpha(0):sleep(3.2):diffusealpha(1):queuecommand("AnOn"):sleep(EndDelay):queuecommand("AnOff")
		end
	};
	Def.Sprite{
		Texture="cleared",
		InitCommand=function(s) s:Center()
			if not GAMESTATE:IsCourseMode() then
				if silent then
					s:Load(THEME:GetPathB("ScreenGameplay","out/PRAY FOR ALL"))
				end
			end
		end,
		OnCommand=function(s)
			if has_value(List,GAMESTATE:GetCurrentSong():GetDisplayMainTitle()) then
				s:diffusealpha(0):zoomy(0):zoomx(4):sleep(3):linear(0.198):diffusealpha(1):zoomy(1):zoomx(1):sleep(5):linear(0.132):zoomy(0):zoomx(4):diffusealpha(0)
			else
				s:diffusealpha(0):zoomy(0):zoomx(4):sleep(3):linear(0.198):diffusealpha(1):zoomy(1):zoomx(1):sleep(2.604):linear(0.132):zoomy(0):zoomx(4):diffusealpha(0)
			end
		end
	};
};
