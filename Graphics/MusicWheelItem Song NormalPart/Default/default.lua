centerSongObjectProxy = nil;
local top
local jk = ...

local diff = Def.ActorFrame{};
local clear = Def.ActorFrame{};
for pn in EnabledPlayers() do
	diff[#diff+1] = loadfile(THEME:GetPathG("MusicWheelItem","Song NormalPart/diff.lua"))(THEME:GetPathG("MusicWheelItem","Song NormalPart/Default/diff.png"), pn, 1)..{
		OnCommand=function(s) s:y(pn==PLAYER_1 and -100 or 100):diffusealpha(0):sleep(0.7):decelerate(0.3):diffusealpha(1) end,
	};
	clear[#clear+1] = loadfile(THEME:GetPathG("MusicWheelItem","Song NormalPart/clear.lua"))(THEME:GetPathG("MusicWheelItem","Song NormalPart/Default/glow.png"), pn)..{
		OnCommand=function(s) s:diffusealpha(0):sleep(0.7):diffusealpha(1) end,
	};
end;

return Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
	end;
	SetMessageCommand=function(s,p)
		local index = p.Index
		if index then
			s:name(tostring(p.Index))
		end
	end,
	clear;
	quadButton(1)..{
		InitCommand=function(s) s:setsize(234,234):visible(false) end,
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
			SOUND:PlayOnce(THEME:GetPathS("",""..ThemePrefs.Get("WheelType").."_MusicWheel change"))
		end
	};
	Def.Quad {
		InitCommand = function(s) s:zoomto(234,234):diffuse(Alpha(Color.White,0.5)) end,
	};
	Def.Quad {
		InitCommand = function(s) s:zoomto(230,230):diffuse(Alpha(Color.Black,0.75)) end,
	};
	Def.Sprite {
		-- Load the banner
		-- XXX Same code can be reused for courses, etc.  Folders too?
		SetMessageCommand = function(self, params)
			local song = params.Song
			if song then
				if params.HasFocus then
					centerSongObjectProxy = self;
				end
				self:Load(jk.GetSongGraphicPath(song))
			end
			self:scaletofit(-115,-115,115,115)
		end,
	};
	diff;
	Def.Sprite{
		Name="SongLength",
		Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
		InitCommand=function(s) s:animate(0):zoom(0.5):xy(-80,80) end,
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
};
