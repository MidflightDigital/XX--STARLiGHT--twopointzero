local t = Def.ActorFrame{}

for pn in EnabledPlayers() do
    t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/_Difficulty"))(pn)..{
		InitCommand=function(s) s:diffusealpha(0):draworder(40)
			:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,_screen.cy-230)
		end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
		OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
	};
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/RadarHandler"))(pn)..{
		InitCommand=function(s) s:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,_screen.cy+126) end,
	}
	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
		t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/InfoPanel"))(pn)..{
			InitCommand=function(s) s:visible(false):y(_screen.cy+240) end,
		};
	end
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/_ShockArrow/default.lua"))(pn)..{
		InitCommand=function(s)
			s:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,_screen.cy+126):zoom(0.5)
		end,
		SetCommand=function(s)
			local song = GAMESTATE:GetCurrentSong()
			if song then
				local steps = GAMESTATE:GetCurrentSteps(pn)
				if steps then
					if steps:GetRadarValues(pn):GetValue('RadarCategory_Mines') >= 1 then
						s:queuecommand("Anim")
					else
						s:queuecommand("Hide")
					end
				else
					s:queuecommand("Hide")
				end
			else
				s:queuecommand("Hide")
			end
		end,
		CurrentSongChangedMessageCommand=function(s) s:stoptweening():queuecommand("Set") end,
		["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
		OffCommand=function(s) s:queuecommand("Hide") end,	
	}
end

-- Duplicate of function in Graphics\MusicWheelItem Song NormalPart\A\default.lua
local function GetExpandedSectionIndex()
	if ToEnumShortString(PREFSMAN:GetPreference("MusicWheelUsesSections")) ~= "Always" then return 0 end
	
	local expandedSectionName = GAMESTATE:GetExpandedSectionName()
	if expandedSectionName == '' then return 0 end
	
	local mWheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
	if not mWheel then return 0 end
	
	local currentSections = mWheel:GetCurrentSections()
	for index, name in ipairs(currentSections) do
		if name == expandedSectionName then
			return index
		end
	end
	
	return 0
end

-- float wrap: https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/RageUtil.h#L84
function wrap(x, n)
	if x < 0 then
		x = x + math.floor((-x / n) + 1) * n
	end
	return x % n
end

