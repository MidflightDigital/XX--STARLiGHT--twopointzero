-- Difficulty Colours
local DiffColors={
	color("#92dd44"), -- Difficulty_Beginner / Difficulty_Easy
	color("#eeee77"), -- Difficulty_Medium / Difficulty_Hard
	color("#ee3fff"), -- Difficulty_Challenge
	color("#888888") -- Difficulty_Edit
}

-- Difficulty Frame Colours
local DiffFrameColors={
	color("#00FF00"), -- Difficulty_Beginner / Difficulty_Easy
	color("#FFFF00"), -- Difficulty_Medium / Difficulty_Hard
	color("#800080"), -- Difficulty_Challenge
	color("#888888") -- Difficulty_Edit
}

-- Difficulty Names.
local DiffNames={
	"NORMAL", -- Difficulty_Beginner / Difficulty_Easy
	"HYPER", -- Difficulty_Medium / Difficulty_Hard
	"EX", -- Difficulty_Challenge
	"EDIT" -- Difficulty_Edit
}

-- We define the curent song if no song is selected.
if not CurSong then CurSong = 1 end

-- We define the current group to be empty if no group is defined.
if not CurGroup then CurGroup = "" end
if not CurGroupNum then CurGroupNum = 1 end

-- Set the standard Difficulty.
if not CurDiff then CurDiff = 1 end

-- The player joined.
if not Joined then Joined = {} end

-- The increase offset for when we move with postive.
local IncOffset = 1
local BanIncOffset = 1
local GroupIncOffset = 1

-- The decrease offset for when we move with negative.
local DecOffset = 10
local BanDecOffset = 3
local GroupDecOffset = 14

-- The center offset of the wheel.
local XOffMin = 4
local XOffset = 5
local XOffPlus = 6

local BanOffset = 2
local GroupOffset = 6

-- Move the wheel, We define the Offset using +1 or -1.
-- We parse the Songs also so we can get the amount of songs.
local function MoveSelection(self,offset,Songs)

	-- Curent Song + Offset.
	CurSong = CurSong + offset
	
	-- Check if curent song is further than Songs if so, reset to 1.
	if CurSong > #Songs then CurSong = 1 end
	-- Check if curent song is lower than 1 if so, grab last song.
    if CurSong < 1 then CurSong = #Songs end

    -- Set the offsets for increase and decrease.
	DecOffset = DecOffset + offset
	IncOffset = IncOffset + offset

	if DecOffset > 10 then DecOffset = 1 end
	if IncOffset > 10 then IncOffset = 1 end

	if DecOffset < 1 then DecOffset = 10 end
    if IncOffset < 1 then IncOffset = 10 end
    
    -- Set the offset for the center of the wheel.	
    XOffset = XOffset + offset
    XOffMin = XOffMin + offset
    XOffPlus = XOffPlus + offset

	if XOffset > 10 then XOffset = 1 end
    if XOffMin > 10 then XOffMin = 1 end
    if XOffPlus > 10 then XOffPlus = 1 end
    
    if XOffset < 1 then XOffset = 10 end
    if XOffMin < 1 then XOffMin = 10 end
    if XOffPlus < 1 then XOffPlus = 10 end

    for i = 1,10 do

        -- Calculate current position based on song with a value to get center.
        local pos = CurSong+(4*offset)

        if offset == 1 then 
            pos = CurSong+(5*offset)
        end

        if i == XOffMin or i == XOffPlus then
            self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("DiffCon"):linear(.1):x(-200):zoom(.4)
        elseif i == XOffset then
            self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("DiffCon"):linear(.1):x(-220):zoom(.5)
        end
        
		-- Keep it within reasonable values.
		while pos > #Songs do pos = pos-#Songs end
        while pos < 1 do pos = #Songs+pos end

        self:GetChild("SongWheel"):GetChild("Song"..i):linear(.1):addx(11*offset*-1):addy(40*offset*-1)

        if (i == IncOffset and offset == -1) or (i == DecOffset and offset == 1) then

            -- Move wheelpart instantly to new location.
            self:GetChild("SongWheel"):GetChild("Song"..i):sleep(0):addy((offset*-40)*-10):addx((offset*-11)*-10)

            self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("Title"):settext(Songs[pos][1]:GetDisplayMainTitle())

            
            self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("DiffCon"):GetChild("Diff"):settext(Songs[pos][2]:GetMeter())

            if Songs[pos][1]:HasBanner() then
                self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("Banner"):visible(true):Load(Songs[pos][1]:GetBannerPath())
            else
                self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("Banner"):visible(false)
            end
            self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("Banner"):zoomto(380,128)
        end
    end

    BanDecOffset = BanDecOffset + offset
    BanIncOffset = BanIncOffset + offset

    BanOffset = BanOffset + offset
    
    if BanDecOffset > 3 then BanDecOffset = 1 end
	if BanIncOffset > 3 then BanIncOffset = 1 end

	if BanDecOffset < 1 then BanDecOffset = 3 end
    if BanIncOffset < 1 then BanIncOffset = 3 end

    if BanOffset < 1 then BanOffset = 3 end
    if BanOffset > 3 then BanOffset = 1 end

    for i = 1,3 do
        local pos = CurSong+(1*offset)

        -- Keep it within reasonable values.
		while pos > #Songs do pos = pos-#Songs end
        while pos < 1 do pos = #Songs+pos end

        self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):linear(.1):addy(128*offset*-1)
        if (i == BanIncOffset and offset == -1) or (i == BanDecOffset and offset == 1) then
            self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):sleep(0):addy((128*3)*offset)
            
            if Songs[pos][1]:HasBanner() then
                self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):visible(true):Load(Songs[pos][1]:GetBannerPath())
            else
                self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):visible(false)
            end
            self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):zoomto(380,128)

        end
    end
    
    self:GetChild("BannerCon"):GetChild("Title"):settext(Songs[CurSong][1]:GetDisplayMainTitle())

    if Songs[CurSong][1]:HasBanner() then 
        self:GetChild("Banner"):visible(true):Load(Songs[CurSong][1]:GetBannerPath()):zoom(TF_WHEEL.Resize(self:GetChild("Banner"):GetWidth(),self:GetChild("Banner"):GetHeight(),210,54))
    else
        self:GetChild("Banner"):visible(false)
    end

    -- Stop all the music playing, Which is the Song Music
    SOUND:StopMusic()
    
    -- Play Current selected Song Music.
    if Songs[CurSong][1]:GetMusicPath() then
	    SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
    end
