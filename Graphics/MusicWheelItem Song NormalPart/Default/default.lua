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
	clear;
	SetMessageCommand=function(s,p)
		s:visible(false)
		local song = p.Song
		if song and p.Type == "Song" then
			s:visible(true)
			--s:GetChild("Jacket"):LoadFromCached("Jacket",jk.GetSongGraphicPath(song))
			s:GetChild("Jacket"):Load(jk.GetSongGraphicPath(song))
			:scaletofit(-115,-115,115,115)
		end
	end,
	Def.ActorFrame{
		Def.Quad {
			InitCommand = function(s) s:zoomto(234,234):diffuse(Alpha(Color.White,0.5)) end,
		};
		Def.Quad {
			InitCommand = function(s) s:zoomto(230,230):diffuse(Alpha(Color.Black,0.75)) end,
		};
	};
	Def.Sprite {
		Name="Jacket",
	};
	diff;
	Def.Sprite{
		Name="SongLength",
		Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
		InitCommand=function(s) s:animate(0):zoom(0.5):xy(-80,80) end,
		SetCommand=function(s,p)
			local song = p.Song
			if song and p.Type == "Song" then
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
