local function BeginShutterDelay()
	local song = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntry(GAMESTATE:GetLoadingCourseSongIndex()-1):GetSong()
	
	local lastBeat = song:GetLastBeat()
	local td = song:GetTimingData()
	local lastBeat = round(td:GetBeatFromElapsedTime(GetSong():GetStepsSeconds(),3))
	local bpm = round(td:GetBPMAtBeat(lastBeat),3)
	local m = 1
	
	if bpm < 60 then
		m = 0.5
	elseif bpm >= 240 then
		m = 2
	elseif bpm >= 480 then
		m = 4
	elseif bpm >= 960 then
		m = 8
	end
	
	local timeSigs = split('=', td:GetTimeSignatures()[1])
	local n = timeSigs[2]
	local d = timeSigs[3]
	local dif = 60/bpm*8*m*n/d
	
	if GAMESTATE:GetSongBeat() < song:GetLastBeat()-2 then
		dif = 0.001
	end
	
	return dif
end

local t = Def.ActorFrame {};

t[#t+1] = Def.Actor {
	ChangeCourseSongInMessageCommand=function(self)
		self:sleep(BeginShutterDelay()):queuecommand('Shutter')
	end,
	ShutterCommand=function(self)
		local delay = THEME:GetMetric('ScreenGameplay', 'NextCourseSongDelay')
		MESSAGEMAN:Broadcast('NextCourseSong')
		self:sleep(delay)
	end,
};

return t