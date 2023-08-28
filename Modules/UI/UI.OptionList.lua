--[[
	LIST of TODOS:
	- Create modules for Keypad, Keyboard and Slider.
	- Make a generic version of this menu for easier understanding.
]]

local CurrentMenu
local allowedToMove = true
local InputTiedTo = nil
local ThreeButtonComp = PREFSMAN:GetPreference("ThreeKeyNavigation")

local ItemWidth = 0
local ItemHeight = 0

-- Visual representation of the cursor.
local cursorVis = 1
local YOffset = 0

local modifiedSystemPref = false

local numObjects = 13
local containerYPos = 0
local RequiresThemeRestart = nil
local PrefsManager = LoadModule("Save.PlayerPrefs.lua")
local buttonBoxGen = LoadModule("UI/UI.ButtonBox.lua")
local needsColorBoolean = false

local function CheckForSkippableItems( Menu )
	local containsMenus = false
	local ind = 0
	while ind < #Menu do
		ind = ind + 1
		local item = Menu[ind]
		if item.SkipIf then
			-- We removed an item, so we need to go back as the index has updated.
			table.remove(Menu, ind)
			ind = ind - 1
		end
		if item.Menu and not item.SkipIf then
			CheckForSkippableItems(item.Menu)
		end
	end
end

