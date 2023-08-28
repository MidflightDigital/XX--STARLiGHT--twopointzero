return function( steps_data )
	if steps_data == nil then
		error( "Steps data provided is nil.", 2 )
		return
	end

	local DiffName = THEME:GetString("CustomDifficulty",ToEnumShortString(steps_data:GetDifficulty()))
	-- If there is a chart name on the chart, use that.
	if steps_data:GetChartName() ~= "" then
		DiffName = steps_data:GetChartName()
	end

	-- Detecting which label to use for the right side of the detailed stats will be perfomed
	-- in a reversed manner.
	-- Description will be the last resort if none of the following items contain anything.
	local whattouse = steps_data:GetDescription()

	-- If there's an author attach to the steps, that's the best one to use.
	if steps_data:GetAuthorCredit() ~= "" then
		whattouse = steps_data:GetAuthorCredit()
	end		

	-- If the DiffName ends up being the same as the author name, then restore the DiffName.
    if DiffName == whattouse then
        DiffName = THEME:GetString("CustomDifficulty",ToEnumShortString(steps_data:GetDifficulty()))
    end

	return DiffName, whattouse
end