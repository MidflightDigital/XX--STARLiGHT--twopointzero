--SNCharacters v1.1 (13 March 2017)
--version 2 characters added and supported.
--GetAssetPath added to abstract differences away a bit.
--GetPathIfValid added to make it so that...
--most functions won't operate on an invalid character now.
Characters = {}
local c = Characters

--each line corresponds to a version.
--v1 represents characters as used in SN2 and X.
--v2 represents characters as used in X2 on.
local requiredFiles =
{
	{"combo.png", "combo100.png"},
	{"comboA.png", "comboB.png", "combo100.png"},
	{"comboA.png", "comboB.png", "combo100.png"}
}

local rootPath

--If they're gonna work on organization, may as well follow it -Inori
 if _VERSION == "Lua 5.3" then
    rootPath = "/Appearance/SNCharacters/"
else
    rootPath = "/SNCharacters/"
end


--Returns the base path for a character or none if that character doesn't exist.
function Characters.GetPath(name)
    if (not name) or (name == "") or (string.lower(name) == "random") then
        return nil
    end
    if string.find(name, "/") then
        return nil
    end
    local charPath = rootPath..name.."/"
    if FILEMAN:DoesFileExist(charPath) then
        return charPath
    end
end

--Characters.GetConfig is cached.
--It returns the configuration if it is valid, nothing if not.
do

local characterConfigs = {}

