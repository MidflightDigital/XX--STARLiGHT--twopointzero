-- Stage Number, used for Nonstop, Oni, and Endless modes
local Player = ...
if not Player then error("ScreenGameplay StageNumber requires a Player") end

return LoadFont("BPMDisplay bpm")..{
	BeginCommand=function(s) s:playcommand("Set") end,
	SetCommand=function(self)
		local curStageStats = STATSMAN:GetCurStageStats()
		local pss = curStageStats:GetPlayerStageStats(Player)
		self:settext(pss:GetSongsPlayed())
	end;
	ChangeCourseSongInMessageCommand=function(s) s:playcommand("Set") end,
	CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
};