end

local function MoveGroup(self,offset,Group)
    CurGroupNum = CurGroupNum + offset

    -- Check if curent group is further than Groups if so, reset to 1.
	if CurGroupNum > #Group then CurGroupNum = 1 end
	-- Check if curent group is lower than 1 if so, grab last group.
    if CurGroupNum < 1 then CurGroupNum = #Group end

    CurGroup = Group[CurGroupNum]

    GroupOffset = GroupOffset + offset

    if GroupOffset > 14 then GroupOffset = 1 end
	if GroupOffset < 1 then GroupOffset = 14 end

    GroupDecOffset = GroupDecOffset + offset
	GroupIncOffset = GroupIncOffset + offset

	if GroupDecOffset > 14 then GroupDecOffset = 1 end
	if GroupIncOffset > 14 then GroupIncOffset = 1 end

	if GroupDecOffset < 1 then GroupDecOffset = 14 end
    if GroupIncOffset < 1 then GroupIncOffset = 14 end

    for i = 1,14 do
        local pos = CurGroupNum+(5*offset)

        if offset == 1 then 
            pos = CurGroupNum+(8*offset)
        end

        -- Keep it within reasonable values.
		while pos > #Group do pos = pos-#Group end
        while pos < 1 do pos = #Group+pos end

        self:GetChild("GroupWheel"):GetChild("Group"..i):linear(.1):addx(90*-1*offset)
        if (i == GroupIncOffset and offset == -1) or (i == GroupDecOffset and offset == 1) then
            self:GetChild("GroupWheel"):GetChild("Group"..i):sleep(0):addx((90*14)*offset)

            if SONGMAN:GetSongGroupBannerPath(Group[pos]) ~= "" then
                self:GetChild("GroupWheel"):GetChild("Group"..i):GetChild("Banner"):Load(SONGMAN:GetSongGroupBannerPath(Group[pos]))
                self:GetChild("GroupWheel"):GetChild("Group"..i):GetChild("Title"):visible(false)
            else
                self:GetChild("GroupWheel"):GetChild("Group"..i):GetChild("Banner"):Load(THEME:GetPathG("","white.png"))
                self:GetChild("GroupWheel"):GetChild("Group"..i):GetChild("Title"):visible(true):settext(Group[pos])
            end
            self:GetChild("GroupWheel"):GetChild("Group"..i):GetChild("Banner"):zoomto(512,160)
        end

        self:GetChild("GroupWheel"):GetChild("Group"..i):GetChild("Banner"):diffuse(.5,.5,.5,1)

        if GroupOffset == i then
            self:GetChild("GroupWheel"):GetChild("Group"..i):GetChild("Banner"):diffuse(1,1,1,1)
        end

    end
