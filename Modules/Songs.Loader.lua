-- The Songs loader for custom wheels.
-- Accepts Style.
return function(Style)

	-- All the Compatible Songs Container.
	local AllCompSongs = {}
		
	-- For all Songs.
	for _, CurSong in pairs(SONGMAN:GetAllSongs()) do
	
		-- Temp Difficulty Container.
		local DiffCon = {}
			
		-- Set the first value to be Current Looped Song, In the Temp Current Song Container.
		local CurSongCon = {CurSong}		
		
		-- For all the steps in Current looped Song.
		for i, CurStep in ipairs(CurSong:GetAllSteps()) do
			-- Find if Steps supports current selected Style.

			if string.find(CurStep:GetStepsType():lower(), Style) then

				-- Check the type of Steps 
				local Type = 1

				-- Check if its HalfDoubles.
				if string.find(CurStep:GetStepsType():lower(), "half") then
					Type = 2
				--Check if its Doubles.
				elseif string.find(CurStep:GetStepsType():lower(), "double") then
					Type = 3
				end
				
				-- Check the step level.
				local Meter = tonumber(CurStep:GetMeter())
				-- If the step level is under 10, Add a 0 in front.
				if tonumber(CurStep:GetMeter()) < 10 then
					-- Add the 0.
					Meter = "0"..CurStep:GetMeter()
				end
				-- Add the Difficulty to the Temp Difficulty Contrainer.
				DiffCon[Type.."_"..tonumber(TF_WHEEL.DiffTab[CurStep:GetDifficulty()]).."_"..Meter] = CurStep	
			end
		end
		
		-- We want to sort the Difficulties, So we gra the Keys and Sort based on them.
		local Keys = {}
		for k in pairs(DiffCon) do table.insert(Keys, k) end
		table.sort(Keys)
		
		-- Now we put the Difficulies inside the Temp Current Song Contrainer.
		for _, k in pairs(Keys) do
			if DiffCon[k] then
				CurSongCon[#CurSongCon+1] = DiffCon[k]
			end
		end
		
		-- If a Difficulty exist for song using Style, Add it to All Compatible Songs.
		if CurSongCon[2] then				
			AllCompSongs[#AllCompSongs+1] = CurSongCon
		end
	end	

	local function compare(a,b)
        return a[1]:GetDisplayMainTitle() < b[1]:GetDisplayMainTitle()
    end
	
	table.sort(AllCompSongs, compare)

	-- Return all the Songs, That support Current Style.
	return AllCompSongs
end