local function radarSet(self)
	local selection = nil
	if GAMESTATE:IsCourseMode() then
		if GAMESTATE:GetCurrentCourse() then
			selection = GAMESTATE:GetCurrentTrail(PLAYER_2)
		end
	else
		if GAMESTATE:GetCurrentSong() then
			selection = GAMESTATE:GetCurrentSteps(PLAYER_2)
		end
	end
	if selection then
		self:SetFromRadarValues(PLAYER_2, selection:GetRadarValues(PLAYER_2))
	else
		self:SetEmpty(PLAYER_2)
	end
end

local t = Def.ActorFrame {
	CurrentSongChangedMessageCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song then
-- 			self:setaux(0)
			self:finishtweening()
			self:queuecommand("TweenOn")
		elseif not song and self:GetZoomX() == 1 then
-- 			self:setaux(1)
			self:finishtweening()
			self:queuecommand("TweenOff")
		end
	end,
	Name="Radar",
	InitCommand=function(s) s:Center() end,

	Def.GrooveRadar {
		OnCommand=function(s) s:zoom(0):sleep(0.583):decelerate(0.150):zoom(1) end,
		OffCommand=function(s) s:sleep(0.00):decelerate(0.167):zoom(0) end,
		CurrentSongChangedMessageCommand=radarSet,
		CurrentStepsP2ChangedMessageCommand=radarSet,
		CurrentTrailP2ChangedMessageCommand=radarSet,
	},
}

return t