end

local function ChangeDiff(self,Songs)
    CurSong = 1

    IncOffset = 1
    BanIncOffset = 1

    -- The decrease offset for when we move with negative.
    DecOffset = 10
    BanDecOffset = 3

    -- The center offset of the wheel.
    XOffMin = 4
    XOffset = 5
    XOffPlus = 6

    self:GetChild("Frame"):diffuse(DiffColors[CurDiff])
    self:GetChild("InfoCon"):diffuse(DiffColors[CurDiff])
    self:GetChild("Selector"):diffuse(DiffFrameColors[CurDiff])
    self:GetChild("Highlight"):diffuse(DiffFrameColors[CurDiff])

    for i = 1,10 do
        local pos = CurSong+i-5

        -- Stay within limits.
		while pos > #Songs do pos = pos-#Songs end
        while pos < 1 do pos = #Songs+pos end
        
        self:GetChild("SongWheel"):GetChild("Song"..i):xy(11*i,40*i)

        self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("DiffCon"):zoom(.4):x(-200)

        if i == 5 then
            self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("DiffCon"):x(-220):zoom(.5)
        end

        if Songs[pos][1]:HasBanner() then 
            self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("Banner"):visible(true):Load(Songs[pos][1]:GetBannerPath()) 
        else
            self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("Banner"):visible(false)
        end
        self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("Banner"):zoomto(380,128)

        self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("DiffCon"):GetChild("Diff"):settext(Songs[pos][2]:GetMeter())
        self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("DiffCon"):GetChild("BG"):diffuse(DiffColors[CurDiff])

        self:GetChild("SongWheel"):GetChild("Song"..i):GetChild("Title"):settext(Songs[pos][1]:GetDisplayMainTitle())
    end

    for i = 1,3 do
        local pos = CurSong+i-2

        -- Stay within limits.
		while pos > #Songs do pos = pos-#Songs end
        while pos < 1 do pos = #Songs+pos end
        
        self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):xy(60,128*(i-2))

        if Songs[pos][1]:HasBanner() then
            self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):visible(true):Load(Songs[pos][1]:GetBannerPath())
        else
            self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):visible(false)
        end
        self:GetChild("BannerCon"):GetChild("BannerWheel"):GetChild("Banner"..i):zoomto(380,128)

        self:GetChild("BannerCon"):GetChild("Title"):settext(Songs[CurSong][1]:GetDisplayMainTitle())
    end

    if Songs[CurSong][1]:HasBanner() then 
        self:GetChild("Banner"):visible(true):Load(Songs[CurSong][1]:GetBannerPath()):zoom(TF_WHEEL.Resize(self:GetChild("Banner"):GetWidth(),self:GetChild("Banner"):GetHeight(),210,54))
    else
        self:GetChild("Banner"):visible(false)
    end

    -- Stop all the music playing, Which is the Song Music
    SOUND:StopMusic()
    
    -- Play Current selected Song Music.
    if Songs[CurSong][1]:GetMusicPath() then
	    SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
    end
end

