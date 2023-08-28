local DiffTab = { 
	["Difficulty_Beginner"] = 1,
	["Difficulty_Easy"] = 1,
	["Difficulty_Medium"] = 2,
	["Difficulty_Hard"] = 2,
	["Difficulty_Challenge"] = 3,
	["Difficulty_Edit"] = 4
}

return function(Songs,CurGroup)
    local DiffSongs = {}
    for i = 1,4 do
        DiffSongs[i] = {}
    end

    for _,song in pairs(Songs) do

        if CurGroup == "" then
            CurGroup = song[1]:GetGroupName()
        end

        if CurGroup == song[1]:GetGroupName() then
            for _,diffs in pairs(song) do
                if diffs ~= song[1] then
                    local curdiff = DiffTab[diffs:GetDifficulty()]
                    DiffSongs[curdiff][#DiffSongs[curdiff]+1] = {song[1],diffs}
                end
            end
        end
    end

    return DiffSongs
end