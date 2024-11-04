--[[
Custom Speed Mods v3 (for StepMania 5)

changelog:

v3 (StepMania 5 b3)
* Complete rewrite to use profile load/save hooks.

--------------------------------------------------------------------------------
v2.3 (StepMania 5 a2/SM5TE) [by AJ]
* If someone has decided to remove 1x from the machine profile's speed mods,
  silently fix it.
* Ignore Cmod and mmod capitalization errors.

v2.2 (StepMania 5 alpha 2) [by FSX]
* Rewrite table management code.
* Add code to make sure that there are speed mods and that they are correct.

v2.1 (StepMania 5 Preview 2)
* Added support for m-Mods.

v2.0 (for sm-ssc)
Giant rewrite of the speed mod parser.
This rewrite comes with the following changes/features:
* Speed mods are now tied to profiles.
  This is arguably the biggest change, as it allows the speed mods to be
  portable, as well as per-profile.
  Thanks to this, we can now support reading SpeedMods from a USB stick or
  other external storage. (I didn't test writing yet, but it should work.)

This version of Custom Speed Mods will only run on StepMania 5 (due to m-mods).
--------------------------------------------------------------------------------
v1.4
* Try to auto-set the speed mod to 1.0 if:
 1) The player hasn't already chosen a speed mod
 2) The player's custom speed mod collection starts with a value under 1x.
 Due to the way the custom speed mods were coded, it will always pick the
 first value, even if it's not 1.0x.

v1.3
* strip whitespace out of file in case people use it.
	(I don't think it really works but SM seems to think the mods are legal)
* fixed an error related to using the fallback return value.

v1.2
* small fixes
* more comments

v1.1
* Cleaned up code some, I think.
]]
local ProfileSpeedMods = {}

-- Returns a new, empty mod table: a table with three members x, C, and m,
-- each being a table with the corresponding numbers set to true.
local function EmptyModTable()
	return {x = {}, C = {}, m = {}}
end

-- Merge one mod table into another.
local function MergeInModTable(dst, src)
	for typ, subtbl in pairs(src) do
		for n, v in pairs(subtbl) do
			dst[typ][n] = v
		end
	end
end

-- Parses a speed mod and returns the pair (type, number) or nil if parsing
-- failed.
local function CanonicalizeMod(mod)
	num = tonumber(mod:match("^(%d+.?%d*)[xX]$"))
	if num ~= nil then
		return "x", num
	end

	num = tonumber(mod:match("^[cC](%d+.?%d*)$"))
	if num ~= nil then
		return "C", num
	end

	num = tonumber(mod:match("^[mM](%d+.?%d*)$"))
	if num ~= nil then
		return "m", num
	end

	return nil
end

-- Parse a comma-separated string into a mod table.
local function StringToModTable(str)
	local mods = EmptyModTable()
	local valid = false

	string.gsub(str, "%s", "")
	for _, mod in ipairs(split(",", str)) do
		local t, n = CanonicalizeMod(mod)
		if t then
			mods[t][n] = true
			valid = true
		end
	end

	return valid and mods or nil
end

-- Return the contents of a mod table as a list of mod names.
local function ModTableToList(mods)
	local l = {}
	local tmp = {}

	-- Do x-mods separately because the x comes after
	for mod, _ in pairs(mods.x) do
		table.insert(tmp, mod)
	end
	table.sort(tmp)
	for _, mod in ipairs(tmp) do
		table.insert(l, mod .. "x")
	end

	-- C- and m-mods
	for _, modtype in ipairs({"C", "m"}) do
		tmp = {}
		for mod, _ in pairs(mods[modtype]) do
			table.insert(tmp, mod)
		end
		table.sort(tmp)
		for _, mod in ipairs(tmp) do
			table.insert(l, modtype .. mod)
		end
	end

	return l
end

local DefaultMods = StringToModTable("0.5x,1x,1.5x,2x,3x,4x,5x,6x,7x,8x,C250,C450,m550")

-- Reads the custom speed mod file at <path> and returns a corresponding mod
-- table.
local function ReadSpeedModFile(path)
	local file = RageFileUtil.CreateRageFile()
	if not file:Open(path, 1) then
		file:destroy()
		return nil
	end

	local contents = file:Read()
	file:Close()
	file:destroy()

	return StringToModTable(contents)
end

-- Hook called during profile load
function LoadProfileCustom(profile, dir)
	-- This will be (intentionally) nil if the file is missing or bad
	local mods = ReadSpeedModFile(dir .. "SpeedMods.txt")

	-- Special case for the machine profile
	if profile == PROFILEMAN:GetMachineProfile() then
		ProfileSpeedMods.machine = mods
		return
	end

	-- Otherwise, it's a player profile.  Store accordingly.
	for i = 1, NUM_PLAYERS do
		if profile == PROFILEMAN:GetProfile(PlayerNumber[i]) then
			ProfileSpeedMods[PlayerNumber[i]] = mods
			break
		end
	end
end

-- Hook called during profile save
function SaveProfileCustom(profile, dir)
	-- Change this if a theme allows you to change and save custom
	-- per-profile settings.
end

