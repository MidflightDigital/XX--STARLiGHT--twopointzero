-- This module is responsible for managing the sorting mode for each group and songs alike.
return function(PremadeData,Groups,SongSetContainer,SortTypeGroup,SortTypeSongs)
	local songMatches = 0
	-- Setting: If the chart has a length higher than the allowed, then it will be skipped from the wheel.
	local hideUnjoinableSongs = false

	local function isAbleToJoin(song)
		if GAMESTATE:IsEventMode() then return true end

		if song:GetStageCost() > GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()) then
			return hideUnjoinableSongs
		end
		return true
	end

	local newGroups = Groups
	local GroupsAndSongs = {}

	local Songsorts = {
		["title"] = function( ToSort )
			table.sort( ToSort, function(a,b) return a[1]:GetDisplayFullTitle():lower() < b[1]:GetDisplayFullTitle():lower() end )
			return ToSort
		end,
		["artist"] = function( ToSort )
			table.sort( ToSort, function(a,b) return a[1]:GetDisplayArtist():lower() < b[1]:GetDisplayArtist():lower() end )
			return ToSort
		end,
		["genre"] = function( ToSort )
			table.sort( ToSort, function(a,b) return a[1]:GetGenre():lower() < b[1]:GetGenre():lower() end )
			return ToSort
		end,
		["bpm"] = function( ToSort )
			table.sort( ToSort, function(a,b) return a[1]:GetDisplayBpms()[2] < b[1]:GetDisplayBpms()[2] end )
			return ToSort
		end,
		["length"] = function( ToSort )
			table.sort( ToSort, function(a,b) return a[1]:MusicLengthSeconds() < b[1]:MusicLengthSeconds() end )
			return ToSort
		end
	}

	local function GenerateSongEntriesFromArray( Array, orderArray )
		-- Sort the resulting set alphabetically to then look through the main array.
		table.sort( orderArray, function(a,b) return a:lower() < b:lower() end )
		local result = {}
		-- Now to report it.
		for i,v in ipairs( orderArray ) do
			result[#result+1] = v
			-- We want to generate the items that are present on the current group.
			if CurGroup == v then
				local tempsong = Array[v]
				tempsong = Songsorts[SortTypeSongs](tempsong)
				for q,z in ipairs( tempsong ) do
					if isAbleToJoin(z[1]) then
						result[#result+1] = z
					end
				end
			end
		end

		return result
	end

	local GroupSorts = {
		["group"] = function( ToSort )
			newGroups = ToSort
			table.sort( newGroups, function(a,b) return a:lower() < b:lower() end )

			local results = GenerateSongEntriesFromArray( SongSetContainer, newGroups )

			-- Add the special items on the top of the table
			table.insert( results, 1, "-RANDOM-" )
			table.insert( results, 2, "-PORTAL-" )
			return results
		end,
		["title"] = function( ToSort )
			-- Alphabetical sorting.
			local LetterSet = {}
			local letters = {}
			for i,v in pairs( SongSetContainer ) do
				for q,z in ipairs( v ) do
					-- Check the first letter.
					local ltr = ToLower(z[1]:GetDisplayMainTitle()):sub(1,1)
					-- Check it's type.
					if ltr:match("%W") then
						-- Ok, it's not alphanumerical, so see if it's a number, or it'll go to the other container.
						ltr = tonumber(ltr) and "number" or "other"
					end
					if not LetterSet[ltr] then
						LetterSet[ltr] = {}
						letters[#letters+1] = ltr
					end
					LetterSet[ltr][#LetterSet[ltr]+1] = z
				end
			end

			return GenerateSongEntriesFromArray( LetterSet, letters )
		end,
		["artist"] = function( ToSort )
			-- Alphabetical sorting.
			local LetterSet = {}
			local artistNames = {}
			for i,v in pairs( SongSetContainer ) do
				for q,z in ipairs( v ) do
					-- Check the first letter.
					local title = ToLower(z[1]:GetDisplayArtist()):sub(1,1)
					if not LetterSet[title] then
						LetterSet[title] = {}
						artistNames[#artistNames+1] = title
					end
					LetterSet[title][#LetterSet[title]+1] = z
				end
			end

			return GenerateSongEntriesFromArray( LetterSet, artistNames )
		end,
	}

	if not PremadeData then
		-- Sort the group contents for the songs!
		-- Note: Since group sorting applies to the already generated listing,
		-- anything that isn't group has to be re-processed to include new group kinds.
		GroupsAndSongs = GroupSorts[SortTypeGroup](Groups) 
	else
		GroupsAndSongs = Songsorts[SortTypeSongs](PremadeData)
	end

	return GroupsAndSongs
end