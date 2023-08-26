local sec = ...

return Def.ActorFrame{
    CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
    SetCommand=function(s)
        local song = GAMESTATE:GetCurrentSong()
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        local so = GAMESTATE:GetSortOrder()
        if mw and  mw:GetSelectedType() == "WheelItemDataType_Section" then
            if so == "SortOrder_Genre" then
                s:visible(true)
            else
                s:visible(false)
            end
        else
            s:visible(false)
        end
    end,
    Def.Sprite{
        Texture="genre/GENRE_sort.png",
    };
    Def.BitmapText{
        Font="_avenirnext lt pro bold/46px",
        SetCommand=function(s,param)
            s:y(-20):maxwidth(300):zoom(1.5):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black)
            local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            local so = GAMESTATE:GetSortOrder()
            if mw and mw:GetSelectedType() == "WheelItemDataType_Section" then
                if so == "SortOrder_Genre" then
                    if sec == BNR then
                        local genre = mw:GetSelectedSection()
                        s:settext(genre)
                    else
                        s:settext("")
                    end
                else
                    s:settext("")
                end
            else
                s:settext("")
            end
        end,
    },
}