-- Returns a list of speed mods for the current round.
local function GetSpeedMods()
	-- Start with machine profile
	local mods = ProfileSpeedMods.machine or EmptyModTable()

	-- Merge in any active players
	for _, p in ipairs(GAMESTATE:GetHumanPlayers()) do
		if ProfileSpeedMods[p] and PROFILEMAN:IsPersistentProfile(p) then
			MergeInModTable(mods, ProfileSpeedMods[p])
		else
			MergeInModTable(mods, DefaultMods)
		end
	end

	-- Apparently removing 1x caused crashes, so be sure it's there.
	-- (This may not be a problem anymore. -- djpohly)
	mods.x[1] = true
	return ModTableToList(mods)
end

-- Implementation of custom Lua option row
function SpeedMods()
	local t = {
		Name = "Speed",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = GetSpeedMods(),

		LoadSelections = function(self, list, pn)
			local pref = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred")
			local selected = 0

			for i, choice in ipairs(self.Choices) do
				if string.find(pref, choice) then
					-- Found it, use it
					selected = i
					break
				elseif choice == "1x" then
					-- Pick this unless we find the
					-- preferred choice
					selected = i
				end
			end

			-- If we didn't find a match, just use the first
			if selected ~= 0 then
				list[selected] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local state = GAMESTATE:GetPlayerState(pn)
			for i, choice in ipairs(self.Choices) do
				if list[i] then
					state:SetPlayerOptions("ModsLevel_Preferred", choice)
					return
				end
			end
			-- Or use the first
			state:SetPlayerOptions("ModsLevel_Preferred", self.Choices[1])
		end
	}
	return t
end

local default_speed_increment= 25
local default_speed_inc_large= 100

local function get_speed_increment()
	local increment= default_speed_increment
	if ReadGamePrefFromFile("SpeedIncrement") then
		increment= tonumber(GetGamePref("SpeedIncrement")) or default_speed_increment
	else
		WriteGamePrefToFile("SpeedIncrement", increment)
	end
	return increment
end

local function get_speed_inc_large()
	local inc_large= default_speed_inc_large
	if ReadGamePrefFromFile("SpeedIncLarge") then
		inc_large= tonumber(GetGamePref("SpeedIncLarge")) or default_speed_inc_large
	else
		WriteGamePrefToFile("SpeedIncLarge", inc_large)
	end
	return inc_large
end

function SpeedModIncSize()
	-- An option row for controlling the size of the increment used by
	-- ArbitrarySpeedMods.
	local increment= get_speed_increment()
	local ret= {
		Name= "Speed Increment",
		LayoutType= "ShowAllInRow",
		SelectType= "SelectMultiple",
		OneChoiceForAllPlayers= true,
		ExportOnChange = true,
		LoadSelections= function(self, list, pn)
			-- The first value is the status element, only it should be true.
			list[1]= true
		end,
		SaveSelections= function(self, list, pn)
			WriteGamePrefToFile("SpeedIncrement", increment)
		end,
		NotifyOfSelection= function(self, pn, choice)
			-- return true even though we didn't actually change anything so that
			-- the underlines will stay correct.
			if choice == 1 then return true end
			local incs= {10, 1, -1, -10}
			local new_val= increment + incs[choice-1]
			if new_val > 0 then
				increment= new_val
			end
			self:GenChoices()
			return true
		end,
		GenChoices= function(self)
			self.Choices= {tostring(increment), "+10", "+1", "-1", "-10"}
		end
	}
	ret:GenChoices()
	return ret
end

function SpeedModIncLarge()
	-- An option row for controlling the size of the increment used by
	-- ArbitrarySpeedMods.
	local inc_large= get_speed_inc_large()
	local ret= {
		Name= "Speed Increment Large",
		LayoutType= "ShowAllInRow",
		SelectType= "SelectMultiple",
		OneChoiceForAllPlayers= true,
		ExportOnChange = true,
		LoadSelections= function(self, list, pn)
			-- The first value is the status element, only it should be true.
			list[1]= true
		end,
		SaveSelections= function(self, list, pn)
			WriteGamePrefToFile("SpeedIncLarge", inc_large)
		end,
		NotifyOfSelection= function(self, pn, choice)
			-- return true even though we didn't actually change anything so that
			-- the underlines will stay correct.
			if choice == 1 then return true end
			local incs= {10, 1, -1, -10}
			local new_val= inc_large + incs[choice-1]
			if new_val > 0 then
				inc_large= new_val
			end
			self:GenChoices()
			return true
		end,
		GenChoices= function(self)
			self.Choices= {tostring(inc_large), "+10", "+1", "-1", "-10"}
		end
	}
	ret:GenChoices()
	return ret
end

function GetSpeedModeAndValueFromPoptions(pn)
	local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
	local speed= nil
	local mode= nil
	if poptions:MaxScrollBPM() > 0 then
		mode= "m"
		speed= math.round(poptions:MaxScrollBPM())
	elseif poptions:TimeSpacing() > 0 then
		mode= "C"
		speed= math.round(poptions:ScrollBPM())
	else
		mode= "x"
		speed= math.round(poptions:ScrollSpeed() * 100)
	end
	return speed, mode
