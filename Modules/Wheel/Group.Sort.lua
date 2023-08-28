-- Return the main function that contains a list of the groups.
return function(Songs,CurGroup,SearchTerm, Sort1, Sort2)

	local SortModeLoader = LoadModule("Wheel/Sort.Modes.lua")

	-- Current output: O( Songs ^ #SearchMethods )
	-- Current output (meter-agnostic): O( Songs ^ #ChartsPerSong )
	-- Current output (pack/Song): O( #pack * pack[song] )
	-- Current output (pack): O( #pack + pack[n] )
	
	-- OPTIMIZATION IDEAS:
	-- [DONE] When using the pack option to search, only perform the search on the closest matches
	-- to the same pack name, and skip over the rest.

	-- [ALMOST DONE] Skip method iteration if the search term is for a very specific thing,
	-- can reduce the ammount of steps exponentially.

	-- Store this in temporary memory for later use.
	if not GAMESTATE:Env()["containerStringSongSet"] then
		local gen = {}
		for _,v in ipairs(Songs) do
			if not gen[v[1]:GetGroupName()] then
				gen[v[1]:GetGroupName()] = {}
			end
			gen[v[1]:GetGroupName()][#gen[v[1]:GetGroupName()]+1] = v
			for i,player in ipairs(GAMESTATE:GetHumanPlayers()) do
				-- NEW: Keep track of each player's favorite songs to be added to a separate group.
				local PlayerProfile = PROFILEMAN:GetProfile(player)
				local PlrGroupPath = "--P"..i.."FAV--"
				if PlayerProfile:SongIsFavorite(v[1]) then
					if not gen[PlrGroupPath] then
						gen[PlrGroupPath] = {}
					end
					gen[PlrGroupPath][#gen[PlrGroupPath]+1] = v
				end
			end
		end
		GAMESTATE:Env()["containerStringSongSet"] = gen
	end
	local containerStringSongSet = GAMESTATE:Env()["containerStringSongSet"]
	local Groups = {}

	for packname,_ in pairs(containerStringSongSet) do
		Groups[#Groups+1] = packname
	end
	
	local GroupsAndSongs = {}

	local searchMatches = 0	
	-- TODO: Add support for multiple-flag search.
	if SearchTerm and SearchTerm ~= "" then
		-- Lower the result for better sets.
		SearchTerm = ToLower(SearchTerm)
		local potentialFlag = nil
		local _, _, key, value = string.find(SearchTerm, "(%a+)%s*:(.+)")
		if key then
			potentialFlag = key
			SearchTerm = value
		end

		-- disable all search states.
		local searchmethods = {
			["artist"] = function(v)
				return string.find(ToLower(v[1]:GetDisplayArtist()),SearchTerm)
			end,
			["title"] = function(v)
				return string.find(ToLower(v[1]:GetDisplayMainTitle()),SearchTerm)
			end,
			["subtitle"] = function(v)
				return string.find(ToLower(v[1]:GetDisplaySubTitle()),SearchTerm)
			end,
			["group"] = function(v)
				return string.find(ToLower(v[1]:GetGroupName()),SearchTerm)
			end,
			["genre"] = function(v)
				return string.find(ToLower(v[1]:GetGenre()),SearchTerm)
			end,
			["bpm"] = function(v)
				return math.floor(v[1]:GetDisplayBpms()[2]) == tonumber(SearchTerm)
			end,
			["meter"] = function(v)
				-- Check if the song has charts with the desired difficulty.
				for i = 2,#v do
					if v[i]:GetMeter() == tonumber(SearchTerm) then
						return true
					end
				end
				return false
			end,
			["description"] = function(v)
				for i = 2,#v do
					if string.find(ToLower(v[i]:GetDescription()), SearchTerm) then
						return true
					end
				end
				return false
			end,
			["stepcharter"] = function(v)
				for i = 2,#v do
					if string.find(ToLower(v[i]:GetAuthorCredit()), SearchTerm) then
						return true
					end
				end
				return false
			end
		}
		local MatchingFlagFound = searchmethods[potentialFlag] and potentialFlag or "title"
		local methodToUse = {}

		local foundAnyState = false
		-- methodToUse[#methodToUse+1] = searchmethods[MatchingFlagFound]
		-- Lookup which states are enabled to search from.
		for k,v in pairs( TF_WHEEL.SearchStates ) do
			if TF_WHEEL.SearchStates[k] then
				methodToUse[k] = searchmethods[k]
				foundAnyState = true
			end
		end

		if not foundAnyState then
			-- Default to title search.
			TF_WHEEL.SearchStates["title"] = true
			methodToUse["title"] = searchmethods["title"]
		end

		local useGeneralSearch = true

		if methodToUse["title"] then
			-- Did the user want to search a song from a specific pack?
			local _, _, pack, title = string.find(SearchTerm, "(.+)/(.+)")
			if pack and title then
				methodToUse["title"] = function(v)
					return string.find(
						ToLower(v[1]:GetGroupName()), ToLower(pack)
					) and string.find(
						ToLower(v[1]:GetDisplayMainTitle()), ToLower(title)
					)
				end

				useGeneralSearch = false

				local pack_matches = {}

				for packName,_ in pairs( containerStringSongSet ) do
					if string.find( ToLower( packName ), pack ) then
						pack_matches[#pack_matches+1] = packName
					end
				end

				-- Given this fetching of songs, search the matches with the string indexed table.
				for _,pack in ipairs( pack_matches ) do
					for _,v2 in ipairs( containerStringSongSet[pack] ) do
						if methodToUse["title"](v2) then
							GroupsAndSongs[#GroupsAndSongs+1] = v2
							searchMatches = searchMatches + 1
						end
					end
				end
			end
		end

		if methodToUse["group"] then
			useGeneralSearch = false

			local pack_matches = {}

			-- Find the packs that match the result...
			for packName,_ in pairs( containerStringSongSet ) do
				if string.find( ToLower( packName ), SearchTerm ) then
					pack_matches[#pack_matches+1] = packName
				end
			end

			-- Now fill them to the result table.
			for _,pack in ipairs( pack_matches ) do
				for _,v2 in ipairs( containerStringSongSet[pack] ) do
					GroupsAndSongs[#GroupsAndSongs+1] = v2
					searchMatches = searchMatches + 1
				end
			end
		end

		-- Special case, if there's a range of bpm, search for that range.
		if MatchingFlagFound == "bpm" or MatchingFlagFound == "meter" then
			-- Fetch low and high numbers to find.
			local _, _, low, high = string.find(SearchTerm, "(%d*)-(%d*)")
			if low and high then
				if MatchingFlagFound == "bpm" then
					methodToUse["bpm"] = function(v)
						return 	math.floor(v[1]:GetDisplayBpms()[1]) >= tonumber(low) and 
								math.floor(v[1]:GetDisplayBpms()[2]) <= tonumber(high)
					end
				end
				if MatchingFlagFound == "meter" then
					methodToUse["meter"] = function(v)
						for i,data in ipairs(v) do
							if data.GetMeter then
								return data:GetMeter() >= tonumber(low) and data:GetMeter() <= tonumber(high)
							end
						end
						return false
					end
				end
			end
		end

		-- So no special search has been requested, anything else will use its method function
		-- instead.
		if useGeneralSearch then
			for _,v2 in ipairs(Songs) do
				for itm,mtd in pairs( methodToUse ) do
					if mtd(v2) then
						GroupsAndSongs[#GroupsAndSongs+1] = v2
						searchMatches = searchMatches + 1
						break
					end
				end
			end
		end

		-- If the result of the search was empty, DONT return, reconstruct the table.
		if #GroupsAndSongs > 0 then
			return SortModeLoader(GroupsAndSongs, Groups, GAMESTATE:Env()["containerStringSongSet"], Sort1 or "group", Sort2 or "title"), searchMatches
		end
	end
	
	local groups = SortModeLoader(nil, Groups, GAMESTATE:Env()["containerStringSongSet"], Sort1 or "group", Sort2 or "title")
	return groups, searchMatches
end
