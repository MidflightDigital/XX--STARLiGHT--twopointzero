return function(Player, Type, Speed)
	local function ObtainSpeedType( pOptions )
		local sptype = 1
        if pOptions:XMod() then sptype = 1 end
        if pOptions:CMod() then sptype = 2 end
        if pOptions:MMod() then sptype = 3 end
        if pOptions:AMod() then sptype = 4 end
        if pOptions:CAMod() then sptype = 5 end

		return sptype
	end

	local function GetSpeed( pOptions, CurType )
		local stype = CurType or ObtainSpeedType(pOptions)

		if stype == 1 then return pOptions:XMod()*100 end
        if stype == 2 then return pOptions:CMod() end
        if stype == 3 then return pOptions:MMod() end
        if stype == 4 then return pOptions:AMod() end
        if stype == 5 then return pOptions:CAMod() end

		return 0
	end

	if not GAMESTATE:GetCurrentSong() then return end
	local function format_bpm(bpm)
		return ("%.0f"):format(bpm)
	end
	local speedtypes = {"X","C","M","A","CA"}
	local song_bpms = GAMESTATE:GetCurrentSong():GetDisplayBpms()

	local PlayerOptions = GAMESTATE:GetPlayerState(Player):GetPlayerOptions("ModsLevel_Preferred")
	local speedType = Type or ObtainSpeedType( PlayerOptions )
	local speedVal = Speed or GetSpeed( PlayerOptions, speedType )
	local isXMod = speedType == 1

	local speed = speedVal * 0.01
	local CurSpeedTxt = ""
	
	-- Set the text label for the music rate converted speed.
	local musicRate = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
	local CSpeedRated = ""

	if not isXMod then
		return speedVal.."BPM", speedtypes[speedType]..""..speedVal
	end
	CurSpeedTxt = string.format("%.2f", speed) .. "x"
	local tmp = ""
	if song_bpms[1] == song_bpms[2] then
		tmp= format_bpm(song_bpms[1] * speed)
		CSpeedRated = format_bpm((song_bpms[1] * speed) * musicRate)
	else
		tmp= format_bpm((song_bpms[1] * speed)) .. " - " .. format_bpm((song_bpms[2] * speed))
		CSpeedRated = format_bpm((song_bpms[1] * speed) * musicRate) .. " - " .. format_bpm((song_bpms[2] * speed) * musicRate)
	end
	return tmp.."BPM", CurSpeedTxt, CSpeedRated.."BPM"
end