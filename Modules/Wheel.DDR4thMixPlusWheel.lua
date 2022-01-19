-- Difficulty Colours
local DiffColors={
	color("#88ffff"), -- Difficulty_Beginner
	color("#ffff88"), -- Difficulty_Easy
	color("#ff8888"), -- Difficulty_Medium
	color("#88ff88"), -- Difficulty_Hard
	color("#8888ff"), -- Difficulty_Challenge
	color("#888888") -- Difficulty_Edit
}

-- Difficulty Names.
-- https://en.wikipedia.org/wiki/Dance_Dance_Revolution#Difficulty
local DiffNames={
	"PRACTICE", -- Difficulty_Beginner
	"BASIC", -- Difficulty_Easy
	"TRICK", -- Difficulty_Medium
	"MANIAC ", -- Difficulty_Hard
	"EXTRA", -- Difficulty_Challenge
	"EDIT" -- Difficulty_Edit
}

-- Song Position.
local SongPos = 1

-- We define the curent song if no song is selected.
if not CurSong then CurSong = 1 end

-- We define the current group to be empty if no group is defined.
if not CurGroup then GurGroup = "" end

-- The player joined.
if not Joined then Joined = {} end

-- The current row of 7 songs that are being displayed.
local CurRow = 1

-- Position on the difficulty select that shows up after we picked a song.
local DiffPos = {[PLAYER_1] = 1,[PLAYER_2] = 1}

-- Check if we're allowed to move on the wheel.
local UnlockedInput = true

-- We start on the wheel so dont start the difficulty select being active.
local DiffSelection = false

-- Change the selection on the wheel.
local function ChangeSelection(self,offset,Songs)

	-- Set old row which is the current displaying row as current row which is the new row before we do math on them.
	local OldRow = CurRow
	
	-- Current Row + Offset.
	CurRow = CurRow + offset
	
	-- Put the row between limits, we have 2 rows.
	if CurRow > 2 then CurRow = 1 end
	if CurRow < 1 then CurRow = 2 end
		
	-- For 7 items on the row do.
	for i = 1,7 do
	
		-- Set the sleep value to i, This is used for the delay between items.
		local sleep = i
		
		-- Position of song
		local pos = CurSong+i
		
		-- If offset is reverse, Do extra math.
		if offset < 0 then 
			sleep = (i - 7)*offset 
			pos = pos - 8
		end
			
		-- Put position between limits.
		while pos > #Songs do pos = pos-#Songs end
		while pos < 1 do pos = #Songs+pos end
		
		-- Check if its a song.
		if type(Songs[pos]) ~= "string" then

			-- For every banner on current row load the next banner.
			self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):diffusealpha(1):Load(Songs[pos][1]:GetBannerPath())
		else
			if SONGMAN:GetSongGroupBannerPath(Songs[pos]) ~= "" then
				-- For every banner on current row load the next banner.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):diffusealpha(1):Load(SONGMAN:GetSongGroupBannerPath(Songs[pos]))
			else
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):diffusealpha(0)
			end
		end

		-- Do the zoom on the banners, We set them to w128 h40.
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):zoom(TF_WHEEL.Resize(self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):GetWidth(),self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):GetHeight(),128,40))

		-- Check if its a song.
		if type(Songs[pos]) ~= "string" then

			-- Check if song has a banner.
			if Songs[pos][1]:HasBanner() then
				-- If they do, hide the fallback banner, And text.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(0):zoom(0)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(0):zoom(0)
			else
				-- If they dont, Show the fallback banner, And set the text.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(1):zoomto(128,40)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(1):zoom(.5)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):settext(Songs[pos][1]:GetDisplayMainTitle())
			end
		else

			-- Check if song has a banner.
			if SONGMAN:GetSongGroupBannerPath(Songs[pos]) ~= "" then
				-- If they do, hide the fallback banner, And text.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(0):zoom(0)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(0):zoom(0)
			else
				-- If they dont, Show the fallback banner, And set the text.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(1):zoomto(128,40)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(1):zoom(.5)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):settext(Songs[pos])
			end
		end
		
		-- Grab the offscreen current row, And move it to the screen
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):sleep(sleep/8):linear(.5):x(0)
		
		-- Wait for a few sec till the new row is on screen, And then make it move away.
		self:GetChild("Banners"):GetChild(OldRow..i):GetChild("BannerCon"):sleep((sleep/8)+.4):x(1280)
		
		-- Grab the slider thats above the wheel and move it ofscreen.
		self:GetChild("SliderCon"):GetChild("Slider"..i):linear(0.2):x((1280*(offset*-1))):sleep(0.00001):diffusealpha(0):x((1280*offset)):diffusealpha(1)
		
		-- Check if its a song.
		if type(Songs[pos]) ~= "string" then
			-- Make the slider load the current row banners.
			self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):diffusealpha(1):Load(Songs[pos][1]:GetBannerPath())
		else
			if SONGMAN:GetSongGroupBannerPath(Songs[pos]) ~= "" then 
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):diffusealpha(1):Load(SONGMAN:GetSongGroupBannerPath(Songs[pos])) 
			else
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):diffusealpha(0)
			end
		end
		
		-- Resize the banners to w256 h80.
		self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):zoom(TF_WHEEL.Resize(self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):GetWidth(),self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):GetHeight(),256,80))
		
		-- Get the amount of songs text that displays the current song we're on.
		self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("CurSong"):settext(pos.."/"..#Songs)
		
		-- Feet Meter.
		for i3 = 1,6 do
		
			-- Grab all the feet and hide them.
			self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("Feet"):diffusealpha(0)
			
			-- do the same for all the lvl text.
			self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("level"):diffusealpha(0)
			
			-- Check if difficulty exists.
			if #Songs[pos] > i3 and type(Songs[pos]) ~= "string" then
			
				-- Color the feet to the difficulties.
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("Feet"):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[pos][i3+1]:GetDifficulty()]])
				
				-- Color the level display to the difficulties.
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("level"):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[pos][i3+1]:GetDifficulty()]]):settext(Songs[pos][i3+1]:GetMeter())
			end
		end			
	end	
	
	-- Sleep for a while before we unlock the input.
	self:sleep((7/8)+.5):queuecommand("UnlockInput")
