local SongAttributes = LoadModule "SongAttributes.lua"

return Def.ActorFrame{
	ChangedLanguageDisplayMessageCommand=function(s) s:queuecommand("Set") end,
	SetMessageCommand=function(s,p)
		local song = p.Song
		if song then
			s:GetChild("Title"):settext(song:GetDisplayFullTitle()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
			s:GetChild("Artist"):settext(song:GetDisplayArtist()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
		end
	end,

	Def.Sprite{
		Texture="backing",
	};
	Def.BitmapText{
		Name="Title",
		Font="_avenirnext lt pro bold/25px";
		InitCommand=function(s) s:halign(0):xy(-420,-14):maxwidth(400):zoom(1.1) end,
	};
	Def.BitmapText{
		Name="Artist",
		Font="_avenirnext lt pro bold/25px";
		InitCommand=function(s) s:halign(0):xy(-420,14):maxwidth(400):zoom(0.95) end,
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/25px";
		InitCommand=function(s) s:halign(0):xy(-420,-32):uppercase(true):zoomy(0.7):zoomx(1.2):diffuse(Color.Red) end,
		SetMessageCommand=function(s,params)
			local song = params.Song
			local text;
			if song then
				if song:IsLong() then
					text = "Long Version"
				elseif song:IsMarathon() then
					text = "Marathon Version"
				else
					text = ""
				end
			else
				text = ""
			end
			s:settext(text)
		end
	},
}