end

function ArbitrarySpeedMods()
	-- If players are allowed to join while this option row is active, problems will probably occur.
	local increment= get_speed_increment()
	local inc_large= get_speed_inc_large()
	local ret= {
		Name= "Speed",
		LayoutType= "ShowAllInRow",
		SelectType= "SelectMultiple",
		OneChoiceForAllPlayers= false,
		ExportOnChange = false,
		LoadSelections= function(self, list, pn)
			-- The first values display the current status of the speed mod.
			if pn == PLAYER_1 or self.NumPlayers == 1 then
				list[1]= true
			else
				list[2]= true
			end
		end,
		SaveSelections= function(self, list, pn)
			local val= self.CurValues[pn]
			local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
			-- modify stage, song and current too so this will work in edit mode.
			local stoptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Stage")
			local soptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Song")
			local coptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Current")
			if val.mode == "x" then
				local speed= val.speed / 100
				poptions:XMod(speed)
				stoptions:XMod(speed)
				soptions:XMod(speed)
				coptions:XMod(speed)
			elseif val.mode == "C" then
				poptions:CMod(val.speed)
				stoptions:CMod(val.speed)
				soptions:CMod(val.speed)
				coptions:CMod(val.speed)
			elseif val.mode == "m" then
				poptions:MMod(val.speed)
				stoptions:MMod(val.speed)
				soptions:MMod(val.speed)
				coptions:MMod(val.speed)
			elseif val.mode == "a" then
				poptions:AMod(val.speed)
				stoptions:AMod(val.speed)
				soptions:AMod(val.speed)
				coptions:AMod(val.speed)
			end
            MESSAGEMAN:Broadcast("ArbitrarySpeedModsSaved",{Player=pn})
		end,
		NotifyOfSelection= function(self, pn, choice)
			-- Adjust for the status elementsgit 
			local real_choice= choice - self.NumPlayers
			-- return true even though we didn't actually change anything so that
			-- the underlines will stay correct.
			if real_choice < 1 then return true end
			local val= self.CurValues[pn]
			if real_choice < 5 then
				local incs= {inc_large, increment, -increment, -inc_large}
				local new_val= val.speed + incs[real_choice]
				if new_val > 0 then
					val.speed= math.round(new_val)
				end
			elseif real_choice >= 5 then
				val.mode= ({"x", "C", "m", "a"})[real_choice - 4]
			end
			self:GenChoices()
			MESSAGEMAN:Broadcast("SpeedChoiceChanged", {pn= pn, mode= val.mode, speed= val.speed})
			return true
		end,
		GenChoices= function(self)
			-- We can't show different options to each player, so compromise by
			-- only showing the xmod increments if one player is in that mode.
			local show_x_incs= false
			for pn, val in pairs(self.CurValues) do
				if val.mode == "x" then
					show_x_incs= true
				end
			end
			local big_inc= inc_large
			local small_inc= increment
			if show_x_incs then
				big_inc= tostring(big_inc / 100)
				small_inc= tostring(small_inc / 100)
			else
				big_inc= tostring(big_inc)
				small_inc= tostring(small_inc)
			end
			--local has_AMod = PlayerOptions.AMod ~= nil
			local has_AMod = false
			if has_AMod then
				self.Choices= {
					"+" .. big_inc, "+" .. small_inc, "-" .. small_inc, "-" .. big_inc,
					"Xmod", "Cmod", "Mmod", "Amod"}
			else	
				self.Choices= {
					"+" .. big_inc, "+" .. small_inc, "-" .. small_inc, "-" .. big_inc,
					"Xmod", "Cmod", "Mmod"}
			end
			-- Insert the status element for P2 first so it will be second
			for i,pn in ipairs({PLAYER_2, PLAYER_1}) do
				local val= self.CurValues[pn]
				if val then
					if val.mode == "x" then
						table.insert(self.Choices, 1, (val.speed/100) .. "x")
					else
						table.insert(self.Choices, 1, val.mode .. val.speed)
					end
				end
			end
		end,
		CurValues= {}, -- for easy tracking of what speed the player wants
		NumPlayers= 0 -- for ease when adjusting for the status elements.
	}
	for i, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
		if GAMESTATE:IsHumanPlayer(pn) then
			local speed, mode= GetSpeedModeAndValueFromPoptions(pn)
			ret.CurValues[pn]= {mode= mode, speed= speed}
			ret.NumPlayers= ret.NumPlayers + 1
		end
	end
	ret:GenChoices()
	return ret
end

--[[
CustomSpeedMods (c) 2013 StepMania team.

Use freely, so long as this notice and the above documentation remains.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Previous version was copyright © 2008-2012 AJ Kelly/KKI Labs.
]]



