local x,y = ({...})[1],({...})[2]

--Sprite Based CDTitle from DDR-EXTREME-JP-INORI, Written by Jose Varela
return Def.ActorFrame{
    OnCommand=function(s)
        s:fov(10):draworder(101)
        :spin():effectmagnitude(0,-180,0)
        :xy(x,y)
        :vanishpoint(x,y)
    end,
    CurrentSongChangedMessageCommand=function(s)
        local c = {"BorderBack","Front","Back","BorderFront"}
        for v in ivalues(c) do
            s:GetChild(v):GetChild("Spr"):visible(false)
            if GAMESTATE:GetCurrentSong() then
                if GAMESTATE:GetCurrentSong():GetCDTitlePath() then
                    s:GetChild(v):GetChild("Spr"):visible(true):Load( GAMESTATE:GetCurrentSong():GetCDTitlePath() )
                end
            end
        end
    end,

    Def.ActorFrame{
        Name="BorderBack",
        Def.Sprite{
            Name="Spr", OnCommand=function(s) s:z(-2):glowshift()
                :effectcolor1(color("1,1,1,1")):cullmode("CullMode_Back") end,
        },
    },
    Def.ActorFrame{
        Name="Back",
        Def.Sprite{
            Name="Spr", OnCommand=function(s) s:shadowlength(1):cullmode("CullMode_Back"):glowshift():effectcolor2(color("0,0,0,0.7")):effectcolor1(color("0,0,0,0")) end,
        },
    },
    Def.ActorFrame{
        Name="Front",
        Def.Sprite{ Name="Spr", OnCommand=function(s) s:shadowlength(1):glow(Color.White):diffuse(color("0,0,0,1")):cullmode("CullMode_Front") end }
    },
    Def.ActorFrame{
        Name="BorderFront",
        Def.Sprite{ Name="Spr", OnCommand=function(s) s:z(-2):glowshift():effectoffset(0.5):effectcolor2(color("0.9,0.9,0.9,1")):effectcolor1(Color.Black)
            :cullmode("CullMode_Front"):effecttiming( 0.5,0.1,0.4,0 ) end,
        },
    }
}