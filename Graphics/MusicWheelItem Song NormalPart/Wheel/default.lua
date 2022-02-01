local SongAttributes = LoadModule "SongAttributes.lua"

local TB = Def.BitmapText{
	Font="_avenirnext lt pro bold/25px";
	InitCommand=function(s) s:halign(0):maxwidth(400):strokecolor(color("0,0,0,0.5")) end,
};

return Def.ActorFrame{
	Def.Sprite{
		Texture="backing",
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/25px";
		InitCommand=function(s) s:halign(0):x(-400):maxwidth(400):strokecolor(color("0,0,0,0.5")) end,
		ChangedLanguageDisplayMessageCommand=function(s) s:queuecommand("Set") end,
		SetMessageCommand=function(self, param)
			local Song = param.Song;
			local Course = param.Course;
			if Song then
				self:zoom(1.2)
				:settext(Song:GetDisplayFullTitle().."\n "..Song:GetDisplayArtist()):vertspacing(-4)
				:diffuse(SongAttributes.GetMenuColor(Song))
			elseif Course then
				self:settext(Course:GetDisplayFullTitle());
			end
		end;
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