function ArbitrarySpeedMods2Increment()
	local increment = get_speed_increment()
	local inc_large = get_speed_inc_large()
    
    local function change_speed_mod_by_amount(pn, amount)
        local ps = GAMESTATE:GetPlayerState(pn)
        if not ps then
            lua.ReportScriptError("change_speed_mod_by_amount: No playerstate for "..pn..", ignoring request.")
            return
        end
        local preferred = ps:GetPlayerOptions("ModsLevel_Preferred")
        local stage = ps:GetPlayerOptions("ModsLevel_Stage")
        local song = ps:GetPlayerOptions("ModsLevel_Song")
        local current = ps:GetPlayerOptions("ModsLevel_Current")
        
        local func_name, value
        local value_needs_scaling_down = false
        --if this is 5.1, AMods won't be available, so don't check for them unless the PlayerOptions
        --supports them.
        if preferred.AMod and preferred:AMod() then
            value = preferred:AMod()
            func_name = 'AMod'
        elseif preferred:MMod() then
            value = preferred:MMod()
            func_name = 'MMod'
        elseif preferred:CMod() then
            value = preferred:CMod()
            func_name = 'CMod'
        elseif preferred:XMod() then
            value = preferred:XMod() * 100
            value_needs_scaling_down = true
            func_name = 'XMod'
        else
            lua.ReportScriptError("change_speed_mod_by_amount(): No recognized speed mod type set, can't modify speed mods.")
            return
        end
        
        value = value + amount
        --silently ignore attempts to reduce the set mod to a value at or below 0.
        if value <= 0 then
            return
        end
        if value_needs_scaling_down then
            value = value / 100
        end
        
        preferred[func_name](preferred, value)
        stage[func_name](stage, value)
        song[func_name](song, value)
        current[func_name](current, value)
        MESSAGEMAN:Broadcast("SpeedModChanged",{PlayerNumber=pn})
    end
    local values = {inc_large, increment, -increment, -inc_large}
    return {
        Name = "SpeedIncrement",
        LayoutType = "ShowAllInRow",
        SelectType = "SelectMultiple",
        OneChoiceForAllPlayers = false,
        ExportOnChange = true,
        Choices = {tostring(values[1]), tostring(values[2]), tostring(values[3]), tostring(values[4])},
        LoadSelections = function(self, choice_list, pn)
            for idx, _ in pairs(choice_list) do
                choice_list[idx] = false
            end
        end,
        --dummy function so SM doesn't crash.
        SaveSelections = function() end,
        NotifyOfSelection = function(self, pn, choice)
            change_speed_mod_by_amount(pn, values[choice])
            --this hack causes SM to call LoadSelections, which clears the choice list.
            return true
        end
    }
        
        
end

function ArbitrarySpeedMods2ModType()
    --In this case, we need to change the choices list depending on the presence of AMods
    local has_AMod = PlayerOptions.AMod ~= nil
    local choices
    if has_AMod then
        choices = {'XMod', 'CMod', 'MMod', 'AMod'}
    else
        choices = {'XMod', 'CMod', 'MMod'}
    end
    
    local function change_speed_mod_type(pn, func_name)
        local ps = GAMESTATE:GetPlayerState(pn)
        if not ps then
            lua.ReportScriptError("change_speed_mod_type: No playerstate for "..pn..", ignoring request.")
            return
        end
        local preferred = ps:GetPlayerOptions("ModsLevel_Preferred")
        if not preferred[func_name] then
            lua.ReportScriptError("change_speed_mod_by_amount(): invalid option function name "..tostring(func_name))
            return
        end
        local stage = ps:GetPlayerOptions("ModsLevel_Stage")
        local song = ps:GetPlayerOptions("ModsLevel_Song")
        local current = ps:GetPlayerOptions("ModsLevel_Current")
        local value = 100
        if has_AMod and preferred:AMod() then
            value = preferred:AMod()
        elseif preferred:MMod() then
            value = preferred:MMod()
        elseif preferred:CMod() then
            value = preferred:CMod()
        elseif preferred:XMod() then
            value = preferred:XMod() * 100
        else
            lua.ReportScriptError("change_speed_mod_by_amount(): No recognized speed mod type set, can't modify speed mods.")
            return
        end
        if func_name == "XMod" then
            value = value / 100
        end
        --To clarify, this does the same thing as [po obj]:[insert func_name here](value)
        preferred[func_name](preferred, value)
        stage[func_name](stage, value)
        song[func_name](song, value)
        current[func_name](current, value)
        MESSAGEMAN:Broadcast("SpeedModChanged",{PlayerNumber=pn})
    end
    
    return {
        Name = "SpeedType",
        LayoutType = "ShowAllInRow",
        SelectType = "SelectMultiple",
        OneChoiceForAllPlayers = false,
        ExportOnChange = true,
        Choices = choices,
        LoadSelections = function(self, choice_list, pn)
            for idx, _ in pairs(choice_list) do
                choice_list[idx] = false
            end
        end,
        --dummy function so SM doesn't crash.
        SaveSelections = function() end,
        NotifyOfSelection = function(self, pn, choice)
            change_speed_mod_type(pn, choices[choice])
            --as above
            return true
        end
    }
end

