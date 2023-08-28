-- Generates a timer with the current time and total possible time.
local total = 0
local ReportViaTime = function(timeammount)
	if timeammount >= 3600 then
		return SecondsToHHMMSS(timeammount)
	end
	return SecondsToMMSS(timeammount)
end
local t = Def.BitmapText{
	Font="_Bold",
	OnCommand=function(self)
		-- Before anything, locate the total time of the song.
		total = GAMESTATE:GetCurrentSong():GetLastSecond()
		self:playcommand("UpdateTime")
	end,
	UpdateTimeCommand=function(self)
		local current = math.ceil(GAMESTATE:GetSongPosition():GetMusicSeconds())

		-- Current can have a negative time, which is caused by the stepfile having a lean-in time,
		-- for example: starting the song on the very first note, which makes the game having to make invisible
		-- time before actually starting the song audio. For that case, we need to clamp the value of current
		-- so it doesn't go through this.
		if current < 0 then current = 0 end

		self:settext( string.format( "%s/%s (-%s)", ReportViaTime( current ), ReportViaTime(total), ReportViaTime( total-current )  ) )
		self:sleep(0.2):queuecommand("UpdateTime")
	end
}
return t