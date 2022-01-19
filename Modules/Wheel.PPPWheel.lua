-- Difficulty Colours
local DiffColors={
	color("#88ffff"), -- Difficulty_Beginner
	color("#ffc0cb"), -- Difficulty_Easy
	color("#ff8888"), -- Difficulty_Medium
	color("#88ff88"), -- Difficulty_Hard
	color("#8888ff"), -- Difficulty_Challenge
	color("#888888") -- Difficulty_Edit
}

-- Difficulty Names.
local DiffNames={
	"BEGIN", -- Difficulty_Beginner
	"PARAPARA", -- Difficulty_Easy
	"NORMAL", -- Difficulty_Medium
	"HARD ", -- Difficulty_Hard
	"EXPERT", -- Difficulty_Challenge
	"EDIT" -- Difficulty_Edit
}

-- We define the curent song if no song is selected.
if not CurSong then CurSong = 1 end

-- We define the current group to be empty if no group is defined.
if not CurGroup then GurGroup = "" end

-- The player joined.
if not Joined then Joined = {} end

-- The increase offset for when we move with postive.
local IncOffset = 1

-- The decrease offset for when we move with negative.
local DecOffset = 10

-- The center offset of the wheel.
local XOffset = 5

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
	if XOffset > 10 then XOffset = 1 end
	if XOffset < 1 then XOffset = 10 end
    
    -- If we are calling this command with an offset that is not 0 then do stuff.
	if offset ~= 0 then

		self:GetChild("Selector"):stoptweening():linear(.05):diffusealpha(.2):linear(.05):diffusealpha(1)

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
		
			-- Transform the wheel, As in make it move.
			self:GetChild("SongWheel"):GetChild("CD"..i):linear(.1):addx((offset*-240))

			-- Here we define what the wheel does if it is outside the values.
			-- So that when a part is at the bottom it will move to the top.
			if (i == IncOffset and offset == -1) or (i == DecOffset and offset == 1) then

				-- Move wheelpart instantly to new location.
                self:GetChild("SongWheel"):GetChild("CD"..i):sleep(0):addx((offset*-240)*-10)
				
				self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDText"):settext("")

                if type(Songs[pos]) ~= "string" then
                    if Songs[pos][1]:HasJacket() then 
						self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDTexture"):Load(Songs[pos][1]:GetJacketPath()) 
                    elseif Songs[pos][1]:HasBackground() then 
						self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDTexture"):Load(Songs[pos][1]:GetBackgroundPath())
					else 
						self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDTexture"):Load(THEME:GetPathG("","white.png"))
						self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDText"):settext(Songs[pos][1]:GetDisplayMainTitle())
                    end
                else
                    if SONGMAN:GetSongGroupBannerPath(Songs[pos]) ~= "" then 
						self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDTexture"):Load(SONGMAN:GetSongGroupBannerPath(Songs[pos])) 
					else 
						self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDTexture"):Load(THEME:GetPathG("","white.png"))
						self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDText"):settext(Songs[pos])
                    end
                end
                self:GetChild("SongWheel"):GetChild("CD"..i):GetChild("CDTexture"):zoomto(400,400) 
            end
        end

		-- Check if its a song.
		if type(Songs[CurSong]) ~= "string" then
			-- Set the Centered Banner.
			self:GetChild("Banner"):visible(true):Load(Songs[CurSong][1]:GetBannerPath())

			if Songs[CurSong][1]:HasBanner() then
				self:GetChild("BannerInfo"):visible(false)
			else
				self:GetChild("BannerInfo"):visible(true):diffuse(math.random()+.5,math.random()+.5,math.random()+.5,1):zoomy(0):linear(.08):zoomy(1)
				self:GetChild("BannerInfo"):GetChild("Title"):settext(ToUpper(Songs[CurSong][1]:GetDisplayMainTitle()))
				self:GetChild("BannerInfo"):GetChild("SubTitle"):settext(ToUpper(Songs[CurSong][1]:GetDisplaySubTitle()))
				self:GetChild("BannerInfo"):GetChild("Artist"):settext(ToUpper(Songs[CurSong][1]:GetDisplayArtist()))
			end

			self:GetChild("Info"):GetChild("BPM"):visible(true):settext("BPM "..string.format("%.0f",Songs[CurSong][1]:GetDisplayBpms()[2]))

		-- Its a group.
		else	
			-- Set banner.
			if SONGMAN:GetSongGroupBannerPath(Songs[CurSong]) ~= "" then
				self:GetChild("Banner"):visible(true):Load(SONGMAN:GetSongGroupBannerPath(Songs[CurSong]))
				self:GetChild("BannerInfo"):visible(false)
			else
				self:GetChild("Banner"):visible(false)
				self:GetChild("BannerInfo"):visible(true):diffuse(math.random()+.5,math.random()+.5,math.random()+.5,1):zoomy(0):linear(.08):zoomy(1)
				self:GetChild("BannerInfo"):GetChild("Title"):settext(ToUpper(Songs[CurSong]))
				self:GetChild("BannerInfo"):GetChild("SubTitle"):settext("")
				self:GetChild("BannerInfo"):GetChild("Artist"):settext("")
			end

			self:GetChild("Info"):GetChild("BPM"):visible(false)
		end

		-- Resize the Centered Banner  to be w(512/8)*5 h(160/8)*5
		self:GetChild("Banner"):zoom(TF_WHEEL.Resize(self:GetChild("Banner"):GetWidth(),self:GetChild("Banner"):GetHeight(),(512/10)*5,(160/10)*5))
			:zoomy(0):linear(.08):zoom(TF_WHEEL.Resize(self:GetChild("Banner"):GetWidth(),self:GetChild("Banner"):GetHeight(),(512/10)*5,(160/10)*5))
    else
        -- For every part of the wheel do.
		for i = 1,10 do	

			-- Offset for the wheel items.
			off = i + XOffset

			-- Stay withing limits.
			while off > 10 do off = off-10 end
			while off < 1 do off = off+10 end

			-- Get center position.
			local pos = CurSong+i

			-- If item is above 5 then we do a -10 to fix the display.
			if i > 5 then
				pos = CurSong+i-10
			end

			-- Keep pos withing limits.
			while pos > #Songs do pos = pos-#Songs end
            while pos < 1 do pos = #Songs+pos end
			
			self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDText"):settext("")

            if type(Songs[pos]) ~= "string" then
                if Songs[pos][1]:HasJacket() then self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDTexture"):Load(Songs[pos][1]:GetJacketPath()) 
                elseif Songs[pos][1]:HasBackground() then 
					self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDTexture"):Load(Songs[pos][1]:GetBackgroundPath())
				else 
					self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDTexture"):Load(THEME:GetPathG("","white.png"))
					self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDText"):settext(Songs[pos][1]:GetDisplayMainTitle())
                end
            else
                if SONGMAN:GetSongGroupBannerPath(Songs[pos]) ~= "" then 
					self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDTexture"):Load(SONGMAN:GetSongGroupBannerPath(Songs[pos])) 
				else 
					self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDTexture"):Load(THEME:GetPathG("","white.png"))
					self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDText"):settext(Songs[pos])
                end
            end
            self:GetChild("SongWheel"):GetChild("CD"..off):GetChild("CDTexture"):zoomto(400,400) 
        end
    end

    -- Check if offset is not 0.
	if offset ~= 0 then
		-- Stop all the music playing, Which is the Song Music
		SOUND:StopMusic()

		-- Check if its a song.
		if type(Songs[CurSong]) ~= "string" then
			-- Play Current selected Song Music.
			if Songs[CurSong][1]:GetMusicPath() then
				SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
			end
		end
	end