function OptionRowScreenFilter()
	--we use integers equivalent to the alpha value multiplied by 10
	--to work around float precision issues
	local choiceToAlpha = {0, 20, 40, 60, 80, 100}
	local alphaToChoice = {[0]=1, [20]=2, [40]=3, [60]=4, [80]=5, [100]=6}
	local t = {
		Name="Filter",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = { "0%", "20%", "40%", "60%", "80%", "100%"},
		LoadSelections = function(self, list, pn)
			local pName = ToEnumShortString(pn)
			local profileID = GetProfileIDForPlayer(pn)
			local pPrefs = ProfilePrefs.Read(profileID)
			local filterValue = pPrefs.filter
			if filterValue ~= nil then
				local val = alphaToChoice[filterValue] or 1
				list[val] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #list do
				if list[i] then
					local profileID = GetProfileIDForPlayer(pn)
					local pPrefs = ProfilePrefs.Read(profileID)
					pPrefs.filter = choiceToAlpha[i]
					ProfilePrefs.Save(profileID)
					break
				end
			end
		end,
	};
	setmetatable(t, t)
	return t
end

local GetModsAndPlayerOptions = function(player)
	local mods = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Preferred')
	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"
	local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions(modslevel)

	return mods, playeroptions
end

function OptionRowGuideLine()
	local t = {
		Name="GuideLine",
		LayoutType = "ShowAllInRow",
		SelectType="SelectOne",
		OneChoiceForAllPlayers=false,
		ExportOnChange=true,
		Choices = {"On","Off"},
		Values = {true,false},
		LoadSelections = function(self,list,pn)
			local profileID = GetProfileIDForPlayer(pn)
			local pPrefs = ProfilePrefs.Read(profileID)
			if pPrefs.guidelines == true then
				list[1] = true
			elseif pPrefs.guidelines == false then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self,list,pn)
			for i, value in ipairs(self.Values) do
				if list[i] then
					local profileID = GetProfileIDForPlayer(pn)
					local pPrefs = ProfilePrefs.Read(profileID)
					pPrefs.guidelines = value
					ProfilePrefs.Save(profileID)
				end
			end
		end,	
	};
	setmetatable(t ,t)
	return t
end

function OptionRowBias()
	local t = {
		Name="Bias",
		LayoutType = "ShowAllInRow",
		SelectType="SelectOne",
		OneChoiceForAllPlayers=false,
		ExportOnChange=true,
		Choices = {"On","Off"},
		Values = {true,false},
		LoadSelections = function(self,list,pn)
			local profileID = GetProfileIDForPlayer(pn)
			local pPrefs = ProfilePrefs.Read(profileID)
			if pPrefs.bias == true then
				list[1] = true
			elseif pPrefs.bias == false then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self,list,pn)
			for i, value in ipairs(self.Values) do
				if list[i] then
					local profileID = GetProfileIDForPlayer(pn)
					local pPrefs = ProfilePrefs.Read(profileID)
					pPrefs.bias = value
					ProfilePrefs.Save(profileID)
				end
			end
		end,	
	};
	setmetatable(t ,t)
	return t
end

function OptionRowEX()
	local t = {
		Name="EX",
		LayoutType = "ShowAllInRow",
		SelectType="SelectOne",
		OneChoiceForAllPlayers=false,
		ExportOnChange=true,
		Default = false,
		Choices = {"Money Score","EXSCORE"},
		Values = {false,true},
		LoadSelections = function(self,list,pn)
			local profileID = GetProfileIDForPlayer(pn)
			local pPrefs = ProfilePrefs.Read(profileID)
			if pPrefs.ex_score == false then
				list[1] = true
			elseif pPrefs.ex_score == true then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self,list,pn)
			for i, value in ipairs(self.Values) do
				if list[i] then
					local profileID = GetProfileIDForPlayer(pn)
					local pPrefs = ProfilePrefs.Read(profileID)
					pPrefs.ex_score = value
					ProfilePrefs.Save(profileID)
				end
			end
		end,	
	};
	setmetatable(t ,t)
	return t
end

function OptionRowScoreLab()
	local t = {
		Name="ScoreLabel",
		LayoutType = "ShowAllInRow",
		SelectType="SelectOne",
		OneChoiceForAllPlayers=false,
		ExportOnChange=true,
		Default = false,
		Choices = {"Profile","BPM","Speed"},
		Values = {"Profile","BPM","Speed"},
		LoadSelections = function(self,list,pn)
			local profileID = GetProfileIDForPlayer(pn)
			local pPrefs = ProfilePrefs.Read(profileID)
			if pPrefs.scorelabel == "Profile" then
				list[1] = true
			elseif pPrefs.scorelabel == "BPM" then
				list[2] = true
			elseif pPrefs.scorelabel == "Speed" then
				list[3] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self,list,pn)
			for i, value in ipairs(self.Values) do
				if list[i] then
					local profileID = GetProfileIDForPlayer(pn)
					local pPrefs = ProfilePrefs.Read(profileID)
					pPrefs.scorelabel = value
					ProfilePrefs.Save(profileID)
				end
			end
		end,	
	};
	setmetatable(t ,t)
	return t
end

