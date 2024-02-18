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
    Def.Sprite{
        Texture="bg.png"
    },
    Def.Sprite{
        SetCommand=function(s,p)
            if p.Song then
                s:Load(jk.GetSongGraphicPath(p.Song,"Banner"))
                s:setsize(473,148)
            end
        end
    };
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