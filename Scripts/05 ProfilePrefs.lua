--[[
ProfilePrefs
Values and their meanings:
guidelines: whether beat lines should be shown
character: the name of the character that should be used.
filter: the screen filter darkness that should be used.
lanes: whether lane boundaries should be shown or not.
bias: whether the early/late indicator should be shown.
stars: extra stage stars (it's not a pref. should that be here?)
Towel: Sudden+/Hidden+ Cover
TowelPos: Sudden/Hidden Cover Position
ex_score: whether score should be displayed as DDR A EX score
]]
local defaultPrefs =
{
	guidelines = false,
	character = "",
	filter = 0,
	lanes = false,
	bias = false,
	stars = 0,
	Towel = false,
	TowelPos = 0,
	ex_score = false,
	exstars = 0,
	evalpane1 = 0,
	evalpane2 = 2,
	targetscore = "Off",
	guidelines_top_aligned = false,
	scorelabel = "Profile",
	Judgment = "DEFAULT",
	Combo = "DEFAULT"
}
local gameSeed = nil
local machinePrefs = DeepCopy(defaultPrefs)
local profilePrefsSetting = create_setting('ProfilePrefs','ProfilePrefs.lua', defaultPrefs, 1, {})
ProfilePrefs = {}

function ProfilePrefs.Read(profileID)
	if not ThemePrefs.Get('MachinePrefsSaveToDisk') and profileID == "!MACHINE" then
		if GAMESTATE then
			local curGameSeed = GAMESTATE:GetGameSeed()
			if curGameSeed ~= gameSeed then
				gameSeed = curGameSeed
				machinePrefs = DeepCopy(defaultPrefs)
			end
		end
		return machinePrefs
	end
	if not profilePrefsSetting:is_loaded(profileID) then
		profilePrefsSetting:load(profileID)
	end
	return profilePrefsSetting:get_data(profileID)
end

function ProfilePrefs.Save(profileID)
	if not ThemePrefs.Get('MachinePrefsSaveToDisk') and profileID == "!MACHINE" then
		--don't do anything
		return
	end
	return profilePrefsSetting:set_dirty(profileID)
end

function ProfilePrefs.SaveAll()
	return profilePrefsSetting:save_all()
end
