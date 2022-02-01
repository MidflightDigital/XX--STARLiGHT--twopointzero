local jk = LoadModule"Jacket.lua"

return Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy) end,
    CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
    Def.Sprite{
        Texture="preview_shine",
        InitCommand=function(s) s:zoomx(1.463):zoomy(1.6)
            :SetAllStateDelays(0.03):animate(false):setstate(0)
        end,
        CurrentSongChangedMessageCommand=function(s) s:stoptweening():diffusealpha(1):animate(true):setstate(0) end,
        AnimationFinishedCommand=function(s) s:animate(false):setstate(0):diffusealpha(0) end,
    };
    Def.ActorFrame{
        Name="Preview Frame",
        InitCommand=function(s) s:y(-67.5) end,
        Def.Sprite{
            Texture="preview_frame",
            InitCommand=function(s) s:zoomto(900,562.5) end,
        };
        Def.Sprite{
            CurrentSongChangedMessageCommand=function(s)
                s:stoptweening():diffusealpha(0)
                if GAMESTATE:GetCurrentSong() then
                    if GAMESTATE:GetCurrentSong():GetPreviewVidPath() == nil then
                        s:sleep(0.4):queuecommand("Load2")
                    end
                end
            end,
            Load2Command=function(s)
                local song = GAMESTATE:GetCurrentSong()
                if song then
                    if song:HasBackground() then
                        if song:HasBGChanges() then
                            local bg = song:GetSongDir()
                            local bgvideo = {}
                            local listing = FILEMAN:GetDirListing(bg, false, true)
                            if not listing then return nil end
                            for _,file in pairs(listing) do
                                if ActorUtil.GetFileType(file) == 'FileType_Movie' then
                                    table.insert(bgvideo,file)
                                end
                            end
                            if song:HasBGChanges() and #bgvideo ~= 0 then
                                s:Load(bgvideo[1])
                            else
                                s:LoadFromSongBackground(song)
                            end
                        else
                            s:LoadFromSongBackground(GAMESTATE:GetCurrentSong())
                        end
                    end
                end
                s:zoomto(864,522):linear(0.2):diffusealpha(1)
            end,
        };
        Def.ActorFrame{
            Name="SongInfo",
            InitCommand=function(s) s:y(180) end,
            Def.Quad{
                InitCommand=function(s) s:zoomto(866.25,168.75)
                    :diffuse(Alpha(Color.Black,0.7))
                end,
            };
            Def.Sprite{
                InitCommand=function(s) s:halign(0):diffusealpha(0):x(-428) end,
                SetCommand=function(s)
                    local song = GAMESTATE:GetCurrentSong()
                    if song then
                        s:Load(jk.GetSongGraphicPath(song))
                    end
                    s:zoomto(68,68):linear(0.05):decelerate(0.25):diffusealpha(1):zoomto(158,158)
                end
            };
            Def.ActorFrame{
                Name="Title",
                Def.BitmapText{
                    Font="_avenirnext lt pro bold/20px",
                    Text="TITLE:",
                    InitCommand=function(s) s:halign(0):xy(-258.75,-52):skewx(-0.2) end,
                    SetCommand=function(s) s:finishtweening():zoomy(0):zoomx(1.625):decelerate(0.33):zoom(1.5) end,
                };
                Def.BitmapText{
                    Font="_stagetext",
                    InitCommand=function(s) s:halign(0):xy(-156,-52):skewx(-0.2) end,
                    SetCommand=function(s) 
                        if not GAMESTATE:GetCurrentSong() then return end
                        s:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle()):maxwidth(300)
                        s:finishtweening():zoomy(0):zoomx(1.525):decelerate(0.33):zoom(1.4)
                    end,
                };
            };
            Def.ActorFrame{
                Name="Artist",
                Def.BitmapText{
                    Font="_avenirnext lt pro bold/20px",
                    Text="ARTIST:",
                    InitCommand=function(s) s:halign(0):xy(-258.75,-18):skewx(-0.2) end,
                    SetCommand=function(s) s:finishtweening():zoomy(0):zoomx(1.525):decelerate(0.33):zoom(1.4) end,
                };
                Def.BitmapText{
                    Font="_stagetext",
                    InitCommand=function(s) s:halign(0):xy(-134,-18):skewx(-0.2) end,
                    SetCommand=function(s) 
                        if not GAMESTATE:GetCurrentSong() then return end
                        s:settext(GAMESTATE:GetCurrentSong():GetDisplayArtist()):maxwidth(300)
                        s:finishtweening():zoomy(0):zoomx(1.525):decelerate(0.33):zoom(1.3)
                    end,
                };
            };
            Def.ActorFrame{
                Name="BPM",
                Def.BitmapText{
                    Font="_avenirnext lt pro bold/20px",
                    Text="BPM:",
                    InitCommand=function(s) s:halign(0):xy(-258.75,16):skewx(-0.2) end,
                    SetCommand=function(s) s:finishtweening():zoomy(0):zoomx(1.525):decelerate(0.33):zoom(1.4) end,
                };
                Def.BitmapText{
                    Font="_stagetext",
                    InitCommand=function(s) s:halign(0):xy(-172,16):skewx(-0.2) end,
                    SetCommand=function(s) 
                        local song = GAMESTATE:GetCurrentSong()
                        if song then
                            local bpmval
                            if song:IsDisplayBpmRandom() then
                                speedvalue = "???"
                            else
                                local rawbpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()
                                local lowbpm = math.ceil(rawbpm[1]);
                                local hibpm = math.ceil(rawbpm[2])
                                if lowbpm == hibpm then
                                    speedvalue = hibpm
                                else
                                    speedvalue = lowbpm.." - "..hibpm
                                end
                            end
                            s:settext(speedvalue)
                            s:finishtweening():zoomy(0):diffusealpha(1):zoomx(1.525):decelerate(0.33):zoom(1.3)
                        else
                            s:finishtweening():linear(0.25):diffusealpha(0)
                        end
                    end,
                };
            };
            Def.BitmapText{
                Name="Song Counter",
                Font="_stagetext",
                InitCommand=function(s) s:halign(1):xy(428,64):zoom(1.8):skewx(-0.2) end,
                SetCommand=function(s,p)
                    local song = GAMESTATE:GetCurrentSong()
                    if song then
                        local num = SCREENMAN:GetTopScreen():GetChild('MusicWheel'):GetCurrentIndex();
                        local total = SCREENMAN:GetTopScreen():GetChild('MusicWheel'):GetNumItems()-2;
                        s:settext( string.format("%.3i", num).."/"..string.format("%.3i", total) );
                        s:finishtweening():zoomy(0):diffusealpha(1):zoomx(1.525):decelerate(0.33):zoom(1.8)
                    else
                        s:finishtweening():linear(0.25):diffusealpha(0)
                    end
                end,

            }
        };
    };
}