function endsWith(str, ending)
	return ending == '' or str:sub(-#ending) == ending
end

-- This is a bit hacky and assumes the music wheel always starts with index 0 when looping through the list of items to
-- draw, but this does work efficiently to properly calculate offsets for each item coming after expanded sections. 
-- See https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/WheelBase.cpp#L485
function CalculateMusicWheelItemOffsets(MusicWheel, numWheelItems)
	local offsets = {}
	local lastExpandedSection = nil
	local currentOffset = 0
	
	local indexOfExpandedSection = GetExpandedSectionIndex()
	-- firstVisibleIndex: https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/WheelBase.cpp#L448
	local firstVisibleIndex = MusicWheel:GetCurrentIndex() - math.floor(numWheelItems / 2)
	local numWheelDataItems = MusicWheel:GetNumItems()
	
	for i = 0, numWheelItems - 1 do
		local MusicWheelItem = MusicWheel:GetWheelItem(i)
		local currentSection = MusicWheelItem:GetText() -- If the item is a song, then this is the section the song belongs to
		local currentDataIndex = wrap(firstVisibleIndex + i, numWheelDataItems)
		
		-- XXX: This code will break if the same section appears twice in row due to it being the only section on the music wheel, but this is unlikely.
		if not lastExpandedSection then
			local itemType = ToEnumShortString(WheelItemDataType[MusicWheelItem:GetType()+1])
			
			-- Check for itemType=='Song' in case the expanded section header is out of NumWheelItems bounds and can't retrieved via MusicWheel:GetWheelItem()
			if itemType == 'SectionExpanded' or itemType == 'FavoriteExpanded' or itemType == 'Song' then
				lastExpandedSection = currentSection
			end
		elseif currentSection ~= lastExpandedSection then -- We're past the expanded section and can now calculate num of songs there
			lastExpandedSection = nil
			local indexOfLastSongInExpandedSection = currentDataIndex - 1
			if indexOfLastSongInExpandedSection < indexOfExpandedSection then
				-- If the expanded section is the last section, then currentDataIndex will wrap around and be less than GetExpandedSectionIndex()
				-- In that case assume the index of the last song being the index the last item on the music wheel
				indexOfLastSongInExpandedSection = numWheelDataItems - 1
			end
			local numSongsInExpandedSection = indexOfLastSongInExpandedSection - indexOfExpandedSection
			local numColsMissingInLastSongRow = 3 - ((numSongsInExpandedSection % 3) + 1)
			currentOffset = currentOffset + numColsMissingInLastSongRow
		end
		offsets[i] = currentOffset
	end
	return offsets
end

return Def.ActorFrame{
		BeginCommand=function(self) -- Grid layout alignment fix
			local MusicWheel = SCREENMAN:GetTopScreen():GetChild('MusicWheel')
			-- WHY is there no lua music wheel method to get WheelBase->m_WheelBaseItems.size() or WheelBase->NUM_WHEEL_ITEMS ???
			-- Have to calculate it myself. Note: MusicWheel:GetNumItems() returns something else entirely so not useful here.
			-- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/WheelBase.h#L15
			-- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/WheelBase.cpp#L61
			local numWheelItems = math.ceil(THEME:GetMetric('MusicWheel' .. 'A', 'NumWheelItems')+2)
			local lastWheelItemIndex = numWheelItems - 1
			local centerIndex = math.floor(numWheelItems / 2)
			local partsToOffsetTable = {}
			local drawIndexMap = {}
			
			for i = 0, lastWheelItemIndex do
				local MusicWheelItem = MusicWheel:GetWheelItem(i)
				local partsToOffset = {}
				
				-- We can't calculate the offsets dynamically within ItemTransformFunction because the output of that function is cached to
				-- achieve smooth performant scrolling while browsing the music wheel, and we can't change the position of MusicWheelItem itself
				-- because that's handled by WheelBase.cpp to do the scrolling, so we need to offset the children instead.
				local parts = MusicWheelItem:GetChildren()
				for name, part in pairs(parts) do
					if endsWith(name, 'NormalPart') or endsWith(name, 'OverPart') then
						partsToOffset[#partsToOffset+1] = part
					end
				end
				partsToOffsetTable[i] = partsToOffset
				
				MusicWheelItem:addcommand('Set', function(self, params)
					if params.DrawIndex == nil then
						-- Failsafe in case someone upstream does self:playcommand('Set').
						-- We only want to listen to Set commands coming from MusicWheelItem::LoadFromWheelItemData()
						return
					end
					
					-- This is needed because of how the WheelBase::RebuildWheelItems() circular shifts the list of drawn items while scrolling
					drawIndexMap[i] = params.DrawIndex
					
					if params.DrawIndex ~= lastWheelItemIndex then
						-- We only want to calculate offsets once WheelBase has updated the last drawn item, so
						-- CalculateMusicWheelItemOffsets() can get the correct data for all the drawn items
						return
					end
					
					local offsets = CalculateMusicWheelItemOffsets(MusicWheel, numWheelItems)
					local centerOffset = offsets[centerIndex]
					
					for j = 0, lastWheelItemIndex do
						local partsToOffset = partsToOffsetTable[j]
						local offset = offsets[drawIndexMap[j]] - centerOffset
						
						for _, part in ipairs(partsToOffset) do
							-- These factors should be the same as the ones in ItemTransformFunction
							part:xy(offset * 30, offset * 80)
						end
					end
				end)
			end
				
			-- Force a WheelBase::RebuildWheelItems() to trigger the dynamically added Set commands, or else they aren't ran initially
			-- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/MusicWheel.cpp#L1469
			MusicWheel:SetOpenSection(GAMESTATE:GetExpandedSectionName())
		end;
    Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:xy(_screen.cx,_screen.cy):draworder(-1)
			:zoom(IsUsingWideScreen() and 1 or 0.75)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:zbuffer(true):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1)
			:sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1)
			:SetDrawByZPosition(true)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
		end,
		SongChosenMessageCommand=function(s)
			s:queuecommand("Off")
		end,
		SongUnchosenMessageCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bounceend(0.15):zoomx(IsUsingWideScreen() and 1 or 0.75):diffusealpha(1)
		end
    };
    t;
    Def.Sprite{
		Texture="Stager",
		InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT,SCREEN_TOP+170) end,
		OnCommand=function(s) s:draworder(144):stoptweening():addx(-400):decelerate(0.2):addx(400) end,
		OffCommand=function(s) s:decelerate(0.2):addx(-400) end,
	};
	StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
		InitCommand=function(s)
			s:xy(SCREEN_LEFT+160,SCREEN_TOP+180)
		end,
	};
	LoadActor("../../_shared/TwoPartDiff"),
	Def.ActorFrame{
		Name="SongInfo/Jacket",
		InitCommand=function(s) s:xy(IsUsingWideScreen() and _screen.cx-100 or _screen.cx+20,_screen.cy-396):zoom(IsUsingWideScreen() and 1 or 0.9) end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
		OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
		loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Types/A/BannerHandler.lua"))();
		loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Types/A/BPM.lua"))()..{
			InitCommand=function(s) s:xy(140,48) end,
		};
	};
}