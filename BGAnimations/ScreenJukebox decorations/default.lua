local t = Def.ActorFrame{};

local jk = LoadModule "Jacket.lua"

t[#t+1] = Def.Quad{
    InitCommand=function(s)
        s:FullScreen():diffuse(color("0,0,0,0.5"))
    end,
    OnCommand=function(s)
        s:diffusealpha(1):sleep(0.2):linear(0.2):diffusealpha(0.5)
    end,
    OffCommand=function(s)
        s:diffusealpha(0.5):sleep(0.2):linear(0.2):diffusealpha(1)
    end,
};

--SongInfo
t[#t+1] = Def.ActorFrame{
    InitCommand=function(s)
        s:Center()
    end,
    CurrentSongChangedMessageCommand=function(s)
        s:queuecommand("Set")
    end,
    OnCommand=function(s)
        s:diffusealpha(0):sleep(0.2):linear(0.2):diffusealpha(1)
    end,
    OffCommand=function(s)
        s:diffusealpha(1):sleep(0.2):linear(0.2):diffusealpha(0)
    end,
    Def.Banner{
        SetCommand=function(s)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                s:Load(jk.GetSongGraphicPath(song))
            end
            s:scaletofit(-256,-256,256,256):x(-SCREEN_WIDTH/2.4):halign(0)

        end
    },
    Def.BitmapText{
        Name="Title",
        Font="_avenirnext lt pro bold/46px";
        SetCommand=function(s)
            s:halign(1):xy(SCREEN_WIDTH/2.4,-50)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                s:settext("Title: "..song:GetDisplayFullTitle())
            end
        end
    },
    Def.BitmapText{
        Name="Artist",
        Font="_avenirnext lt pro bold/46px";
        SetCommand=function(s)
            s:halign(1):xy(SCREEN_WIDTH/2.4,50)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                s:settext("Artist: "..song:GetDisplayArtist())
            end
        end
    },
}

--Progress Bar
t[#t+1] = Def.ActorFrame{
    InitCommand=function(s)
        s:xy(_screen.cx,SCREEN_BOTTOM-50)
    end,
    OnCommand=function(s)
        s:diffusealpha(0):sleep(0.2):linear(0.2):diffusealpha(1)
    end,
    OffCommand=function(s)
        s:diffusealpha(1):sleep(0.2):linear(0.2):diffusealpha(0)
    end,
    Def.Quad{
        InitCommand=function(s)
            s:setsize(SCREEN_WIDTH/1.2,4):diffusealpha(0.5)
        end,
    },
    Def.SongMeterDisplay{
        InitCommand=function(s) s:SetStreamWidth(SCREEN_WIDTH/1.2) end,
        Stream=Def.Quad{
            InitCommand=function(s)
                s:setsize(SCREEN_WIDTH/1.2,6)
            end,
        },
        Tip=Def.Quad{
            InitCommand=function(s)
                s:setsize(4,12)
            end
        },
    };
    Def.BitmapText{
        Name="Length",
        Font="_avenirnext lt pro bold/25px";
        CurrentSongChangedMessageCommand=function(s)
            s:queuecommand("Set")
        end,
        SetCommand=function(s)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                local secs = song:MusicLengthSeconds()
                s:settext(SecondsToMMSS(secs)):diffusealpha(0.5)
                s:halign(1):xy(SCREEN_WIDTH/2.4,16):zoom(0.75)
            end
        end
    }
}

return t;