local function ValidateAndProcessConfig(loadedCfg)
    if not (loadedCfg.version and loadedCfg.color) then
        return false, "missing field"
    end
    if (loadedCfg.version < 1) then
        return false, "invalid version field"
    end
    if (loadedCfg.version ~= math.floor(loadedCfg.version)) then
    	return false, "version is not an integer"
    end
    if (loadedCfg.version > 3) then
        return false, "version too new"
    end
    local colorDef = loadedCfg.color
    local colorType = type(colorDef)
    if not ((colorType=="string") or (colorType == "table")) then
        return false, "color is not a string or table"
    end
    if (colorType == "table") and (#colorDef ~= 4) then
        return false, "invalid color table size"
    end
    if (colorType=="string") then
        loadedCfg.color = color(colorDef)
    end
    return true
end

--This function actually does the work, Characters.GetConfig just decides
--whether the cached value can be used or not
local function GetConfigInternal(name)
    local charPath = c.GetPath(name)
    if charPath then
        local configPath = charPath.."config.lua"
        if FILEMAN:DoesFileExist(configPath) then
            local result = {dofile_safer(configPath)}
            if result[1] and (type(result[2]) == "table") then
                --ValidateAndProcessConfig works in place, so it doesn't need
                --to return anything
                if ValidateAndProcessConfig(result[2]) then
                    return result[2]
                end
            end
        end
    end
    --Though Characters.GetConfig returns nil on a bad configuration, Lua doesn't
    --distinguish absent table values from nil table values, so this returns false
    --and Characters.GetConfig turns that back into nil.
    return false
end

function Characters.GetConfig(name, forceRecheck)
    if (characterConfigs[name]~=nil and (not forceRecheck)) then
        return (characterConfigs[name]~=false)
            and characterConfigs[name]
            or nil
    else
        local cfg = GetConfigInternal(name)
        characterConfigs[name] = cfg
        return (cfg ~= false) and cfg or nil
    end
end

end
--!!end Characters.GetConfig!!

--Characters.Validate is cached because I feel like it could take a while.
--Returns true if a character is valid, false if not.
do

local characterValidity = {}

--This function actually does the work, Characters.Validate just decides whether
--the cached value can be used or not
local function ValidateInternal(name)
    local charPath = c.GetPath(name)
    if charPath then
        --presumably we want to recheck the config every time we actually run
        local config = c.GetConfig(name, true)
        if config then
            for fileName in ivalues(requiredFiles[config.version]) do
                if not FILEMAN:DoesFileExist(charPath..fileName) then
                    return false
                end
            end
            return true
        end
    end
    return false
end

function Characters.Validate(name, forceRecheck)
    if (characterValidity[name]~=nil and (not forceRecheck)) then
        return characterValidity[name]
    else
        local status = ValidateInternal(name)
        characterValidity[name] = status
        return status
    end
end

end
--!!end Characters.Validate!!

function Characters.GetPathIfValid(name)
	if c.Validate(name) then
		return c.GetPath(name)
	end
end

--Returns a table with every character name in it, unvalidated.
function Characters.GetAllPotentialCharacterNames()
    local output = FILEMAN:GetDirListing(rootPath, true, false)
    table.sort(output)
    return output
end

function Characters.GetAllCharacterNames()
    local potentials = c.GetAllPotentialCharacterNames()
    local output = {}
    for charName in ivalues(potentials) do
        if c.Validate(charName) then
            table.insert(output, charName)
        end
    end
    return output
end

--Returns a dancer video or nothing if none exist.
function Characters.GetDancerVideo(name)
    local potentialVideos = {}
    local charPath = c.GetPathIfValid(name)
    if charPath then
        charPath = charPath .. "DancerVideos/"
        local listing = FILEMAN:GetDirListing(charPath, false, true)
        if not listing then return nil end
        for _, file in pairs(listing) do
            if ActorUtil.GetFileType(file) == 'FileType_Movie' then
                table.insert(potentialVideos,file)
            end
        end
    end
    if #potentialVideos ~= 0 then
        if #potentialVideos == 1 then
            return potentialVideos[1]
        else
            return potentialVideos[math.random(1,#potentialVideos)]
        end
    end
end

do
	local missingAssetFallbacks = {
		["combo.png"] = "comboA.png",
		["comboA.png"] = "combo.png",
		["comboB.png"] = "combo.png"
	}
	function Characters.GetAssetPath(name, asset)
		local charPath = c.GetPathIfValid(name)
		if charPath then
			local targetName = charPath..asset
			if FILEMAN:DoesFileExist(targetName) then
				return targetName
			end
			--try a fallback
			targetName = charPath..missingAssetFallbacks[asset]
			if FILEMAN:DoesFileExist(targetName) then
				return targetName
			end
            return nil
		end
	end
end
--!!end Characters.GetAssetPath()

--an OptionRow, because we need a way to pick this stuff somehow

function OptionRowCharacters()
    local choiceList = c.GetAllCharacterNames()
    local choiceListReverse = {}
    for index, name in pairs(choiceList) do
        choiceListReverse[name] = index
    end
    table.insert(choiceList, 1, THEME:GetString('OptionNames','Off'))
    if #choiceList > 1 then
        table.insert(choiceList, 2, "random")
    end
    local t = {
        Name="Characters",
        LayoutType = "ShowAllInRow",
        SelectType = "SelectOne",
        OneChoiceForAllPlayers = false,
        ExportOnChange = false,
        Choices = choiceList,
        LoadSelections = function(self, list, pn)
            local pn = ToEnumShortString(pn)
            local env = GAMESTATE:Env()
            local currentChar = env['SNCharacter'..pn]
            if choiceListReverse[currentChar] then
                list[choiceListReverse[currentChar]+2] = true
            elseif currentChar == "random" then
                list[2] = true
            else
                list[1] = true
            end
        end,
        SaveSelections = function(self, list, pn)
            local pn = ToEnumShortString(pn)
            local env = GAMESTATE:Env()
            local varName = 'SNCharacter'..pn
            for idx, selected in ipairs(list) do
                if selected then
                    if idx == 1 then
                        env[varName] = nil
                    else
                        env[varName] = choiceList[idx]
                    end
                    --nothing bad would happen if i didn't break here
                    --but it would be a waste of (not very much) time
                    break
                end
            end
        end
    }
    --this is a standard idiom for LuaOptionRows.
    --I do not know what it does or if it is necessary or not.
    setmetatable(t,t)
    return t
end

function GetRandomCharacter(pn)
    assert(GAMESTATE and STATSMAN, "what are you doing")
    local env = GAMESTATE:Env()
    if not env.RandomCharacter then
        env.RandomCharacter = {PlayerNumber_P1={}, PlayerNumber_P2={}}
    end
    local this_rc = env.RandomCharacter[pn]
    local stage = STATSMAN:GetStagesPlayed()
    local course_mode = GAMESTATE:IsCourseMode()
    if (not course_mode and this_rc.stage ~= stage) 
        or (course_mode and not this_rc.char)
    then
        if SN3Debug then
            print("picking new random character. old stage: "
                ..tostring(this_rc.stage).." new stage: "..tostring(stage))
        end
        local chars = Characters.GetAllCharacterNames()
        this_rc.stage = stage
        this_rc.char = chars[math.random(1,#chars)]
    end
    return this_rc.char
end

function ResolveCharacterName(pn)
    local name = (GAMESTATE:Env())['SNCharacter'..ToEnumShortString(pn)] or ""    
    if string.lower(name) ~= "random" then
        return name
    else
        return GetRandomCharacter(pn)
    end
end

if SN3Debug then
    Trace("potential characters: "..table.concat(c.GetAllPotentialCharacterNames(), " "))
    Trace("valid characters: "..table.concat(c.GetAllCharacterNames(), " "))
end

-- (c) 2016-2021 tertu marybig, Inorizushi
-- All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, and/or sell copies of the Software, and to permit persons to
-- whom the Software is furnished to do so, provided that the above
-- copyright notice(s) and this permission notice appear in all copies of
-- the Software and that both the above copyright notice(s) and this
-- permission notice appear in supporting documentation.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
-- OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF
-- THIRD PARTY RIGHTS. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR HOLDERS
-- INCLUDED IN THIS NOTICE BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL INDIRECT
-- OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
-- OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
-- OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
-- PERFORMANCE OF THIS SOFTWARE.
