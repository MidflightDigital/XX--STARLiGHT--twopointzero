--[[SOUND:DimMusic(1,math.huge)
local t = LoadFallbackB();
t[#t+1] = StandardDecorationFromFileOptional("Header","Header");
-- other items (balloons, etc.)

return t]]

return Def.Actor{
    OnCommand=function(s) SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen") end
};
