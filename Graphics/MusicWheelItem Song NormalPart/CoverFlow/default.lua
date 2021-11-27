local song;
local group;

local JM = LoadModule "Jacket.lua"
return Def.ActorFrame{
	--[[Def.Sprite{
		InitCommand=function(s) s:zoomy(-1):y(372):diffusealpha(0.5):croptop(0.5):diffusetopedge(Alpha(Color.White,0)) end,
		SetMessageCommand=function(s, p)
			local song = p.Song
			if song then
				s:Load(Jacket.GetJacketPath(song))
			end
			s:setsize(372,372)
		end,
	};]]
	Def.Sprite{
		SetMessageCommand=function(s, p)
			local song = p.Song
			if song then
				s:Load(JM.GetSongGraphicPath(song,"Jacket"))
			end
			s:setsize(372,372)
		end,
	};
	Def.Sprite{
		Name="SongLength",
		Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
		InitCommand=function(s) s:animate(0):zoom(0.75):xy(-140,140) end,
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
