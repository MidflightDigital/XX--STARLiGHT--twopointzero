local songoptions = GAMESTATE:GetSongOptionsString();
local ratemod = string.match(songoptions, "%d.%d");
if ratemod then
	ratemod = tonumber(ratemod);
else
	ratemod = 1.0
end


local function UpdateSingleBPM(self)
	local bpmDisplay = self:GetChild("BPMDisplay")
	local pn = GAMESTATE:GetMasterPlayerNumber()
	local pState = GAMESTATE:GetPlayerState(pn);
	local songPosition = pState:GetSongPosition()
	local bpm = songPosition:GetCurBPS() * 60 * ratemod
	bpmDisplay:settext( round(bpm) )
end

local t = Def.ActorFrame{};

local displaySingle = Def.ActorFrame{
	OnCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if GAMESTATE:IsExtraStage() or GAMESTATE:IsExtraStage2() then
			(THEME:GetMetric("BPMDisplay","SetExtraCommand"))(self)
		elseif song:IsDisplayBpmRandom() then
			(THEME:GetMetric("BPMDisplay","SetRandomCommand"))(self)
		else
			local bpms = song:GetDisplayBpms()
			if bpms[1]==bpms[2] then
				(THEME:GetMetric("BPMDisplay","SetNormalCommand"))(self)
			else
				(THEME:GetMetric("BPMDisplay","SetChangeCommand"))(self)
			end
		end
	end;
	Def.BitmapText{
		Font="BPMDisplay bpm",
		Name="BPMDisplay";
		InitCommand=function(s) s:x(60):halign(1):zoomx(1.3):zoomy(1.1)  end,
	};
	Def.BitmapText{
		Font="BPMDisplay bpm",
		Name="BPMLabel";
		Text="BPM",
		InitCommand=function(s) s:x(-90):halign(0):diffuse(Color.Yellow):zoomx(1.3):zoomy(1.1) end,
	};
};

displaySingle.InitCommand=function(s) s:SetUpdateFunction(UpdateSingleBPM) end

-- in CourseMode, both players should always be playing the same charts, right?
t[#t+1] = displaySingle

return t