local ex = ""
if GAMESTATE:IsAnExtraStage() then
  ex = "ex_"
end
local jk = LoadModule "Jacket.lua"

return Def.ActorFrame{
    CurrentSongChangedMessageCommand=function(s) 
        s:finishtweening()
        local Jacket = s:GetChild("Jacket")
        local Banner = s:GetChild("BannerArea")

        local song = GAMESTATE:GetCurrentSong()
        local so = GAMESTATE:GetSortOrder()
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")

        if not mw then return end

        if song then
            Jacket:GetChild("Graphic"):Load(jk.GetSongGraphicPath(song,"Jacket"))
            Banner:GetChild("Graphic"):Load(jk.GetSongGraphicPath(song,"Banner"))
        else
            if mw:GetSelectedType('WheelItemDataType_Section') then
                if mw:GetSelectedSection() ~= "" then
                    Banner:GetChild("Graphic"):Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Banner",GAMESTATE:GetSortOrder()))
                    Jacket:GetChild("Graphic"):Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Jacket",GAMESTATE:GetSortOrder()))
                else
                    if mw:GetSelectedType() == 'WheelItemDataType_Random' then
                        Banner:GetChild("Graphic"):Load(THEME:GetPathG("","_banners/random"))
                        Jacket:GetChild("Graphic"):Load(THEME:GetPathG("","_jackets/random"))
                    elseif mw:GetSelectedType() == 'WheelItemDataType_Roulette' then
                        Banner:GetChild("Graphic"):Load(THEME:GetPathG("","_banners/random"))
                        Jacket:GetChild("Graphic"):Load(THEME:GetPathG("","_jackets/random"))
                    elseif mw:GetSelectedType('WheelItemDataType_Custom') then
                        Banner:GetChild("Graphic"):Load(THEME:GetPathG("","_banners/COURSE"))
                        Jacket:GetChild("Graphic"):Load(THEME:GetPathG("","_jackets/COURSE"))
                    end
                end
            end
        end
        Jacket:GetChild("Graphic"):scaletofit(-120,-120,120,120)
        Banner:GetChild("Graphic"):scaletofit(-239,-75,239,75):xy(-24,-20)
    end,
    Def.ActorFrame{
        Name="Jacket",
        InitCommand=function(s) 
            s:visible(IsUsingWideScreen())
            :xy(_screen.cx-256,_screen.cy-254)
        end,
        OnCommand=function(s) s:addy(-800):sleep(0.4):decelerate(0.5):addy(800) end,
        OffCommand=function(s) s:sleep(0.3):decelerate(0.5):addy(-800) end,
        Def.Sprite{
            Texture=ex.."Jacket Backer",
        },
        Def.Sprite{
            Name="Graphic",
        }
    },
    Def.ActorFrame{
        Name="BannerArea",
        InitCommand=function(s) s:xy(SCREEN_LEFT+286,_screen.cy-254) end,
        OnCommand=function(s) s:addx(-800):sleep(0.3):decelerate(0.3):addx(800) end,
        OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(-800) end,
        Def.Quad{
            InitCommand=function(s) s:setsize(478,150):xy(-24,-20):diffuse(Color.Black) end,
        },
        Def.Sprite{
            Name="Graphic",
        },
        Def.Sprite{
            Texture=ex.."BannerFrame",
        },
        Def.Sprite{
            Name="Style",
            OnCommand=function(self)
              local style = GAMESTATE:GetCurrentStyle():GetStyleType()
              if style == 'StyleType_OnePlayerOneSide' then
                self:Load(THEME:GetPathB("","ScreenEvaluationSummary decorations/1Pad"))
              else
                self:Load(THEME:GetPathB("","ScreenEvaluationSummary decorations/2Pad"))
              end;
                self:xy(-210,85):zoom(0.6)
            end;
        };
        loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_CDTITLE.lua"))(180,-70)..{
            InitCommand=function(s)
              s:visible(ThemePrefs.Get("CDTITLE")):draworder(1)
            end,
        }
    }
}