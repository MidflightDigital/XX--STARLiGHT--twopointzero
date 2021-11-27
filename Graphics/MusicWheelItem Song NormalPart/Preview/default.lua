local jk = ...

local SongAttributes = LoadModule "SongAttributes.lua"
local TB = Def.BitmapText{
	Font="_avenirnext lt pro bold 36px";
    InitCommand=function(s) s:strokecolor(color("0,0,0,0.3"))
    end,
};

return Def.ActorFrame{
    Def.ActorFrame{
        Def.Sprite{
            SetCommand=function(s,p)
                if p.Song then
                    s:Load(jk.GetSongGraphicPath(p.Song,"Jacket"))
                    :setsize(459,459)
                end
            end
        };
    };
    Def.ActorFrame{
		ChangedLanguageDisplayMessageCommand=function(s) s:queuecommand("Set") end,
		Name="TextBanner",
		TB..{
            Name="Song/Course",
			SetMessageCommand=function(self, param)
				local Song = param.Song;
				local Course = param.Course;
				if Song then
					self:y(270):maxwidth(459*.8)
					self:settext(Song:GetDisplayFullTitle());
					self:diffuse(SongAttributes.GetMenuColor(Song))
				elseif Course then
					self:settext(Course:GetDisplayFullTitle());
				end
			end;
		};
	};
};