local SongAttributes = LoadModule "SongAttributes.lua"
local t = Def.ActorFrame {
	LoadActor("backing");
};

t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:x(20) end,
	--Title/Subtitle
	Def.BitmapText{
		Font="_avenirnext lt pro bold 25px";
		InitCommand=function(s) s:halign(0):x(-420):maxwidth(400) end,
		SetMessageCommand=function(self, param)
			local Song = param.Song;
			local Course = param.Course;
			if Song then
				self:y(-12):zoom(1.2)
				:settext(Song:GetDisplayFullTitle())
				:diffuse(SongAttributes.GetMenuColor(Song))
			elseif Course then
				self:settext(Course:GetDisplayFullTitle());
			end
		end;
	};
	--Artist
	Def.BitmapText{
		Font="_avenirnext lt pro bold 25px";
		InitCommand=function(s) s:halign(0):xy(-400,12):maxwidth(300/0.6):zoom(1.2) end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
		CurrentCourseChangedMessageCommand=function(s) s:queuecommand("Set") end,
		ChangedLanguageDisplayMessageCommand=function(s) s:queuecommand("Set") end,
		SetMessageCommand=function(self, param)
			local Song = param.Song;
			local Course = param.Course;
			if Song then
				self:visible(true)
				:settext(Song:GetDisplayArtist())
				:diffuse(SongAttributes.GetMenuColor(Song))
			end
		end;
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold 25px";
		InitCommand=function(s) s:halign(0):xy(-420,-30):uppercase(true):zoomy(0.7):zoomx(1.2):diffuse(Color.Red) end,
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
};

return t;
