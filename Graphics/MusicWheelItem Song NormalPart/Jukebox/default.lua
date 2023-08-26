local jk = ...

return Def.ActorFrame{
	InitCommand=function(s) s:zoom(0.5) end,
	Def.Sprite{
		Texture="cd/cd_mask",
		InitCommand=function(s) 
			if CDImage[songtit] == nil or jk.DoesSongHaveCD(song) == false then
				s:blend(Blend.NoEffect):zwrite(1):clearzbuffer(true):zoom(1)
			end
		end
	};
	Def.Banner{
		Name="SongCD";
		SetMessageCommand=function(self,params)
			self:ztest(1)
			local song = params.Song;
			if song then
				local songtit = params.Song:GetDisplayMainTitle();
				if CDImage[songtit] ~= nil then
					local diskImage = CDImage[songtit];
					self:Load(THEME:GetPathG("","MusicWheelItem Song NormalPart/Jukebox/cd/"..diskImage));
				else
					self:Load(jk.GetSongGraphicPath(song,"CD"))
				end;
			end;
			self:setsize(475,475);
		end;
	};
	--Overlay
	Def.ActorFrame{
		Name="CdOver";
		Def.Sprite{
			Texture=THEME:GetPathG("", "MusicWheelItem Song NormalPart/Jukebox/cd/overlay"),
			SetMessageCommand=function(self,params)
				local song = params.Song;
				if song then
					local songtit = params.Song:GetDisplayMainTitle();
					if CDImage[songtit] ~= nil or jk.DoesSongHaveCD(song) == true then
						self:visible(false)
					else
						self:visible(true)
					end;
				else
					self:visible(false)
				end;
			end;
		};
	};
	Def.Sprite{
		Name="SongLength",
		Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
		InitCommand=function(s) s:animate(0):zoom(0.75):xy(160,0) end,
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
