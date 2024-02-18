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
local jk = LoadModule "Jacket.lua"
local SongAttributes = LoadModule "SongAttributes.lua"


t[#t+1] =  Def.ActorFrame{
    Def.Sprite{
        Texture=THEME:GetPathG("MusicWheelItem","Song NormalPart/Solo/bg.png"),
    },
    Def.Sprite{
        SetCommand=function(s,p)
            s:Load(jk.GetGroupGraphicPath(p.Text,"Banner",GAMESTATE:GetSortOrder()))
            :setsize(473,148)
        end
    };
}

return t;