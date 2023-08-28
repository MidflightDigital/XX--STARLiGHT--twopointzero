--[[
	This module takes care of obtaining the proper grahpic for the judgment for a specific player.
]]
return function(pn)
	local CurrentTiming = LoadModule("Options.ReturnCurrentTiming.lua")()
	local judgeGraphics = LoadModule("Options.SmartJudgments.lua")()
	local judgeNames = LoadModule("Options.SmartJudgments.lua")("Show")
	local CToValue = LoadModule("Options.ChoiceToValue.lua")

	local PrefsManager = LoadModule("Save.PlayerPrefs.lua")
	PrefsManager:Load( CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini" )

	if not THEME:GetMetric("Common","UseAdvancedJudgments") then
		return THEME:GetPathG("Judgment","Normal")
	end

	local DefaultJudgment = THEME:GetMetric("Common","DefaultJudgment")
	if GAMESTATE:IsDemonstration() then
		return judgeGraphics[CToValue(judgeNames,DefaultJudgment)] 
	end
	-- Check if the preference contains an available entry for the current timing mode.
	local valueToUse = DefaultJudgment
	if PrefsManager:Get("JudgmentGraphic"..CurrentTiming.Name,nil) then
		valueToUse = PrefsManager:Get("JudgmentGraphic"..CurrentTiming.Name,nil)
	else
		valueToUse = PrefsManager:Get( "SmartJudgments", DefaultJudgment)
	end

	return judgeGraphics[CToValue(judgeNames,valueToUse)] 
end