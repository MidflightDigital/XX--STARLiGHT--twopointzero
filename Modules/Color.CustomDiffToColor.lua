return function(self, steps_data, LightTone, BoostFactor)
	if steps_data == nil then
		lua.ReportScriptError("[CustomDiffToColor] Steps Data is nil.")
		return
	end
	local cd = GetCustomDifficulty(steps_data:GetStepsType(), steps_data:GetDifficulty())
	self:diffuse(ColorMidTone(CustomDifficultyToColor(cd))):diffusebottomedge(ColorDarkTone(CustomDifficultyToColor(cd)))
	if LightTone then
		self:diffuse( ColorLightTone( self:GetDiffuse() ) )
	end
	if BoostFactor then
		self:diffuse( BoostColor( self:GetDiffuse(), BoostFactor ) )
	end
end