end

-- Move the wheel, We define the Offset using +1 or -1.
-- We parse the Songs also so we can get the amount of songs.
local function MoveSelection(self,offset,Songs)

	-- Set unlocked input to false.
	UnlockedInput = false
	
	-- Do a loop to stop the blink effect on all the banners.
	for i = 1,7 do
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):linear(0.1):x(0):stopeffect()
	end
	
	-- Update the song position.
	SongPos = SongPos + offset
	
	-- Check if song position is between limits, If it goes outside of it, Load next selection of banners.
	if SongPos < -2 then SongPos = 4 ChangeSelection(self,-1,Songs) end
	if SongPos > 4 then SongPos = -2 ChangeSelection(self,1,Songs) end
	
	-- Curent Song + Offset.
	CurSong = CurSong + offset
	
	-- Check if curent song is further than Songs if so, reset to 1.
	if CurSong > #Songs then CurSong = 1 end
	-- Check if curent song is lower than 1 if so, grab last song.
	if CurSong < 1 then CurSong = #Songs end
	
	-- Change the slider position.
	for i = 1,7 do
		self:GetChild("SliderCon"):GetChild("Slider"..i):linear(.1):x((256*((i-3)+(SongPos*-1))))
	end
		
	-- Change the active banner selector.	
	self:GetChild("Banners"):GetChild(CurRow..SongPos+3):GetChild("BannerCon"):linear(.1):x(32):effectclock("Beat"):glowshift()
	
	-- Stop all the music playing, Which is the Song Music
	SOUND:StopMusic()

	-- Check if its a song.
	if type(Songs[CurSong]) ~= "string" then
		-- Change the current song title.
		self:GetChild("Title"):settext(Songs[CurSong][1]:GetDisplayMainTitle())

		-- Change the current song subtitle.
		self:GetChild("Subtitle"):settext(Songs[CurSong][1]:GetDisplaySubTitle())

		-- Play Current selected Song Music.
		if Songs[CurSong][1].PlayPreviewMusic then
			Songs[CurSong][1]:PlayPreviewMusic()
		elseif Songs[CurSong][1]:GetMusicPath() then
			SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
		end

		if Songs[CurSong][1]:HasBanner() then
			self:GetChild("Banners"):GetChild(CurRow..SongPos+3):GetChild("BannerCon"):GetChild("Banner"):position(0)
		end
	else
		-- Change the current song title.
		self:GetChild("Title"):settext(Songs[CurSong])

		-- Change the current song subtitle.
		self:GetChild("Subtitle"):settext("")
	end
	
	-- Unlock the input.
	self:sleep(.2):queuecommand("UnlockInput")
