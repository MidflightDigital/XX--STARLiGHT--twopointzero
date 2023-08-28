local SongAttributes = LoadModule "SongAttributes.lua"
local jk = LoadModule"Jacket.lua"
local aspectRatio = GetScreenAspectRatio()
local RepeatRateTime = 1 / THEME:GetMetric( Var "LoadingScreen", "RepeatRate" )
local isEventMode = GAMESTATE:IsEventMode()
local doneWithInput = false
local holdingSelect = false

local UseTwoStepDiff = LoadModule("Config.Load.lua")("UseTwoStepDiff","/Save/OutFoxPrefs.ini")

-- Useful function for determine a range and limiting it without overflowing
local function LimitRange(Val, Start, Endv, Min, Max)
    -- Unfortunately, the scale function available does not properly limit the value
    local EndVal = scale(Val, Start, Endv, Min, Max)
	return clamp( EndVal, Min, Max )
end

local PlayerAreaWidth = LimitRange(aspectRatio,1.60,1.77,350,360)

local WheelItemWidth = GAMESTATE:GetNumPlayersEnabled() == 1 and (SCREEN_WIDTH*.8 - PlayerAreaWidth) or clamp( scale(aspectRatio,1.60,1.77,300,360), 300, 700 )

local Songs
local GroupsAndSongs
local PlayerPage = {
	[PLAYER_1] = { Index = 1 },
	[PLAYER_2] = { Index = 1 }
}

local function AnyPlayerIsOnOptions()
	for player in ivalues( PlayerNumber ) do
		if PlayerPage[player].MenuOpen then
			return true
		end
	end
	return false
end

local ThreeButtonComp = PREFSMAN:GetPreference("ThreeKeyNavigation")

-- Load up the set of utilities for this wheel.
local ModuleUtils = {
	GroupSet = LoadModule("Wheel/Group.Sort.lua"),
	DynChartNames = LoadModule("Steps.GetDynamicChartName.lua"),
	SongLoader = LoadModule("Wheel/Songs.Loader.lua")
}


local LastGroup = ""

local NotEnoughStages = THEME:GetString(Var "LoadingScreen", "NotEnoughStagesToPlay")
local RestoreWheelFromSearch

local availablesortingmodes = {
	Group = { "group", "title", "artist" },
	Song = { "title", "artist", "genre", "bpm", "length" }
}

if not m_styleindex then m_styleindex = 1 end
if not m_SortingModes then m_SortingModes = { Group = 1, Song = 1 } end

local function getSortingModeFromType( type )
	return availablesortingmodes[type][ m_SortingModes[type] ]
end

local visSearch = {}

local function FetchNextAvailableStyle( StyleContainer, offset )
	m_styleindex = m_styleindex + offset
	if m_styleindex < 1 then m_styleindex = 1 end
	if m_styleindex > #StyleContainer then m_styleindex = #StyleContainer end
end

local function toggleSortingFromType( type )
	-- increase value from the sorting mode selected.
	m_SortingModes[type] = m_SortingModes[type] + 1
	if m_SortingModes[type] > #availablesortingmodes[type] then
		m_SortingModes[type] = 1
	end
end

local performedCode = false

