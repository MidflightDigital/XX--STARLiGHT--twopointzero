local t = Def.ActorFrame{
    SetMessageCommand=function(s,p)
        if p.DrawIndex then
            if p.DrawIndex == 8  then
                s:diffusealpha(0.7)
            elseif p.DrawIndex == 9 then
                s:diffusealpha(0.5)
            elseif p.DrawIndex == 10 then
                s:diffusealpha(0.3)
            elseif p.DrawIndex >= 11 or p.DrawIndex < 2 then
                s:diffusealpha(0)
            else
                s:diffusealpha(1)
            end
        end
    end,
} 
local jk = ...

local SongAttributes = LoadModule "SongAttributes.lua"
local TB = Def.BitmapText{
	Font="_avenirnext lt pro bold 36px";
    InitCommand=function(s) s:halign(0):maxwidth(350):strokecolor(color("0,0,0,0.3"))
    end,
};


local ex = ""
if GAMESTATE:IsAnExtraStage() then
  ex = "ex_"
end

t[#t+1] = Def.ActorFrame{
    Def.Sprite{
        Texture="bg.png";
        InitCommand=function(s) s:diffusealpha(0.7) end,
    };
    Def.ActorFrame{
        InitCommand=function(s) s:diffuseramp():effectcolor1(color("1,1,1,0.2"))
            :effectcolor2(color("1,1,1,1")):effectclock('beatnooffset')
        end,
        SetMessageCommand=function(s,p)
            if p.Index then s:visible(p.HasFocus) end
        end,
        Def.Sprite{
            Texture="HL",
            SetMessageCommand=function(s,p)
                local song = p.Song
                if song then
                    s:diffuse(SongAttributes.GetGroupColor(song:GetGroupName()))
                end
            end,
        };
    };
    Def.ActorFrame{
        InitCommand=function(s) s:x(-470) end,
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenSelectMusic","overlay/SoloDeco/JacketMask.png"),
            InitCommand=function(s) s:MaskSource(true):zoom(0.13) end,
        };
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenSelectMusic","overlay/SoloDeco/JacketMask.png"),
            InitCommand=function(s) s:zoom(0.14) end,
        };
        Def.Sprite{
            InitCommand=function(s) s:MaskDest():ztestmode('ZTestMode_WriteOnFail') end,
            SetCommand=function(s,p)
                if p.Song then
                    s:Load(jk.GetSongGraphicPath(p.Song,"Jacket"))
                    :setsize(60,60)
                end
            end
        };
    };
    Def.ActorFrame{
        InitCommand=function(s) s:x(-430) end,
		ChangedLanguageDisplayMessageCommand=function(s) s:queuecommand("Set") end,
		Name="TextBanner",
		TB..{
            Name="Song/Course",
			SetMessageCommand=function(self, param)
				local Song = param.Song;
				local Course = param.Course;
				if Song then
					self:y(-12)
					self:settext(Song:GetDisplayFullTitle());
					self:diffuse(SongAttributes.GetMenuColor(Song))
				elseif Course then
					self:settext(Course:GetDisplayFullTitle());
				end
			end;
		};
		TB..{
            Name="Artist",
			InitCommand=function(s) s:xy(20,12) end,
			SetMessageCommand=function(self, param)
				local Song = param.Song;
				local Course = param.Course;
				if Song then
					self:visible(true):zoom(0.4)
					self:settext(Song:GetDisplayArtist());
					self:diffuse(SongAttributes.GetMenuColor(Song))
                    :diffusealpha(0.7)
				end
			end;
		}
	};
    Def.ActorFrame{
        InitCommand=function(s) s:y(59) end,
        SetMessageCommand=function(s,p)
            local song = p.Song
            if song then
                if song:IsLong() or song:IsMarathon() then
                   s:visible(true)
                else
                    s:visible(false)
                end
            end
        end,
        Def.Quad{
            InitCommand=function(s)
                s:setsize(473,30):diffuse(Alpha(Color.Black,0.5))
            end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold 20px",
            SetMessageCommand=function(s,p)
                local song = p.Song
            if song then
                if song:IsLong() then
                    s:settext("Long Version")
                elseif song:IsMarathon() then
                    s:settext("Marathon Version")
                else
                    s:settext("")
                end
            end
        end,
        }
    };
};

for pn in EnabledPlayers() do
    t[#t+1] = Def.ActorFrame{
        loadfile(THEME:GetPathG("MusicWheelItem","Song NormalPart/Solo/diff.lua"))(pn)..{
            InitCommand=function(s) s:x(-50) end,
        }
    };
end;

return t;