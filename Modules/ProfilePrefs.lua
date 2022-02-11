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
	evalpane1 = 2,
	evalpane2 = 0,
	guidelines_top_aligned = false,
	scorelabel = "profile",
}

local entryToPrefixMap = {
	['filter'] = "ScreenFilter",
	['character'] = "SNCharacter",
	['ex_score'] = "EXScore",
	["towelpos"] = "TowelPos",
	['evalpane1'] = "EvalPane1",
	['evalpane2'] = "EvalPane2",
	['stars'] = "EXStars",
	["towelpos"] = "TowelPos"
}

local gameSeed = nil
local machinePrefs = DeepCopy(defaultPrefs)
local profilePrefsSetting = create_setting('ProfilePrefs','ProfilePrefs.lua',
	defaultPrefs, 1, {})

local function Read(profileID)
    if profileID == "!MACHINE" then
        if GAMESTATE then
            local curGameSeed = GAMESTATE:GetGameSeed()
            if curGameSeed ~= gameSeed then
                machinePrefs = DeepCopy(defaultPrefs)
            end
            return machinePrefs
        else
            return DeepCopy(defaultPrefs)
        end
    end
    if not profilePrefsSetting:is_loaded(profileID) then
        profilePrefsSetting:load(profileID)
    end
    return profilePrefsSetting:get_data(profileID)
end

local function Save(profileID)
    if profileID == "!MACHINE" then
        --don't do anything
        return
    end
    return profilePrefsSetting:set_dirty(profileID)
end

return {
    Read=function(profileID)
        return Read(profileID)
    end,
    Save=function(profileID)
        return Save(profileID)
    end,
    SaveAll=function()
        return profilePrefsSetting:save_all()
    end,
    LoadFromProfilePrefs=function()
	    --note: unless you don't use the _fallback version of getenv/setenv this
	    --code does not work
	    local env = GAMESTATE:Env()
	    for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
		    local prefs = Read(GetProfileIDForPlayer(pn))
		    local shortPn = ToEnumShortString(pn)
		    for sourceName, destName in pairs(entryToPrefixMap) do
			    destName = destName..shortPn
			    if not env[destName] then
			    	env[destName] = prefs[sourceName]
			    end
		    end
	    end
    end 
}