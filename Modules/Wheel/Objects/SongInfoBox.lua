local SongAttributes = LoadModule "SongAttributes.lua"
local jk = LoadModule"Jacket.lua"

return function( args )

	return Def.ActorFrame{
		Name="SongInfoBox",
		InitCommand=function(self)
			self:xy( SCREEN_CENTER_X, SCREEN_CENTER_Y-150 )

			-- Add a wrapper state to this actorframe as I can't seem to control it's tweens anymore.
			self:AddWrapperState()
		end,
		CancelCommand=function(self)
			self:GetWrapperState(1):sleep(0.2):easeoutexpo(0.25):diffusealpha(0)
		end,
		PlayerJoinedMessageCommand=function(self,params)
			cachedImagePath[params.Player] = playerdata(params.Player)
		end,
		UpdateSongInfoCommand=function(self,params)
			local c = self:GetChildren()
			local JBox = self:GetChild("JacketArea"):GetChildren()
			JBox.Image:playcommand("Load",params)
			JBox.FallbackJacket:playcommand("Load",params)
			JBox.BannerView:GetChildAt(1):playcommand("Load",params)
			local SInfo = self:GetChild("SongInfo"):GetChildren()
			if params and type(params.Data) ~= "string" then
				local pSong = params.Data[1]
				SInfo.Title:settext( pSong:GetDisplayMainTitle() )
				SInfo.Artist:settext( pSong:GetDisplayArtist() )
				SInfo.SubTitle:settext( pSong:GetDisplaySubTitle() )
				
				local subsAvailable = pSong:GetDisplaySubTitle() ~= ""
				SInfo.SubTitle:stoptweening():easeoutexpo(0.2):diffusealpha( subsAvailable and 1 or 0 )
				SInfo.Title:stoptweening():easeoutexpo(0.2):zoom( subsAvailable and 0.7 or 0.8 )
				SInfo.Artist:stoptweening():easeoutexpo(0.2):y( pSong:GetDisplaySubTitle() ~= "" and 25 or 20 )

			else
				-- It's a group, show different info.
				local groupName = params.Data
				
				for i,player in ipairs( PlayerNumber ) do
					local prof = PROFILEMAN:GetProfile(player)
					if groupName == "--P"..i.."FAV--" then
						groupName = string.format(THEME:GetString("LuaSelectMusic","PlayerFavorite"), prof:GetDisplayName())
						-- Apply the player's profile picture as the jacket background.
						c.Image:visible(true):Load( cachedImagePath[player]["Image"] )
						:zoom(TF_WHEEL.Resize(c.Image:GetWidth(),c.Image:GetHeight(),90,90))
					end
				end

				SInfo.Title:settext( groupName )
				SInfo.Artist:settext( "" )
				SInfo.SubTitle:settext("")
				
			end
		end,

		Def.ActorFrame{
			Name="JacketArea",
			OnCommand=function(s) s:y(-40) end,
			Def.Sprite{
				Texture=THEME:GetPathG("","_shared/_jacket back"),
				Name="BGItem",
			},
			Def.ActorFrameTexture{
				Name="BannerView",
				InitCommand=function(self)
					-- local af = self:GetParent():GetParent():GetParent()
					self:SetWidth(220):SetHeight(134):EnableAlphaBuffer(false)
					:Create()
				end,
	
				Def.Sprite{
					InitCommand=function(self)
						self:align(1,0)
						:x( 220 )
					end,
					LoadCommand=function(self,param)
						-- Check if its a song.
						local imageFound = false
						if type(param.Data) ~= "string" then
							-- It is, Load banner
							if param.Data[1]:GetBannerPath() then
								self:LoadFromCached("banner",param.Data[1]:GetBannerPath())
								imageFound = true
							end
						else
							-- It's a group, Check if it has a banner.
							local bannerPath = SONGMAN:GetSongGroupBannerPath(param.Data)
							if bannerPath ~= "" then
								-- It does, Load it.
								self:LoadFromCached("banner",bannerPath)
								imageFound = true
							end
						end
						
						
						self:visible(imageFound):zoom(TF_WHEEL.Resize(self:GetWidth(),self:GetHeight(),250,100))
					end
				},
			},
			Def.Sprite{
				OnCommand=function(self)
					self:SetTexture( self:GetParent():GetChild("BannerView"):GetTexture() )
	
					local af = self:GetParent()
					self:xy(af:GetWidth() * .5 + 20, -af:GetHeight()*.5 ):valign(0):halign(1)
					:diffusealpha(0.3):fadeleft(0.3):cropbottom(0.45)
				end
			},
			Def.Quad{
				Name="JacketBG",
				OnCommand=function(self)
					local af = self:GetParent()
					self:diffuse(color("#002339"))
					:zoomto( 90, 90 )
					:x( -af:GetWidth() * .5 + 55 )
				end
			},
	
			-- Failsafe texture in case the group doesn't have a banner.
			Def.Sprite{
				Name="FallbackJacket",
				Texture=THEME:GetPathG("MusicWheelItem","fallback"),
				OnCommand=function(self)
					local af = self:GetParent()
					self:zoomto(378,378)
				end,
				LoadCommand=function(self,params)
					local isGroup = type(params.Data) ~= "table"
					local function HasAnImage(song)
						if song:GetBannerPath() then
							return song:GetBannerPath() ~= ""
						end
						if song:GetJacketPath() then
							return song:GetJacketPath() ~= ""
						end
						return false
					end
					if isGroup then
						local hasBanner = SONGMAN:GetSongGroupBannerPath(params.Data) ~= ""
						self:visible( not hasBanner )
					else
						self:visible( not HasAnImage(params.Data[1]) )
					end
				end
			},
	
			Def.Sprite{
				Name="Image",
				LoadCommand=function(self,param)
					-- Check if its a song.
					-- TODO: Reduce the ammount of instructions in this. Maybe even unifify it because it is multiple versions of the
					-- same thing.
					if type(param.Data) ~= "string" then
						-- It is, Load banner
						local found = false
	
						if param.Data[1]:GetJacketPath() then
							self:LoadFromCached("jacket",param.Data[1]:GetJacketPath())
							found = true
						else
							if param.Data[1]:GetBannerPath() then
								self:LoadFromCached("banner",param.Data[1]:GetBannerPath())
								found = true
							end
						end
						self:visible(found)
					else
						-- Just to be curious, check if the group has a dedicated jacket image.
						if jk.GetGroupGraphicPath(param.Data,"Jacket","SortOrder_Group") ~= "" then
							self:Load(jk.GetGroupGraphicPath(param.Data,"Jacket","SortOrder_Group"))
							self:visible(true)
						end
					end
					
					self:scaletofit(-189,-189,189,189)
				end
			},
		},

		-- Song Text information
		Def.ActorFrame{
			Name="SongInfo",
			OnCommand=function(s) s:y(208) end,
			Def.Sprite{
				Texture=THEME:GetPathG("","_shared/titlebox.png"),
				Name="Box",
			},
			Def.BitmapText{
				Font="_avenirnext lt pro bold/20px",
				Name="Title",
				InitCommand=function(self) self:maxwidth(400) end
			},
			Def.BitmapText{
				Font="_avenirnext lt pro bold/20px",
				Name="SubTitle",
				InitCommand=function(self) self:maxwidth(400) end
			},
			Def.BitmapText{
				Font="_avenirnext lt pro bold/20px",
				Name="Artist",
				InitCommand=function(self) self:maxwidth(400) end
			},
		},
	}
end