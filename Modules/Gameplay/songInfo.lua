return Def.ActorFrame{
	InitCommand=function(self)
		local c = self:GetChildren()
		c.Subtitle:zoom(.525)
		c.Artist:y(16):zoom(.8)
	end,
	CurrentSongChangedMessageCommand=function(self) self:playcommand("UpdateSongInfo") end,
	UpdateSongInfoCommand=function(self)
		if not GAMESTATE:GetCurrentSong() then return end
		local c = self:GetChildren()
		local song = GAMESTATE:GetCurrentSong()
		local hassubtitle = song:GetDisplaySubTitle() ~= ""
		
		c.Artist:settext( song:GetDisplayArtist(), song:GetTranslitArtist() ):y( hassubtitle and 16 or 10 )
		c.Subtitle:settext( song:GetDisplaySubTitle(), song:GetTranslitSubTitle() ):visible(hassubtitle)
		c.Title:settext( song:GetDisplayMainTitle(), song:GetTranslitMainTitle() ):y( hassubtitle and -18 or -10 )
	end,
	Def.BitmapText{ Text="Title", Name="Title", Font="_Kurinto Semibold" },
	Def.BitmapText{ Text="Subtitle", Name="Subtitle", Font="_Kurinto Semibold" },
	Def.BitmapText{ Text="Artist", Name="Artist", Font="_Kurinto Semibold" }
}