function stringify( tbl, form )
	if not tbl then return end

	local t = {}
	for _,value in ipairs(tbl) do
		t[#t+1] = (type(value)=="number" and form and form:format(value) ) or tostring(value)
	end
	return t
end

function MiniSelector()
	local t = {
		Name="Mini",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = stringify(fornumrange(-100,100,5), "%g%%"),
		LoadSelections=function(self,list,pn)
			setenv("NumMini",#list)
			local nearest_i
			local best_difference = math.huge
			for i,v2 in ipairs(self.Choices) do
				local mini = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):Mini()
				local this_diff = math.abs(mini - v2:gsub("(%d+)%%", tonumber) / 100)
				if this_diff < best_difference then
					best_difference = this_diff
					nearest_i = i
				end
			end
			list[nearest_i] = true
		end,
		SaveSelections=function(self,list,pn)
			for i, choice in ipairs(self.Choices) do
				if list[i] then
					local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
					local stoptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Stage")
					local soptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Song")
					local coptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Current")
					local mini = string.gsub(choice,"%%","")/100
					poptions:Mini(mini)
					stoptions:Mini(mini)
					soptions:Mini(mini)
					coptions:Mini(mini)
				end
			end
		end,
	}
	return t
end

function MusicRate()
	local increment = 0.025
	local inc_large= 0.1
	local t = {
		Name="Rate",
		LayoutType="ShowAllInRow",
		SelectType="SelectOne",
		Choices = stringify(fornumrange(10,200,5), "%g%%"),
		OneChoiceForAllPlayers=true,
		ExportOnChange=true,
		LoadSelections=function(self,list, pn)
			local nearest_i
			local best_difference = math.huge
			setenv("NumRate",#list)
			for i,v2 in ipairs(self.Choices) do
				local rate = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
				local this_diff = math.abs(rate - v2:gsub("(%d+)%%", tonumber) / 100)
				if this_diff < best_difference then
					best_difference = this_diff
					nearest_i = i
				end
			end
			list[nearest_i] = true
		end,
		SaveSelections = function(self,list,pn)
			for i,choice in ipairs(self.Choices) do
				if list[i] then
					local MR = string.gsub(self.Choices[i],"%%","")/100
					GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(MR)
				end
			end
		end,
	};
	return t
end

function LuaNoteSkins()
	local t = {
		Name="LuaNoteSkins",
		LayoutType="ShowOneInRow",
		SelectType="SelectOne",
		OneChoiceForAllPlayers=false,
		ExportOnChange=true,
		Choices = NOTESKIN:GetNoteSkinNames(),
		Values = NOTESKIN:GetNoteSkinNames(),
		LoadSelections=function(self,list, pn)
			local CurNoteSkin = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin()
			for i,v2 in ipairs(self.Choices) do
				if string.lower(tostring(v2)) == string.lower(tostring(CurNoteSkin)) then
					list[i] = true return
				end
			end
			list[1] = true
		end,
		NotifyOfSelection=function(self,pn,choice)
			MESSAGEMAN:Broadcast("LuaNoteSkinsChange", {pn=pn,choice=choice,choicename=self.Values[choice]})
		end,
		SaveSelections = function(self,list,pn)
			for i,v2 in ipairs(self.Choices) do
				if list[i] then
					prev_note_name, succeeded=GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin(v2)
				end
			end
		end
	};
	setmetatable(t, t)
	return t
end

--Programmatically search the noteskin list and add any matching the STARLiGHT noteskins.
--may expand to use a whitelist system. -Sunny
function GetXXSkins()
	function find(table, value)
		for key, _value in pairs(table) do
			if type(_value) == 'table' then
				local f = { find(_value, value) }
				if #f ~= 0 then
					table.insert(f, 2, key); return unpack(f)
				end
			elseif _value == value or key == value then
				return key, _value
			end
		end
	end
	local All = NOTESKIN:GetNoteSkinNames()
	local XXSkins = {}
	for v in ivalues(All) do
		if find(All, string.find(v, "slnexxt")) then
			table.insert(XXSkins,v)
		end
	end
	return XXSkins
end

function ExclusiveNoteskins()
	local All = NOTESKIN:GetNoteSkinNames()
	local NSList
	if #GetXXSkins() ~= 0 and ThemePrefs.Get("ExclusiveNS") == true then
		NSList = GetXXSkins()
	else
		NSList = All
	end
	local t = {
		Name="ExclusiveNoteskins",
		LayoutType="ShowOneInRow",
		SelectType="SelectOne",
		ExportOnChange=true,
		Choices = NSList,
		Values = NSList,
		LoadSelections=function(self,list, pn)
			local CurNoteSkin = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin()
			for i,v2 in ipairs(self.Choices) do
				if string.lower(tostring(v2)) == string.lower(tostring(CurNoteSkin)) then
					list[i] = true return
				end
			end
			list[1] = true
		end,
		NotifyOfSelection=function(self,pn,choice)
			MESSAGEMAN:Broadcast("LuaNoteSkinsChange", {pn=pn,choice=choice,choicename=self.Values[choice]})
		end,
		SaveSelections = function(self,list,pn)
			for i,v2 in ipairs(self.Choices) do
				if list[i] then
					prev_note_name, succeeded=GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin(v2)
				end
			end
		end
	}
	setmetatable(t,t)
	return t
end

function StepsListing()
    local Steplist = function()
        return GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetAllTrails() or GAMESTATE:GetCurrentSong():GetStepsByStepsType( GAMESTATE:GetCurrentStyle():GetStepsType() )
    end
    local conv = {{},{}}
    local fixeddifflist = {
        Difficulty_Beginner = 1,
        Difficulty_Easy = 2,
        Difficulty_Medium = 3,
        Difficulty_Hard = 4,
        Difficulty_Challenge = 5,
        Difficulty_Edit = 6,
    }
    for v in ivalues(Steplist()) do
        if v:GetDifficulty() and v:GetStepsType() == GAMESTATE:GetCurrentStyle():GetStepsType() then
            conv[1][#conv[1]+1] = v
            conv[2][#conv[2]+1] = ("%s %i"):format(THEME:GetString("CustomDifficulty",ToEnumShortString(v:GetDifficulty())), v:GetMeter())
        end
    end
	local t = {
		Name="Steps",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		ExportOnChange = true,
		Choices = conv[2],
        LoadSelections = function(s, list, pn)
            local CM = GAMESTATE:IsCourseMode()
            local StepsOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(pn) or GAMESTATE:GetCurrentSteps(pn)
            for i,v in ipairs(Steplist()) do
                if v == StepsOrCourse then
                    list[i] = true
                    MESSAGEMAN:Broadcast("DifficultyIconChanged",{Player=pn,Difficulty=fixeddifflist[StepsOrCourse:GetDifficulty()]-1})
                end
            end
        end,
        NotifyOfSelection= function(s, pn, choice)
            local CM = GAMESTATE:IsCourseMode()
            MESSAGEMAN:Broadcast("DifficultyIconChanged",{
                Player=pn,
                Difficulty=fixeddifflist[conv[1][choice]:GetDifficulty()]-1
            })
        end,
        SaveSelections = function(s, list, pn)
            for i,v in ipairs(Steplist()) do
                if list[i] then
                    if GAMESTATE:IsCourseMode() then
                        GAMESTATE:SetCurrentTrail(pn,conv[1][i])
                    else
                        GAMESTATE:SetCurrentSteps(pn,conv[1][i])
                    end
                end
            end
		end
	}
	setmetatable(t, t)
	return t
end

function Gauge()
	local choice_names = {'Normal', 'Life4', 'Risky', 'Risky+'}

	if not GAMESTATE:IsCourseMode() then
		if IsExtraStage1() then 
			choice_names = {'Life4', 'Risky'}
		elseif IsExtraStage2() then
			choice_names = {'Risky'}
		end
	end
	
	local t = {
		Name="Gauge",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = choice_names,
		LoadSelections = function(self, list, pn)
			local po = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsArray("ModsLevel_Preferred")
			local poptions = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
			if not IsAnExtraStage() then
				if table.search(po, '4Lives') then
					 list[2] = true
				elseif table.search(po, "1Lives") then
					if getenv("RiskyMode") == 1 then
						list[4] = true
					else
						list[3] = true
					end
				else
					list[1] = true
				end	
			elseif IsExtraStage1() then
				if table.search(po, '1Lives') then
					list[2] = true
				else
					list[1] = true
				end
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local mod = ''
			local poptions = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
			if not IsAnExtraStage() then
				if list[2] then
					mod = '4 lives,battery'
					setenv("RiskyMode",0)
				elseif list[3] then
					mod = '1 lives,battery'
					setenv("RiskyMode",0)
				elseif list[4] then
					mod = '1 lives,battery'
					setenv("RiskyMode",1)
				else
					mod = 'bar'
					setenv("RiskyMode",0)
				end
			elseif IsExtraStage1() then
				if list[2] then
					mod = '1 lives,battery,failimmediate'
				else
					mod = '4 lives,battery,failimmediate'
				end
			elseif IsExtraStage2() then
				mod = '1 lives,battery,failimmediate'
			end
			
			if mod ~= '' then
				GAMESTATE:ApplyPreferredModifiers(pn, mod)
				SCREENMAN:SystemMessage(GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred"))
			end
		end,
	};
	setmetatable(t, t)
	return t
end


function ListChooser()
	local t = {
		Name="ListChooser",
		LayoutType="ShowAllInRow",
		SelectType="SelectOne",
		Choices={"Gameplay","Select Music","Display Options","Advanced Modifiers","Song Options"},
		OneChoiceForAllPlayers=true,
		LoadSelections=function(self,list,pn)
			list[1] = true
		end,
		SaveSelections=function(self,list,pn)
			local screen = SCREENMAN:GetTopScreen()
			if list[1] then
				screen:SetNextScreenName("ScreenStageInformation")
			elseif list[2] then
				screen:SetNextScreenName(SelectMusicOrCourse())
			elseif list[3] then
				screen:SetNextScreenName("ScreenPlayerOptions2")
			elseif list[4] then
				screen:SetNextScreenName("ScreenPlayerOptions3")
			elseif list[5] then
				screen:SetNextScreenName("ScreenSongOptions")
			else
				screen:SetNextScreenName("ScreenStageInformation")
			end
		end
	}
	setmetatable(t,t)
	return t
end

function ListChooser2()
	local t = {
		Name="ListChooser2",
		LayoutType="ShowAllInRow",
		SelectType="SelectOne",
		Choices={"Gameplay","Select Music","Main Modifiers","Advanced Modifiers","Song Options"},
		OneChoiceForAllPlayers=true,
		LoadSelections=function(self,list,pn)
			list[1] = true
		end,
		SaveSelections=function(self,list,pn)
			local screen = SCREENMAN:GetTopScreen()
			if list[1] then
				screen:SetNextScreenName("ScreenStageInformation")
			elseif list[2] then
				screen:SetNextScreenName(SelectMusicOrCourse())
			elseif list[3] then
				screen:SetNextScreenName("ScreenPlayerOptions")
			elseif list[4] then
				screen:SetNextScreenName("ScreenPlayerOptions3")
			elseif list[5] then
				screen:SetNextScreenName("ScreenSongOptions")
			else
				screen:SetNextScreenName("ScreenStageInformation")
			end
		end
	}
	setmetatable(t,t)
	return t
end

function ListChooser3()
	local t = {
		Name="ListChooser3",
		LayoutType="ShowAllInRow",
		SelectType="SelectOne",
		Choices={"Gameplay","Select Music","Main Modifiers","Display Options","Song Options"},
		OneChoiceForAllPlayers=true,
		LoadSelections=function(self,list,pn)
			list[1] = true
		end,
		SaveSelections=function(self,list,pn)
			local screen = SCREENMAN:GetTopScreen()
			if list[1] then
				screen:SetNextScreenName("ScreenStageInformation")
			elseif list[2] then
				screen:SetNextScreenName(SelectMusicOrCourse())
			elseif list[3] then
				screen:SetNextScreenName("ScreenPlayerOptions")
			elseif list[4] then
				screen:SetNextScreenName("ScreenPlayerOptions2")
			elseif list[5] then
				screen:SetNextScreenName("ScreenSongOptions")
			else
				screen:SetNextScreenName("ScreenStageInformation")
			end
		end
	}
	setmetatable(t,t)
	return t
end

function JudgmentSel()
	local t = {
		Name="Judgment Graphic",
		LayoutType="ShowOneInRow",
		SelectType="SelectOne",
		ExportOnChange=true,
		Default = false,
		Choices={"DEFAULT", "SN3"},
		Values={"DEFAULT", "SN3"},
		OneChoiceForAllPlayers=false,
		LoadSelections=function(self,list,pn)
			local profileID = GetProfileIDForPlayer(pn)
			local pPrefs = ProfilePrefs.Read(profileID)
			local judge = pPrefs.Judgment
			if judge == "DEFAULT" then
				list[1] = true
			elseif judge == "SN3" then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self,list,pn)
			for i,value in ipairs(self.Values) do
				if list[i] then
					local profileID = GetProfileIDForPlayer(pn)
					local pPrefs = ProfilePrefs.Read(profileID)
					pPrefs.Judgment = value
					ProfilePrefs.Save(profileID)
				end
			end
		end,
	};
	setmetatable(t,t)
	return t
end

function ComboSel()
	local t = {
		Name="Combo Graphic",
		LayoutType="ShowOneInRow",
		SelectType="SelectOne",
		ExportOnChange=true,
		Default = false,
		Choices={"DEFAULT", "SN3"},
		Values={"DEFAULT", "SN3"},
		OneChoiceForAllPlayers=false,
		LoadSelections=function(self,list,pn)
			local profileID = GetProfileIDForPlayer(pn)
			local pPrefs = ProfilePrefs.Read(profileID)
			local judge = pPrefs.Combo
			if judge == "DEFAULT" then
				list[1] = true
			elseif judge == "SN3" then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self,list,pn)
			for i,value in ipairs(self.Values) do
				if list[i] then
					local profileID = GetProfileIDForPlayer(pn)
					local pPrefs = ProfilePrefs.Read(profileID)
					pPrefs.Combo = value
					ProfilePrefs.Save(profileID)
				end
			end
		end,
	};
	setmetatable(t,t)
	return t
end

function OptionRowTargetScore()
	local t = {
		Name="ShowTarget",
		LayoutType = "ShowAllInRow",
		SelectType="SelectOne",
		OneChoiceForAllPlayers=false,
		ExportOnChange=true,
		Default = false,
		Choices = {"Off","Best Score","Machine Record"},
		Values = {"Off","Best Score","Machine Record"},
		LoadSelections = function(self,list,pn)
			local profileID = GetProfileIDForPlayer(pn)
			local pPrefs = ProfilePrefs.Read(profileID)
			if pPrefs.targetscore == "Off" then
				list[1] = true
			elseif pPrefs.targetscore == "Best Score" then
				list[2] = true
			elseif pPrefs.targetscore == "Machine Record" then
				list[3] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self,list,pn)
			for i, value in ipairs(self.Values) do
				if list[i] then
					local profileID = GetProfileIDForPlayer(pn)
					local pPrefs = ProfilePrefs.Read(profileID)
					pPrefs.targetscore = value
					ProfilePrefs.Save(profileID)
				end
			end
		end,	
	};
	setmetatable(t ,t)
	return t
end