local function GetSelectedSong( GroupsAndSongs )
	if GroupsAndSongs[CurSong] == "-RANDOM-" then
		-- Full stop.
		return "-RANDOM-"
	end
	if GroupsAndSongs[CurSong] == "-PORTAL-" then
		if (CurGroup and CurGroup ~= "") then
			return GetPreferredSelectionForRandomOrPortal( GroupsAndSongs )
		end
		return Songs[ OFMath.randomint1arg(#Songs)+1 ]
	end
	return GroupsAndSongs[CurSong]
end

local StyleTEMP

-- if not m_ChooserDiffs then m_ChooserDiffs = {} end
-- We define the curent song if no song is selected
-- We'll offset this value to 3 to avoid problems with Portal and Random not being initialized
-- properly.
if not CurSong then CurSong = 3 end

-- We define the current group to be empty if no group is defined.
if not CurGroup then GurGroup = "" end

-- The player joined.
local Joined = {}

for pn in ivalues(PlayerNumber) do
	Joined[pn] = GAMESTATE:IsPlayerEnabled(pn)
end

-- Position on the difficulty select that shows up after we picked a song.
local DiffPos = {[PLAYER_1] = 1,[PLAYER_2] = 1}
local LastDiff = {[PLAYER_1] = nil,[PLAYER_2] = nil}

local ColorBasedOnAward = LoadModule("Gameplay/ColorBasedOnAward.lua")

-- The increase offset for when we move with postive.
local IncOffset = 1

-- The decrease offset for when we move with negative.
local DecOffset = 10

-- The center offset of the wheel.
local XOffset = 5

local getJoinedPlayers = function()
	local total = 0
	for k,v in pairs(Joined) do
		if Joined[k] then
			total = total + 1
		end
	end
	return total
end

local getFirstAvailablePlayer = function()
	for k,v in pairs(Joined) do
		if Joined[k] then
			return k
		end
	end
end

local lastSong
local function GetGroupNameBasedOnSort( songToUse )
	-- If we happen to be in a player's favorite folder, do not change folder.
	for i,_ in ipairs( PlayerNumber ) do
		if CurGroup == "--P"..i.."FAV--" then
			return CurGroup
		end
	end
	
	-- Special Case: If the player hasn't actually picked anything at all, then we can't really provide
	-- an answer of where to go, so just assume to go to the default group instead.
	if not songToUse or not lastSong then
		return CurGroup
	end

	local song = type(songToUse) == "table" and songToUse or lastSong[1]
	local modes = {
		group = function() return song:GetGroupName() end,
		artist = function() return ToLower(song:GetDisplayArtist()):sub(1,1) end,
		title = function()
			-- Special case: When toggling this mode, we need to automatically set the
			-- group to the appropiate one.
			local title = ToLower(song:GetDisplayMainTitle()):sub(1,1)
			-- Check it's type.
			if title:match("%W") then
				-- Ok, it's not alphanumerical, so see if it's a number, or it'll go to the other container.
				title = tonumber(title) and "number" or "other"
			end

			return title
		end
	}
	return modes[ getSortingModeFromType("Group") ]()
end

local mainActorFrame = nil

local newsong
local function UpdateCurrentlyPlayingMusic(self,Songs)
	-- Check if its a song.
	if newsong and type(newsong) ~= "string" then
		-- Play Current selected Song Music.
		-- If there's already an audio preview playing on the sound manager, don't perform the change.
		SOUND:StopMusic()

		if newsong[1]:GetMusicPath() ~= SOUND:GetMusicPath() then
			self:stoptweening():sleep(0.25):queuecommand("PlayCurrentSong")
		end
	else
		-- Group / nil, stop music.
		SOUND:PlayMusicPart(GetMenuMusicPath("music"),0,-1,0,0,true)
	end
end

local function FetchStepsForWheelItem(pn)
	if inPortal then
		return newsong[DiffPos[pn]+1]
	end
	return GroupsAndSongs[CurSong][DiffPos[pn]+1]
end

-- Change the cursor of Player on the difficulty selector.
local function MoveDifficulty(self,offset)
	if doneWithInput then return end
	if holdingSelect then return end
	local player = self.pn

	-- check if player is joined.
	if not Joined[player] then return end
	if PlayerPage[player].MenuOpen then
		PlayerPage[player].OptionListHandler:MoveSelection(offset,player)
		return
	end
	
	-- Is the current selected item a song?
	if type(newsong) == "string" then return end

	-- Move cursor.
	DiffPos[player] = DiffPos[player] + offset

	-- Keep within boundaries.
	if DiffPos[player] < 1 then
		DiffPos[player] = 1
	end
	if DiffPos[player] > #newsong-1 then
		DiffPos[player] = #newsong-1
	end
	if DiffPos[player] <= 1 or DiffPos[player] >= #newsong-1 then
		self:GetChild("NoDiffSound"):play()
	else
		self:GetChild("DiffSound"):play()
	end

	LastDiff[player] = FetchStepsForWheelItem(player):GetDifficulty()

	-- If BothAtOnce is enabled, then it's likely the user is going to play on both areas
	-- at the same time, so match the diffs.
	if tobool(PREFSMAN:GetPreference("BothAtOnce")) then
		for pn in ivalues(PlayerNumber) do
			DiffPos[pn] = DiffPos[player]
			LastDiff[pn] = LastDiff[player]
			MESSAGEMAN:Broadcast("PlayerSwitchedStep",{ Player = pn, Index = DiffPos[pn]+1, Song = newsong })
		end
		return
	end

	-- Send information to other actors so they can use it.
	MESSAGEMAN:Broadcast("PlayerSwitchedStep",{ Player = player, Index = DiffPos[player]+1, Song = newsong })

	GAMESTATE:SetCurrentSteps(player, newsong[DiffPos[player]+1])
end

local wheelItemYSpacing = 45
local wheelItemCenterSpacing = 0

local function CalcOffsetForSpot( valoffset, i )
	local yoffset = valoffset*wheelItemYSpacing
	-- Off from center.
	local needsTweening = true

	if valoffset == 0 then return yoffset end

	-- Calculate the points after the wheel.
	if valoffset > 0 then
		yoffset = wheelItemCenterSpacing+valoffset*wheelItemYSpacing
		if (i-XOffset) >= 6 then
			needsTweening = false
			yoffset = (wheelItemYSpacing * -13) + (-wheelItemCenterSpacing+valoffset*wheelItemYSpacing)
		end
	end
	if valoffset < 0 then
		yoffset = -wheelItemCenterSpacing+valoffset*wheelItemYSpacing
		if (i-XOffset) <= -7 then
			needsTweening = false
			yoffset = (wheelItemYSpacing * 14) + (-wheelItemCenterSpacing+valoffset*wheelItemYSpacing)
		end
	end

	return yoffset
end

-- Move the wheel, We define the Offset using +1 or -1.
-- We parse the Songs also so we can get the amount of songs.
local function MoveSelection(self,offset,Songs,ignoreRules)
	if doneWithInput then return end

	-- check if player is joined if the parameter is given.
	if self.pn then
		if not Joined[self.pn] then self.pn = nil return end
		if PlayerPage[self.pn].MenuOpen and not ignoreRules then self.pn = nil return end
	end

	-- Curent Song + Offset.
	CurSong = CurSong + offset
	
	-- Check if curent song is further than Songs if so, reset to 1.
	if CurSong > #Songs then CurSong = 1 end
	-- Check if curent song is lower than 1 if so, grab last song.
	if CurSong < 1 then CurSong = #Songs end
	
	if (offset ~= 0 or IsTouch) then
		newsong = GetSelectedSong(Songs)
		if type(newsong) == "table" then
			lastSong = newsong
		end
	end
	
	-- Simple flag to avoid sending SongInfoBox repeat data.
	local songChanged = newsong and GAMESTATE:GetCurrentSong() ~= newsong[1] or true
	if newsong then
		GAMESTATE:SetCurrentSong(newsong[1])
	end
	-- Set the offsets for increase and decrease.
	DecOffset = DecOffset + offset
	IncOffset = IncOffset + offset

	if DecOffset > 10 then DecOffset = 1 end
	if IncOffset > 10 then IncOffset = 1 end

	if DecOffset < 1 then DecOffset = 10 end
	if IncOffset < 1 then IncOffset = 10 end
	
	-- Set the offset for the center of the wheel.	
	XOffset = XOffset + offset
	if XOffset > 10 then XOffset = 1 end
	if XOffset < 1 then XOffset = 10 end

	-- If we are calling this command with an offset that is not 0 then do stuff.
	if offset ~= 0 then

		-- For every part on the wheel do.
		for i = 1,10 do
			-- Calculate current position based on song with a value to get center.
			local pos = CurSong+(4*offset)

			if offset == 1 then
                pos = CurSong+(5*offset)
            end
		
			-- Keep it within reasonable values.
			while pos > #Songs do pos = pos-#Songs end
			while pos < 1 do pos = #Songs+pos end

			self:GetChild("Wheel"):GetChild("Container"..i):stoptweening(0.1):linear(0.08):addx( (offset*-280) )


			-- Here we define what the wheel does if it is outside the values.
			-- So that when a part is at the bottom it will move to the top.
			if (i == IncOffset and offset == -1) or (i == DecOffset and offset == 1) then
				-- Send the current information back to the wheel to update its contents.
				self:GetChild("Wheel"):playcommand("UpdateContainer",{Data=Songs[pos],Offset = i})
				self:GetChild("Wheel"):GetChild("Container"..i):sleep(0):addx((offset*-280)*-10)
			end
		end
	
		self:GetChild("SongInfoBox"):playcommand("UpdateSongInfo",{Data=newsong,visSearch=visSearch})
		self:GetChild("Additional"):GetChild("BPM"):playcommand("UpdateSongInfo",{Data=newsong})
		self:GetChild("Toolkit"):GetChild("GroupChooser"):playcommand("UpdateSongInfo",{Data=newsong})
		-- We have a top banner and an under banner to make smooth transisions between songs.

	-- We are on an offset of 0.
	else

		if songChanged then
			self:GetChild("SongInfoBox"):playcommand("UpdateSongInfo",{Data=newsong,visSearch=visSearch})
			self:GetChild("Additional"):GetChild("BPM"):playcommand("UpdateSongInfo",{Data=newsong})
			self:GetChild("Toolkit"):GetChild("GroupChooser"):playcommand("UpdateSongInfo",{Data=newsong})
		end

		-- For every part of the wheel do.
		for i = 1,10 do	

			-- Offset for the wheel items.
			local off = i + XOffset

			-- Stay withing limits.
			while off > 10 do off = off-10 end
			while off < 1 do off = off+10 end

			-- Get center position.
			local pos = CurSong+i

			-- If item is above 6 then we do a +13 to fix the display.
			if i > 5 then
				pos = CurSong+i-10
			end

			-- Keep pos withing limits.
			while pos > #Songs do pos = pos-#Songs end
			while pos < 1 do pos = #Songs+pos end

			-- Send the current information back to the wheel to update its contents.
			self:GetChild("Wheel"):playcommand("UpdateContainer",{Data=Songs[pos],Offset = off})
		end

		self:GetChild("SongInfoBox"):playcommand("UpdateSongInfo",{Data=newsong})
		self:GetChild("Additional"):GetChild("BPM"):playcommand("UpdateSongInfo",{Data=newsong})
		self:GetChild("Toolkit"):GetChild("GroupChooser"):playcommand("UpdateSongInfo",{Data=newsong})

	end
	
	-- Check if it's a song.
	for pn in ivalues(PlayerNumber) do 
		if GAMESTATE:IsPlayerEnabled(pn) then
			if type(newsong) ~= "string" then
				local foundDiff = false

				for i=2,#newsong do
					if newsong[i]:GetDifficulty() == LastDiff[pn] then
						DiffPos[pn] = i-1
						foundDiff = true
						break
					end
				end
				if not foundDiff then
					if DiffPos[pn] > #newsong-1 then
						DiffPos[pn] = #newsong-1
					end
				end

				
				MESSAGEMAN:Broadcast("PlayerSwitchedStep",{ Player = pn, Force = true, Index = DiffPos[pn]+1, Song = newsong })

			else
				MESSAGEMAN:Broadcast("PlayerSwitchedStep",{ Player = pn, Song = "" })
			end
		end
	end

	-- Check if offset is not 0.
	if offset ~= 0 then
		
		-- self:GetChild("Slider"):stoptweening():linear(.1):y( SCREEN_HEIGHT * (CurSong/#Songs) )

		-- Stop all the music playing, Which is the Song Music
		if not IsTouch then
			UpdateCurrentlyPlayingMusic(self,Songs)
		end

		self:GetChild("ChangeSound"):play()
	else
		-- self:GetChild("Slider"):y( SCREEN_HEIGHT*(CurSong/#Songs) )

		if IsTouch and hasHitAnotherSong then
			UpdateCurrentlyPlayingMusic(self,Songs)
		end
	end

	-- We're done, clear the player buffer.
	self.pn = nil
end

local function CheckStageAvailability( song )
	if not song then return false end
	return isEventMode or (song:GetStageCost() <= GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()))
end

local WheelItemsActorFrame
local WIAF = Def.ActorFrame{
	InitCommand=function(self)
		WheelItemsActorFrame = self
		-- Hide the actorframe, the Actor Proxy will deal with showing it.
		self:visible(false)
	end,
	CancelCommand=function(self)
		self:RunCommandsRecursively(function(self)
			self:easeinexpo(0.2):diffusealpha(0)
		end)
	end,

	-- Generate actors that will represent the background items for the wheel.
	-- To avoid generating a lot of sprite instances, we'll use actor proxies to point to these instead.
	Def.Quad{
		Name="ItemBG",
		InitCommand=function(s) s:setsize(234,234):diffuse(Alpha(Color.White,0.5)) end,
	}
}

-- This is the main function, Its the function that contains the wheel.
return function(Style)

	local function ApplyNewGroupsAndSongs()
		GAMESTATE:Env()["containerStringSongSet"] = nil
		GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,CurGroup,CurSearch,getSortingModeFromType("Group"),getSortingModeFromType("Song"))
		GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]
	end

	StyleTEMP = Style

	-- Load the songs from the Songs.Loader module.
	if m_styleindex > #Style then m_styleindex = 1 end
	Songs = ModuleUtils.SongLoader(Style[m_styleindex])

	-- No songs were found on the current mode? Check the next one.
	while( #Songs == 0 ) do
		m_styleindex = m_styleindex + 1
		-- We're out of bounds, stop operation.
		if m_styleindex > #Style then
			m_styleindex = #Style
			break
		end

		Songs = ModuleUtils.SongLoader(Style[m_styleindex])
	end

	local initialFetchForPlayerProfileSong = false

	if not GAMESTATE:Env()["GroupsAndSongs"] then
		-- When entering this screen for the first time, the selection is going to be null, so make the player be pointed to
		-- their last played song just like in the engine wheel.
		local songToFind = nil
		local pMatch = PROFILEMAN:GetProfile( GAMESTATE:GetMasterPlayerNumber() )

		if pMatch then
			songToFind = pMatch:GetLastPlayedSong()
			if songToFind then
				initialFetchForPlayerProfileSong = songToFind
				CurGroup = songToFind:GetGroupName()
			end
		end

		GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,CurGroup,KeepSearch and CurSearch or nil,getSortingModeFromType("Group"),getSortingModeFromType("Song"))
	end

	GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]

	-- Sort the Songs and Group.
	-- local GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,CurGroup,KeepSearch and CurSearch or nil,getSortingModeFromType("Group"),getSortingModeFromType("Song"))

	newsong = GroupsAndSongs[CurSong]

	local function FindNextAvailableSongInGroup()
		local attempts = 0
		local num = 0
		while ( attempts < 13 ) do
			if type(GroupsAndSongs[num]) == "table" then
				CurSong = num
				return true
			end
			num = num + 1
			attempts = attempts + 1
		end
		return false
	end
	
	-- Set CurSong to the right group.
	local function FindSongInGroup(song)
		for i,v in ipairs(GroupsAndSongs) do
			if type(v) == "table" and v[1] == song then
				CurSong = i
				return true
			end
		end

		return false
	end

	-- Needed for the initial state-player profile fetching.
	if initialFetchForPlayerProfileSong then
		FindSongInGroup( initialFetchForPlayerProfileSong )
		newsong = GroupsAndSongs[CurSong]
	end

	-- The actual wheel.
	local Wheel = Def.ActorFrame{
		Name="Wheel",
		InitCommand=function(self)
			self:AddWrapperState()
		end,
		CloseMenuCommand=function(self)
			self:diffuse(Color.White)
		end,
		UpdateContainerCommand=function(self,params)
			-- It's a song, Display song title.
			local container = self:GetChild("Container"..params.Offset)
			-- This is a shortcut to obtain the children actors to modify.
			local c = container:GetChildren()

			c.WheelPointer:SetTarget(WheelItemsActorFrame:GetChild("ItemBG"))
			if type(params.Data) ~= "string" then
				local found = false
				local pSong = params.Data[1]
				if pSong:GetJacketPath() then
					-- Load the cached version of the jacket instead.
					-- TODO: Maybe add support to cache jackets.
					c.JacketContainer:LoadFromCached("jacket",pSong:GetJacketPath() )
					:scaletofit( -c.JacketContainer.expectedSize/2, -c.JacketContainer.expectedSize/2, c.JacketContainer.expectedSize/2, c.JacketContainer.expectedSize/2 )
					found = true
				else
					if pSong:GetBannerPath() then
						c.JacketContainer:LoadFromCached("banner",pSong:GetBannerPath() )
						:scaletofit( -c.JacketContainer.expectedSize/2, -c.JacketContainer.expectedSize/2, c.JacketContainer.expectedSize/2, c.JacketContainer.expectedSize/2 )
						found = true
					end
					c.JacketContainer:visible(found)
				end

				-- Does the player have enough stages to play this song?
				if not CheckStageAvailability(params.Data[1]) then
					-- TODO: Redo this color by fetching it to the ItemBG item itself.
				end
			else
				if jk.GetGroupGraphicPath(params.Data,"Jacket","SortOrder_Group") ~= "" then
					c.JacketContainer:Load(jk.GetGroupGraphicPath(params.Data,"Jacket","SortOrder_Group"))
					:visible(true)
					:scaletofit( -c.JacketContainer.expectedSize/2, -c.JacketContainer.expectedSize/2, c.JacketContainer.expectedSize/2, c.JacketContainer.expectedSize/2 )
						
				end
			end

			-- Check if it's a song.
			if type(params.Data) == "string" then return end

			if not inSearchMode then return end
		end
	}

	local function UpdateSortingFolders()
		mainActorFrame:GetChild("Toolkit"):GetChild("SortingMethodsInsideFolder"):playcommand("UpdateSongSort",{inSearchMode = inSearchMode, Mode = getSortingModeFromType("Song")})
		mainActorFrame:GetChild("Toolkit"):GetChild("SortingMethodsFolders"):playcommand("UpdateGroupSort",{inSearchMode = inSearchMode, Mode = getSortingModeFromType("Group")})
	end

	-- For every item on the wheel do.
	for i = 1,10 do
		-- Also grab center of wheel.
		local pos = CurSong+i-5

		-- But we keep it within limits.
		while pos > #GroupsAndSongs do pos = pos-#GroupsAndSongs end
		while pos < 1 do pos = #GroupsAndSongs+pos end
		
		-- Append to the wheel.
		Wheel[#Wheel+1] = Def.ActorFrame{
			Name="Container"..i,

			-- Set position of item.
			OnCommand=function(self)
				self:x((-280*5)+(280*i))
			end,

			CancelCommand=function(self)
				self:easeoutexpo(0.5):diffusealpha(0)
			end,

			UpdateSizeCommand=function(self)
				self:GetChild("JacketContainer"):stoptweening():easeoutexpo(0.2):x( WheelItemWidth*.5 - 14 )
			end,

			Def.ActorProxy{
				Name="WheelPointer",
				OnCommand=function(self)
					local item = "ItemBG"
					self:SetTarget( WheelItemsActorFrame:GetChild(item) )
				end
			},

			-- Jacket image spot (if available)
			Def.Sprite{
				Name="JacketContainer",
				InitCommand=function(self)
					self.expectedSize = 230
				end
			},
		}	
	end

	RestoreWheelFromSearch = function()
		if newsong == nil or lastSong == nil then return end

		local cursong = type(newsong) == "string" and lastSong[1] or newsong[1]
		CurGroup = GetGroupNameBasedOnSort(cursong)
		-- Reset the groups location so we dont bug.
		GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,"")
		GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]
		-- Set CurSong to the right group.
		for i,v in ipairs(GroupsAndSongs) do
			if v == CurGroup then
				CurSong = i
			end
		end						
		-- Set the current group.
		GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,CurGroup,CurSearch,getSortingModeFromType("Group"),getSortingModeFromType("Song"))
		GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]
		FindSongInGroup( cursong )
	end

	local PlayerInfoPanes = Def.ActorFrame{Name="PlayerInfoPanes"}

	for player in ivalues(PlayerNumber) do
		PlayerPage[player] = {Index=1,MenuOpen=false,OptionListHandler=nil}

		local PrefsManager = LoadModule("Save.PlayerPrefs.lua")
		PrefsManager:Load( CheckIfUserOrMachineProfile(string.sub(player,-1)-1).."/OutFoxPrefs.ini" )

		local playerInfo = Def.ActorFrame{
			Name=player,
			InitCommand=function(s)
				s:xy(player == PLAYER_1 and (IsUsingWideScreen() and _screen.cx-566 or _screen.cx-420) or
				(IsUsingWideScreen() and _screen.cx+566 or _screen.cx+420)
				,_screen.cy-200)
				:visible(GAMESTATE:IsPlayerEnabled(player))
			end,
			PlayerJoinedMessageCommand=function(self)
				self:visible(true)
				-- Load the profles.
				GAMESTATE:LoadProfiles()
			end,
			LoadModule("Wheel/Objects/DiffSelector.lua"){
				Player = player,
			}..{
			},
		}

		PlayerInfoPanes[#PlayerInfoPanes+1] = playerInfo
	end

	local t = Def.ActorFrame{
		OnCommand=function(self)
		end
	}

	t[#t+1] = Def.ActorFrame{
		OnCommand=function(self)
			if (not GAMESTATE:IsEventMode() and GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()) <= 0) then
				lua.ReportScriptError("Woah, there's no more stages, how are you here?")
			end

			SOUND:PlayAnnouncer("select music intro")

			mainActorFrame = self
			-- We use a Input function from the Scripts folder.
			-- It uses a Command function. So you can define all the Commands,
			-- Like MenuLeft is MenuLeftCommand.
			SCREENMAN:GetTopScreen():AddInputCallback(TF_WHEEL.Input(self))
			
			for a,pn in ipairs( GAMESTATE:GetHumanPlayers() ) do
				if type(GroupsAndSongs[CurSong]) ~= "table" then break end
				local lastDifficultySelected = PROFILEMAN:GetProfile(pn):GetLastDifficulty()
				for i = 2,#GroupsAndSongs[CurSong] do
					if GAMESTATE:GetCurrentSteps(pn) then
						if GroupsAndSongs[CurSong][i] == GAMESTATE:GetCurrentSteps(pn) then
							DiffPos[pn] = i
							LastDiff[pn] = GAMESTATE:GetCurrentSteps(pn):GetDifficulty()
						end
					else
						-- We don't have steps selected, so grab the difficulty saved from stats.
						if GroupsAndSongs[CurSong][i]:GetDifficulty() == lastDifficultySelected then
							lua.ReportScriptError("match")
							DiffPos[pn] = i
							LastDiff[pn] = lastDifficultySelected
						end
					end
				end
			end

			UpdateSortingFolders()
			
			local StageIndex = GAMESTATE:GetCurrentStageIndex()
			
			MoveSelection(self,0,GroupsAndSongs)
			
			-- Sleep for 0.2 sec, And then load the current song music.
			if type(GroupsAndSongs[CurSong]) ~= "string" and GroupsAndSongs[CurSong][1]:GetMusicPath() then
				self:GetChild("SongInfoBox"):playcommand("UpdateSongInfo",{Data=GroupsAndSongs[CurSong],visSearch=visSearch})
				for i,player in ipairs( PlayerNumber ) do
					MESSAGEMAN:Broadcast("PlayerSwitchedStep",{ Player = player, Force = true, Index = DiffPos[player]+1, Song = GroupsAndSongs[CurSong] })
				end
			end
			self:sleep(0.2):queuecommand("PlayCurrentSong")
		end,

		-- Play Music at start of screen,.
		PlayCurrentSongCommand=function(self)
			if type(newsong) ~= "string" and newsong[1]:GetMusicPath() then
				-- If there's already an audio preview playing on the sound manager, don't perform the change.
				-- newsong[1]:PlayPreviewMusic()
				-- TODO: Make support for the different SampleMode types.

				-- ???: Needed here so it doesn't
				-- freeze when going to player options.
				for i,player in ipairs( PlayerNumber ) do
					local prof = PROFILEMAN:GetProfile(player)
					if newsong[1]:GetGroupName() == prof:GetDisplayName() then
						GAMESTATE:prepare_song_for_gameplay()
						break
					end
				end

				-- Before playing, does the song actually have a song path to play from?
				if string.find(newsong[1]:GetMusicPath(), "/EMPTY") then return end

				SOUND:PlayMusicPart(newsong[1]:GetMusicPath(),newsong[1]:GetSampleStart(),-1,0,0,true,true,false,newsong[1]:GetTimingData())
				-- newsong[1]:PlayPreviewMusic()
			end
		end,

		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuDownCommand=function(self) MoveDifficulty(self,1) end,
		
		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuUpCommand=function(self) MoveDifficulty(self,-1) end,

		-- Do stuff when a user presses the Back on Pad or Menu buttons.
		BackCommand=function(self) 
			-- Check if User is joined.
			if Joined[self.pn] then
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					-- If both players are joined, We want to unjoin the player that pressed back.
					Joined[self.pn] = false
					GAMESTATE:UnjoinPlayer(self.pn)
					GAMESTATE:SetCurrentStyle("single")

					MoveSelection(self,0,GroupsAndSongs)
				else
					PROFILEMAN:SaveProfile(self.pn)
					-- Go to the previous screen.
					CurSearch = ""
					SCREENMAN:GetTopScreen():Cancel()
				end
			end
		end,

		CodeMessageCommand=function(self,param)
			if param.Name == "SortChange" then
				-- Update the sorting mode.
				holdingSelect = true
				performedCode = true
				toggleSortingFromType( "Song" )
				RestoreWheelFromSearch()
				UpdateSortingFolders()
				hasHitAnotherSong = true
				MoveSelection(mainActorFrame,0,GroupsAndSongs,true)
				return
			end

			if param.Name == "CloseGroup" then
				-- Don't allow this while searching.
				if inSearchMode or inPortal then return end
				-- Neither if the player hasn't joined.
				if not Joined[param.PlayerNumber] then return end
				-- Nor if they're on their menu.
				if PlayerPage[param.PlayerNumber].MenuOpen then return end
				
				-- Set CurSong to the right group.
				for i,v in ipairs(GroupsAndSongs) do
					if v == CurGroup then
						CurSong = i
					end
				end

				self.pn = param.PlayerNumber

				CurGroup = ""
				newsong = ""
				GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,"")
				GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]
				MoveSelection(self,0,GroupsAndSongs,true)

				-- Reset the groups location so we dont bug.
				GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,CurGroup,nil,getSortingModeFromType("Group"),getSortingModeFromType("Song"))
				GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]
				hasHitAnotherSong = true
				MoveSelection(self,0,GroupsAndSongs,true)
			end

			if param.Name == "NextSong" or param.Name == "PrevSong" then
				if not Joined[param.PlayerNumber] then return end
				
				local offset = ( param.Name == "PrevSong" and -1 or 1 )
				if PlayerPage[param.PlayerNumber].MenuOpen then
					if ThreeButtonComp then
						if PlayerPage[param.PlayerNumber].OptionListHandler:InSpecialMenu() then
							PlayerPage[param.PlayerNumber].OptionListHandler:ChangeValue(offset, param.PlayerNumber)
						else
							PlayerPage[param.PlayerNumber].OptionListHandler:MoveSelection(offset,param.PlayerNumber)
						end
					else
						PlayerPage[param.PlayerNumber].OptionListHandler:ChangeValue(offset, param.PlayerNumber)
					end
					return
				end

				MoveSelection(self,offset,GroupsAndSongs)
			end
		end,

		ShowNotEnoughStagesCommand=function(self)
			-- If we're not in event mode, does the player have enough stages to play this song?
			self:GetChild("Wheel"):GetChild("Container"..XOffset):playcommand("ShakeContainer")
			self:GetChild("ItemLocked"):play()
		end,

		PlayerJoinedMessageCommand=function(self,params)
			ApplyNewGroupsAndSongs()
			RestoreWheelFromSearch()
			UpdateSortingFolders()
			hasHitAnotherSong = true

			local newwidth = clamp( scale(aspectRatio,1.60,1.77,300,360), 300, 700 )
			WheelItemWidth = newwidth
			self:GetChild("PlayerInfoPanes"):GetChild(params.Player):visible(true)
			WheelItemsActorFrame:playcommand("UpdateSize",{Width = newwidth - 70})
			self:GetChild("Wheel"):GetWrapperState(1):stoptweening():easeoutexpo(0.2):x( 0 )
			self:GetChild("Wheel"):playcommand("UpdateSize")

			self:GetChild("SongInfoBox"):playcommand("UpdateSize",{Width = newwidth - 40}):stoptweening():easeoutexpo(0.2)
			:x( SCREEN_CENTER_X )
			GAMESTATE:SetCurrentSteps(params.Player, newsong[DiffPos[params.Player]+1])

			MESSAGEMAN:Broadcast("PlayerSwitchedStep",{ Player = params.Player, Index = DiffPos[params.Player]+1, Song = newsong })

			-- Turn off the group display as it clips into player 2.
			self:GetChild("Toolkit"):playcommand("Compact")

			self:GetChild("SongInfoBox"):playcommand("UpdateSongInfo",{Data=GroupsAndSongs[CurSong]})
			MoveSelection(mainActorFrame,0,GroupsAndSongs,true)
		end,

		PlayerUnjoinedMessageCommand=function(self,params)
			ApplyNewGroupsAndSongs()
			RestoreWheelFromSearch()
			UpdateSortingFolders()
			hasHitAnotherSong = true
			---
			WheelItemWidth = (SCREEN_WIDTH*.8 - PlayerAreaWidth)
			WheelItemsActorFrame:playcommand("UpdateSize",{Width = WheelItemWidth - 70})

			local newMaster = GAMESTATE:GetMasterPlayerNumber()

			local margin = scale( aspectRatio, 1.60, 1.77, .155, .15 )

			self:GetChild("SongInfoBox"):playcommand("UpdateSize",{Width = WheelItemWidth})
			:x( SCREEN_CENTER_X + ((SCREEN_WIDTH * margin) * (newMaster == PLAYER_1 and 1 or -1))  )
			
			self:GetChild("Wheel"):GetWrapperState(1):stoptweening():easeoutexpo(0.2)
			:x( ((SCREEN_WIDTH * margin) * (newMaster == PLAYER_1 and 1 or -1)) )
			self:GetChild("Wheel"):playcommand("UpdateSize")


			self:GetChild("Toolkit"):playcommand("Extend")


			self:GetChild("SongInfoBox"):playcommand("UpdateSongInfo",{Data=GroupsAndSongs[CurSong]})
			MoveSelection(mainActorFrame,0,GroupsAndSongs,true)
		end,

		StartSongButtonMessageCommand=function(self)
			for pn in ivalues(PlayerNumber) do
				PlayerPage[pn].MenuOpen = false
				PlayerPage[pn].OptionListHandler:LockInput(true)
				-- if PlayerPage[pn].MenuOpen then
			end
			self:playcommand("Start")
		end,

		-- Do stuff when a user presses the Start on Pad or Menu buttons.
		StartCommand=function(self)
			if performedCode then
				performedCode = false
				return
			end

			-- if no player has been assigned, then consider the master player.
			if not self.pn then
				self.pn = GAMESTATE:GetMasterPlayerNumber()
			end

			-- Check if we want to go to ScreenPlayerOptions instead of ScreenGameplay.
			-- Check if player is joined.
			if Joined[self.pn] then 
				if PlayerPage[self.pn].MenuOpen then
					PlayerPage[self.pn].OptionListHandler:ConfirmSelection( self.pn )
					return
				end
			
				-- Check if we are on a group.
				if type(GroupsAndSongs[CurSong]) == "string" then
				
					-- Check if we are on the same group thats currently open,
					-- If not we set the curent group to our new selection.
					if CurGroup ~= GroupsAndSongs[CurSong] then			
						CurGroup = GroupsAndSongs[CurSong]
					-- Same group, Close it.
					else
						CurGroup = ""
					end

					-- SPECIAL: Did the user select the RANDOM option?
					if GroupsAndSongs[CurSong] == "-RANDOM-" then
						-- Show all songs, and pick one at random.
						GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,CurGroup,"",getSortingModeFromType("Group"),getSortingModeFromType("Song"))
						GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]
						-- Force group to be empty
						CurGroup = ""
						newsong = GetPreferredSelectionForRandomOrPortal( GroupsAndSongs )
						RestoreWheelFromSearch()
						hasHitAnotherSong = true
						MoveSelection(mainActorFrame,0,GroupsAndSongs,true)
						return
					end
					
					-- Reset the groups location so we dont bug.
					GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,"")
					GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]
					MoveSelection(self,0,GroupsAndSongs)
					
					-- Set CurSong to the right group.
					if getSortingModeFromType("Group") == "group" then
						for i,v in ipairs(GroupsAndSongs) do
							if v == CurGroup then
								CurSong = i
							end
						end
					end

					-- Set the current group.
					GAMESTATE:Env()["GroupsAndSongs"] = ModuleUtils.GroupSet(Songs,CurGroup,nil,getSortingModeFromType("Group"),getSortingModeFromType("Song"))
					GroupsAndSongs = GAMESTATE:Env()["GroupsAndSongs"]

					if getSortingModeFromType("Group") ~= "group" then
						for i,v in ipairs(GroupsAndSongs) do
							if v == CurGroup then
								CurSong = i
							end
						end
					end

					MoveSelection(self,0,GroupsAndSongs)

				-- Not on a group, Start song.
				else
					if not CheckStageAvailability(newsong[1]) then
						self:playcommand("ShowNotEnoughStages")
						return
					end
					
					--We use PlayMode_Regular for now.
					GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
					
					--Set the song we want to play.
					GAMESTATE:SetCurrentSong(newsong[1])
					GAMESTATE:SetPreferredSong( newsong[1] )
					
					-- Check if 2 players are joined.
					if Joined[PLAYER_1] and Joined[PLAYER_2] then
				
						-- Is someone on a menu? Stop!
						if PlayerPage[PLAYER_1].MenuOpen or PlayerPage[PLAYER_2].MenuOpen then
							return
						end
						-- If they are, We will use Versus.
						GAMESTATE:SetCurrentStyle('versus')
					
						-- Save Profiles.
						-- PROFILEMAN:SaveProfile(PLAYER_1)
						-- PROFILEMAN:SaveProfile(PLAYER_2)
					
						-- Set the Current Steps to use.
						GAMESTATE:SetCurrentSteps(PLAYER_1,newsong[DiffPos[PLAYER_1]+1])
						GAMESTATE:SetCurrentSteps(PLAYER_2,newsong[DiffPos[PLAYER_2]+1])
					else
				
						-- If we are single player, Use Single.
						GAMESTATE:SetCurrentStyle(TF_WHEEL.StyleDB[Style[m_styleindex]])
					
						-- Save Profile.
						-- PROFILEMAN:SaveProfile(self.pn)
					
						-- Set the Current Step to use.
						GAMESTATE:SetCurrentSteps(self.pn,newsong[DiffPos[self.pn]+1])
					end

					-- If the song comes from an external source like a USB, make
					-- sure to load it.
					local checks = GAMESTATE:prepare_song_for_gameplay()

					if checks ~= "success" then
						lua.ReportScriptError("Debug: "..checks)
						return
					end

					local isSafe,reason = GAMESTATE:CanSafelyEnterGameplay()

					if not isSafe then
						lua.ReportScriptError("Debug: "..reason)
						return
					end
					
					-- Store wheel when finished and still in search mode.
					if inSearchMode then
						if not KeepSearch then
							CurSearch = nil
						end
						-- RestoreWheelFromSearch()
					end

					doneWithInput = true

					self:stoptweening():queuecommand("StartSong")
				end
			else
				-- Add to joined list.
				Joined[self.pn] = true

				-- if THEME:GetMetric("GameState","AllowLateJoin") == false then return end
				-- If no player is active Join.
				GAMESTATE:JoinPlayer(self.pn)
				
				
				MoveSelection(self,0,GroupsAndSongs)
			end			
		end,

		PlayerOpenMenuCommand=function(self,params)
			local isEveryoneOnPause = true
			for i,pn in ipairs(GAMESTATE:GetHumanPlayers()) do
				if not PlayerPage[pn].MenuOpen then
					isEveryoneOnPause = false
				end
			end
			if not isEveryoneOnPause then return end

			self:playcommand("DimMainItems")
		end,

		DimMainItemsCommand=function(self)
			self:GetChild("Wheel"):stoptweening():linear(0.1):diffuse( color("#777777") )
			self:GetChild("SongInfoBox"):stoptweening():linear(0.1):diffuse( color("#777777") )
		end,

		RestoreItemDiffuseCommand=function(self)
			self:GetChild("Wheel"):stoptweening():linear(0.1):diffuse( Color.White )
			self:GetChild("SongInfoBox"):finishtweening():linear(0.1):diffuse( Color.White )
		end,

		-- Change to ScreenGameplay.
		StartSongCommand=function(self)

			-- TODO: Add check for different music comment modes.
			SOUND:PlayAnnouncer("select music comment general")

			local screentogo = UseTwoStepDiff and "ScreenPlayerOptionsLua" or "ScreenGameplay"
			SCREENMAN:PlayStartSound()
			if not UseTwoStepDiff then
				SOUND:Volume(0,0.3)
			end
			SCREENMAN:GetTopScreen():SetNextScreenName(screentogo):StartTransitioningScreen("SM_GoToNextScreen")
		end,

		Def.Sprite{
			Texture=THEME:GetPathG("","_SelectMusic/wheelunder.png"),
			InitCommand=function(s) 
				s:xy(_screen.cx,_screen.cy+246)
			end,
			OnCommand=function(s) s:zoomtowidth(0):linear(0.2):zoomtowidth(SCREEN_WIDTH) end,
			OffCommand=function(s) s:sleep(0.3):decelerate(0.3):zoomtowidth(0) end,
		},

		PlayerInfoPanes,

		WIAF,

		-- Load the wheel.
		Wheel..{
			OnCommand=function(self)
				self:xy(_screen.cx,_screen.cy+254):z(-200)
				self:AddWrapperState()
				self:GetWrapperState(1)
			end,
			OffCommand=function(self)
				self:stoptweening():easeinexpo(0.2):diffusealpha(0):addx(20)
			end,
		},
		Def.ActorFrame{
			Name="Toolkit",
			InitCommand=function(self)
				self.SetPosition = SCREEN_CENTER_X
				self:y( 28 )
				-- Player 2 is going to need a special offset.
				if getJoinedPlayers() == 1 and GAMESTATE:GetMasterPlayerNumber() == PLAYER_2 then
					self.SetPosition = 280
				end
				self:x( self.SetPosition )
			end,
			OnCommand=function(self)
				-- self:GetChildAt(3):x(CurSearch ~= "" and -75 or -200 )
			end,
			CompactCommand=function(self)
				self:GetChild("GroupChooser"):stoptweening():linear(0.1):diffusealpha(0)
				self:GetChild("SortingMethodsInsideFolder"):x(74 + 30)
				self:GetChild("SortingMethodsFolders"):x(-74 + 30)
				self:stoptweening():easeoutexpo(0.3):x( SCREEN_CENTER_X ) 
			end,
			ExtendCommand=function(self)
				self.SetPosition =GAMESTATE:GetMasterPlayerNumber() == PLAYER_1 and SCREEN_CENTER_X or 280
				self:GetChild("GroupChooser"):stoptweening():linear(0.1):diffusealpha(1)
				self:GetChild("SortingMethodsInsideFolder"):x(74)
				self:GetChild("SortingMethodsFolders"):x(-74)
				self:stoptweening():easeoutexpo(0.3):x( self.SetPosition ) 
			end,
			LoadModule("Wheel/Objects/OutsideFolderSort.lua"){
				Width = (300/3) + 46,
				Action = function(self)
					if not newsong then return end
					-- Update the sorting mode.
					toggleSortingFromType( "Group" )
					CurGroup = GetGroupNameBasedOnSort(newsong[1])
					RestoreWheelFromSearch()
					UpdateSortingFolders()
					hasHitAnotherSong = true
					MoveSelection(mainActorFrame,0,GroupsAndSongs,true)
				end
			}..{ InitCommand=function(self) self:x( -74 ) end },
			LoadModule("Wheel/Objects/InsideFolderSort.lua"){
				Width = (300/3) + 46,
				Action = function(self)
					-- Update the sorting mode.
					toggleSortingFromType( "Song" )
					RestoreWheelFromSearch()
					UpdateSortingFolders()
					hasHitAnotherSong = true
					MoveSelection(mainActorFrame,0,GroupsAndSongs,true)
				end
			}..{ InitCommand=function(self) self:x( 74 ) end },
			LoadModule("Wheel/Objects/GroupChooser.lua"){
				Width = needsSDVersion and 220 or 400,
			}..{ InitCommand=function(self) self:x( needsSDVersion and 260 or 350 ) end }
		},

		LoadModule("Wheel/Objects/SongInfoBox.lua"){
			Width = WheelItemWidth+4 - ( getJoinedPlayers() > 1 and 40 or 0),
			MoveFunction = function( pos )
				MoveSelection( mainActorFrame, pos, GroupsAndSongs )
			end,
			Touch = CanUseTouchControls,
			StartFunction = function()
				mainActorFrame:playcommand("Start")
			end
		}..{
			OnCommand=function(self)
				local wheel = self:GetParent():GetChild("Wheel")
				self:diffusealpha(0):easeoutquint(0.4):diffusealpha(1)
			end,
			OffCommand=function(self)
				self:easeinexpo(0.2):diffusealpha(0)
			end
		},
		Def.ActorFrame{
			Name="Additional",
			LoadModule("Wheel/Objects/BPM.lua"){
				Name="BPM",
			},
		},
		Def.Sound{
			Name="ChangeSound",
			IsAction = true,
			File=THEME:GetPathS("","MWChange/Default_MWC.ogg"),
		},
		Def.Sound{ Name="ItemLocked", IsAction = true, File=THEME:GetPathS("MusicWheel","locked") },
		Def.Sound{
			Name="NoDiffSound",
			IsAction = true,
			File=THEME:GetPathS("","NoDiff.ogg"),
		},

		Def.Sound{
			Name="DiffSound",
			IsAction = true,
			File=THEME:GetPathS("","ScreenSelectMusic difficulty harder.ogg"),
		},

		Def.Sound{
			Name="ExpandSound",
			IsAction = true,
			File=THEME:GetPathS("","MusicWheel expand.ogg"),
		},

	}

	return t
end