local t = Def.ActorFrame{} 
local jk = ...

local SongAttributes = LoadModule "SongAttributes.lua"
local TB = Def.BitmapText{
	Font="_avenirnext lt pro bold/25px";
    InitCommand=function(s) s:halign(0):maxwidth(400):strokecolor(color("0,0,0,0.3"))
    end,
};


local ex = ""
if GAMESTATE:IsAnExtraStage() then
  ex = "ex_"
end

t[#t+1] = Def.ActorFrame{
    Def.Quad{
        InitCommand=function(s) s:setsize(473,100):skewx(-0.5):MaskSource() end,
    };
    Def.Quad{
        InitCommand=function(s) s:setsize(473,100):skewx(-0.5):diffuse(Alpha(Color.Black,0.75)) end,
    };
    Def.Sprite{
        InitCommand=function(s) s:MaskDest():ztestmode('ZTestMode_WriteOnFail') end,
        SetCommand=function(s,p)
            if p.Song then
                s:Load(jk.GetSongGraphicPath(p.Song,"Banner"))
                s:setsize(473,148):croptop(0.22):cropbottom(0.22):zoom(1.2)
                :diffusetopedge(color("1,1,1,0.5")):diffuserightedge(color("1,1,1,0"))
            end
        end
    };
    Def.ActorFrame{
        InitCommand=function(s) s:y(30) end,
		ChangedLanguageDisplayMessageCommand=function(s) s:queuecommand("Set") end,
		Name="TextBanner",
		TB..{
			InitCommand=function(s) s:x(-240) end,
			SetMessageCommand=function(self, param)
				local Song = param.Song;
				local Course = param.Course;
				if Song then
					self:y(-8)
					self:settext(Song:GetDisplayFullTitle());
					self:diffuse(SongAttributes.GetMenuColor(Song))
				elseif Course then
					self:settext(Course:GetDisplayFullTitle());
				end
			end;
		};
		TB..{
			InitCommand=function(s) s:xy(-250,8) end,
			SetMessageCommand=function(self, param)
				local Song = param.Song;
				local Course = param.Course;
				if Song then
					self:visible(true):zoom(0.6)
					self:settext(Song:GetDisplayArtist());
					self:diffuse(SongAttributes.GetMenuColor(Song))
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
            Font="_avenirnext lt pro bold/20px",
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
    Def.ActorFrame{

    }
}

for pn in EnabledPlayers() do
    t[#t+1] = Def.ActorFrame{
        OnCommand=function(s) s:x(pn==PLAYER_1 and -257 or 257) end,
        LoadActor("../diff.lua", "Solo/diff.png", pn, 0.6);
        Def.Sprite{
            Texture=ex.."Diff Outline.png";
            InitCommand=function(s) s:zoomx(pn==PLAYER_1 and 1 or -1) end,
        }
    };
end;

return t;