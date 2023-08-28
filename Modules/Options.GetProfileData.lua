return function(PData)
	local Dir = FILEMAN:GetDirListing("/Appearance/Avatars/")

	local profile = PROFILEMAN:GetProfile( PData ) or PROFILEMAN:GetMachineProfile()
	local pDirectory = CheckIfUserOrMachineProfile(string.sub(PData,-1)-1)
	local configLocation = pDirectory.."/OutFoxPrefs.ini"
	local Info = { Name="", Image="" }

	local PrefsManager = LoadModule("Save.PlayerPrefs.lua")
	PrefsManager:Load( configLocation )

	local AvatarImageLoc = PrefsManager:Get("AvatarImage")

	Info.Image = THEME:GetPathG("UserProfile","generic icon")
	if profile and profile:GetDisplayName() ~= "" then
		Info.Name = profile:GetDisplayName()
		if not AvatarImageLoc then
			-- Oh no, we didn't found an image, let's look for a suitable one from the appearance folder.
			for _,v in ipairs(Dir) do
				if string.match(v, "(%w+)") == profile:GetDisplayName() then
					Info.Image = "/Appearance/Avatars/"..v
					PrefsManager:Set("AvatarImage", Info.Image):SaveToFile()
				end
			end
		else
			-- Is the image stored on the user's memory card instead of the game itself?
			-- For this, we'll check for a special flag stored on the filepath.
			if string.find( AvatarImageLoc, "/mem/" ) then
				local loc = CheckIfUserOrMachineProfile(string.sub(PData,-1)-1)..string.sub(AvatarImageLoc,6)
				if FILEMAN:DoesFileExist( loc ) then
					Info.Image = loc
				end
			else
				Info.Image = AvatarImageLoc
			end
		end
	else
		Info.Name = string.find(PData, "P1") and THEME:GetString("GameState","Player 1") or THEME:GetString("GameState","Player 2")
	end

	return Info
end
