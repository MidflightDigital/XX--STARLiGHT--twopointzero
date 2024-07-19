local IsMenuOpen = { PlayerNumber_P1 = false, PlayerNumber_P2 = false}
local CurrentClosingPlayer -- Global hack for race condition when exiting with the Select button...
local MenuButtonsOnly = PREFSMAN:GetPreference("OnlyDedicatedMenuButtons")

local HideExp = {
    "NoteSkins",
    "Characters",
    "Mini",
    "MusicRate",
}

local t= Def.ActorFrame{
    Def.Sound{
        File=THEME:GetPathS("","Codebox/o-change"),
        OptionsListRightMessageCommand=function(s) s:play() end,
        OptionsListLeftMessageCommand=function(s) s:play() end,
        OptionsListPushMessageCommand=function(s) s:play() end,
        OptionsListPopMessageCommand=function(s) s:play() end,
        OptionsListResetMessageCommand=function(s) s:play() end,
        OptionsListStartMessageCommand=function(s) s:play() end,
    };
    Def.Sound{
        File=THEME:GetPathS("","Codebox/o-open"),
        OptionsListOpenedMessageCommand=function(s) s:play() end,
    };
    Def.Sound{
        File=THEME:GetPathS("","Codebox/o-close"),
        OptionsListClosedMessageCommand=function(s) s:play()
            ProfilePrefs.SaveAll()
        end,
    };
}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    local OptionsListActor, OptionsListMenu
    local numRows

    t[#t+1] = Def.ActorFrame{
        InitCommand=function(s)
            s:x(
                pn==PLAYER_1 and (IsUsingWideScreen() and _screen.cx-566 or _screen.cx-360) or
                (IsUsingWideScreen() and _screen.cx+566 or _screen.cx+360)
            )
            :y(SCREEN_BOTTOM+700):zoom(0.8)
        end,
        OnCommand=function(self)
            OptionsListActor = self:GetChild("OptionsList" .. pname(pn))
        end,
        OptionsListOpenedMessageCommand=function(s,p)
            if p.Player == pn then
                IsMenuOpen[pn] = true
                s:decelerate(0.2):y(_screen.cy)
            end
        end,
        OptionsListClosedMessageCommand=function(self, params)
            if params.Player == pn then
                CurrentClosingPlayer = pn
                self:stoptweening():accelerate(0.2):y(SCREEN_BOTTOM+700)
                self:queuecommand("ClosedMenu")
            end
        end,
        ClosedMenuCommand=function(self)
            IsMenuOpen[CurrentClosingPlayer] = false
        end,

        -- Make us able to view what menu we're in later (and also adjust its position)
        OptionsMenuChangedMessageCommand=function(self, params)
            if params.Player == pn then
                OptionsListMenu = params.Menu
                numRows = tonumber(THEME:GetMetric("ScreenOptionsMaster",OptionsListMenu))
                self:playcommand("Adjust", params)
            end
        end,

        OptionsListLeftMessageCommand=function(self, params) self:playcommand("Adjust", params) end,
        OptionsListRightMessageCommand=function(self, params) self:playcommand("Adjust", params) end,
        OptionsListStartMessageCommand=function(self, params) self:playcommand("Adjust", params) end,
        OptionsListQuickChangeMessageCommand=function(self, params) self:playcommand("Adjust", params) end,

        -- To avoid overflowing the list, we will hide the outer parts and
        -- dynamically move the entire list's vertical position relative
        -- to what the player is currently selecting
        AdjustCommand=function(self, params)
            if params.Player == pn then
                local base_y = -210

                -- Edge case since we don't need to scroll in Speed Mods
                if params.Selection + 1 > 5 and OptionsListMenu == "NoteSkins" then
                    OptionsListActor:stoptweening():linear(0.1):y(base_y - (26 * (params.Selection - 5)))
                elseif params.Selection + 1 > 9 then
                    OptionsListActor:stoptweening():linear(0.1):y(base_y - (26 * (params.Selection - 9)))
                else
                    OptionsListActor:stoptweening():linear(0.1):y(base_y)
                end
                local sel = params.Selection
                if OptionsListMenu == "SongMenu" or OptionsListMenu == "AdvMenu" then
                    if sel+1 <= numRows then
                        local itemName = string.gsub(THEME:GetMetric("ScreenOptionsMaster",OptionsListMenu..","..params.Selection+1):split(";")[1],"name,","")
                        self:GetChild("Explanation"):GetChild("ExpText"):settext(THEME:GetString("OptionExplanations",itemName))
                    else
                        self:GetChild("Explanation"):GetChild("ExpText"):settext("Exit.")
                    end
                else
                    if OptionsListMenu ~= "Exit" then
                        if OptionsListMenu == "Gauge" then
                            if IsExtraStage1() then
                                sel = (sel == 1) and 2 or 1
                            elseif IsExtraStage2() then
                                sel = 2
                            end
                        end

                        if THEME:GetMetric("ScreenOptionsMaster",OptionsListMenu.."Explanation") then
                            self:GetChild("Explanation"):GetChild("ExpText"):settext(THEME:GetString("OptionListItemExplanations",OptionsListMenu..tostring(params.Selection)))
                        else
                            self:GetChild("Explanation"):GetChild("ExpText"):settext("")
                        end
                    end
                    if OptionsListMenu == "Mini" or OptionsListMenu == "Characters" or OptionsListMenu == "NoteSkins" or OptionsListMenu == "MusicRate" then
                        self:GetChild("Explanation"):GetChild("ExpText"):settext(THEME:GetString("OptionExplanations",OptionsListMenu))
                    end
                end
            end
        end,

        Def.ActorFrame{
            Name="PlayerFrame",
            Def.Sprite{ Texture="Backer",};
            Def.Sprite{
                Texture="Backer",
                InitCommand=function(s) s:MaskSource() end,
            };
            Def.ActorFrame{
                InitCommand=function(s) s:y(-364) end,
                Def.Sprite{
                    Texture="top",
                };
                Def.Sprite{
                    Texture="color",
                    InitCommand=function(s) s:y(12):diffuse(PlayerColor(pn)) end,
                };
            }
        };

        Def.ActorFrame{
            Name="Explanation",
            InitCommand=function(s) s:y(396) end,
            OnCommand=function(s) s:diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):linear(0.05):diffusealpha(1) end,
		    OffCommand=function(s) s:diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05) end,
		    Def.Sprite{ Texture="exp.png", };
            Def.BitmapText{
                Name="ExpText",
                Font="_avenirnext lt pro bold/25px",
                InitCommand=function(s) s:wrapwidthpixels(420) end,
            },
        },

        Def.OptionsList {
            Name="OptionsList" .. pname(pn),
            Player=pn,
            CodeMessageCommand=function(self, params)
                if ((params.Name == "OpenOpList" and not MenuButtonsOnly) or
                    params.Name == "OpenOpListButton") and params.PlayerNumber == pn and not IsMenuOpen[pn] then
                    self:Open()
                    :zoom(1.2)
                    MESSAGEMAN:Broadcast("OptionsListPlaySound")
                end
            end
        }

    }
end

return t
