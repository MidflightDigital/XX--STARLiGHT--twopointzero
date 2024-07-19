local song_bpms= {}
local bpm_text= "??? - ???"
local function format_bpm(bpm)
	return ("%.0f"):format(bpm)
end


local t= Def.ActorFrame{
    OnCommand=function(s) setenv("OPList",0) end,
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
        OptionsListOpenedMessageCommand=function(s) s:play()
            setenv("OPList",1)
        end,
    };
    Def.Sound{
        File=THEME:GetPathS("","Codebox/o-close"),
        OptionsListClosedMessageCommand=function(s) s:play()
            setenv("OPList",0)
            if getenv("DList") == 1 and not ShowTwoPart() then
                SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_MenuTimer")
            end
        end,
    };
}

local OPLIST_splitAt = THEME:GetMetric("OptionsList","MaxItemsBeforeSplit")
local OPLIST_ScrollAt = 16
local OPTIONSLIST_NUMNOTESKINS = #NOTESKIN:GetNoteSkinNames()
local OPTIONSLIST_NOTESKINS = NOTESKIN:GetNoteSkinNames()

if THEME:GetMetric("ScreenSelectMusic","UseOptionsList") then
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
    --OpList
    for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
        --This keeps the name of the current OptionsList because OptionsListLeft and OptionsListRight does not know what list this is otherwise
		local currentOpList
		--The amount of rows in the current optionsList menu.
		local numRows
		--This gets a handle on the optionsList Actor so it can be adjusted.
		local optionsListActor
        t[#t+1] = Def.ActorFrame{
            InitCommand=function(s) s:xy(pn==PLAYER_1 and SCREEN_LEFT-300 or SCREEN_RIGHT+300,_screen.cy) end,
            OnCommand=function(s)
                optionsListActor = SCREENMAN:GetTopScreen():GetChild("OptionsList"..pname(pn))
            end,
            CodeMessageCommand=function(s,p)
                if p.Name == "OptionList" then
                    SCREENMAN:GetTopScreen():OpenOptionsList(p.PlayerNumber)
                end
            end,
            OptionsListOpenedMessageCommand=function(s,p)
                if p.Player == pn then
                    setenv("currentplayer",pn)
                    s:decelerate(0.2):x(pn==PLAYER_1 and SCREEN_LEFT+300 or SCREEN_RIGHT-300)
                end
            end,
            OptionsListClosedMessageCommand=function(s,p)
                if p.Player == pn then
                    s:stoptweening():accelerate(0.2):x(pn==PLAYER_1 and SCREEN_LEFT-300 or SCREEN_RIGHT+300)
                end
            end,
            Def.Quad{
                InitCommand=function(s)
                    s:setsize(600,SCREEN_HEIGHT):diffuse(Alpha(Color.Black,0.7)):fadebottom(0.2):fadetop(0.1)
                end,
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/42px",
                Text="SELECT\n        OPTIONS";
                InitCommand=function(s)
                    s:xy(-180,-400):zoom(1.2):halign(0):vertspacing(-20)
                end,
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/25px",
                InitCommand=function(s) s:y(-345):wrapwidthpixels(420):valign(0):playcommand("Meme") end,
                MemeCommand=function(s) s:settext("(;•́︿•̀  ;) h….hewwo…?"):sleep(math.random(3,7)):queuecommand("One") end,
                OneCommand=function(s) s:settext("……. (　•́  ^•̀｀) hewwo….? is anybodwy hewre…?"):sleep(math.random(3,7)):queuecommand("Two") end,
                TwoCommand=function(s) s:settext("*BANG*"):sleep(0.5):queuecommand("Three") end,
                ThreeCommand=function(s) s:settext("｀Σ ( •́△•̀|||)｀ HEWWO?!? HEWWO!!?!!?????"):sleep(8):queuecommand("Meme2") end,
                Meme2Command=function(s) s:settext("hewwo! i will be youw suwgeon today! intewnal bweeding you say? let’s make ouw fiwst wittle incision "):sleep(5):queuecommand("Four") end,
                FourCommand=function(s) s:settext("Dowcto , wewre loswing him!!! (´・ω・｀)"):sleep(4):queuecommand("Five") end,
                FiveCommand=function(s) s:settext("quick! hand me the defibwiwatow!!"):sleep(8):queuecommand("Meme") end,
                OptionsListOpenedMessageCommand=function(s,p)
                    s:stoptweening()
                    if p.Player == pn then
                        currentOpList = "SongMenu"
                        s:settext(THEME:GetString("OptionExplanations",string.gsub(THEME:GetMetric("ScreenOptionsMaster",THEME:GetMetric("OptionsList","TopMenu")..",1"):split(";")[1],"name,","")))
                    end
                end;
                OffCommand=function(s) s:stoptweening() end,
                AdjustCommand=function(s,p)
                    if p.Player == pn then
                    local OpListMax = {
                        ["NoteSkins"] = OPTIONSLIST_NUMNOTESKINS,
                        ["Mini"] = getenv("NumMini"),
                        ["MusicRate"] = getenv("NumRate"),
                        ["Characters"] = #Characters.GetAllCharacterNames()
                    }
                    if currentOpList == "SongMenu" or currentOpList == "AdvMenu" then
                        if p.Selection+1 <= numRows then
                            local itemName = string.gsub(THEME:GetMetric("ScreenOptionsMaster",currentOpList..","..p.Selection+1):split(";")[1],"name,","")
                            s:settext(THEME:GetString("OptionExplanations",itemName))
                        else
                            s:settext("Exit.");
                        end;
                    else
                        if currentOpList ~= "Exit" then
                            if THEME:GetMetric("ScreenOptionsMaster",currentOpList.."Explanation") then
                                local itemName = THEME:GetMetric("ScreenOptionsMaster",currentOpList.."Explanation")
                                s:settext(THEME:GetString("OptionListItemExplanations",currentOpList..tostring(p.Selection)))
                            else s:settext("")
                            end
                        end
                    end
                    if currentOpList == "NoteSkins" or currentOpList == "Mini" or currentOpList == "MusicRate" or currentOpList == "Characters" then
                        local curRow
                        if OPLIST_splitAt < OpListMax[currentOpList] then
                            curRow = math.floor((p.Selection)/2)+1
                        else
                            curRow = p.Selection+1
                        end
                        if curRow>OPLIST_ScrollAt then
                            optionsListActor:stoptweening():linear(.2):y((SCREEN_CENTER_Y-160)+THEME:GetMetric("OptionsList","ItemsSpacingY")*(OPLIST_ScrollAt-curRow))
                        else
                            optionsListActor:stoptweening():linear(.2):y(SCREEN_CENTER_Y-160)
                        end;
                    end
                end
                end,
                OptionsListRightMessageCommand=function(self,params)
                    self:playcommand("Adjust",params);
                end;
                OptionsListLeftMessageCommand=function(self,params)
                    self:playcommand("Adjust",params);
                end;
                OptionsListStartMessageCommand=function(self,params)
                    self:playcommand("Adjust",params);
                end,
                OptionsMenuChangedMessageCommand=function(self,params)
                    --SCREENMAN:SystemMessage("MenuChanged: Menu="..params.Menu);
                    if params.Player == pn then
                        currentOpList=params.Menu
                        optionsListActor:stoptweening():y(SCREEN_CENTER_Y-160) --Reset the positioning
                        if params.Menu ~= "SongMenu" and params.Menu ~= "AdvMenu" then
                            self:settext(THEME:GetString("OptionExplanations",params.Menu))
                        else
                            --SCREENMAN:SystemMessage(params.Size);
                            numRows = tonumber(THEME:GetMetric("ScreenOptionsMaster",currentOpList))
                        end;
                    end;
                end;
            };
            Def.Sprite{
                InitCommand=function(s) s:xy(pn==PLAYER_1 and 140 or -140,160):diffusealpha(0):fadebottom(0.2)
                    :faderight(0.1):fadeleft(0.1)
                end,
                OnCommand=function(s)
                    local charName = ResolveCharacterName(pn)
                    if charName ~= "" and Characters.GetAssetPath(charName, "comboA.png") ~= nil then
                        s:Load(Characters.GetAssetPath(charName, "comboA.png"))
                        s:scaletoclipped(300,720)
                    end
                end,
                OptionsMenuChangedMessageCommand=function(self,params)
                    local charName = ResolveCharacterName(pn)
                    if params.Player == pn then
                        if params.Menu == "Characters" and charName ~= "" then
                            self:queuecommand("On")
                            self:stoptweening():linear(.3):diffusealpha(0.7);
                        else
                            self:diffusealpha(0);
                        end;
                    end;
                end,
                AdjustCommand=function(self,params)
                    if params.Player == pn and currentOpList == "Characters" then
                        if params.Selection < #Characters.GetAllCharacterNames() and params.Selection > 1 then
                            self:diffusealpha(1)
                            local charName = Characters.GetAllCharacterNames()[params.Selection-1]
                            if charName ~= "" then
                                local charVer = (Characters.GetConfig(charName).version)
                                self:Load(Characters.GetAssetPath(charName, "comboA.png"))
                                self:diffusealpha(0.7)
                                 self:scaletoclipped(300,720)
                            else
                                self:diffusealpha(0)
                            end
                        else
                            self:diffusealpha(0)
                        end
                    end
                end,
                OptionsListRightMessageCommand=function(self,params)
                    self:playcommand("Adjust",params);
                end;
                OptionsListLeftMessageCommand=function(self,params)
                    self:playcommand("Adjust",params);
                end;
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/25px",
                InitCommand=function(s) s:y(-200) end,
                OptionsListOpenedMessageCommand=function(s,p)
                    s:queuecommand("UpdateText")
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
                    if currentOpList == "SongMenu" or currentOpList == "AdvMenu" or string.find(currentOpList, "Speed") then
                        self:queuecommand("UpdateText");
                        self:visible(true)
                    else
                        self:visible(false)
                    end;
                end;
                SpeedModChangedMessageCommand=function(self,params)
                    if params.PlayerNumber == pn then
                        return self:queuecommand("Adjust")
                    end;
                end;
            };
            Def.Sprite{
                Texture="optionIcon",
                InitCommand=function(s) s:y(-260):diffusealpha(0) end,
                OptionsMenuChangedMessageCommand=function(self,params)
                    --SCREENMAN:SystemMessage("MenuChanged: Menu="..params.Menu);
                    if params.Player == pn then
                        if params.Menu == "NoteSkins" then
                            self:stoptweening():linear(.3):diffusealpha(1);
                        else
                            self:diffusealpha(0);
                        end;
                    end;
                end;
            };
            --NoteSkin
            Def.ActorFrame{
                InitCommand=function(s) s:y(-260):zoom(1):diffusealpha(0) end,
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
                OnCommand=function(self)
                    highlightedNoteSkin = CurrentNoteSkin(pn);
                    self:RemoveAllChildren()
                    self:AddChildFromPath(THEME:GetPathB("ScreenSelectMusic","overlay/_OptionsList/Noteskin.lua"))
                    
                end;
                AdjustCommand=function(self,params)
                    if params.Player == pn and currentOpList == "NoteSkins" then
                        if params.Selection < OPTIONSLIST_NUMNOTESKINS then
                            --This is a global var, it's used in Noteskin.lua.
                            highlightedNoteSkin = OPTIONSLIST_NOTESKINS[params.Selection+1];
                            self:RemoveAllChildren()
                            self:AddChildFromPath(THEME:GetPathB("ScreenSelectMusic","overlay/_OptionsList/Noteskin.lua"))
                        else
                            self:playcommand("On");
                        end;
                    end;
                end;
                OptionsListRightMessageCommand=function(self,params)
                    self:playcommand("Adjust",params);
                end;
                OptionsListLeftMessageCommand=function(self,params)
                    self:playcommand("Adjust",params);
                end;
            };
        }
    end
end

return t
