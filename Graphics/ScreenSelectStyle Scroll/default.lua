-- I got this idea for using a single sprite instead of PerChoiceScrollElement
-- from k//eternal's PROJEKTXV theme.
--
-- The "GameCommand" var is defined in ScreenSelectMaster.cpp:
--   LuaThreadVariable var("GameCommand", LuaReference::Create(&mc));
local style = Var("GameCommand"):GetName()
local gc = Var("GameCommand");

local t = Def.ActorFrame{
	LoadActor(style)..{
		OffCommand=function(self, param)
			self:smooth(0.1):zoom(0):diffusealpha(0)
		end;
	}
};

return t