-- Handle the visual representation of the items upon load.
local ValueTypeHandler = {
	["nil"] = function(self, value)
		self:GetChild("image"):visible(false)
		self:GetChild("Label"):visible(false)
		self:GetChild("Value"):visible(false)
		self:playcommand("ToggleButtons",{Visible=false})
		self:GetChild("BG"):visible(false)
	end,
	action = function(self, value)
		self:GetChild("Value"):settext("")
		self:GetChild("image"):visible(false)
		self:playcommand("ToggleButtons",{Visible=false})
	end,
	boolean = function(self, value)
		-- Ok, update that value.
		self:GetChild("Value"):settext("")
		self:playcommand("ToggleButtons",{Visible=false})
		local image= self:GetChild("image")
		self:GetChild("ClickAction"):zoomtowidth( image:GetZoomedWidth() )
		:x( image:GetX() )
		image:visible(true):setstate( value and 1 or 0 )
		-- :stoptweening():linear(0.1):diffuse( BoostColor( needsColorBoolean and PlayerColor(InputTiedTo) or Color.White, value and 1 or 0.3 )  )
		return image
	end,
	menu = function(self, value)
		local c = self:GetChildren()
		c.image:visible(false)
		local BGWidth = ItemWidth
		self.player = InputTiedTo
		local extraval = self.container.FormatVisible and self.container.FormatVisible(self) or ""
		c.Value:visible(true):settext(extraval.." ".."→"):x( BGWidth*.5 - 20 )
		self:playcommand("ToggleButtons",{Visible=false})
		c.ClickAction:x( c.Value:GetX() - 12 ):zoomtowidth( c.Value:GetZoomedWidth() )
	end,
	label = function(self, value)
		self:playcommand("ToggleButtons",{Visible=false})
		self:GetChild("image"):visible(false)
		self:GetChild("Label"):visible(true):zoom(0.8)
		:maxwidth( ItemWidth + 20 )
		self:GetChild("Value"):visible(false)
		self:GetChild("BG"):visible(false)
	end,
	message = function(self, value, params)
		self:GetChild("image"):visible(false)
		self:GetChild("Value"):visible(false)
		self:playcommand("ToggleButtons",{Visible=false})
		if not value then return self end
		return self
	end,
	screen = function(self, value)
		local BGWidth = ItemWidth
		self:GetChild("image"):visible(false)
		self:GetChild("Value"):visible(true):settext("→"):x( BGWidth*.5 - 20 )

		if self.container.FormatVisible then
			self:GetChild("Value"):settext(
				self.container.FormatVisible() .. " →"
			)
		end

		self:playcommand("ToggleButtons",{Visible=false})
		return self
	end,
	cancel = function(self, value)
		self:GetChild("image"):visible(false)
		self:GetChild("Value"):visible(false)
		self:playcommand("ToggleButtons",{Visible=false})
		return self
	end,
	list = function(self, value)
		self:GetChild("image"):visible(false)
		local c = self:GetChildren()
		local BGWidth = ItemWidth
		local dim = color("#AAAAAA")
		self:GetChild("Label"):maxwidth( BGWidth*.35 )
		self:GetChild("Next"):visible(true):diffuse( value == #self.container.Values and dim or Color.White )
		self:GetChild("Prev"):visible(true):diffuse( value == 1 and dim or Color.White )
		c.ClickAction:x( c.Next:GetX() ):zoomtowidth( c.Next:GetZoomedWidth() + 20 )


		self:GetChild("Value"):visible(true):x( BGWidth*.5 - 50 ):maxwidth( BGWidth*.35 )
		if value == nil then return self end

		self.player = InputTiedTo

		self:GetChild("Value"):settext(
			self.container.FormatVisible and self.container.FormatVisible(self,value) or tostring(self.container.Values[value])
		)

		return self
	end,
	number = function(self, value)
		local BGWidth = ItemWidth
		self:GetChild("image"):visible(false)
		self:playcommand("ToggleButtons",{Visible=true})
		self:GetChild("Label"):maxwidth( BGWidth*.35 )
		
		self:GetChild("ClickAction"):x( self:GetChild("Next"):GetX() )
		:zoomtowidth( 30 )

		if not value then return end

		self.player = InputTiedTo

		return self:GetChild("Value"):visible(true):x( BGWidth*.5 - 50 ):settext(
			self.container.FormatVisible and self.container.FormatVisible(value) or string.format("%d", value)
		)
	end,
	default= function(self, value)
		self:GetChild("image"):visible(false)
		self:playcommand("ToggleButtons",{Visible=false})
		return self:GetChild("Value"):settext(tostring(value))
	end,
}

local function GetCPlayerOptions( pn ) return GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions("ModsLevel_Preferred") end
local function GetPlayerOptions( pn ) return GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred") end

local function ConvertValueFromDataType( dataType, value, tableToIterate )
	if dataType == "list" then
		-- It's a list, so there's likely a list of elements to look for
		-- with the answer that we just obtained.
		for k,v in ipairs( tableToIterate ) do
			if v == value then
				return k
			end
		end
	end

	if dataType == "number" then return tonumber(value) end

	if dataType == "boolean" then
		if type(value) == "number" then
			return value > 0
		end
		return value
	end
	-- nothing passed, it's just a string return.
	return value
end

-- Need to make this an empty initializer to allow variables to interact with it
-- while being inside it.
local DataGet,DataSet

DataGet = {
	-- Need to look up a player mod, this will return the string literate version of the result.
	-- Since Player and Song options are the same kind of object operator, it can interoperate on the same
	-- function, hence the use of the ModObject variable to determine which one to use.
	player_mod = function(self, pn, ModObject)
		-- Are player options available before hand?
		local PlrOptions = ModObject or GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
		local option = self.container.Name
		if PlrOptions then
			if not PlrOptions[option] then return "-nil-" end
			return ConvertValueFromDataType( self.valueType, PlrOptions[option](PlrOptions), self.container.Values )
		end
		return "-nil-"
	end,
	song_option = function(self, pn)
		return DataGet.player_mod(self, pn, GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"))
	end,
	player_mod_table = function(self, pn)
		-- Are player options available before hand?
		local PlrOptions = GetPlayerOptions(pn)
		local option = self.container.Name
		if PlrOptions then
			-- It's a list, so there's likely a list of elements to look for
			-- with the answer that we just obtained.
			for k,v in ipairs( self.container.Values ) do
				local val = PlrOptions[v](PlrOptions)
				if val then
					return k
				end
			end
			return 1
		end
		return 1
	end,
	-- This is an option that will fall to the outfox preferences file.
	outfox_pref = function(self, pn)
		-- Is this going to a player profile or the engine preferences?
		local preflist = CheckIfUserOrMachineProfile(string.sub(pn,-1)-1)
		if self.container.MachinePref then
			-- It's a machine preference, so it must be saved on
			-- the global OutFox Prefs.
			preflist = "Save"
		end
		-- Save the configuration.
		local Location = preflist .."/OutFoxPrefs.ini"
		if self.container.MachinePref then
			return LoadModule("Config.Load.lua")(self.container.Name, Location)
		end
		return PrefsManager:Get(self.container.Name,self.container.Default)
	end,
	outfox_pref_table = function(self, pn)
		-- Get the info from the listing, to then match.
		local currentPref = DataGet.outfox_pref(self, pn)

		-- Now to search.
		for k,v in ipairs( self.container.Values ) do
			if v == currentPref then
				return k
			end
		end
		return 1
	end,
	system_option = function(self)
		-- Get Preference
		local pref = self.container.Load and self.container.Load(self) or PREFSMAN:GetPreference(self.container.Name)
		return ConvertValueFromDataType( self.valueType, pref, self.container.Values )
	end,
	system_option_table = function(self)
		-- Get Preference
		local pref = PREFSMAN:GetPreference(self.container.Name)
		return ConvertValueFromDataType( self.valueType, pref, self.container.Values )
	end,
	default = function(self, pn)
		local valtype = type(self.container.Value)
		if valtype == "boolean" or valtype == "number" then
			return self.container.Value
		end
		return self.container.ValueE
	end
}

DataSet = {
	-- Need to look up a player mod, this will return the string literate version of the result.
	-- Since Player and Song options are the same kind of object operator, it can interoperate on the same
	-- function, hence the use of the ModObject variable to determine which one to use.
	player_mod = function(self, pn, ModObject, isBoolLiteral)
		-- Are player options available before hand?
		local PlrOptions = ModObject or GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
		local option = self.container.Name
		local value = self.container.ValueE
		if PlrOptions then
			if not PlrOptions[option] then
				return false
			end
			local oprdone = false
			-- Check what kind of result we must return.
			if self.valueType == "list" then
				local choice = self.container.Values[value]
				-- It's a list, so there's likely a list of elements to look for
				-- with the answer that we just obtained.
				PlrOptions[option](PlrOptions, tostring(choice))
				oprdone = true
			end

			if self.valueType == "boolean" then
				if isBoolLiteral or self.container.LiteralBool then
					PlrOptions[option](PlrOptions, value)
				else
					PlrOptions[option](PlrOptions, (value == true and 1 or 0))
				end
				oprdone = true
			end

			if self.valueType == "number" then
				PlrOptions[option](PlrOptions, tonumber( string.format( self.container.Format or "%.2f", value ) ) )
				oprdone = true
			end

			if not oprdone then
				PlrOptions[option](PlrOptions, value)
			end

			MESSAGEMAN:Broadcast("PlayerOptionChange",{ Player = pn, Option = self.container.Name })
			return true
		end
		return false
	end,
	player_mod_table = function(self, pn)
		-- Are player options available before hand?
		local PlrOptions = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
		local option = self.container.Name
		local value = self.container.ValueE
		if PlrOptions then
			-- Check what kind of result we must return.
			if self.valueType == "list" then
				local choice = self.container.Values[value]
				-- It's a list, so there's likely a list of elements to look for
				-- with the answer that we just obtained.
				PlrOptions[choice](PlrOptions, 1)
				MESSAGEMAN:Broadcast("PlayerOptionChange",{ Player = pn })
				return true
			end
		end
		return false
	end,
	song_option = function(self, pn)
		DataSet.player_mod(self, pn, GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"), self.valueType == "boolean")
	end,
	outfox_pref = function(self, pn, forceOption)
		-- Is this going to a player profile or the engine preferences?
		local preflist = self.container.MachinePref and "Save" or ""
		if pn and not self.container.MachinePref then
			preflist = CheckIfUserOrMachineProfile(string.sub(pn,-1)-1)
		end
		-- Save the configuration.
		local Location = preflist .."/OutFoxPrefs.ini"
		if self.container.MachinePref then
			return LoadModule("Config.Save.lua")( self.container.Name, tostring(forceOption or self.container.ValueE), Location)
		end
		PrefsManager:Set(self.container.Name,forceOption or self.container.ValueE)
	end,
	outfox_pref_table = function(self, pn)
		-- Get the name of the preference chosen
		local nameOption = self.container.Values[ self.container.ValueE ]
		-- Just save like regular pref
		DataSet.outfox_pref(self, pn, nameOption)
	end,
	system_option = function(self)
		modifiedSystemPref = true
		PREFSMAN:SetPreference( self.container.Name, self.container.ValueE )
	end
}

local function CheckNotify(index,player)
	-- Does the option have a NotifyOfChange function?
	-- call it if it does so it can alert externally.
	if CurrentMenu[index].NotifyOfChange then
		CurrentMenu[index].NotifyOfChange( CurrentMenu[index], CurrentMenu[index].ValueE, player )
	end
	-- Broadcast the current item so any subscribed actors can listen.
	MESSAGEMAN:Broadcast("CheckForMessages",{Value=CurrentMenu[index].Name, Item = CurrentMenu[index].Values and CurrentMenu[index].Values or nil, Player = player})
end

-- Define the calls when the user wants to save.
-- There are options which are defined with its type.
-- Some options contain custom save functions, which will override the type one.
-- However there might be some options where you might want an extra option.
local function PerformSetCall( func, InputTied )
	-- The save function to use is already defined upon item generation, so this will only deal
	-- with what parameters to provide.
	if func.container.UsePrefs then
		return func.set(func, InputTied, PrefsManager)
	end
	-- The original needs to be defined as other options could tie an extra parameter on its result.
	return func.set(func, InputTied)
end

local function ChangeValue(self,index,visualizedCursor,offset,player)
	if not allowedToMove or index == 0 then return end
	-- The value MUST be something that can be changed.
	if CurrentMenu[index].Type ~= "number" and CurrentMenu[index].Type ~= "list" then return end

	-- If the player input happens to be set, then ignore if it isn't.
	if InputTiedTo and InputTiedTo ~= player then return end

	-- If its a number value, perform this.
	if CurrentMenu[index].Margin then
		-- Cache the margin
		local margin = CurrentMenu[index].Margin
		local newval = math.round(CurrentMenu[index].ValueE + (margin*offset),5)

		-- Special case, check if the value that we arrived at is beyond what it should be.
		local OFBVal = newval % margin
		-- Use 0.1 to deal with .3 floating point numbers.
		if OFBVal > 0.1 then
			newval = newval - OFBVal
		end
		
		if CurrentMenu[index].Min and CurrentMenu[index].Max then
			newval = clamp(newval, CurrentMenu[index].Min, CurrentMenu[index].Max)
		end

		-- Change the value depending on its offset.
		CurrentMenu[index].ValueE = newval
	else
		-- Then it's a table choice value.
		local val = CurrentMenu[index].ValueE + offset

		if val > #CurrentMenu[index].Values then val = 1 end
		if val < 1 then val = #CurrentMenu[index].Values end

		CurrentMenu[index].ValueE = val
	end

	-- Does the option have a NotifyOfChange function?
	-- call it if it does so it can alert externally.
	CheckNotify(index,player)

	-- Update the container.
	local cursor = self:GetChild("Item"..visualizedCursor)
	cursor:playcommand("DisplayInformation",CurrentMenu[index])
	if cursor.set then
		PerformSetCall( cursor, InputTiedTo )

		local sets = {
			["Update_Strings"] = function()
				for i = 1,numObjects do
					self:GetChild("Item"..i):playcommand("DisplayInformation",CurrentMenu[i+YOffset])
					self:GetChild("Item"..i):playcommand("UpdateControllers",CurrentMenu[i])
				end
				MESSAGEMAN:Broadcast("LanguageStringsUpdate")
			end,
			["Theme_Change"] = function()
				-- Is the value chosen not the same as the current one?
				RequiresThemeRestart = THEME:GetCurThemeName() ~= cursor.container.Values[cursor.container.ValueE] and cursor.container.Values[cursor.container.ValueE] or nil
			end
		}
		
		if sets[a] then sets[a]() end
	end
end

local handleAction = {
	action = function(self)
		if self.container.Value then
			self.container.Value(self, InputTiedTo)
		end
	end,
	screen = function(self, value)
		SCREENMAN:GetTopScreen():SetNextScreenName(self.container.Value):StartTransitioningScreen("SM_GoToNextScreen")
	end,
	cancel = function(self)
		local screen = SCREENMAN:GetTopScreen()
		if self.container.Value then
			screen:SetPrevScreenName(self.container.Value)
		end
		if self.container.ForceSave then
			PrefsManager:SaveToFile()
		end
		screen:Cancel()
	end,
	menu = function(self, value)
		return self:GetParent():playcommand("CreateNewMenu",{NewMenu = CurrentMenu[value]})
	end,
	message = function(self, value, params)
		if not value then return self end
		MESSAGEMAN:Broadcast(self.container.Value, {Player = InputTiedTo} )
		return self
	end,
	-- By default, this will assume it is the right side of the button list (Next).
	-- The flag will determine if its Prev instead.
	list = function(self, value, isLeft)
		ChangeValue(self:GetParent(), value, self.cursorVis, isLeft and -1 or 1, self.pn)
	end,
	number = function(self, value, isLeft)
		ChangeValue(self:GetParent(), value, self.cursorVis, isLeft and -1 or 1, self.pn)
	end,
	boolean = function(self,value)
		CurrentMenu[value].ValueE = not CurrentMenu[value].ValueE
		return self.handler(self, self.container.ValueE)
	end,
	["nil"] = function(self) return false end,
	default = function(self) return false end,
}

local OriginalY = 0
local cursor = 1
local insideSpecialMenu = false
-- Special flag to determine if the user has pressed the back button while overlapping another one.
local Touch_PressedButton = false
return setmetatable({
	_LICENSE = [[
		Copyright 2021-2022 Jose Varela, Project OutFox

		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at

			http://www.apache.org/licenses/LICENSE-2.0

		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.
	]],
	Handler = nil,
	ActorFrame = nil,
	Create = function(this)
		return this.ActorFrame
	end,
	GetCursorIndex = function(this)
		return cursor
	end,
	InSpecialMenu = function(this)
		return insideSpecialMenu
	end,
	IsCurrentOptionToggable = function(this)
		local choices = {
			["number"] = true,
			["list"] = true,
		}

		return CurrentMenu[ cursor ] and choices[CurrentMenu[ cursor ].Type] or false
	end,
	LockInput = function(this,state)
		allowedToMove = not state
	end,
	ResetCursor = function(this)
		this.Handler:playcommand("ResetCursor")
	end,
	ChangeValue = function(this,offset,player)
		ChangeValue( this.Handler, cursor, cursorVis, offset, player )
	end,
	GetFirstAvailableChoiceInMenu = function(this, Menu)
		local attempts = 0
		local cursorpos = 1
		while ( Menu[cursorpos].Type == "label" or Menu[cursorpos].Disabled ) do
			if attempts > #Menu*2 then return nil end
			cursorpos = cursorpos + 1
			attempts = attempts + 1

			-- Loop back.
			if cursorpos > #Menu then cursorpos = 1 end
		end

		return cursorpos
	end,
	UseNewMenu = function(this, NewMenu)
		-- Is the menu valid?
		if type(NewMenu) ~= "table" then return end
		-- Is it the same as the one right now?
		if NewMenu == CurrentMenu then return end

		-- Reset all available values to prevent bugs.
		local newcursorpos = this:GetFirstAvailableChoiceInMenu(NewMenu)
		if newcursorpos then
			insideSpecialMenu = false
			cursor = newcursorpos
			CurrentMenu = NewMenu
			cursorVis = this:GetCursorVisPosition(newcursorpos)
			local self = this.Handler
	
			self:playcommand("UpdateContainer")
		else
			Trace("[OptionList] This menu has no available choices to move around in!")
		end
	end,
	GetCursorVisPosition = function(this,cursor)
		local newpos = cursor
		local midPoint = math.floor(numObjects/2)
		if #CurrentMenu > numObjects then
			-- Detect the middle point of the menu, which is where it will
			-- begin to scroll.
			if cursor > numObjects/2 then
				-- Once the cursor is upon reaching the last 4 items
				-- on the list, stop.
				if cursor < (#CurrentMenu-midPoint) then
					-- Force cursor to the middle.
					newpos = midPoint
				else
					newpos = cursor - (#CurrentMenu-numObjects)
				end
			end
		end

		return newpos
	end,
	MoveSelection = function(this,offset,player,IsTouch)
		local self = this.Handler
		-- Don't perform anything if we're in a special kind of menu.
		if insideSpecialMenu or not allowedToMove then return end

		-- If the player input happens to be set, then ignore if it isn't.
		if InputTiedTo and InputTiedTo ~= player then return end

		cursor = cursor + offset
		-- NeedsToUpdate, NeedsToMove
		local forcenewOffset = {false,false}
		
		-- Make cursor loop around when reaching the edges
		if cursor > #CurrentMenu then cursor = 1 forcenewOffset = {true,false} end
		-- SPECIAL CASE: If the current menu has a back button, then allow the cursor to select it.
		if cursor < 0 then cursor = #CurrentMenu forcenewOffset = {true,false} end
		
		-- Label style rows should not be selectable at all, so just skip past them.
		if CurrentMenu[cursor] then
			-- HOWEVER, if we're using a touch screen/mouse, don't do anything.
			if IsTouch and (CurrentMenu[cursor].Type == "label" or CurrentMenu[cursor].Disabled) then
				return
			end

			local attempts = 0
			while ( cursor ~= 0 and (CurrentMenu[cursor].Type == "label" or CurrentMenu[cursor].Disabled) ) do
				if attempts > #CurrentMenu*2 then break end
				cursor = cursor + offset
				attempts = attempts + 1
				-- Don't do this if we're reaching 1.
				local isLabel = CurrentMenu[cursor-offset].Type == "label" or CurrentMenu[cursor-offset].Disabled
				forcenewOffset = {(offset == -1 or (isLabel and offset == 1)) and cursor ~= 1,offset == -1}

				-- Loop back.
				if cursor > #CurrentMenu then cursor = 1 end
				if cursor < 0 then cursor = #CurrentMenu end
			end
		end
		
		-- IF we're on a position that is now below the usual spot, begin increasing the list to keep
		-- track of position.
		cursorVis = cursor

		local midPoint = math.floor(numObjects/2)
		-- Update visible items with the cursor.
		-- Indicate the new objects.
		-- Only perform this if there are more objects than the allowed visible elements.
		if #CurrentMenu > numObjects then
			-- Detect the middle point of the menu, which is where it will
			-- begin to scroll.
			if cursor > numObjects/2 then
				-- Once the cursor is upon reaching the last 4 items
				-- on the list, stop.
				if cursor < (#CurrentMenu-midPoint) then
					-- Force cursor to the middle.
					cursorVis = midPoint
					-- Now move the cursor field with an offset.
					YOffset = cursor - midPoint
				else
					-- Fix the scroller with the last visible items available.
					if cursor == (#CurrentMenu-midPoint) then
						forcenewOffset = {true,false}
					end
					local mid = (#CurrentMenu-numObjects)
					YOffset = mid
					cursorVis = cursor - mid
				end
			else
				cursorVis = cursor
				YOffset = 0
			end
			local itemsNeedToMove = (cursor > numObjects/2) and (cursor < #CurrentMenu-midPoint)
			local movefoward = offset > 0
			local moveback = offset < 0
			-- move them
			-- Add transitions
			if itemsNeedToMove then
				self:GetChild("Item"..( movefoward and numObjects or 1)):stoptweening():diffusealpha(0)
			end
			for i = numObjects,1,-1 do
				-- Either items can move, or its the special case for the very last item before
				-- the transition begins when going backwards
				if itemsNeedToMove or (forcenewOffset[1] and forcenewOffset[2]) or
					( (YOffset >= 0 and (cursor >= midPoint and cursor < #CurrentMenu-midPoint)) and moveback )
				then
					self:GetChild("Item"..i):stoptweening():y( containerYPos * (i+offset) )
					-- Mid transition point.
					self:GetChild("Item"..i):linear(0.1):y( containerYPos * (i) ):diffusealpha(1)

					-- Update those corner items.
					self:GetChild("Item"..i):playcommand("DisplayInformation",CurrentMenu[i+YOffset])
					self:GetChild("Item"..i):playcommand("UpdateControllers",CurrentMenu[i+YOffset])
				end

				-- Special case for the very last item before the transition begins when going backwards
				if forcenewOffset[1] then
					self:GetChild("Item"..i):playcommand("DisplayInformation",CurrentMenu[i+YOffset])
					self:GetChild("Item"..i):playcommand("UpdateControllers",CurrentMenu[i+YOffset])
				end
			end
		end

		for i = 1,numObjects do
			local txt = self:GetChild("Item"..i)
			-- Indicate the item that it can be marked as hovered or not.
			-- This is mainly for custom-assigned frames.
			self:GetChild("Item"..i):playcommand( (cursorVis == i and "Active" or "Inactive") )
		end

		-- Update visible cursor with new position
		self:GetChild("Cursor"):playcommand("MovePosition",{Offset=cursorVis})
	end,
	ConfirmSelection = function(this,player)
		local self = this.Handler
		self:playcommand("Start",{Player = player})
	end,
	Back = function(this,player)
		local self = this.Handler
		self:playcommand("Back",{Player = player})
	end,
	BroadcastCurMenuEnterMessage = function(this,player)
		if CurrentMenu.MessageOnEntry then
			MESSAGEMAN:Broadcast(CurrentMenu.MessageOnEntry, { pn = player })
		end
	end,
	BroadcastCurMenuExitMessage = function(this,player)
		if CurrentMenu.MessageOnExit then
			MESSAGEMAN:Broadcast(CurrentMenu.MessageOnExit, { pn = player })
		end
	end
	},
	{
		__call = function( this, Container )
			CurrentMenu = Container.List
			CheckForSkippableItems(CurrentMenu)
			InputTiedTo = Container.InputTiedTo or GAMESTATE:GetMasterPlayerNumber()
			ItemWidth = Container.ItemWidth or 360
			ItemHeight = Container.ItemHeight or 42
			numObjects = Container.NumChoices or 13
			needsColorBoolean = Container.ColorBooleanSwitches
			local t = Def.ActorFrame{
				InitCommand=function(self)
					this.Handler = self
					OriginalY = self:GetY()
				end,
				OnCommand=function(self)
					PrefsManager:Load( CheckIfUserOrMachineProfile(string.sub(InputTiedTo,-1)-1).."/OutFoxPrefs.ini" )

					if not Container.UseDedicatedController then
						self.Controller = LoadModule("Lua.InputSystem.lua")(self)
						SCREENMAN:GetTopScreen():AddInputCallback(self.Controller)
					end

					self:playcommand("UpdateContainer")
				end,
				CancelCommand=function(self)
					if Container.SaveOnCancel then
						PrefsManager:SaveToFile()
					end
				end,
				OffCommand=function(self)
					PrefsManager:SaveToFile()
					if modifiedSystemPref then
						PREFSMAN:SavePreferences()
					end
					if not Container.UseDedicatedController then
						SCREENMAN:GetTopScreen():RemoveInputCallback(self.Controller)
					end
				end,

				MenuDownCommand=function(self) this:MoveSelection(1,self.pn) end,
				MenuUpCommand=function(self) this:MoveSelection(-1,self.pn) end,
				
				MenuLeftCommand=function(self)
					if ThreeButtonComp and not insideSpecialMenu then
						this:MoveSelection(-1,self.pn)
					else
						ChangeValue(self, cursor, cursorVis, -1, self.pn)
					end
				end,
				MenuRightCommand=function(self)
					if ThreeButtonComp and not insideSpecialMenu then
						this:MoveSelection(1,self.pn)
					else
						ChangeValue(self, cursor, cursorVis, 1, self.pn)
					end
				end,

				SelectCommand = function(self)
					if not allowedToMove then return end
					-- If the player input happens to be set, then ignore if it isn't.
					if Container.InputTiedTo and Container.InputTiedTo ~= self.pn then return end
					
					MESSAGEMAN:Broadcast("OptionListTopOfTree",{Player = self.pn})
				end,
				
				StartCommand=function(self,params)
					if not allowedToMove then return end
					local player = params and params.Player or self.pn
					-- If the player input happens to be set, then ignore if it isn't.
					if Container.InputTiedTo and Container.InputTiedTo ~= player then return end

					if RequiresThemeRestart then
						THEME:SetTheme( RequiresThemeRestart )
						return
					end

					if cursor == 0 then
						-- The user selected the back menu.
						self:playcommand("ReturnMenu",{NewMenu = CurrentMenu})
						return
					end

					if insideSpecialMenu then
						insideSpecialMenu = false
						self:GetChild("Item"..cursorVis):playcommand("LoseFocus")
						return
					end

					local needSpecial = {
						["list"] = true,
						["number"] = true,
					}
					if ThreeButtonComp and needSpecial[self:GetChild("Item"..cursorVis).valueType] then
						insideSpecialMenu = true
						self:GetChild("Item"..cursorVis):playcommand("GainFocus")
						return
					end

					-- Is this button a menu? Only perform the calls to change the menu,
					-- don't bother updating any data type, otherwise we'll get problems specially on booleans.
					if self:GetChild("Item"..cursorVis).valueType == "menu" then
						self:GetChild("Item"..cursorVis).action(self:GetChild("Item"..cursorVis), cursor)
						return
					end

					-- If the item action was successful, update its container with the new information.
					if self:GetChild("Item"..cursorVis).action(self:GetChild("Item"..cursorVis), cursor) then
						local cursorActor = self:GetChild("Item"..cursorVis)
						if cursorActor.set then
							PerformSetCall( cursorActor, InputTiedTo )
						end
						cursorActor:playcommand("DisplayInformation",CurrentMenu[cursor])
						CheckNotify(cursor,InputTiedTo)
					end
				end,
				BackCommand=function(self,params)
					if RequiresThemeRestart then
						SCREENMAN:SystemMessage("A popup message shows up here.")
						return
					end
					local player = params.Player or InputTiedTo
					if not allowedToMove then return end
					-- If the player input happens to be set, then ignore if it isn't.
					if Container.InputTiedTo and Container.InputTiedTo ~= player then return end

					if insideSpecialMenu then
						insideSpecialMenu = false
					else
						self:playcommand("ReturnMenu",{NewMenu = CurrentMenu})
					end
				end,
				AllowInputCommand=function(self,params)
					allowedToMove = params.State
					return
				end,
				ResetCursorCommand=function(self)
					self:playcommand("UpdateContainer")
				end,
				CreateNewMenuCommand = function(self,params)
					-- Since we're in the new menu, the CurrentMenu table must mutate to become
					-- part of the new level's menu system.
					-- Store the previous position in case the user wants to return to the previous option.
					if not params.NewMenu.Menu then return end

					-- Is the cursor right now in a label/disabled option?
					-- If so, we need to move until the next available choice.
					local npos = this:GetFirstAvailableChoiceInMenu(params.NewMenu.Menu)
					if not npos then return end

					local old = CurrentMenu
					if params.NewMenu.MessageOnEntry then
						MESSAGEMAN:Broadcast(params.NewMenu.MessageOnEntry, { pn = InputTiedTo })
					end
					CurrentMenu = params.NewMenu.Menu
					CurrentMenu.Back = old
					CurrentMenu.Pos = cursor
					cursor = npos
					cursorVis = this:GetCursorVisPosition(npos)
					self:playcommand("UpdateContainer")
				end,
				ReturnMenuCommand = function(self,params)
					-- Since we're in the new menu, the CurrentMenu table must mutate to become
					-- part of the new level's menu system.
					if params.NewMenu.Back then
						local old = CurrentMenu
						if CurrentMenu.MessageOnExit then
							MESSAGEMAN:Broadcast(CurrentMenu.MessageOnExit, { pn = InputTiedTo })
							OriginalY = self:GetDestY()
						end
						cursor = CurrentMenu.Pos
						CurrentMenu = params.NewMenu.Back
						cursorVis = this:GetCursorVisPosition(cursor)
						self:playcommand("UpdateContainer")
						this:MoveSelection(0,InputTiedTo)
					else
						-- We don't have a top menu, which means we're on the root level.
						-- That can indicate that the player wants to go back.
						local p = Container.UseDedicatedController and InputTiedTo or self.pn
						MESSAGEMAN:Broadcast("OptionListTopOfTree",{Player = p, UsedBack = true})
						if Container.BackExitsScreen then
							SCREENMAN:GetTopScreen():Cancel()
						end
					end
				end,
				UpdateContainerCommand=function(self)
					-- Reset the cursor
					YOffset = 0
					self:GetChild("Cursor"):playcommand("MovePosition",{Offset=cursor})

					-- Indicate the new objects.
					for i = numObjects,1,-1 do
						self:GetChild("Item"..i):playcommand("DisplayInformation",CurrentMenu[i])
						self:GetChild("Item"..i):playcommand("UpdateControllers",CurrentMenu[i])
						self:GetChild("Item"..i):playcommand( (cursorVis == i and "Active" or "Inactive") )
					end
					OriginalY = self:GetDestY()
					Touch_PressedButton = false
				end,
				UpdateYCoordinateCommand = function(self)
					OriginalY = self:GetDestY()
				end
			}

			local function AllowedToClickArea(self)
				return (not Touch_PressedButton) and allowedToMove and (self.valueType ~= nil and self.valueType ~= "label" and not self.container.Disabled)
			end
			
			-- Back button for mouse/touch users
			t[#t+1] = LoadModule("UI/UI.ClickArea.lua"){
				Width = 40,
				Height = 40,
				ReturnAdjacentActorFrame = true,
				Position = function(self)
					self:xy( -ItemWidth*.5 + 24, -6 )
				end,
				Action = function(self)
					if not allowedToMove then return end
					Touch_PressedButton = true
					self:playcommand("Back",{Player = InputTiedTo})
				end
			}..{ Name="BackButton" }

			-- Generate the containers.
			for i = 1, numObjects do
				t[#t+1] = Def.ActorFrame{
					Name="Item"..i,

					InitCommand=function(self)
						self.handler = nil
						self:y( (32 * i) )

						local BGWidth = ItemWidth
						local c = self:GetChildren()
						c.Value:halign(1):x( BGWidth*.5 - 20 ):visible(false)
						:maxwidth( 100 )
						c.Label:halign(0):maxwidth( BGWidth*2 ):x( -BGWidth*.5 + 20 ):zoom(0.5)

						c.Next:visible(false):x( BGWidth*.5 - 30 ):zoom(0.7):rotationz(180)
						c.Prev:visible(false):x( -10 ):zoom(0.125):zoom(0.7)
						self.cursorVis = i

						if Container.TransformationCommand then
							Container.TransformationCommand( self, i )
						end

						if i == 1 then
							containerYPos = self:GetY()
						end
					end,

					ToggleButtonsCommand=function(self,params)
						self:GetChild("Next"):visible(params.Visible)
						self:GetChild("Prev"):visible(params.Visible)
					end,

					CheckForMessagesMessageCommand=function(self,params)
						if not self.container then return end

						if self.container.SubscribedMessage and self.container.SubscribedMessage == params.Value then
							if self.container.UpdateFromMessage then
								-- Reverse logic is fun?
								if self.container.UsePrefs then
									params.PrefsManager = PrefsManager
								end
								self.container.UpdateFromMessage( self.container, self.container.ValueE, InputTiedTo, params )
								self:linear(0.1):diffuse( self.container.Disabled and color("#777777") or Color.White )
								self.handler( self, self.container.ValueE )
							end
						end
					end,

					DisplayInformationCommand=function(self,container)
						self.container = container
						local c = self:GetChildren()
						if not self.container then
							ValueTypeHandler["nil"](self)
							self.valueType = nil
							self.action = handleAction.default
							c.icon:Load( nil )
							c.PrevAction:visible(false)
							c.ClickAction:visible(false)
							c.MainClickArea:visible(false)
							return
						end
						
						self.valueType = self.container.Type or nil
						if self.container.Menu then
							self.valueType = "menu"
						end

						self:diffuse( self.container.Disabled and color("#777777") or Color.White )

						-- Bring the handler to update the visible information.
						self.handler = ValueTypeHandler[self.valueType] or ValueTypeHandler.default
						self.handler(self, self.container.ValueE)
						self.action = handleAction[self.valueType] or handleAction.default
						
						local needshrinking = { ["list"] = true, ["number"] = true }

						c.PrevAction:visible( needshrinking[self.valueType] ~= nil  )
						c.ClickAction:visible( needshrinking[self.valueType] ~= nil or self.valueType == "boolean" )
						c.MainClickArea:visible( self.valueType ~= nil and self.valueType ~= "label" )

						c.icon:Load( self.container.Icon or nil )
						:zoom( TF_WHEEL.Resize(c.icon:GetWidth(),c.icon:GetHeight(),28,28) )
						c.BG:visible( self.valueType ~= "label" )

						local BGWidth = ItemWidth
						c.Label:visible(true):settext( container.Name or "" )

						-- If the theme has chosen to enable translations, check the type the value to convert from
						-- and process it.
						if Container.TranslateValueNames and container.Name then
							local translationTypes = {
								["song_option"] = "OptionTitles",
								["system_option"] = "OptionTitles",
								["system_option_table"] = "OptionTitles",
								["player_mod"] = "OptionNames"
							}
							local typeTrs = container.Translate and "OptionTitles" or (translationTypes[container.Value] or "OptionTitles")
							if typeTrs then
								if THEME:HasString(typeTrs, container.Name) then
									local TranslatedValue = THEME:GetString(typeTrs, container.Name)
									c.Label:settext( TranslatedValue )
								end
							end
						end

						c.Label:maxwidth( ItemWidth * ( needshrinking[self.valueType] and 0.35 or 1.6 ) )
						:x( -BGWidth*.5 + (self.container.Icon and 60 or 20) )
						:zoom( self.valueType == "label" and .8 or TF_WHEEL.Resize( c.Label:GetWidth(), c.Label:GetHeight(), ItemWidth * 1.6, 15 ) )
					end,

					FORCEOptionListStringsMessageCommand=function(self)
						self:playcommand("DisplayInformation",CurrentMenu[i+YOffset])
					end,

					UpdateControllersCommand=function(self,container)
						if not self.container then return end

						-- Update the current value with the available option.
						local LookUp

						if self.container.Load then
							LookUp = self.container.Load
						else
							LookUp = DataGet[self.container.Value] or DataGet.default
						end
						-- Add the set option if there was a get different from default.
						self.set = DataSet[self.container.Value] or nil
						if self.container.Save then
							self.set = self.container.Save
						end
						self.container.ValueE = LookUp(self, InputTiedTo)

						self.handler(self, self.container.ValueE)

						-- Perform a function after succesfully loading the data in.
						if self.container.AfterLoad then
							if self.container.AfterLoad(self) then
								-- The command returned true, that means they want to broadcast
								-- a value state change like CheckForMessages!
								MESSAGEMAN:Broadcast("CheckForMessages",{Value=self.container.Name})
							end
						end
					end,

					ActiveCommand=function(self) end,
					InactiveCommand=function(self) end,
					GainFocusCommand=function(self)
						self:stoptweening():decelerate(0.2):zoom(1)
						:diffuse( BoostColor(GameColor.Custom["MenuButtonBorder"], 1) )
					end,
					LoseFocusCommand=function(self)
						self:stoptweening():decelerate(0.2):zoom(1)
						:diffuse( Color.White )
					end,

					(Container.Frame and Container.Frame( ItemWidth, InputTiedTo )..{
						Name="BG"
					}
						or Def.Quad{
							Name="BG",
							InitCommand=function(self)
								self:diffuse( BoostColor(GameColor.Custom["MenuButtonBorder"], 0.5) )
								:zoomto( ItemWidth, 40 )
							end,
							ColorSchemeChangedMessageCommand=function(self)
								self:finishtweening():diffuse( BoostColor(GameColor.Custom["MenuButtonBorder"], 0.5) )
							end
						}
					),

					Def.Sprite{
						Name="icon",
						InitCommand=function(self)
							self:x( -ItemWidth*.5 + 34 )
						end
					},

					Def.BitmapText{ Name="Label", Font="_Bold" },
					Def.BitmapText{ Name="Value", Font="Common Normal" },

					Def.ActorFrame{
						Name="Next",
						buttonBoxGen(40,40,2),
						Def.Sprite{ Texture=THEME:GetPathG("","UI/Back") },
					},
					Def.ActorFrame{
						Name="Prev",
						buttonBoxGen(40,40,2),
						Def.Sprite{ Texture=THEME:GetPathG("","UI/Back") },
					},

					Def.Sprite{
						Name="image",
						Texture=Container.BoolImage or THEME:GetPathG("","switch"),
						InitCommand=function(self)
							self:setstate(0):animate(0):zoom(0.25)
							:x( ItemWidth*.5 - 50 )

							if needsColorBoolean then
								self:diffuse( PlayerColor(InputTiedTo) )
							end
						end
					},

					---------
					--	TODO: This combination of 4 possible touch areas
					--	has created a situation where an input can eat into another
					--	causing a two-tap buffer. Deal with this!
					--	- Jose_Varela
					---------

					-- Clickable cursor area
					LoadModule("UI/UI.ClickArea.lua"){
						Width = 60,
						Height = 30,
						ReturnAdjacentActorFrame = true,
						Position = function(self)
							local bg = self:GetParent():GetChild("BG")
							-- It's possible the actorframe might've set a height.
							self:zoomto( ItemWidth, bg:GetZoomedHeight() )
						end,
						Action = function(self)
							if not AllowedToClickArea(self) then return end

							-- Allow going to other menus on any area of the button.
							local allowed = {
								action = true,screen = true,
								cancel = true,menu = true,message = true,
							}

							if allowed[self.valueType] then
								self.pn = InputTiedTo
								self.action( self, i+YOffset )
								self.pn = nil
							else
								-- Couldn't find an action, just move the cursor.
								cursor = i + YOffset
								this:MoveSelection(0,InputTiedTo,true)
							end
						end
					}.. { Name="MainClickArea" },

					-- Boolean toggle switch
					LoadModule("UI/UI.ClickArea.lua"){
						Width = 20,
						Height = 30,
						ReturnAdjacentActorFrame = true,
						Position = function(self)
							self:x( ItemWidth*.5 - 50 )
						end,
						Action = function(self)
							if not AllowedToClickArea(self) then return end

							local allowed = { ["boolean"] = true, ["number"] = true, ["list"] = true }
							if not allowed[self.valueType] then return end

							self.pn = InputTiedTo
							self.action(self, i+YOffset)
							self.pn = nil
							if self.set then
								PerformSetCall(self, InputTiedTo )
							end
							CheckNotify(i+YOffset,InputTiedTo)
						end
					} .. { Name="ClickAction" },

					-- Choice for previous
					LoadModule("UI/UI.ClickArea.lua"){
						Width = 60,
						Height = 30,
						ReturnAdjacentActorFrame = true,
						Position = function(self)
							self:x( self:GetParent():GetChild("Prev"):GetX() )
							:zoomtowidth( self:GetParent():GetChild("Prev"):GetZoomedWidth() + 20 )
						end,
						Action = function(self)
							if not AllowedToClickArea(self) then return end
							
							local allowed = { ["number"] = true, ["list"] = true }
							if not allowed[self.valueType] then return end

							self.pn = InputTiedTo
							self.action(self, i+YOffset, true)
							self.pn = nil
							if self.set then
								PerformSetCall( self, InputTiedTo )
							end
							CheckNotify(i+YOffset,InputTiedTo)
						end
					} .. { Name="PrevAction" },
				}
			end

			t[#t+1] = Def.ActorFrame{
				Name="BackBG",
				InitCommand=function(self)
					self:xy( -ItemWidth*.5 + 24, -6 )
				end,
				LoadModule("UI/UI.ButtonBox.lua")(40,40,2),
				Def.Sprite{ Texture=THEME:GetPathG("","UI/Back") }
			}

			t[#t+1] = Def.Quad{
				Name="Scroller",
				InitCommand=function(self)
					self:zoomto(16,30)
					:x( -ItemWidth*.5 - 10 )
					:visible( Container.ShowScroller or true )
				end,
				MovePositionCommand = function(self,param)
					if #CurrentMenu < numObjects then self:visible(false) return end
					self:visible(true):stoptweening():easeoutexpo(0.2)

					local midPoint = math.floor(numObjects/2)
					if cursor >= midPoint and cursor <= (#CurrentMenu - midPoint) then
						self:y( scale( cursor, midPoint, (#CurrentMenu - midPoint)-1, 12, 42 * numObjects  )  )
					end
				end
			}

			t[#t+1] = (
					Container.Cursor and
					Container.Cursor( ItemWidth, InputTiedTo )
					or Def.Quad{
						InitCommand=function(self)
							self:y( 32 ):zoomto(ItemWidth,40):diffusealpha(0.5)
						end
					}
				)..{
				Name="Cursor",
				InitCommand=function(self)
					self.OGWidth = ItemWidth
					self.OGHeight = ItemHeight
				end,
				MovePositionCommand = function(self,param)
					self:stoptweening():easeoutexpo(0.2)

					-- If the user requested a custom transformation method, move the cursor to these positions as well.
					if Container.TransformationCommand then
						Container.TransformationCommand(self, param.Offset)
					else
						self:y( 32 + (32 * (param.Offset-1)) )
					end

					if param.Offset == 0 then
						self:xy(
							self:GetParent():GetChild("BackButton"):GetX(),
							self:GetParent():GetChild("BackButton"):GetY()
						)
					end

					if Container.Cursor ~= nil then
						self:playcommand("CursorFrameChange",{ Width = ItemWidth, isMenuButton = param.Offset == 0 })
					else
						-- Version with the built-in cursor
						self:zoomto( self.OGWidth, self.OGHeight )
	
						-- If the user wants to use the back button, force the cursor to it.
						if param.Offset == 0 then
							self:zoomto( 46,46 )
						end
					end

					self:GetParent():GetChild("Scroller"):playcommand("MovePosition",{Offset=param.Offset})
				end
			}

			if Container.UseMetatable then
				this.ActorFrame = t
				return this
			end
			return t
		end
	}
)