-- This is the main function, Its the function that contains the wheel.
return function(Style)

	-- Load the songs from the Songs Loader module.
    local Songs = LoadModule("Songs.Loader.lua")(Style)
    
    -- Load a list of all the groups.
    local Groups = LoadModule("Group.List.lua")(Songs)

    if CurGroup == "" then CurGroup = Groups[1] end

    -- Load the Difficulty songs system.
    local DiffLoader = LoadModule("Songs.DifficultyLoader.lua")(Songs,CurGroup)
    local DiffSongs = DiffLoader[CurDiff]

    while #DiffSongs < 1 do

        print(CurDiff.." - "..CurGroup)

        CurDiff = CurDiff + 1
        if CurDiff > 4 then
            error("YOU DO NOT HAVE A SONGPACK THAT IS SUPORTED")
        end

        DiffSongs = DiffLoader[CurDiff]
    end

    local function compare(a,b)
        return a[2]:GetMeter() < b[2]:GetMeter()
    end

    table.sort(DiffSongs, compare)

    -- We define here is we load the Options menu when people double press,
	-- Because they need to double press it starts at false.
	local StartOptions = false

    -- The main songwheel that contains all the songs.
    local SongWheel = Def.ActorFrame{Name="SongWheel"}

    -- The secondary bannerwheel for ontop of the songwheel.
    local BannerWheel = Def.ActorFrame{Name="BannerWheel"}

    -- The groupwheel to select group.
    local GroupWheel = Def.ActorFrame{Name="GroupWheel"}

    for i = 1,10 do

        local pos = CurSong+i-5

        -- Stay within limits.
		while pos > #DiffSongs do pos = pos-#DiffSongs end
		while pos < 1 do pos = #DiffSongs+pos end

        SongWheel[#SongWheel+1] = Def.ActorFrame{
            Name="Song"..i,
            OnCommand=function(self)
                self:zoom(.30):xy(11*i,40*i)
            end,

            Def.Sprite{
                Texture=THEME:GetPathG("","POPN/POPNmask.png"),
                OnCommand=function(self)
                    self:MaskSource()
                end
            },

            Def.Quad{
                OnCommand=function(self)
                    self:x(60):zoomto(380,128):diffuse(0,0,0,1):MaskDest()
                end
            },

            Def.Sprite{
                Name="Banner",
			    -- Load white as fallback.
    			Texture=THEME:GetPathG("","white.png"),
                OnCommand=function(self)
                    -- If the banner exist, Load Banner.png.
                    if DiffSongs[pos][1]:HasBanner() then 
                        self:visible(true):Load(DiffSongs[pos][1]:GetBannerPath()) 
                    else
                        self:visible(false)
                    end
                    self:x(60):zoomto(380,128):MaskDest()
                end
            },

            Def.Quad{
                OnCommand=function(self)
                    self:x(60):zoomto(380,128):diffuse(1,1,1,.6):MaskDest()
                end
            },

            Def.BitmapText{
                Name="Title",
                Font="_open sans 40px",
                Text=DiffSongs[pos][1]:GetDisplayMainTitle(),
                OnCommand=function(self)
                    self:diffuse(0,0,0,1):maxwidth(320):x(60):strokecolor(0,0,0,1)
                end
            },

            Def.ActorFrame{
                Name="DiffCon",
                OnCommand=function(self)
                    self:zoom(.4):x(-200)
                    if i == 5 then
                        self:x(-220):zoom(.5)
                    end
                end,
                Def.Sprite{
                    Name="BG",
        			Texture=THEME:GetPathG("","POPN/POPNdiff.png"),
                    OnCommand=function(self)
                        self:diffuse(DiffColors[CurDiff])
                    end
                },
                Def.BitmapText{
                    Name="Diff",
                    Font="_open sans 40px",
                    Text=DiffSongs[pos][2]:GetMeter(),
                    OnCommand=function(self)
                        self:diffuse(0,0,0,1):strokecolor(0,0,0,1):zoom(4):zoomy(3)
                    end
                }
            }
        }
    end

    for i = -1,1 do
        local pos = CurSong+i

        -- Stay within limits.
		while pos > #DiffSongs do pos = pos-#DiffSongs end
        while pos < 1 do pos = #DiffSongs+pos end  
        
        BannerWheel[#BannerWheel+1] = Def.Sprite{
            Name="Banner"..i+2,
            -- Load white as fallback.
            Texture=THEME:GetPathG("","white.png"),
            OnCommand=function(self)
                -- If the banner exist, Load Banner.png.
                if DiffSongs[pos][1]:HasBanner() then 
                    self:visible(true):Load(DiffSongs[pos][1]:GetBannerPath()):zoomto(380,128)
                else
                    self:visible(false):zoomto(0,0)
                end
                self:xy(60,128*i):MaskDest()
            end
        }
    end

    for i = 1,14 do
        local pos = CurGroupNum+i-6

        -- Stay within limits.
		while pos > #Groups do pos = pos-#Groups end
        while pos < 1 do pos = #Groups+pos end
        
        GroupWheel[#GroupWheel+1] = Def.ActorFrame{
            Name="Group"..i,
            OnCommand=function(self)
                self:rotationz(-22.5):xy(90*i,100):zoom(.2)
            end,
            Def.Sprite{
                Name="Banner",
                Texture=THEME:GetPathG("","white.png"),
                OnCommand=function(self)
                    if SONGMAN:GetSongGroupBannerPath(Groups[pos]) ~= "" then
                        self:Load(SONGMAN:GetSongGroupBannerPath(Groups[pos]))
                    end

                    self:zoomto(512,160)

                    if CurGroupNum ~= pos then
                        self:diffuse(.5,.5,.5,1)
                    end
                end
            },
            Def.BitmapText{
                Name="Title",
                Text=Groups[pos],
                Font="_open sans 40px",
                OnCommand=function(self)
                    self:diffuse(0,0,0,1):maxwidth(420):strokecolor(0,0,0,1)

                    if SONGMAN:GetSongGroupBannerPath(Groups[pos]) ~= "" then
                        self:visible(false)
                    end
                end
            }
        }

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
			if DiffSongs[CurSong][1].PlayPreviewMusic then
				DiffSongs[CurSong][1]:PlayPreviewMusic()
			elseif GroupDiffSongssAndSongs[CurSong][1]:GetMusicPath() then
				SOUND:PlayMusicPart(DiffSongs[CurSong][1]:GetMusicPath(),DiffSongs[CurSong][1]:GetSampleStart(),DiffSongs[CurSong][1]:GetSampleLength(),0,0,true)
			end
		end,
        
        -- Do stuff when a user presses left on Pad or Menu buttons.
        MenuLeftCommand=function(self) 
            MoveGroup(self,-1,Groups)
            DiffLoader = LoadModule("Songs.DifficultyLoader.lua")(Songs,CurGroup)
            DiffSongs = DiffLoader[CurDiff]

            while #DiffSongs < 1 do
                CurDiff = CurDiff +1
                if CurDiff > 4 then CurDiff = 1 end
                DiffSongs = DiffLoader[CurDiff]
            end

            table.sort(DiffSongs, compare)

            ChangeDiff(self,DiffSongs) end,
		
		-- Do stuff when a user presses Right on Pad or Menu buttons.
        MenuRightCommand=function(self) 
            MoveGroup(self,1,Groups) 
            DiffLoader = LoadModule("Songs.DifficultyLoader.lua")(Songs,CurGroup)
            DiffSongs = DiffLoader[CurDiff]

            while #DiffSongs < 1 do
                CurDiff = CurDiff +1
                if CurDiff > 4 then CurDiff = 1 end
                DiffSongs = DiffLoader[CurDiff]
            end

            table.sort(DiffSongs, compare)

            ChangeDiff(self,DiffSongs) 
        end,
		
		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuDownCommand=function(self) MoveSelection(self,1,DiffSongs) end,
		
		-- Do stuff when a user presses the Down on Pad or Menu buttons.
        MenuUpCommand=function(self) MoveSelection(self,-1,DiffSongs) end,

        SelectCommand=function(self)

            CurDiff = CurDiff +1
            if CurDiff > 4 then CurDiff = 1 end
            DiffSongs = DiffLoader[CurDiff]

            while #DiffSongs < 1 do
                CurDiff = CurDiff +1
                if CurDiff > 4 then CurDiff = 1 end
                DiffSongs = DiffLoader[CurDiff]
            end

            table.sort(DiffSongs, compare)
            
            ChangeDiff(self,DiffSongs)
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
			-- Check if we want to go to ScreenPlayerOptions instead of ScreenGameplay.
			if StartOptions then
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPlayerOptions"):StartTransitioningScreen("SM_GoToNextScreen")
			end
			-- Check if player is joined.
			if Joined[self.pn] then 
			
				--We use PlayMode_Regular for now.
				GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
				
				--Set the song we want to play.
				GAMESTATE:SetCurrentSong(DiffSongs[CurSong][1])
				
				-- Check if 2 players are joined.
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
				
					-- If they are, We will use Versus.
					GAMESTATE:SetCurrentStyle('versus')
					
					-- Save Profiles.
					PROFILEMAN:SaveProfile(PLAYER_1)
					PROFILEMAN:SaveProfile(PLAYER_2)
					
					-- Set the Current Steps to use.
					GAMESTATE:SetCurrentSteps(PLAYER_1,DiffSongs[CurSong][2])
					GAMESTATE:SetCurrentSteps(PLAYER_2,DiffSongs[CurSong][2])
				else
				
					-- If we are single player, Use Single.
					GAMESTATE:SetCurrentStyle(TF_WHEEL.StyleDB[Style])
					
					-- Save Profile.
					PROFILEMAN:SaveProfile(self.pn)
					
					-- Set the Current Step to use.
					GAMESTATE:SetCurrentSteps(self.pn,DiffSongs[CurSong][2])
				end
				
				-- We want to go to player options when people doublepress, So we set the StartOptions to true,
				-- So when the player presses Start again, It will go to player options.
				StartOptions = true
				
				-- Wait 0.4 sec before we go to next screen.
				self:sleep(0.4):queuecommand("StartSong")
			else
				-- If no player is active Join.
				GAMESTATE:JoinPlayer(self.pn)
				
				-- Load the profles.
				GAMESTATE:LoadProfiles()
				
				-- Add to joined list.
				Joined[self.pn] = true
			end
        end,
        
        -- Change to ScreenGameplay.
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
        end,
        
        GroupWheel..{
            OnCommand=function(self)            
                self:x(-700)
            end
        },

        Def.Sprite{
            Name="Frame",
            Texture=THEME:GetPathG("","POPN/POPNframe.png"),
            OnCommand=function(self)
                self:zoom(.3):x(120):diffuse(DiffColors[CurDiff])
            end
        },
        Def.Quad{
            OnCommand=function(self)
                self:zoomto(256,256):diffuse(0,0,0,1):xy(100,-232):MaskSource()
            end
        },
        SongWheel..{
            OnCommand=function(self)            
                self:xy(54,-190):z(-200):MaskDest()
            end
        },

        Def.ActorFrame{
            Name="BannerCon",
            OnCommand=function(self)
                self:zoom(.35):xy(110,10)
            end,
            Def.Quad{
                OnCommand=function(self)
                    self:xy(60,-1560):zoomto(3000,3000):diffuse(0,0,0,1):MaskSource()
                end
            },
            Def.Quad{
                OnCommand=function(self)
                    self:xy(60,1560):zoomto(3000,3000):diffuse(0,0,0,1):MaskSource()
                end
            },
            Def.Quad{
                OnCommand=function(self)
                    self:xy(-1630,0):zoomto(3000,3000):diffuse(0,0,0,1):MaskSource()
                end
            },
            Def.Quad{
                OnCommand=function(self)
                    self:xy(1750,0):zoomto(3000,3000):diffuse(0,0,0,1):MaskSource()
                end
            },
            Def.Sprite{
                Texture=THEME:GetPathG("","POPN/POPNmask.png"),
                OnCommand=function(self)
                    self:MaskSource()
                end
            },
            Def.Quad{
                OnCommand=function(self)
                    self:x(60):zoomto(380,128):diffuse(0,0,0,1):MaskDest()
                end
            },

            BannerWheel,            

            Def.Quad{
                OnCommand=function(self)
                    self:x(60):zoomto(380,128):diffuse(1,1,1,.6):MaskDest()
                end
            },

            Def.BitmapText{
                Name="Title",
                Font="_open sans 40px",
                Text=DiffSongs[CurSong][1]:GetDisplayMainTitle(),
                OnCommand=function(self)
                    self:diffuse(0,0,0,1):maxwidth(320):x(60):strokecolor(0,0,0,1)
                end
            }
        },

        Def.Sprite{
            Name="Selector",
            Texture=THEME:GetPathG("","POPN/POPNSel.png"),
            OnCommand=function(self)
                self:zoom(.35):xy(110,10):diffuse(DiffFrameColors[CurDiff])
            end           
        },

        Def.Sprite{
            Name="Highlight",
            Texture=THEME:GetPathG("","POPN/POPNSel.png"),
            OnCommand=function(self)
                self:zoom(.35):xy(110,10):diffuse(DiffFrameColors[CurDiff])
                :queuecommand("Effect")
            end,
            EffectCommand=function(self)
                self:decelerate(0.4):zoomy(.7):diffusealpha(0):sleep(1):zoomy(.35):diffusealpha(1):queuecommand("Effect")
            end
        },

        Def.Sprite{
            Name="InfoCon",
            Texture=THEME:GetPathG("","POPN/POPNBannerCon.png"),
            OnCommand=function(self)
                self:zoom(.6):xy(-140,-60):diffuse(DiffColors[CurDiff])
            end
        },

        Def.Sprite{
            Name="Banner",
            Texture=THEME:GetPathG("","white.png"),
                OnCommand=function(self)
                -- If the banner exist, Load Banner.png.
                if DiffSongs[CurSong][1]:HasBanner() then 
                    self:visible(true):Load(DiffSongs[CurSong][1]:GetBannerPath()) 
                else
                    self:visible(false)
                end
                self:zoom(TF_WHEEL.Resize(self:GetWidth(),self:GetHeight(),210,54)):xy(-134,-60)
            end
        }
    }
end