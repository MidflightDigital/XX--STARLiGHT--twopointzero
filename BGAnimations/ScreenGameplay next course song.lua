local function BeginShutterDelay()
	local song = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntry(GAMESTATE:GetLoadingCourseSongIndex()-1):GetSong()
	local td = song:GetTimingData()
	local bpm = round(td:GetBPMAtBeat(song:GetLastBeat()),3)
	local m = 1
	
	if bpm >= 60 and bpm < 120 then
		m = 0.75
	elseif bpm < 60 then
		m = 0.5
	else
		--- 240 bpm and above
		for i=1, 3 do
			if bpm >= 240*(3-(i-1)) then
				m = 2*(3-(i-1))
				break
			end
		end
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