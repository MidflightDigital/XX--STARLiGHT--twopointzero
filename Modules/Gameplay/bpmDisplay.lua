-- Store the ammount of players that are available, so there's no need to call it several times.
local availablePlayers = GAMESTATE:GetEnabledPlayers()

-- The main manager for handling the information about the Rate Display and BPM counters.
local t = Def.ActorFrame{
	DrawGlyphsCommand=function(self)
		-- MusicRate stuff
		local MusicRate = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
		if MusicRate > 1 then
			self:GetChild("RateModDisplay"):settext( ("%.2fx rate"):format(MusicRate) )
			for _, pn in ipairs( availablePlayers ) do
				self:GetChild(pn):y( -7 )
			end
		end
	end,
	InitCommand=function(self) self:playcommand("DrawGlyphs") end,
	-- Add the RateMod display BitmapText which we'll control eventually.
	Def.BitmapText { Font="_Bold", Name="RateModDisplay", InitCommand=function(self) self:zoom(0.7):y(18) end }
}

-- Check if all players are playing the same steps
local isDifferentTiming = false
-- The iterator for checking the current stable timing
local CurTiming = nil

-- in CourseMode, both players should always be playing the same charts, right?
-- If not, then let's check if each playing is on a chart with a unique timing set.
if #availablePlayers ~= 1 and not GAMESTATE:IsCourseMode() then
	for _, pn in ipairs( availablePlayers ) do
		local Steps = GAMESTATE:GetCurrentSteps(pn)
		-- Initially, the value of CurTiming is nil, this is on purpose to ensure
		-- it can initialize properly without having to perform a hacky situation of guessing
		-- which is the first available player.
		if not CurTiming then CurTiming = Steps:GetTimingData() end
		
		if Steps:GetTimingData() ~= CurTiming then
			-- Ok, now we know there's different timing data between the players, so we need to draw more.
			-- No need to perform the check again, so a break is set to stop the loop.
			isDifferentTiming = true
			break
		end
	end
end

-- Create the BitmapText actors that will show the BPM for each player.
for i, pn in ipairs( availablePlayers ) do
	t[#t+1] = Def.SongBPMDisplayModern {
		Font="_Plex Numbers 40px",
		Name=pn,
		InitCommand=function(self)
			if isDifferentTiming then
				self:x( scale( i, 1, #PlayerNumber, -40, 40 ) ):zoom(0.8)
				:diffuse(ColorLightTone(PlayerColor(pn)))
			end
		end
	}
end

return t