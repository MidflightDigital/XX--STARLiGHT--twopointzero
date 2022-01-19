-- Return the main function that contains a list of the groups.
return function(Songs,CurGroup)

	local Groups = {}

	for _,v in ipairs(Songs) do
		local Add = true
		for _,v2 in ipairs(Groups) do
			if v2 == v[1]:GetGroupName() then Add = false break end
		end
		if Add then
			Groups[#Groups+1] = v[1]:GetGroupName()
		end		
	end	

	local function compare(a,b)
        return a < b
    end
	
	table.sort(Groups, compare)
	
	local GroupsAndSongs = {}
	
	for _,v in ipairs(Groups) do
		GroupsAndSongs[#GroupsAndSongs+1] = v
		if v == CurGroup then
			for _,v2 in ipairs(Songs) do
				if v2[1]:GetGroupName() == v then
					GroupsAndSongs[#GroupsAndSongs+1] = v2
				end
			end		
		end
	end

	return GroupsAndSongs
end