end

-- Define the start difficulty to be the 2nd selection,
-- Because the first selection is the entire Song,
-- And the second and plus versions are all difficulties.
local CurDiff = 2

-- Move the Difficulty (or change selection in this case).
local function MoveDifficulty(self,offset,Songs)	
	
	-- Check if its a group
	if type(Songs[CurSong]) == "string" then
	
		-- If it is a group hide the diffs
		self:GetChild("DiffStars"):visible(false)
		self:GetChild("Info"):GetChild("ChartArtist"):visible(false)
		
	-- Not a group
	else	
		-- Move the current difficulty + offset.
		CurDiff = CurDiff + offset
	
		-- Stay withing limits, But ignoring the first selection because its the entire song.
		if CurDiff > #Songs[CurSong] then CurDiff = 2 end
		if CurDiff < 2 then CurDiff = #Songs[CurSong] end

		self:GetChild("DiffStars"):visible(true)
		
		for i = 1,7 do
			self:GetChild("DiffStars"):GetChild("Star"..i):diffusealpha(0)
		end
		
		-- We get the Meter from the game, And make it so it stays between 8 which is the Max feets we support.
		local DiffCount = Songs[CurSong][CurDiff]:GetMeter()
		if DiffCount > 7 then  DiffCount = 7 end
	
		-- For every Meter value we got for the game, We show the amount of feets for the difficulty, And center them.
		for i = 1,DiffCount do
			self:GetChild("DiffStars"):GetChild("Star"..i):diffusealpha(1)
		end

		self:GetChild("DiffDisplay"):GetChild("BG"):diffuse(DiffColors[TF_WHEEL.DiffTab[Songs[CurSong][CurDiff]:GetDifficulty()]])
		self:GetChild("DiffDisplay"):GetChild("Text"):settext(DiffNames[TF_WHEEL.DiffTab[Songs[CurSong][CurDiff]:GetDifficulty()]])
		self:GetChild("Info"):GetChild("ChartArtist"):visible(true):settext(Songs[CurSong][CurDiff]:GetAuthorCredit())
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

    -- The main songwheel that contains all the songs.
    local SongWheel = Def.ActorFrame{Name="SongWheel"}

	local DiffStars = Def.ActorFrame{Name="DiffStars"}

    for i = 1,10 do

        -- Position of current song, We want the cd in the front, So its the one we change.
		local pos = CurSong+i-5
		
		-- Stay within limits.
		while pos > #GroupsAndSongs do pos = pos-#GroupsAndSongs end
		while pos < 1 do pos = #GroupsAndSongs+pos end

        SongWheel[#SongWheel+1] = Def.ActorFrame{
            Name="CD"..i,
            OnCommand=function(self)
                self:zoom(.5):x(200+(-240*5)+(240*i))
            end,
            Def.Sprite{
                Texture=THEME:GetPathG("","PPP/CD.png")
            },
            Def.Sprite{
                Texture=THEME:GetPathG("","PPP/Mask.png"),
                OnCommand=function(self)
                    self:MaskSource()
                end
            },
            Def.Sprite{
                Name="CDTexture",
                Texture=THEME:GetPathG("","white.png"),
                OnCommand=function(self)
                    if type(GroupsAndSongs[pos]) ~= "string" then
                        if GroupsAndSongs[pos][1]:HasJacket() then self:Load(GroupsAndSongs[pos][1]:GetJacketPath()) 
                        elseif GroupsAndSongs[pos][1]:HasBackground() then self:Load(GroupsAndSongs[pos][1]:GetBackgroundPath()) 
                        end
                    else
                        if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos]) ~= "" then self:Load(SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos])) end
                    end
                    self:MaskDest():zoomto(400,400) 
                end
			},
			Def.BitmapText{
				Name="CDText",
				Font="_open sans 40px",
				OnCommand=function(self)
					if type(GroupsAndSongs[pos]) ~= "string" then
						if not GroupsAndSongs[pos][1]:HasJacket() and not GroupsAndSongs[pos][1]:HasBackground() then
							self:settext(GroupsAndSongs[pos][1]:GetDisplayMainTitle())
                        end
                    else
						if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos]) == "" then
							self:settext(GroupsAndSongs[pos])
						end
					end
					self:diffuse(0,0,0,1):maxwidth(320):y(-100)
				end
			}
        }


    end

	for i = 1,7 do
		DiffStars[#DiffStars+1] = Def.ActorFrame{
			Name="Star"..i,
			OnCommand=function(self) self:zoom(.06):x(-30+(i*40)) end,
			Def.Sprite{
				Texture=THEME:GetPathG("","Star.png"),
				OnCommand=function(self)
					self:MaskSource():zoom(.5)
				end
			},
			Def.Sprite{
				Texture=THEME:GetPathG("","Star.png"),
				OnCommand=function(self)
					self:MaskDest():diffuse(1,1,0,1)
				end
			},
			Def.Sprite{
				Texture=THEME:GetPathG("","Star.png"),
				OnCommand=function(self)
					self:MaskDest():fadetop(.4):fadebottom(.6)
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

			-- Initalize the Difficulties.
			MoveDifficulty(self,0,GroupsAndSongs)
        end,
        
        -- Play Music at start of screen,.
		PlayCurrentSongCommand=function(self)
			if type(GroupsAndSongs[CurSong]) ~= "string" and GroupsAndSongs[CurSong][1]:GetMusicPath() then
				SOUND:PlayMusicPart(GroupsAndSongs[CurSong][1]:GetMusicPath(),GroupsAndSongs[CurSong][1]:GetSampleStart(),GroupsAndSongs[CurSong][1]:GetSampleLength(),0,0,true)
			end
        end,
        
        -- Do stuff when a user presses left on Pad or Menu buttons.
        MenuLeftCommand=function(self) 
			MoveSelection(self,-1,GroupsAndSongs) 
			MoveDifficulty(self,0,GroupsAndSongs) 
			self:GetChild("Select"):GetChild("LeftCon"):GetChild("LeftArrow"):diffuse(1,1,0,.6):sleep(.08):diffusealpha(0)
		end,
		
		-- Do stuff when a user presses Right on Pad or Menu buttons.
        MenuRightCommand=function(self) 
			MoveSelection(self,1,GroupsAndSongs) 
			MoveDifficulty(self,0,GroupsAndSongs)
			self:GetChild("Select"):GetChild("RightCon"):GetChild("RightArrow"):diffuse(1,1,0,.6):sleep(.08):diffusealpha(0)
		 end,

		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuDownCommand=function(self) MoveDifficulty(self,1,GroupsAndSongs) end,
		
		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuUpCommand=function(self) MoveDifficulty(self,-1,GroupsAndSongs) end,

        -- Do stuff when a user presses the Back on Pad or Menu buttons.
		BackCommand=function(self) 
			-- Check if User is joined.
			if Joined[self.pn] then
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					-- If both players are joined, We want to unjoin the player that pressed back.
					GAMESTATE:UnjoinPlayer(self.pn)
					Joined[self.pn] = false
					
					MoveSelection(self,0,GroupsAndSongs)
				else
					-- Go to the previous screen.
					SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen") 
				end
			end
		end,

        -- Do stuff when a user presses the Start on Pad or Menu buttons.
		StartCommand=function(self)

			self:GetChild("Select"):GetChild("Start"):GetChild("StartButton"):diffuse(1,0,0,.6):sleep(.08):diffusealpha(0)

			-- Check if we want to go to ScreenPlayerOptions instead of ScreenGameplay.
			if StartOptions then
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPlayerOptions"):StartTransitioningScreen("SM_GoToNextScreen")
			end
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
					MoveSelection(self,0,GroupsAndSongs)
					
					-- Set CurSong to the right group.
					for i,v in ipairs(GroupsAndSongs) do
						if v == CurGroup then
							CurSong = i
						end
					end

					-- Set the current group.
					GroupsAndSongs = LoadModule("Group.Sort.lua")(Songs,CurGroup)
					MoveSelection(self,0,GroupsAndSongs)
					
				-- Not on a group, Start song.
				else

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
						GAMESTATE:SetCurrentSteps(PLAYER_1,GroupsAndSongs[CurSong][CurDiff])
						GAMESTATE:SetCurrentSteps(PLAYER_2,GroupsAndSongs[CurSong][CurDiff])
					else
				
						-- If we are single player, Use Single.
						GAMESTATE:SetCurrentStyle(TF_WHEEL.StyleDB[Style])
					
						-- Save Profile.
						PROFILEMAN:SaveProfile(self.pn)
					
						-- Set the Current Step to use.
						GAMESTATE:SetCurrentSteps(self.pn,GroupsAndSongs[CurSong][CurDiff])
					end
				
					-- We want to go to player options when people doublepress, So we set the StartOptions to true,
					-- So when the player presses Start again, It will go to player options.
					StartOptions = true

					-- Wait 0.4 sec before we go to next screen.
					self:sleep(0.4):queuecommand("StartSong")
				end
			else
				-- If no player is active Join.
				GAMESTATE:JoinPlayer(self.pn)
				
				-- Load the profles.
				GAMESTATE:LoadProfiles()
				
				-- Add to joined list.
				Joined[self.pn] = true
				
				MoveSelection(self,0,GroupsAndSongs)
			end			
		end,
		
		-- Change to ScreenGameplay.
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,

		SongWheel..{
			OnCommand=function(self)            
                self:z(-200)
            end
		},
		
		Def.Sprite{
			Name="Selector",
			OnCommand=function(self)
				self:x(200):zoom(.5):diffuse(color("#CFEEFA"))
			end,
			Texture=THEME:GetPathG("","PPP/Selector.png")
		},

		Def.ActorFrame{
			OnCommand=function(self)
				self:xy(-160,36)
			end,
			Def.Quad{
				OnCommand=function(self)	
					self:zoomto(354,200):diffuse(.3,0,.5,.8):y(-40)
				end
			},
			Def.Quad{
				OnCommand=function(self)	
					self:zoomto(300,48):diffuse(.3,0,.5,.8):y(118):x(-25)
				end
			},
			Def.Sprite{
				OnCommand=function(self)
					self:zoom(.45):zoomx(.4)
				end,
				Texture=THEME:GetPathG("","PPP/MusicInfo.png")
			
			},
			Def.BitmapText{
				Text="MUSIC INFORMATION",
				Font="_open sans 40px",
				OnCommand=function(self)
					self:zoom(.45):xy(70,74):diffuse(.5,.5,.5,1):strokecolor(.5,.5,.5,1):zoomy(.65)
				end
			}
		},

		Def.ActorFrameTexture{
			Name="Diff",
			InitCommand=function(self)
				self:SetTextureName("DiffAFT")
					:SetWidth(360)
					:SetHeight(60)
					:EnableAlphaBuffer(true)
					:Create()
					:Draw()
			end,
			Def.Quad{
				OnCommand=function(self)	
					self:zoomto(300,10):diffuse(.8,0,.8,1):xy(180,30)
				end
			},
			Def.Sprite{
				Name="Circle",
				OnCommand=function(self)
					self:zoom(.05):xy(330,30):diffuse(.8,0,.8,1)
				end,
				Texture=THEME:GetPathG("","Circle.png")
			},
			Def.ActorProxy{
				OnCommand=function(self)
					self:SetTarget(self:GetParent():GetChild("Circle")):x(-300)
				end
			},
			Def.BitmapText{
				Font="_open sans 40px",
				Text="E",
				OnCommand=function(self)
					self:xy(30,30):zoom(.6)
				end
			},
			Def.BitmapText{
				Font="_open sans 40px",
				Text="D",
				OnCommand=function(self)
					self:xy(330,30):zoom(.6)
				end
			}
		},
		Def.Sprite{
			Texture="DiffAFT",
			OnCommand=function(self)		
				self:xy(-160,76):diffusealpha(.5)
			end
		},

		DiffStars..{
			OnCommand=function(self)            
                self:z(100):xy(-290,76):diffusealpha(.5)
            end
		},

		Def.ActorFrame{
			Name="DiffDisplay",
			OnCommand=function(self)
				self:xy(-58,-130):zoomy(.85)
			end,
			Def.Quad{
				Name="BG",
				OnCommand=function(self)
					if type(GroupsAndSongs[CurSong]) ~= "string" then	
						self:zoomto(148,38):diffuse(DiffColors[TF_WHEEL.DiffTab[GroupsAndSongs[CurSong][CurDiff]:GetDifficulty()]])
					else
						self:zoomto(148,38):diffuse(DiffColors[2])
					end

				end
			},
			Def.Sprite{
				OnCommand=function(self)
					self:zoom(.4)
				end,
				Texture=THEME:GetPathG("","PPP/Diff.png")
			},
			Def.BitmapText{
				Name="Text",
				Font="_open sans 40px",
				OnCommand=function(self)
					self:zoom(.6):diffuse(1,1,1,1):maxwidth(320)
						:strokecolor(1,1,1,1)
					if type(GroupsAndSongs[CurSong]) ~= "string" then	
						self:settext(DiffNames[TF_WHEEL.DiffTab[GroupsAndSongs[CurSong][CurDiff]:GetDifficulty()]])
					else
						self:settext(DiffNames[2])
					end

				end
			}
		},

		-- Load the Global Centered Banner.
		Def.Sprite{
			Name="Banner",
			Texture=THEME:GetPathG("","white.png"),
			OnCommand=function(self)
				-- Check if we are on song
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					self:Load(GroupsAndSongs[CurSong][1]:GetBannerPath())
					
				-- Not on song, Show group banner.
				else
					if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[CurSong]) ~= "" then
						self:Load(SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[CurSong]))
					else
						self:visible(false)
					end
				end
			
				self:xy(-160,-40):zoom(TF_WHEEL.Resize(self:GetWidth(),self:GetHeight(),(512/10)*5,(160/10)*5))
			end				
		},

		Def.ActorFrame{
			Name="BannerInfo",
			OnCommand=function(self)
				self:x(-160):y(-30):diffuse(math.random()+.5,math.random()+.5,math.random()+.5,1)
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					if GroupsAndSongs[CurSong][1]:HasBanner() then
						self:visible(false)
					end
				else	
					if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[CurSong]) ~= "" then
						self:visible(false)
					end
				end
			end,
			Def.Quad{
				OnCommand=function(self)			
					self:zoomto(320,2)
				end
			},
			Def.BitmapText{
				Name="Title",
				Font="_open sans 40px",
				OnCommand=function(self)
					self:diffuse(1,1,1,1)
						:y(-30)
						:maxwidth(320)
					-- Check if we are on song
					if type(GroupsAndSongs[CurSong]) ~= "string" then
						self:settext(ToUpper(GroupsAndSongs[CurSong][1]:GetDisplayMainTitle()))
					else
						self:settext(ToUpper(GroupsAndSongs[CurSong]))
					end
				end
			},
			Def.BitmapText{
				Name="SubTitle",
				Font="_open sans 40px",
				OnCommand=function(self)
					self:zoom(.2):diffuse(1,1,1,1)
						:y(-10)
						:maxwidth(1600)

					-- Check if we are on song
					if type(GroupsAndSongs[CurSong]) ~= "string" then
						self:settext(ToUpper(GroupsAndSongs[CurSong][1]:GetDisplaySubTitle()))
					end
				end
			},
			Def.BitmapText{
				Name="Artist",
				Font="_open sans 40px",
				OnCommand=function(self)
					self:zoom(.8):diffuse(1,1,1,1)
						:y(20)
						:maxwidth(400)

					-- Check if we are on song
					if type(GroupsAndSongs[CurSong]) ~= "string" then
						self:settext(ToUpper(GroupsAndSongs[CurSong][1]:GetDisplayArtist()))
					end
				end
			}
		},

		Def.ActorFrame{
			OnCommand=function(self) self:xy(-160,-94) end,
			Def.BitmapText{
				Font="_open sans 40px",
				Text="Music Title", -- Thanks subo and paraph
				OnCommand=function(self)
					self:zoom(.38):zoomx(.8):diffuse(1,1,1,.2)
						:MaskSource()
				end
			},
			Def.BitmapText{
				Font="_open sans 40px",
				Text="Music Title", -- Thanks subo and paraph
				OnCommand=function(self)
					self:zoom(.4):zoomx(.8):diffuse(1,1,1,1)
						:strokecolor(.8,.6,1,1)
						:MaskDest()
				end
			}
		},

		Def.ActorFrame{
			OnCommand=function(self) self:xy(-160,46) end,
			Def.BitmapText{
				Font="_open sans 40px",
				Text="Dance Level", -- Thanks subo and paraph
				OnCommand=function(self)
					self:zoom(.38):zoomx(.5):diffuse(1,1,1,.2)
						:MaskSource()
				end
			},
			Def.BitmapText{
				Font="_open sans 40px",
				Text="Dance Level", -- Thanks subo and paraph
				OnCommand=function(self)
					self:zoom(.4):zoomx(.5):diffuse(1,1,1,1)
						:strokecolor(.8,.6,1,1)
						:MaskDest()
				end
			}
		},

		Def.ActorFrame{
			Name="Info",
			OnCommand=function(self) self:xy(-160,20) end,
			Def.Quad{
				OnCommand=function(self)
					self:zoomto(154,26)
						:diffuse(.8,.6,1,.5)
						:x(-80)
				end
			},
			Def.Quad{
				OnCommand=function(self)
					self:zoomto(154,26)
						:diffuse(.8,.6,1,.5)
						:x(80)
				end
			},
			Def.BitmapText{
				Name="BPM",
				Font="_open sans 40px",
				OnCommand=function(self)
					self:zoom(.5):diffuse(1,1,1,1)
						:halign(0)
						:x(-150)
						:maxwidth(260)

					-- Check if we are on song
					if type(GroupsAndSongs[CurSong]) ~= "string" then
						self:settext("BPM "..string.format("%.0f",GroupsAndSongs[CurSong][1]:GetDisplayBpms()[2]))
					end
				end
			},
			Def.BitmapText{
				Name="ChartArtist",
				Font="_open sans 40px",
				OnCommand=function(self)
					self:zoom(.5):diffuse(1,1,1,1)
						:x(80)
						:maxwidth(260)

					-- Check if we are on song
					if type(GroupsAndSongs[CurSong]) ~= "string" then
						self:settext(GroupsAndSongs[CurSong][CurDiff]:GetAuthorCredit())
					end
				end
			}
		},

		Def.BitmapText{
			Font="_open sans 40px",
			Text=ToEnumShortString(GAMESTATE:GetCurrentStage()):upper().." STAGE",
			OnCommand=function(self)
				self:zoom(.7):diffuse(1,1,1,1)
					:strokecolor(color("#ffc0cb"))
					:halign(1)
					:xy(-150,-126)
			end
		},

		Def.ActorFrame{
			Name="Select",
			OnCommand=function(self)
				self:zoom(1.2):zoomx(1.6):xy(-200,154)
			end,
			Def.ActorFrame{
				Name="LeftCon",
				Def.ActorFrame{
					Name="Left",
					OnCommand=function(self)
						self:x(-70)
					end,
					Def.Sprite{
						Texture=THEME:GetPathG("","Triangle.png"),
						OnCommand=function(self)
							self:zoom(.05):rotationz(-90):diffusealpha(.4)
						end
					},
					Def.Sprite{
						Texture=THEME:GetPathG("","Triangle.png"),
						OnCommand=function(self)
							self:zoom(.04):rotationz(-90):diffuse(0,0,0,1):x(1)
						end
					},
					Def.Sprite{
						Texture=THEME:GetPathG("","Triangle.png"),
						OnCommand=function(self)
							self:zoom(.03):rotationz(-90):diffuse(.6,.4,0,1):x(2)
						end
					},
					Def.Sprite{
						Texture=THEME:GetPathG("","Triangle.png"),
						OnCommand=function(self)
							self:zoom(.03):rotationz(-90):diffuse(1,1,0,.8):x(2):fadeleft(.5):faderight(.3)
						end
					}
				},
				Def.Sprite{
					Name="LeftArrow",
					Texture=THEME:GetPathG("","Triangle.png"),
					OnCommand=function(self)
						self:zoom(.05):rotationz(-90):diffusealpha(0):x(-70)
					end
				}
			},
			Def.ActorFrame{
				Name="RightCon",
				Def.ActorProxy{
					OnCommand=function(self)
						self:SetTarget(self:GetParent():GetParent():GetChild("LeftCon"):GetChild("Left")):x(-114):zoomx(-1)
					end
				},
				Def.Sprite{
					Name="RightArrow",
					Texture=THEME:GetPathG("","Triangle.png"),
					OnCommand=function(self)
						self:zoom(.05):rotationz(90):diffusealpha(0):x(-44)
					end
				}
			},
			Def.BitmapText{
				Font="_open sans 40px",
				Text="Select", -- Thanks subo and paraph
				OnCommand=function(self)
					self:zoom(.4):diffuse(1,1,1,1):x(-10)
				end
			},
			Def.ActorFrame{
				Name="Start",
				OnCommand=function(self)
					self:x(35)
				end,
				Def.Quad{
					OnCommand=function(self)
						self:zoomto(26,26):diffusealpha(.4)
					end
				},
				Def.Quad{
					OnCommand=function(self)
						self:zoomto(22,22):diffuse(0,0,0,1)
					end
				},
				Def.Quad{
					OnCommand=function(self)
						self:zoomto(18,18):diffuse(1,0,0,1)
					end
				},
				Def.Quad{
					OnCommand=function(self)
						self:zoomto(18,18):diffuse(1,1,1,.5):fadebottom(1)
					end
				},
				Def.Quad{
					Name="StartButton",
					OnCommand=function(self)
						self:zoomto(26,26):diffusealpha(0)
					end
				}
			},
			Def.BitmapText{
				Font="_open sans 40px",
				Text="Decide", -- Thanks subo and paraph
				OnCommand=function(self)
					self:zoom(.4):diffuse(1,1,1,1):x(76)
				end
			}
		}
    }
end