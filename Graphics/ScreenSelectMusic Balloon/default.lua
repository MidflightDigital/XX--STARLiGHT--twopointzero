return Def.ActorFrame{
	InitCommand=function(self) c = self:GetChildren(); end;
	Def.Sprite{
		Texture="_long",
		Name="Long";
		InitCommand=function(s) s:visible(false) end,
		OnCommand=function(self)
			local song = GAMESTATE:GetCurrentSong()
			if song and song:IsLong() then
				self:visible(true);
			end;
		end;
	};
	Def.Sprite{
		Texture="_marathon",
		Name="Marathon";
		InitCommand=function(s) s:visible(false) end,
		OnCommand=function(self)
			local song = GAMESTATE:GetCurrentSong()
			if song and song:IsMarathon() then
				self:visible(true);
			end;
		end;
	};
	CurrentSongChangedMessageCommand=function(self)
		local song = GAMESTATE:GetCurrentSong();
		self:stoptweening();
		if song then
			if song:IsLong() then
				c.Long:visible(true);
				c.Marathon:visible(false);
				self:playcommand("Show");
			elseif song:IsMarathon() then
				c.Long:visible(false);
				c.Marathon:visible(true);
				self:playcommand("Show");
			else
				self:playcommand("Hide");
			end;
		else
			self:playcommand("Hide");
		end;
	end;
};