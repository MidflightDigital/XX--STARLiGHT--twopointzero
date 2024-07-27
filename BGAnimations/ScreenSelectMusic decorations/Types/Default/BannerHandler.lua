local SongAttributes = LoadModule "SongAttributes.lua"
local jk = LoadModule"Jacket.lua"

return Def.ActorFrame{
    CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
    ChangedLanguageDisplayMessageCommand = function(s) s:finishtweening():queuecommand("Set") end,
    SetCommand=function(s,p)
        local song = GAMESTATE:GetCurrentSong()
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        local Jacket = s:GetChild("Jacket Area"):GetChild("Jacket")
        local Banner = s:GetChild("Info"):GetChild("Banner")
        local Title = s:GetChild("Info"):GetChild("Title")
        local Artist = s:GetChild("Info"):GetChild("Artist")
        if not mw then return end
        if song then
            Jacket:Load(jk.GetSongGraphicPath(song,"Jacket"))
            Banner:Load(jk.GetSongGraphicPath(song,"Banner"))
            Title:visible(true):settext(song:GetDisplayFullTitle()):diffuse(SongAttributes.GetMenuColor(song)):y(-6):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
            Artist:visible(true):settext(song:GetDisplayArtist()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
        else
            if mw:GetSelectedType('WheelItemDataType_Section') then
                if mw:GetSelectedSection() ~= "" then
                    Jacket:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Jacket",GAMESTATE:GetSortOrder()))
                    Title:visible(true):settext(SongAttributes.GetGroupName(mw:GetSelectedSection())):y(6):diffuse(SongAttributes.GetGroupColor(mw:GetSelectedSection())):strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(mw:GetSelectedSection())))
                    Artist:settext(""):visible(false)
                    Banner:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Banner",GAMESTATE:GetSortOrder()))
                else
                    if mw:GetSelectedType() == 'WheelItemDataType_Random' then
                        Jacket:Load(THEME:GetPathG("","_jackets/Random"))
                        Title:visible(true):settext("RANDOM"):y(6):diffuse(Color.HoloDarkBlue):strokecolor(ColorDarkTone(Color.HoloDarkBlue))
                        Banner:Load(THEME:GetPathG("","_banners/Random"))
                    elseif mw:GetSelectedType() == 'WheelItemDataType_Roulette' then
                        Jacket:Load(THEME:GetPathG("","_jackets/Roulette"))
                        Title:visible(true):settext("ROULETTE"):y(6):diffuse(Color.HoloRed):strokecolor(ColorDarkTone(Color.HoloRed))
                        Banner:Load(THEME:GetPathG("","_banners/Roulette"))
                    elseif mw:GetSelectedType('WheelItemDataType_Custom') then
                        Jacket:Load(THEME:GetPathG("","_jackets/COURSE"))
                        Title:visible(true):settext("COURSE MODE"):y(6):diffuse(Color.HoloDarkPurple):strokecolor(ColorDarkTone(Color.HoloDarkPurple))
                        Banner:Load(THEME:GetPathG("","_banners/Course"))
                    end
                end
            end
        end
        Jacket:scaletofit(-189,-189,189,189)
        Banner:scaletofit(-205,-75,205,70)
    end,
    Def.ActorFrame{
        Name="Jacket Area",
        InitCommand=function(s) s:y(-40) end,
        Def.Sprite{
            Name="Backer",
            Texture=THEME:GetPathG("","_shared/_jacket back"),
        },
        Def.Sprite{
            Name="Jacket",
        };
    },
    Def.ActorFrame{
        Name="Info",
        InitCommand=function(s) s:y(208) end,
        Def.Sprite{
            Texture=THEME:GetPathG("","_shared/titlebox"),
        };
        Def.Sprite{
            Texture=THEME:GetPathG("","_shared/mask_titlebox"),
            InitCommand=function(s) s:MaskSource() end,
        },
        Def.Sprite{
            Name="Banner",
            InitCommand=function(s) s:MaskDest():ztestmode('ZTestMode_WriteOnFail'):blend(Blend.Add):diffusealpha(0.25):y(20) end,
        },
        Def.BitmapText{
            Name="Title",
            Font="_avenirnext lt pro bold/20px",
            InitCommand=function(s) s:maxwidth(400) end,
          };
          Def.BitmapText{
            Name="Artist",
            Font="_avenirnext lt pro bold/20px",
            InitCommand=function(s) s:y(20):maxwidth(400) end,
          };
    },
}