end

-- We use this function to do an effect on the content of the music wheel when we open a group.
local function UpdateSelection(self,Songs)

	-- Set unlocked input to false.
	UnlockedInput = false

	-- Set old row which is the current displaying row as current row which is the new row before we do math on them.
	local OldRow = CurRow
	
	-- Current Row + Offset.
	CurRow = CurRow + 1
	
	-- Put the row between limits, we have 2 rows.
	if CurRow > 2 then CurRow = 1 end
	if CurRow < 1 then CurRow = 2 end

	for i = 1,7 do
	
		-- Set the sleep value to i, This is used for the delay between items.
		local sleep = i
		
		-- Position of song
		local pos = CurSong+i-1
					
		-- Put position between limits.
		while pos > #Songs do pos = pos-#Songs end
		while pos < 1 do pos = #Songs+pos end
		
		-- Check if its a song.
		if type(Songs[pos]) ~= "string" then

			-- For every banner on current row load the next banner.
			self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):diffusealpha(1):Load(Songs[pos][1]:GetBannerPath())
		else
			if SONGMAN:GetSongGroupBannerPath(Songs[pos]) ~= "" then
				-- For every banner on current row load the next banner.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):diffusealpha(1):Load(SONGMAN:GetSongGroupBannerPath(Songs[pos]))
			else
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):diffusealpha(0)
			end
		end

		-- Do the zoom on the banners, We set them to w128 h40.
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):zoom(TF_WHEEL.Resize(self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):GetWidth(),self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):GetHeight(),128,40))

		-- Check if its a song.
		if type(Songs[pos]) ~= "string" then

			-- Check if song has a banner.
			if Songs[pos][1]:HasBanner() then
				-- If they do, hide the fallback banner, And text.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(0):zoom(0)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(0):zoom(0)
			else
				-- If they dont, Show the fallback banner, And set the text.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(1):zoomto(128,40)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(1):zoom(.5)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):settext(Songs[pos][1]:GetDisplayMainTitle())
			end
		else

			-- Check if song has a banner.
			if SONGMAN:GetSongGroupBannerPath(Songs[pos]) ~= "" then
				-- If they do, hide the fallback banner, And text.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(0):zoom(0)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(0):zoom(0)
			else
				-- If they dont, Show the fallback banner, And set the text.
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(1):zoomto(128,40)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(1):zoom(.5)
				self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):settext(Songs[pos])
			end
		end
		
		-- Grab the offscreen current row, And move it to the screen
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):sleep(sleep/8):linear(.5):x(0)
		
		-- Wait for a few sec till the new row is on screen, And then make it move away.
		self:GetChild("Banners"):GetChild(OldRow..i):GetChild("BannerCon"):sleep((sleep/8)+.4):x(1280)
		
		-- Grab the slider thats above the wheel and move it ofscreen.
		self:GetChild("SliderCon"):GetChild("Slider"..i):linear(.1):diffusealpha(0):sleep((7/8)+.3):x((256*((i-3)+(-2*-1)))):linear(.2):diffusealpha(1)
		
		-- Check if its a song.
		if type(Songs[pos]) ~= "string" then
			-- Make the slider load the current row banners.
			self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):diffusealpha(1):Load(Songs[pos][1]:GetBannerPath())
		else
			if SONGMAN:GetSongGroupBannerPath(Songs[pos]) ~= "" then 
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):diffusealpha(1):Load(SONGMAN:GetSongGroupBannerPath(Songs[pos])) 
			else
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):diffusealpha(0)
			end
		end
		
		-- Resize the banners to w256 h80.
		self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):zoom(TF_WHEEL.Resize(self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):GetWidth(),self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):GetHeight(),256,80))
		
		-- Get the amount of songs text that displays the current song we're on.
		self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("CurSong"):settext(pos.."/"..#Songs)
		
		-- Feet Meter.
		for i3 = 1,6 do
		
			-- Grab all the feet and hide them.
			self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("Feet"):diffusealpha(0)
			
			-- do the same for all the lvl text.
			self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("level"):diffusealpha(0)
			
			-- Check if difficulty exists.
			if #Songs[pos] > i3 and type(Songs[pos]) ~= "string" then
			
				-- Color the feet to the difficulties.
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("Feet"):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[pos][i3+1]:GetDifficulty()]])
				
				-- Color the level display to the difficulties.
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("level"):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[pos][i3+1]:GetDifficulty()]]):settext(Songs[pos][i3+1]:GetMeter())
			end
		end			
	end	

	-- Do a loop to stop the blink effect on all the banners.
	for i = 1,7 do
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):linear(0.1):x(0):stopeffect()
	end

	-- Set SongPos to first value.
	SongPos = -2

	-- Change the active banner selector.	
	self:GetChild("Banners"):GetChild(CurRow..SongPos+3):GetChild("BannerCon"):linear(.1):x(32):effectclock("Beat"):glowshift()
	

	-- Sleep for a while before we unlock the input.
	self:sleep((7/8)+.5):queuecommand("UnlockInput")
