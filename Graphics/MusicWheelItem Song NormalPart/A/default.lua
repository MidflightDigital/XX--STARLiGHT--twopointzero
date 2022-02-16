local SongAttributes = LoadModule "SongAttributes.lua"
local top
local jk = LoadModule"Jacket.lua"

local function GetExpandedSectionIndex()
	local mWheel = SCREENMAN:GetTopScreen():GetMusicWheel()
	local curSections = mWheel:GetCurrentSections()
	
	for i=1, #curSections do
		if curSections[i] == GAMESTATE:GetExpandedSectionName() then
			return i-1
		end
	end
end

local function SetXYPosition(self, param)
	if GetExpandedSectionIndex() then
		local index = param.Index-GetExpandedSectionIndex()-1
		
		if index%3 == 0 then
			self:x(-250):y(80)
		elseif index%3 == 1 then
			self:x(0):y(0)
		else
			self:x(250):y(-80)
		end
		
		self:addy(-30)
	end
end

local clearglow = Def.ActorFrame{};
local diffblocks = Def.ActorFrame{};

for pn in EnabledPlayers() do
	clearglow[#clearglow+1] = loadfile(THEME:GetPathG("MusicWheelItem","Song NormalPart/clear.lua"))("A/glow.png",pn)..{
		OnCommand=function(s) s:diffusealpha(0):sleep(0.7):diffusealpha(1) end,
	};
	diffblocks[#diffblocks+1] = loadfile(THEME:GetPathG("MusicWheelItem","Song NormalPart/diff.lua"))("A/diff.png",pn,0.7)..{
		InitCommand=function(s) s:xy(pn==PLAYER_1 and -100 or 100,pn==PLAYER_1 and -60 or 60) end,
	}
end


return Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
	end;
	SetMessageCommand=function(self,params)
		local index = params.Index
		
		if index ~= nil then
			SetXYPosition(self, params)
			self:zoom(params.HasFocus and 1.2 or 1);
			self:name(tostring(params.Index))
		end
	end;
	quadButton(1)..{
		InitCommand=function(s)
			s:zoomto(304,172):visible(false)
		end,
		TopPressedCommand=function(self)
			local newIndex = tonumber(self:GetParent():GetName())
			local wheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			local size = wheel:GetNumItems()
			local move = newIndex-wheel:GetCurrentIndex()

		if math.abs(move)>math.floor(size/2) then
			if newIndex > wheel:GetCurrentIndex() then
				move = (move)%size-size
			else
				move = (move)%size
			end
		end

		wheel:Move(move)
		wheel:Move(0)

		-- TODO: play sounds.
		if move == 0 and wheel:GetSelectedType() == 'WheelItemDataType_Section' then
			if wheel:GetSelectedSection() == curFolder then
				wheel:SetOpenSection("")
				curFolder = ""
			else
				wheel:SetOpenSection(wheel:GetSelectedSection())
				curFolder = wheel:GetSelectedSection()
			end
		end
	end,
	};
	Def.Sprite{
		Texture="backer",
	},
	Def.Sprite{
		Texture="glow",
		InitCommand=function(s) s:diffusealpha(0.5) end,
	},
	Def.Sprite{
		SetMessageCommand=function(s,p)
			local song = p.Song
			if song then
				if HasThumbnail(song) then
					--- rescaling down 256x256 and above yields bad image quality, unreadable and slows down screen performance so we use thumbnail images instead
					--- thumbnail image uses "-tn" filename affix; preferably 104x104 (for 720p) or 156x156 (for 1080p) dimension
					s:Load(GetThumbnailPath(song))
				else
					s:Load(jk.GetSongGraphicPath(song))
				end
			end
			s:scaletofit(-69,-69,69,69):xy(2,-1)
		end
	};
	Def.ActorFrame{
		Name="Textbox",
		InitCommand=function(s) s:xy(16,104) end,
		Def.ActorFrame{
			InitCommand=function(s) s:diffusealpha(0.75) end,
			Def.Quad{
				InitCommand=function(s) s:setsize(220,30):diffuse(Color.Black) end,
			},
			Def.Quad{
				InitCommand=function(s) s:setsize(214,24):diffuse(Alpha(Color.White,0.5)):diffusetopedge(color("1,1,1,0")) end,
			},
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/20px",
			SetMessageCommand=function(s,p)
				local song = p.Song
				if song then
					s:settext(song:GetDisplayMainTitle()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
				end
				s:basezoom(0.7):maxwidth(200)
			end,
		}
	};
	Def.ActorFrame{
		Name="Additional Effects",
		SetMessageCommand=function(s,p)
			if p.Index then
				s:visible(p.HasFocus)
			end
		end,
		OffCommand=function(s) s:stopeffect():sleep(0.2):diffusealpha(0) end,
		Def.Sprite{
			Texture="HL.png",
			SetMessageCommand=function(s,p)
				local song = p.Song
				if song then
					if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
						s:diffuseramp():effectcolor1(color("1,1,1,0.2"))
						:effectcolor2(color("1,1,1,1")):effectclock('music'):effectperiod(0.5)
					else
						s:diffuseramp():effectcolor1(color("1,1,1,0.2"))
						:effectcolor2(color("1,1,1,1")):effectclock('beatnooffset')
					end
				end
			end,
		};
		Def.ActorFrame{
			Name="Cursor",
			SetMessageCommand=function(s,p)
				local song = p.Song
				if song then
					if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
						s:diffuseramp():effectcolor1(color("1,1,1,0"))
						:effectcolor2(color("1,1,1,1")):effectclock('music'):effectperiod(0.5)
					else
						s:diffuseramp():effectcolor1(color("1,1,1,0"))
						:effectcolor2(color("1,1,1,1")):effectclock('beatnooffset')
					end
				end
			end,
			Def.Sprite{
				Texture="cursor",
				InitCommand=function(s) s:thump(1):effectmagnitude(1.1,1,0):effectclock('beatnooffset') end,
				SetMessageCommand=function(s,p)
					local song = p.Song
					if song then
						if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
							s:thump(1):effectmagnitude(1.1,1,0):effectclock('music'):effectperiod(0.5)
						else
							s:thump(1):effectmagnitude(1.1,1,0):effectclock('beatnooffset')
						end
					end
				end,
			};
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/arrows/arrowb"),
			InitCommand=function(s) s:x(-140) end,
			SetMessageCommand=function(s,p)
				local song = p.Song
				if song then
					if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
						s:bounce():effectmagnitude(6,0,0):effectclock('music'):effectperiod(0.7)
					else
						s:bounce():effectmagnitude(6,0,0):effectclock('beatnooffset')
					end
				end
			end,
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/arrows/arrowb"),
			InitCommand=function(s) s:x(140):rotationy(180) end,
			SetMessageCommand=function(s,p)
				local song = p.Song
				if song then
					if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
						s:bounce():effectmagnitude(-6,0,0):effectclock('music'):effectperiod(0.7)
					else
						s:bounce():effectmagnitude(-6,0,0):effectclock('beatnooffset')
					end
				end
			end,
		};
	};
	Def.Sprite{
		Name="SongLength",
		Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
		InitCommand=function(s) s:animate(0):zoom(0.35):xy(-100,-20) end,
		SetCommand=function(s,p)
			local song = p.Song
			if song then
				if song:IsLong() then
					s:setstate(0)
					s:visible(true)
				elseif song:IsMarathon() then
					s:setstate(1)
					s:visible(true)
				else
					s:visible(false)
				end
			end
		end,
	};
	clearglow;
	diffblocks;
};
