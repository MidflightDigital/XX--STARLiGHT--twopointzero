local IsMenuOpen = { PlayerNumber_P1 = false, PlayerNumber_P2 = false}
local CurrentClosingPlayer -- Global hack for race condition when exiting with the Select button...
local MenuButtonsOnly = PREFSMAN:GetPreference("OnlyDedicatedMenuButtons")

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
        OptionsListOpenedMessageCommand=function(s)
            setenv("OPList",1)
            s:play()
        end,
    };
    Def.Sound{
        File=THEME:GetPathS("","Codebox/o-close"),
        OptionsListClosedMessageCommand=function(s) s:play()
            setenv("OPList",0)
            if getenv("DList") == 1 and not ShowTwoPart() then
                SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_MenuTimer")
            end
            ProfilePrefs.SaveAll()
        end,
    };
}

local OPTIONSLIST_NUMNOTESKINS = (ThemePrefs.Get("ExclusiveNS") == true and #GetXXSkins() ~= 0) and #GetXXSkins() or #NOTESKIN:GetNoteSkinNames()
local OPTIONSLIST_NOTESKINS = (ThemePrefs.Get("ExclusiveNS") == true and #GetXXSkins() ~= 0) and GetXXSkins() or NOTESKIN:GetNoteSkinNames()

local song_bpms= {}
local bpm_text= "??? - ???"
local function format_bpm(bpm)
	return ("%.0f"):format(bpm)
end

local fixedNS = OPTIONSLIST_NOTESKINS
table.insert(fixedNS,"EXIT")


local fixedChar = Characters.GetAllCharacterNames()
if #fixedChar > 1 then
    table.insert(fixedChar, 1, "OFF")
    if SN3Debug then SCREENMAN:SystemMessage("Found "..#fixedChar.." characters!") end
    table.insert(fixedChar, 2, "RANDOM")
else
    --if SN3Debug then SCREENMAN:SystemMessage("Found no characters! :<") end
end
table.insert(fixedChar, "EXIT")

local NumMini = fornumrange(-100,100,5)
table.insert(NumMini, "EXIT")

local NumRate = fornumrange(10,200,5)
table.insert(NumRate,"EXIT")

local _CHAR, _NSKIN, _MINI, _RATE = {},{},{},{};
for i=1,#fixedChar do
    local CurrentCharacter = fixedChar[i];
    _CHAR[i] = Def.ActorFrame{
        Def.Sprite{
            Texture="longoptionIcon",
            InitCommand=function(s) s:zoom(1.5) end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold/20px",
            Text=CurrentCharacter,
            InitCommand=function(s) s:zoom(1.5) end,
        }
    }
end
for i=1,#fixedNS do
    local CurrentSkin = fixedNS[i];
    _NSKIN[i] = LoadModule("NoteskinObjLoad.lua",{NoteSkin = CurrentSkin, Player = GAMESTATE:GetMasterPlayerNumber()})
end;
for i=1,#NumMini do
    local CurrentMini = NumMini[i];
    _MINI[i] = Def.ActorFrame{
        Def.Sprite{
            Texture="optionIcon",
            InitCommand=function(s) s:zoom(1.5) end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold/20px",
            InitCommand=function(s) s:zoom(1.5)
                if CurrentMini ~= "EXIT" then
                    s:settext(CurrentMini.."%")
                else
                    s:settext("EXIT")
                end
            end,
        };
    }
end;

for i=1,#NumRate do
    local CurrentRate = NumRate[i];
    _RATE[i] = Def.ActorFrame{
        Def.Sprite{
            Texture="optionIcon",
            InitCommand=function(s) s:zoom(1.5) end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold/20px",
            InitCommand=function(s) s:zoom(1.5)
                if CurrentRate ~= "EXIT" then
                    s:settext(CurrentRate.."%")
                else
                    s:settext("EXIT")
                end
            end,
        };
    }
end;

local function CurrentNoteSkin(p)
    local state = GAMESTATE:GetPlayerState(p)
    local mods = state:GetPlayerOptionsArray( 'ModsLevel_Preferred' )
    local skins = NOTESKIN:GetNoteSkinNames()

    for i = 1, #mods do
        for j = 1, #skins do
            if string.lower( mods[i] ) == string.lower( skins[j] ) then
               return skins[j];
            end
        end
    end
end
--I really ought to just make these unified.
local function CurrentMiniVal(p)
    local nearest_i
    local best_difference = math.huge
    for i,v2 in ipairs(stringify(fornumrange(-100,100,5), "%g%%")) do
        local mini = GAMESTATE:GetPlayerState(p):GetPlayerOptions("ModsLevel_Preferred"):Mini()
        local this_diff = math.abs(mini - v2:gsub("(%d+)%%", tonumber) / 100)
        if this_diff < best_difference then
            best_difference = this_diff
            nearest_i = i
        end
    end
    return NumMini[nearest_i]
end

local function CurrentRateVal(p)
    local nearest_i
    local best_difference = math.huge
    for i,v2 in ipairs(stringify(fornumrange(10,200,5), "%g%%")) do
        local rate = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
        local this_diff = math.abs(rate - v2:gsub("(%d+)%%", tonumber) / 100)
        if this_diff < best_difference then
            best_difference = this_diff
            nearest_i = i
        end
    end
    return NumRate[nearest_i]
end

local function GetRateIndex(Rate)
    local index={}
    for k,v in pairs(NumRate) do
        index[v] = k
    end
    return index[Rate]
end
    

local function GetCNSIndex(CNS)
    local index={}
    for k,v in pairs(OPTIONSLIST_NOTESKINS) do
        index[v] = k
    end
    return index[CNS]
end

local function GetCharIndex(Char)
    local index={}
    for k,v in pairs(fixedChar) do
        index[v] = k
    end
    return index[Char]
end

local function GetMiniIndex(Mini)
    local index={}
    for k,v in pairs(NumMini) do
        index[v] = k
    end
    return index[Mini]
end

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    local OptionsListActor, OptionsListMenu
    local numRows
    if (string.find(ProductVersion(), "LTS")) then
        if SN3Debug then
            SCREENMAN:SystemMessage("LTS or below detected! Changing OptionsList actor call!")
        end
        t[#t+1] = Def.ActorFrame{
            Def.Actor{
                Name="OptionsList" .. pname(pn),
                CodeMessageCommand=function(self, params)
                    if ((params.Name == "OpenOpList" and not MenuButtonsOnly) or
                        params.Name == "OpenOpListButton") and params.PlayerNumber == pn and not IsMenuOpen[pn] then
                        SCREENMAN:GetTopScreen():OpenOptionsList(p.PlayerNumber)
                        MESSAGEMAN:Broadcast("OptionsListPlaySound")
                    end
             end
            },
        }
    else
        if SN3Debug then
            SCREENMAN:SystemMessage("AlphaV or above detected! Changing OptionsList actor call! Version: "..string.sub(ProductVersion(),1,3))
        end
        t[#t+1] = Def.ActorFrame{
            Def.OptionsList {
                Name="OptionsList" .. pname(pn),
                Player=pn,
                InitCommand=function(s) s:ztestmode('ZTestMode_WriteOnPass'):MaskDest() end,
                CodeMessageCommand=function(self, params)
                    if ((params.Name == "OpenOpList" and not MenuButtonsOnly) or
                        params.Name == "OpenOpListButton") and params.PlayerNumber == pn and not IsMenuOpen[pn] then
                        self:Open()
                        MESSAGEMAN:Broadcast("OptionsListPlaySound")
                    end
                end
            },
        }
    end

    t[#t+1] = Def.ActorFrame{
        InitCommand=function(s)
            s:x(
                pn==PLAYER_1 and (IsUsingWideScreen() and _screen.cx-566 or _screen.cx-360) or
                (IsUsingWideScreen() and _screen.cx+566 or _screen.cx+360)
            )
            :y(SCREEN_BOTTOM+700):zoom(0.8)
        end,
        OnCommand=function(self)
            OptionsListActor = SCREENMAN:GetTopScreen():GetChild("OptionsList"..pname(pn))
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
                if params.Menu ~= "SongMenu" and params.Menu ~= "AdvMenu" and params.Menu ~= "RemMenu" then
                    if params.Menu == "NoteSkins" or params.Menu == "Characters" or params.Menu == "Mini" or params.Menu == "MusicRate" then
                        OptionsListActor:stoptweening():diffusealpha(0)
                    else
                        OptionsListActor:stoptweening():diffusealpha(1)
                    end
                else
                    --SCREENMAN:SystemMessage(params.Size);
                    OptionsListActor:stoptweening():diffusealpha(1)
                end

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
                local base_y = 350

                -- Edge case since we don't need to scroll in Speed Mods
                if params.Selection + 1 > 5 and OptionsListMenu == "NoteSkins" then
                    OptionsListActor:stoptweening():linear(0.1):y(base_y - (22 * (params.Selection - 5)))
                elseif params.Selection + 1 > 9 then
                    OptionsListActor:stoptweening():linear(0.1):y(base_y - (22 * (params.Selection - 9)))
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
                    else
                        if OptionsListMenu == "Mini" or OptionsListMenu == "Characters" or OptionsListMenu == "NoteSkins" or OptionsListMenu == "MusicRate" then
                            self:GetChild("Explanation"):GetChild("ExpText"):settext(THEME:GetString("OptionExplanations",OptionsListMenu))
                        end
                    end
                end
            end
        end,

        Def.ActorFrame{
            Name="PlayerFrame",
            Def.Sprite{ Texture="Backer",};
            Def.Sprite{
                Texture="Backer",
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

        Def.BitmapText{
            Font="_avenirnext lt pro bold/25px",
            InitCommand=function(s) s:y(-300) end,
            OptionsListOpenedMessageCommand=function(s,p)
                s:playcommand("UpdateText")
            end,
            UpdateTextMessageCommand= function(self)
                local speed, mode= GetSpeedModeAndValueFromPoptions(pn)
                -- Courses don't have GetDisplayBpms.
                if GAMESTATE:GetCurrentSong() then
                    song_bpms= GAMESTATE:GetCurrentSong():GetDisplayBpms()
                    song_bpms[1]= math.round(song_bpms[1])
                    song_bpms[2]= math.round(song_bpms[2])
                    if song_bpms[1] == song_bpms[2] then
                        bpm_text= format_bpm(song_bpms[1])
                    else
                        bpm_text= format_bpm(song_bpms[1]) .. " - " .. format_bpm(song_bpms[2])
                    end
                end
                local text= ""
                local no_change= true
                if mode == "x" then
                    if not song_bpms[1] then
                        text= "??? - ???"
                    elseif song_bpms[1] == song_bpms[2] then
                        text= "x"..(speed/100).." ("..format_bpm(song_bpms[1] * speed*.01)..")"
                    else
                        text= "x"..(speed/100).." ("..format_bpm(song_bpms[1] * speed*.01) .. " - " ..
                            format_bpm(song_bpms[2] * speed*.01)..")"
                    end
                    no_change= speed == 100
                elseif mode == "C" then
                    text= mode .. speed
                    no_change= speed == song_bpms[2] and song_bpms[1] == song_bpms[2]
                else
                    no_change= speed == song_bpms[2]
                    if song_bpms[1] == song_bpms[2] then
                        text= mode .. speed
                    else
                        local factor= song_bpms[1] / song_bpms[2]
                        text= mode .. format_bpm(speed * factor) .. " - "
                            .. mode .. speed
                    end
                end
                if GAMESTATE:IsCourseMode() then
                    if mode == "x" then
                        text = "x"..(speed/100)
                    else
                        text = mode .. speed
                    end
                    self:settext("Current Velocity: "..text)
                else
                    self:settext("Current Velocity: "..text):zoom(1)
                end
            end,
            AdjustCommand=function(self,params)
                if OptionsListMenu then
                    if OptionsListMenu == "SongMenu" or string.find(OptionsListMenu, "Speed") then
                        self:queuecommand("UpdateText");
                        self:visible(true)
                    else
                        self:visible(false)
                    end
                else
                    self:visible(false)
                end
            end;
            SpeedModChangedMessageCommand=function(self,params)
                if params.PlayerNumber == pn then
                    return self:queuecommand("Adjust")
                end;
            end;
        };

        -- Masks that will hide the off limits portion of the list, shhh
        Def.Quad {
            InitCommand=function(self) self:setsize(620, 360):xy(0, -332):valign(1):MaskSource() end,
        },

        Def.Quad {
            InitCommand=function(self) self:setsize(620, 360):xy(0, 332):valign(0):MaskSource() end,
        },
        --Characters
        Def.ActorFrame{
            InitCommand=function(s) s:y(-100):zoom(1):diffusealpha(0) end,
            OptionsMenuChangedMessageCommand=function(self,params)
                if params.Player == pn then
                    if params.Menu == "Characters" then
                        self:playcommand("On")
                        self:stoptweening():linear(.3):diffusealpha(1);
                    else
                        self:diffusealpha(0);
                    end;
                end;
            end;
            Def.Sprite{
                Name="Character Sprite",
                InitCommand=function(s) s:xy(308,100):diffusealpha(0):fadebottom(0.2)
                    :faderight(0.1):fadeleft(0.1):halign(1)
                end,
                OnCommand=function(s)
                    local charName = ResolveCharacterName(pn)
                    if charName ~= "" and Characters.GetAssetPath(charName, "comboA.png") ~= nil then
                        s:Load(Characters.GetAssetPath(charName, "comboA.png"))
                        s:scaletoclipped(220,640)
                    end
                end,
                OptionsMenuChangedMessageCommand=function(self,params)
                    local charName = ResolveCharacterName(pn)
                    if params.Player == pn then
                        if charName ~= "" then
                            self:queuecommand("On")
                            self:stoptweening():linear(.3):diffusealpha(0.7);
                        else
                            self:diffusealpha(0);
                        end;
                    end;
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "Characters" then
                        if params.Selection < #Characters.GetAllCharacterNames() and params.Selection > 1 then
                            self:diffusealpha(1)
                            local charName = Characters.GetAllCharacterNames()[params.Selection-1]
                            if charName ~= "" then
                                local charVer = (Characters.GetConfig(charName).version)
                                self:Load(Characters.GetAssetPath(charName, "comboA.png"))
                                self:diffusealpha(0.7)
                                 self:scaletoclipped(220,640)
                            else
                                self:diffusealpha(0)
                            end
                        else
                            self:diffusealpha(0)
                        end
                    end
                end,
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/36px",
                InitCommand=function(s) s:y(180):maxwidth(500):strokecolor(Color.Black) end,
                OnCommand=function(self)
                    self:settext("Select\n"..ResolveCharacterName(pn).."\nas your dancer.")
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "Characters" then
                        if Characters.GetAllCharacterNames()[params.Selection-1] ~= nil then
                            self:settext("Select\n"..Characters.GetAllCharacterNames()[params.Selection-1].. "\nas your dancer.")
                        elseif params.Selection == 0 then
                            self:settext("Dancer is disabled.")
                        elseif params.Selection == 1 and (#fixedChar > 1 and fixedChar[1] ~= "OFF") then
                            self:settext("A random dancer is selected.")
                        else
                            self:settext("")
                        end
                    end
                end,
            };
            Def.ActorScroller{
                Name="Character Scroller",
                NumItemsToDraw=3;
                SecondsPerItem=0.2;
                children = _CHAR;
                InitCommand=function(s)
                    s:SetLoop(true):SetWrap(true)
                    :SetDrawByZPosition(true):SetFastCatchup(true)
                end,
                OptionsMenuChangedMessageCommand=function(self,params)
                    if params.Player == pn then
                        if GetCharIndex(ResolveCharacterName(pn)) ~= nil then
                            self:SetCurrentAndDestinationItem(GetCharIndex(ResolveCharacterName(pn))-1)
                        else
                            self:SetCurrentAndDestinationItem(0)
                        end
                    end;
                end;
                TransformFunction=function(s,offset,itemIndex,numItems)
                    local sign = offset == 0 and 1 or offset/math.abs(offset)
                    s:x((offset*240*math.cos((math.pi/6*offset))+math.min(math.abs(offset),1)*sign*0))
                    :z((offset*-62*3*math.sin((math.pi/6)*offset))+(math.min(math.abs(offset),1)*0))
                    :rotationy(offset*(360/(6*1.135)))
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "Characters" then
                        self:SetDestinationItem(params.Selection)
                    end
                end,
            };
            Def.Sprite{
                Texture="arrow",
                InitCommand=function(s) s:x(-260):zoom(2):diffusealpha(1):bounce():effectmagnitude(3,0,0):effectperiod(1) end,
                OptionsListLeftMessageCommand=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
            };
            Def.Sprite{
                Texture="arrow",
                InitCommand=function(s) s:x(260):basezoom(2):zoomx(-1):diffusealpha(1):bounce():effectmagnitude(-3,0,0):effectperiod(1) end,
                OptionsListRightMessageCommand=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
            };
        };
        --Mini
        Def.ActorFrame{
            InitCommand=function(s) s:y(-100):zoom(1):diffusealpha(0) end,
            OptionsMenuChangedMessageCommand=function(self,params)
                if params.Player == pn then
                    if params.Menu == "Mini" then
                        self:playcommand("On")
                        self:stoptweening():linear(.3):diffusealpha(1);
                    else
                        self:diffusealpha(0);
                    end;
                end;
            end;
            Def.BitmapText{
                Font="_avenirnext lt pro bold/36px",
                InitCommand=function(s) s:y(180):maxwidth(500):strokecolor(Color.Black) end,
                OnCommand=function(self)
                    if CurrentMiniVal(pn) ~= nil then
                        self:settext("Select\n"..CurrentMiniVal(pn).."%\nas your Mini value.")
                    else
                        self:settext("Invalid mini value is set.")
                    end
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "Mini" then
                        if params.Selection < #NumMini then
                            if NumMini[params.Selection+1] == "EXIT" then
                                self:settext("Exit.")
                            else
                                self:settext("Select\n"..string.format("%01d",NumMini[params.Selection+1]).."%\nas your Mini value.")
                            end
                        else
                            self:settext("")
                        end
                    end
                end,
            };
            Def.ActorScroller{
                Name="Mini Scroller",
                NumItemsToDraw=5;
                SecondsPerItem=0.2;
                children = _MINI;
                InitCommand=function(s)
                    s:SetLoop(true):SetWrap(true)
                    :SetDrawByZPosition(true):SetFastCatchup(true)
                end,
                OptionsMenuChangedMessageCommand=function(self,params)
                    if params.Player == pn then
                        if GetMiniIndex(CurrentMiniVal(pn)) ~= nil then
                            
                            self:SetCurrentAndDestinationItem(GetMiniIndex(CurrentMiniVal(pn))-1)
                        else
                            self:SetCurrentAndDestinationItem(0)
                        end
                    end;
                end;
                TransformFunction=function(s,offset,itemIndex,numItems)
                    local sign = offset == 0 and 1 or offset/math.abs(offset)
                    s:x((offset*160*math.cos((math.pi/10*offset))+math.min(math.abs(offset),1)*sign*0))
                    :z((offset*-62*3*math.sin((math.pi/10)*offset))+(math.min(math.abs(offset),1)*0))
                    :rotationy(offset*(360/(10*1.135)))
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "Mini" then
                        self:SetDestinationItem(params.Selection)
                    end
                end,
            };
            Def.Sprite{
                Texture="arrow",
                InitCommand=function(s) s:x(-260):zoom(2):diffusealpha(1):bounce():effectmagnitude(3,0,0):effectperiod(1) end,
                OptionsListLeftMessageCommand=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
            };
            Def.Sprite{
                Texture="arrow",
                InitCommand=function(s) s:x(260):basezoom(2):zoomx(-1):diffusealpha(1):bounce():effectmagnitude(-3,0,0):effectperiod(1) end,
                OptionsListRightMessageCommand=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
            };
        };
        --NoteSkin
        Def.ActorFrame{
            InitCommand=function(s) s:y(-100):zoom(1):diffusealpha(0) end,
            OptionsMenuChangedMessageCommand=function(self,params)
                if params.Player == pn then
                    if params.Menu == "NoteSkins" then
                        self:playcommand("On")
                        self:stoptweening():linear(.3):diffusealpha(1);
                    else
                        self:diffusealpha(0);
                    end;
                end;
            end;
            Def.BitmapText{
                Condition=ThemePrefs.Get("ExclusiveNS") == true,
                Font="_avenirnext lt pro bold/36px",
                Text="Exclusive NoteSkins:",
                InitCommand=function(s) s:y(-180):maxwidth(500):DiffuseAndStroke(color("#00AAFF"),(color("#0030FF"))) end,
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/36px",
                InitCommand=function(s) s:y(180):maxwidth(500):strokecolor(Color.Black) end,
                OnCommand=function(self)
                    if CurrentNoteSkin(pn) ~= nil then
                        self:settext("Select\n"..CurrentNoteSkin(pn).."\nNote Skin")
                    else
                        self:settext("Invalid noteskin is set.")
                    end
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "NoteSkins" then
                        if params.Selection < OPTIONSLIST_NUMNOTESKINS then
                            highlightedNoteSkin = OPTIONSLIST_NOTESKINS[params.Selection+1];
                            self:settext("Select\n"..highlightedNoteSkin.. "\nNote Skin")
                        else
                            self:settext("")
                        end
                    end
                end,
            };
            Def.ActorScroller{
                Name="Noteskin Scroller",
                NumItemsToDraw=5;
                SecondsPerItem=0.2;
                children = _NSKIN;
                InitCommand=function(s)
                    s:SetLoop(true):SetWrap(true)
                    :SetDrawByZPosition(true):SetFastCatchup(true)
                end,
                OptionsMenuChangedMessageCommand=function(self,params)
                    if params.Player == pn then
                        if GetCNSIndex(CurrentNoteSkin(pn)) ~= nil then
                            self:SetCurrentAndDestinationItem(GetCNSIndex(CurrentNoteSkin(pn))-1)
                        else
                            self:SetCurrentAndDestinationItem(0)
                        end
                    end;
                end;
                TransformFunction=function(s,offset,itemIndex,numItems)
                    local sign = offset == 0 and 1 or offset/math.abs(offset)
                    s:x((offset*160*math.cos((math.pi/10*offset))+math.min(math.abs(offset),1)*sign*0))
                    :z((offset*-62*3*math.sin((math.pi/10)*offset))+(math.min(math.abs(offset),1)*0))
                    :rotationy(offset*(360/(10*1.135)))
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "NoteSkins" then
                        self:SetDestinationItem(params.Selection)
                    end
                end,
            };
            Def.Sprite{
                Texture="arrow",
                InitCommand=function(s) s:x(-260):zoom(2):diffusealpha(1):bounce():effectmagnitude(3,0,0):effectperiod(1) end,
                OptionsListLeftMessageCommand=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
            };
            Def.Sprite{
                Texture="arrow",
                InitCommand=function(s) s:x(260):basezoom(2):zoomx(-1):diffusealpha(1):bounce():effectmagnitude(-3,0,0):effectperiod(1) end,
                OptionsListRightMessageCommand=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
            };
        };
        --Mini
        Def.ActorFrame{
            InitCommand=function(s) s:y(-100):zoom(1):diffusealpha(0) end,
            OptionsMenuChangedMessageCommand=function(self,params)
                if params.Player == pn then
                    if params.Menu == "MusicRate" then
                        self:playcommand("On")
                        self:stoptweening():linear(.3):diffusealpha(1);
                    else
                        self:diffusealpha(0);
                    end;
                end;
            end;
            Def.BitmapText{
                Font="_avenirnext lt pro bold/36px",
                InitCommand=function(s) s:y(180):maxwidth(500):strokecolor(Color.Black) end,
                OnCommand=function(self)
                    if CurrentRateVal(pn) ~= nil then
                        self:settext("Select\n"..CurrentRateVal(pn).."%\nas your song speed.")
                    else
                        self:settext("Invalid song speed is set.")
                    end
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "MusicRate" then
                        if params.Selection < #NumRate then
                            if NumRate[params.Selection+1] == "EXIT" then
                                self:settext("Exit.")
                            else
                                self:settext("Select\n"..string.format("%01d",NumRate[params.Selection+1]).."%\nas song speed.")
                            end
                        else
                            self:settext("")
                        end
                    end
                end,
            };
            --MusicRate
            Def.ActorScroller{
                Name="MusicRate Scroller",
                NumItemsToDraw=5;
                SecondsPerItem=0.2;
                children = _RATE;
                InitCommand=function(s)
                    s:SetLoop(true):SetWrap(true)
                    :SetDrawByZPosition(true):SetFastCatchup(true)
                end,
                OptionsMenuChangedMessageCommand=function(self,params)
                    if params.Player == pn then
                        if GetRateIndex(CurrentRateVal(pn)) ~= nil then
                            
                            self:SetCurrentAndDestinationItem(GetRateIndex(CurrentRateVal(pn))-1)
                        else
                            self:SetCurrentAndDestinationItem(0)
                        end
                    end;
                end;
                TransformFunction=function(s,offset,itemIndex,numItems)
                    local sign = offset == 0 and 1 or offset/math.abs(offset)
                    s:x((offset*160*math.cos((math.pi/10*offset))+math.min(math.abs(offset),1)*sign*0))
                    :z((offset*-62*3*math.sin((math.pi/10)*offset))+(math.min(math.abs(offset),1)*0))
                    :rotationy(offset*(360/(10*1.135)))
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and OptionsListMenu == "MusicRate" then
                        self:SetDestinationItem(params.Selection)
                    end
                end,
            };
            Def.Sprite{
                Texture="arrow",
                InitCommand=function(s) s:x(-260):zoom(2):diffusealpha(1):bounce():effectmagnitude(3,0,0):effectperiod(1) end,
                OptionsListLeftMessageCommand=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
            };
            Def.Sprite{
                Texture="arrow",
                InitCommand=function(s) s:x(260):basezoom(2):zoomx(-1):diffusealpha(1):bounce():effectmagnitude(-3,0,0):effectperiod(1) end,
                OptionsListRightMessageCommand=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
            };
        };
    }
end

return t