end

-- We use this function to do an effect on the content of the music wheel when we switch to next screen.
local function StartSelection(self,Songs)

	-- Set unlocked input to false.
	UnlockedInput = false
	
	-- Set starting offset to 0
	local offset = 0
	
	-- Grab all the songs after the current selected song.
	for i = SongPos+3,7 do
		-- Let them fly off.
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):sleep(offset/8):linear(.5):x(-1280)
		offset = offset + 1
	end
	
	-- Set the offset to current song.
	offset = SongPos+3
	
	-- Grab all the songs before the current selected song.
	for i = 1,SongPos+3 do
		-- Let the fly off.
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):sleep(offset/8):linear(.5):x(-1280)
		offset = offset - 1
	end
	
	-- Loop for all the difficulties.
	for i = 1,#Songs[CurSong]-1 do
		-- If difficulties are more than 5, Stop the loop.
		if i > 6 then break end
		
		-- For all the allowed meter feets set their colour and diffuse them.
		for i2 = 1,9 do
			self:GetChild("Diffs"):GetChild("Feet"..i..i2):sleep(.5):linear(.5):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]]):diffusealpha(.5)
		end
		
		-- Loop till the value of the meter.
		for i2 = 1,Songs[CurSong][i+1]:GetMeter() do
			-- If the meter passes 9, Stop the loop.
			if i2 > 9 then break end
			
			-- For every foot inside the loop make them bright again.
			self:GetChild("Diffs"):GetChild("Feet"..i..i2):diffusealpha(1)
		end
		
		-- If player 1 is joined.
		if Joined[PLAYER_1] then
		
			-- Show the difficulty border on the left side of the selector.
			self:GetChild("Diffs"):GetChild("DiffSelector"..i.."1"):GetChild("DiffCon"):sleep(.5):linear(.5):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
			
			-- Set the difficulty name on the left side of the selector.
			self:GetChild("Diffs"):GetChild("DiffSelector"..i.."1"):GetChild("DiffName"):sleep(.5):linear(.5):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]]):settext(DiffNames[TF_WHEEL.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
		end
		
		-- If player 2 is joined
		if Joined[PLAYER_2] then
		
			-- Show the difficulty border on the right side of the selector.
			self:GetChild("Diffs"):GetChild("DiffSelector"..i.."2"):GetChild("DiffCon"):sleep(.5):linear(.5):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
			
			-- Set the difficulty name on the right side of the selector.
			self:GetChild("Diffs"):GetChild("DiffSelector"..i.."2"):GetChild("DiffName"):sleep(.5):linear(.5):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]]):settext(DiffNames[TF_WHEEL.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
		end
	end	
	
	-- Set the diff selection to the first value.
	self:sleep(1):queuecommand("DiffSelection")
end

-- The move difficulty function.
local function MoveDifficulty(self,offset,Songs)	

	-- Set player number to 1.
	local pn = 1
	
	-- If self.pn = Player 2 then player number is 2.
	if self.pn == PLAYER_2 then pn = 2 end

	-- If player is joined, let them change the difficulty.
	if Joined[self.pn] then
	
		-- For all difficulties that are used stop the blink.
		for i = 1,6 do 
			self:GetChild("Diffs"):GetChild("DiffSelector"..i..pn):stopeffect()
		end
		
		-- Change the difficulty position for the current player.
		DiffPos[self.pn] = DiffPos[self.pn] + offset
		
		-- Check if its within limits.
		if DiffPos[self.pn] > #Songs[CurSong]-1 then DiffPos[self.pn] = 1 end
		if DiffPos[self.pn] < 1 then DiffPos[self.pn] = #Songs[CurSong]-1 end
		
		-- Get selected difficulty container and glowshift it.
		self:GetChild("Diffs"):GetChild("DiffSelector"..DiffPos[self.pn]..pn):effectclock("Beat"):glowshift()	
	end
end

-- This is the main function, Its the function that contains the wheel.
return function(Style)

	-- Load the songs from the Songs.Loader module.
	local Songs = LoadModule("Songs.Loader.lua")(Style)

	-- Sort the Songs and Group.
	local GroupsAndSongs = LoadModule("Group.Sort.lua")(Songs,CurGroup)
	
	-- We define here is we load the Options menu when people double press,
	-- Because they need to double press it starts at false.
	local StartOptions = false
	
	-- The slider thats above the wheel.
	local Slider = Def.ActorFrame{Name="SliderCon"}
	
	-- The wheel banners.
	local Banners = Def.ActorFrame{Name="Banners"}
	
	-- The difficulty containers.
	local Diffs = Def.ActorFrame{Name="Diffs"}
	
	-- Here we generate all the banners for the wheel and slider.
	for i = 1,7 do	
	
		-- Position of current song, We want the middle banner at start.
		local pos = CurSong+i-4
		while pos > #GroupsAndSongs do pos = pos-#GroupsAndSongs end
		while pos < 1 do pos = #GroupsAndSongs+pos end
		
		-- The difficulty container for the slider.
		local DiffDisplay = Def.ActorFrame{Name="DiffCon"}
		
		-- We can display 6 difficulties on the slide .
		for i2 = 1,6 do
			DiffDisplay[#DiffDisplay+1] = Def.ActorFrame {
				Name="DiffDisplay"..i2,
				OnCommand=function(self)
					-- Move them down a little.
					self:y(38)
				end,
				-- Set the feet, We need to do this with Def.Sprite because we cant diffuse an ActorProxy.
				Def.Sprite{
					Name="Feet",
					Texture=THEME:GetPathG("","DDR/Feet.png"),
					OnCommand=function(self)
						-- Zoom the foot to the right size, and hide it.
						self:zoom(.075):x(-56+(15*i2)):diffusealpha(0)
				
						-- Check if its a song.
						if type(GroupsAndSongs[pos]) ~= "string" then
							-- If difficulty exists.
							if #GroupsAndSongs[pos] > i2 then
								-- Then diffuse to difficulty colour.
								self:diffuse(DiffColors[TF_WHEEL.DiffTab[GroupsAndSongs[pos][i2+1]:GetDifficulty()]])
							end
						end
					end
				},
				
				-- The display meter level text for on the slider.
				Def.BitmapText{
					Name="level",
					Font="_open sans 40px",
					OnCommand=function(self)
					
						-- Zoom the text to the right size.
						self:zoom(.125):x(-49+(15*i2))
						
						-- Check if its a song.
						if type(GroupsAndSongs[pos]) ~= "string" then
							-- If difficulty exists.
							if #GroupsAndSongs[pos] > i2 then
								-- Then diffuse to difficulties colour and set text to meter level.
								self:diffuse(DiffColors[TF_WHEEL.DiffTab[GroupsAndSongs[pos][i2+1]:GetDifficulty()]]):settext(GroupsAndSongs[pos][i2+1]:GetMeter())
							end
						end
					end
				}
			}					
		end
		
		-- Setting up the slider.
		Slider[#Slider+1] = Def.ActorFrame{
			Name="Slider"..i,
			OnCommand=function(self)
				self:xy((256*(i-4)),-56):diffusealpha(0):linear(.5):diffusealpha(1)
			end,
			-- The banner on the slider.
			Def.Sprite{
				Name="Banner",
				OnCommand=function(self)
					-- Check if its a song.
					if type(GroupsAndSongs[pos]) ~= "string" then

						-- If the banner exist, Load Banner.png.
						if GroupsAndSongs[pos][1]:HasBanner() then self:Load(GroupsAndSongs[pos][1]:GetBannerPath()) end
					else

						-- IF group banner exist, Load banner.png
						if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos]) ~= "" then self:Load(SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos])) end
					end

					self:zoom(TF_WHEEL.Resize(self:GetWidth(),self:GetHeight(),256,80))
				end
			},
			
			-- The diffuse info container.
			Def.Sprite{
				Texture=THEME:GetPathG("","DDR/DiffInfo.png"),
				OnCommand=function(self) 
					self:zoom(.5):y(32):diffuse(color("#88ff88"))
				end
			},
			
			-- The current song and amount of songs text.
			Def.BitmapText{
				Font="_open sans 40px",
				Name="CurSong",
				Text=pos.."/"..#GroupsAndSongs,
				OnCommand=function(self) 
					self:zoom(.2):y(44):x(96):strokecolor(0,0,0,1)
				end
			},
			
			-- Add the difficulties.
			DiffDisplay
		}
		
		-- For both banner wheel rows.
		for i2 = 1,2 do
			Banners[#Banners+1] = Def.ActorFrame{
				-- i2 is row, i is banner.
				Name=i2..i,
				InitCommand=function(self) self:rotationz(-45):xy((64*(i-4)),80) end,
				
				-- Setting the banner locations.
				Def.ActorFrame{
					Name="BannerCon",
					OnCommand=function(self)
						local offset = i-4
						if i-4 < 1 then offset = offset*-1 end
						self:x(1280)
						if i2 == 1 then
							self:sleep(offset/8):linear(.5):x(0)
						
							if i-4 == 0 then 
								self:effectclock("Beat"):glowshift():x(32)
							end
						end
					end,

					-- Actual banners.
					Def.Sprite{
						Name="Banner",
						OnCommand=function(self)
							-- Check if its a song.
							if type(GroupsAndSongs[pos]) ~= "string" then

								-- If the banner exist, Load Banner.png.
								if GroupsAndSongs[pos][1]:HasBanner() then self:Load(GroupsAndSongs[pos][1]:GetBannerPath()) end
							else

								-- IF group banner exist, Load banner.png
								if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos]) ~= "" then self:Load(SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos])) end
							end

							self:zoom(TF_WHEEL.Resize(self:GetWidth(),self:GetHeight(),128,40))
						end
					},

					-- Fallback quad, Incase of no banner.
					Def.Quad{
						Name="FallbackBanner",
						OnCommand=function(self)
							self:zoomto(128,40):diffuse(.5,.5,.5,1)
							-- Check if its a song.
							if type(GroupsAndSongs[pos]) ~= "string" then
								if GroupsAndSongs[pos][1]:HasBanner() then
									self:diffusealpha(0):zoom(0)
								end
							else
								if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos]) ~= "" then
									self:diffusealpha(0):zoom(0)
								end
							end
						end					
					},
					
					-- Text ontop of fallback banners. 
					Def.BitmapText{
						Font="Common Normal",
						Name="BannerText",
						OnCommand=function(self) 
							self:maxwidth(250):strokecolor(0,0,0,1):zoom(.5)
							-- Check if its a song.
							if type(GroupsAndSongs[pos]) ~= "string" then
								if not GroupsAndSongs[pos][1]:HasBanner() then
									self:settext(GroupsAndSongs[pos][1]:GetDisplayMainTitle())
								end
							else
								if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos]) == "" then
									self:settext(GroupsAndSongs[pos])
								end
							end
						end
					}
				}
			}
		end
	end
	
	-- Loop for all the supported difficulties.
	for i = 1,6 do
		-- The difficulty text on left and right side of feet meter.
		for i2 = 1,2 do
			Diffs[#Diffs+1] = Def.ActorFrame{ 
				-- The container image.
				Name="DiffSelector"..i..i2,
				Def.Sprite{
					Name="DiffCon",
					Texture=THEME:GetPathG("","DDR/DiffCon.png"),
					OnCommand=function(self)
						self:zoom(.5):y((i*32)):x(((i2-1.5)*224)):diffusealpha(0)
					end
				},
				
				-- The text.
				Def.BitmapText{
					Font="_open sans 40px",
					Name="DiffName",
					Text="Practice",
					OnCommand=function(self)
						self:maxwidth(60):zoom(.5):zoomy(.25):y((i*32)):x(((i2-1.5)*224)):diffusealpha(0)
					end
				}
			}
		end
		
		-- For 9 times, Add the amount of feet.
		for i2 = 1,9 do
			Diffs[#Diffs+1] = Def.Sprite{
				Name="Feet"..i..i2,
				Texture=THEME:GetPathG("","DDR/Feet.png"),
				OnCommand=function(self)
					self:zoom(.125):y((i*32)):x(((i2-5)*16)):diffusealpha(0)
				end
			}
		end
	end
	
	-- Here we return the actual Music Wheel Actor.
	return Def.ActorFrame{
		OnCommand=function(self)
			self:Center():zoom(SCREEN_HEIGHT/480)
			-- We use a Input function from the Scripts folder.
			-- It uses a Command function. So you can define all the Commands,
			-- Like MenuLeft is MenuLeftCommand.		
			SCREENMAN:GetTopScreen():AddInputCallback(TF_WHEEL.Input(self))
			
			-- Sleep for 0.2 sec, And then load the current song music.
			self:sleep(0.2):queuecommand("PlayCurrentSong")
		end,
		
		-- Play Music at start of screen,.
		PlayCurrentSongCommand=function(self)
			if GroupsAndSongs[CurSong][1].PlayPreviewMusic then
				GroupsAndSongs[CurSong][1]:PlayPreviewMusic()
			elseif GroupsAndSongs[CurSong][1]:GetMusicPath() then
				SOUND:PlayMusicPart(GroupsAndSongs[CurSong][1]:GetMusicPath(),GroupsAndSongs[CurSong][1]:GetSampleStart(),GroupsAndSongs[CurSong][1]:GetSampleLength(),0,0,true)
			end
		end,
		
		-- Do stuff when a user presses left on Pad or Menu buttons.
		MenuLeftCommand=function(self) 
		
			-- If input is unlocked change selected song.
			if UnlockedInput then MoveSelection(self,-1,GroupsAndSongs) end 
			
			-- If we are on difficulty selector change the difficulty.
			if DiffSelection then MoveDifficulty(self,-1,GroupsAndSongs) end 
		end,
		
		-- Do stuff when a user presses Right on Pad or Menu buttons.
		MenuRightCommand=function(self)
		
			-- If input is unlocked change selected song.
			if UnlockedInput then MoveSelection(self,1,GroupsAndSongs) end 
			
			-- If we are on difficulty selector change the difficulty.
			if DiffSelection then MoveDifficulty(self,1,GroupsAndSongs) end 
		end,
		
		-- Do stuff when a user presses Up on Pad or Menu buttons.
		MenuUpCommand=function(self) 
		
			-- If we are on difficulty selector change the difficulty.
			if DiffSelection then MoveDifficulty(self,-1,GroupsAndSongs) end 
		end,
		
		-- Do stuff when a user presses Doiwn on Pad or Menu buttons.
		MenuDownCommand=function(self)

			-- If we are on difficulty selector change the difficulty.
			if DiffSelection then MoveDifficulty(self,1,GroupsAndSongs) end 
		end,
		
		-- Do stuff when a user presses the Back on Pad or Menu buttons.
		BackCommand=function(self) 
			-- Check if User is joined.
			if Joined[self.pn] then
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					-- If both players are joined, We want to unjoin the player that pressed back.
					GAMESTATE:UnjoinPlayer(self.pn)
					Joined[self.pn] = false
				else
					-- Go to the previous screen.
					SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen") 
				end
			end
		end,
		
		
		-- Do stuff when a user presses the Start on Pad or Menu buttons.
		StartCommand=function(self)
		
			-- Check if we are on difficulty select menu.
			if DiffSelection then
				-- Check if we want to go to ScreenPlayerOptions instead of ScreenGameplay.
				if StartOptions then
					SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPlayerOptions"):StartTransitioningScreen("SM_GoToNextScreen")
				end
				-- Check if player is joined.
				if Joined[self.pn] then 
				
					--We use PlayMode_Regular for now.
					GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
				
					--Set the song we want to play.
					GAMESTATE:SetCurrentSong(GroupsAndSongs[CurSong][1])
				
					-- Check if 2 players are joined.
					if Joined[PLAYER_1] and Joined[PLAYER_2] then
				
						-- If they are, We will use Versus.
						GAMESTATE:SetCurrentStyle('versus')
						
						-- Save Profiles.
						PROFILEMAN:SaveProfile(PLAYER_1)
						PROFILEMAN:SaveProfile(PLAYER_2)
						
						-- Set the Current Steps to use.
						GAMESTATE:SetCurrentSteps(PLAYER_1,GroupsAndSongs[CurSong][DiffPos[PLAYER_1]+1])
						GAMESTATE:SetCurrentSteps(PLAYER_2,GroupsAndSongs[CurSong][DiffPos[PLAYER_2]+1])
					else
				
						-- If we are single player, Use Single.
						GAMESTATE:SetCurrentStyle(TF_WHEEL.StyleDB[Style])
					
						-- Save Profile.
						PROFILEMAN:SaveProfile(self.pn)
					
						-- Set the Current Step to use.
					GAMESTATE:SetCurrentSteps(self.pn,GroupsAndSongs[CurSong][DiffPos[self.pn]+1])
					end
				
					-- We want to go to player options when people doublepress, So we set the StartOptions to true,
					-- So when the player presses Start again, It will go to player options.
					StartOptions = true
				
					-- Wait 0.4 sec before we go to next screen.
					self:sleep(1):queuecommand("StartSong")
				end
			else
			
				-- If we are not changing row.
				if UnlockedInput then 
				
					-- Check if player is joined.
					if Joined[self.pn] then
					
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
					
							-- Reset the groups location so we dont bug.
							GroupsAndSongs = LoadModule("Group.Sort.lua")(Songs,"")
					
							-- Set CurSong to the right group.
							for i,v in ipairs(GroupsAndSongs) do
								if v == CurGroup then
									CurSong = i
								end
							end

							-- Set the current group.
							GroupsAndSongs = LoadModule("Group.Sort.lua")(Songs,CurGroup)

							-- Run update command to open/close group.
							UpdateSelection(self,GroupsAndSongs)

						-- Not on a group, Go to next step.
						else

							-- Go to next step.
							StartSelection(self,GroupsAndSongs)
						end
					else
						-- If no player is active Join.
						GAMESTATE:JoinPlayer(self.pn)
				
						-- Load the profles.
						GAMESTATE:LoadProfiles()
				
						-- Add to joined list.
						Joined[self.pn] = true
					end
				end
			end			
		end,
		
		-- Change to ScreenGameplay.
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,
		
		-- The command to unlock input.
		UnlockInputCommand=function() UnlockedInput = true end,
		
		-- Start difficulty selector.
		DiffSelectionCommand=function(self) 
			DiffSelection = true 
			
			-- Set the first value in the difficulty selector active.
			if Joined[PLAYER_1] then self:GetChild("Diffs"):GetChild("DiffSelector11"):effectclock("Beat"):glowshift() end
			if Joined[PLAYER_2] then self:GetChild("Diffs"):GetChild("DiffSelector12"):effectclock("Beat"):glowshift() end
		end,
		
		Slider, -- Load the sliders
		Banners, -- Load the banner wheel.
		Diffs, -- Load the difficulty selector.
		
		-- Current song title text.
		Def.BitmapText{
			Font="_open sans 40px",
			Name="Title",
			OnCommand=function(self) 
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					if not GroupsAndSongs[CurSong][1]:HasBanner() then
						self:settext(GroupsAndSongs[CurSong][1]:GetDisplayMainTitle())
					end
				else
					if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[CurSong]) == "" then
						self:settext(GroupsAndSongs[CurSong])
					end
				end
				self:diffuse(color("#88ff88")):strokecolor(0,0,0,1):zoom(.25)
			end
		},
		
		-- Current song subtitle text.
		Def.BitmapText{
			Font="_open sans 40px",
			Name="Subtitle",
			OnCommand=function(self)
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					if not GroupsAndSongs[CurSong][1]:HasBanner() then
						self:settext(GroupsAndSongs[CurSong][1]:GetDisplaySubTitle())
					end
				end 
				self:y(10):diffuse(color("#88ff88")):strokecolor(0,0,0,1):zoom(.25)
			end
		}
	}
	
end