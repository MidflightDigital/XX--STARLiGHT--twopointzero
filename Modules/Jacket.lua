if StarlightCache.Jacket then
    return StarlightCache.Jacket
end

local Jacket = {
    GetSongGraphicPath=function(song,type,fallback)
        local fbg = THEME:GetPathG("MusicWheelItem", "fallback")
        --i.e. 
        if type == "Banner" then
            if song.HasBanner and song:HasBanner() then
                return song:GetBannerPath()
            elseif song:HasBackground() then
                return song:GetBackgroundPath()
            elseif song:HasJacket() then
                return song:GetJacketPath()
            end
            fbg = THEME:GetPathG("","Common fallback banner")
        else
            if song.HasJacket and song:HasJacket() then
                return song:GetJacketPath()
            elseif song:HasBackground() then
                --disable the animated banner loading stuff for now
                --[[if (string.find(song:GetBannerPath(),".avi")) or
                (string.find(song:GetBannerPath(),".gif")) then
                    return song:GetBannerPath()
                else]]
                    return song:GetBackgroundPath()
                --end
            elseif song:HasBanner() then
                return song:GetBannerPath()
            end
        end
        return fallback or fbg
    end,
    GetGroupGraphicPath=function(text,type,so,fallback)
        if not text or text=="" then
            return nil
        end

        so = ToEnumShortString(so)

        local sog = "_jackets"
        if type == "Banner" then
            sog = "_banners"
        end

        local fbg = THEME:GetPathG("MusicWheelItem", "fallback")
        if type == "Banner" then
            fbg = THEME:GetPathG("","Common fallback banner")
        end


        if so == "Genre" then
            return THEME:GetPathG("",sog.."/genre/GENRE_sort.png")
        elseif so == "TopGrades" then
            return THEME:GetPathG("",sog.."/grade/"..group_name[text]..".png")
        elseif string.find(so,"Meter") then
            return THEME:GetPathG("",sog.."/EasyMeter/"..group_name[text]..".png")
        else
            local internalPath = THEME:GetCurrentThemeDirectory().."Graphics/"..sog.."/"..so.."/"..text..".png"
            if FILEMAN:DoesFileExist(internalPath) then
                return internalPath
            end
            if so == "Group" then
                local paths = {
                    "/Songs/"..text.."/"..type..".png",
                    "/Songs/"..text.."/"..type..".jpg",
                    "/Songs/"..text.."/"..text..".png",
                    "/Songs/"..text.."/"..text..".jpg",
                    "/AdditionalSongs/"..text.."/"..type..".png",
                    "/AdditionalSongs/"..text.."/"..type..".jpg",
                    "/AdditionalSongs/"..text.."/"..text..".png",
                    "/AdditionalSongs/"..text.."/"..text..".jpg",
                    
                }
                for path in ivalues(paths) do
                    if FILEMAN:DoesFileExist(path) then
                        return path
                    end
                end
            end
        end
        return fallback or fbg
    end,
}

StarlightCache.Jacket = Jacket
return Jacket