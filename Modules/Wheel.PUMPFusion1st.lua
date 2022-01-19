-- We define the curent song if no song is selected.
if not CurSong then CurSong = 1 end

-- We define the current group to be empty if no group is defined.
if not CurGroup then GurGroup = "" end

-- The player joined.
if not Joined then Joined = {} end

-- This is the main function, Its the function that contains the wheel.
return function(Style)

    -- Load the songs from the Songs.Loader module.
	local Songs = LoadModule("Songs.Loader.lua")(Style)
	
	-- Sort the Songs and Group.
    local GroupsAndSongs = LoadModule("Group.Sort.lua")(Songs,CurGroup)

	-- We define here is we load the Options menu when people double press,
	-- Because they need to double press it starts at false.
	local StartOptions = false
    
    local Items = Def.ActorFrame{}

    for i = 1,4 do

        -- Position of current song, We want the cd in the front, So its the one we change.
		local pos = CurSong+i-1
        
        local xoffset = 1
        if i == 2 or i == 3 then xoffset = -1 end
        local yoffest = 1
        if i > 2 then yoffest = -1 end

		-- Stay within limits.
		while pos > #GroupsAndSongs do pos = pos-#GroupsAndSongs end
		while pos < 1 do pos = #GroupsAndSongs+pos end

        Items[#Items+1] = Def.ActorFrame {
            Def.ActorFrame{
                OnCommand=function(self)
                    self:xy(SCREEN_CENTER_X-(160*xoffset),SCREEN_CENTER_Y-(128*yoffest))
                end,
                Def.Sprite {
                    Texture=THEME:GetPathG("PUMP/pump","mask"),
                    OnCommand=function(self)
                        self:zoomto(256/1.5,256/1.5):MaskSource()
                    end 
                },
                
                Def.Sprite {
                    Texture=THEME:GetPathG("","white"),
                    OnCommand=function(self)
                        
                        if i < 3 then

                           -- Check if its a song.
        				    if type(GroupsAndSongs[pos]) ~= "string" then

		    	    		    -- If the banner exist, Load Banner.png.
    		        			if GroupsAndSongs[pos][1]:HasBanner() then self:Load(GroupsAndSongs[pos][1]:GetBannerPath()) end
	    		    	    else

            					-- IF group banner exist, Load banner.png
	        				    if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos]) ~= "" then self:Load(SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos])) end
                            end
                        else
                            self:diffuse(1,1,0,1)
                        end

                        self:zoomto(256/1.5,256/1.5):MaskDest()
                    end
                },

                Def.BitmapText {
                    Font="_open sans 40px",
                    OnCommand=function(self)
                        
                        if i < 3  then
			    	        -- Check if we are on group.
    		    		    if type(GroupsAndSongs[pos]) == "string" then
	    				        -- Check if group has banner, If so, Set text to empty
            					if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[pos]) == "" then
	    				    	    self:settext(GroupsAndSongs[pos])
    	    			    	end					
			        	    -- not group.
		    	    	    else
	    			    	    -- Check if we have banner, if not, set text to song title.
    					        if not GroupsAndSongs[pos][1]:HasBanner() then
						            self:settext(GroupsAndSongs[pos][1]:GetDisplayMainTitle())
            					end
                            end
                            self:diffuse(1,1,0,1):strokecolor(0,0,1,1):zoom(.5)
                        else
                            self:settext("SHIFT")
                                :diffuse(1,1,1,1):strokecolor(1,0,0,1):zoom(1):zoomx(1.5)
                        end
                    end
                },

                Def.BitmapText {
                    Font="_open sans 40px",
                    OnCommand=function(self)
                    
                        if i == 4 then
                            self:settext("LEFT"):xy(-40,30)
                        elseif i == 3 then
                            self:settext("RIGHT"):xy(40,30)
                        end
                        self:diffuse(0,0,0,1):strokecolor(1,1,1,1):zoom(.5)
                    end
                },

                Def.Sprite {
                    Texture=THEME:GetPathG("PUMP/pump","outerring"),
                    OnCommand=function(self)
                        self:zoomto(256/1.5,256/1.5)
                    end 
                }
            },

            Def.ActorFrame {
                OnCommand=function(self)
                    self:CenterY():rotationz(90*i):x(SCREEN_CENTER_X-(30*xoffset))
                end,
                Def.Sprite {
                    Texture=THEME:GetPathG("PUMP/pump","arrow"),
                    OnCommand=function(self)
                        self:zoomto(96,96):xy(-70,70):diffuse(0,0,1,1):queuecommand("Loop")
                    end,
                    LoopCommand=function(self)
                        self:diffusealpha(1):xy(-70,70):linear(.5):xy(-90,90):diffusealpha(0):sleep(.5):queuecommand("Loop")
                    end
                }
            }
        }
    end
        
    return Def.ActorFrame {
        Items
    }
end