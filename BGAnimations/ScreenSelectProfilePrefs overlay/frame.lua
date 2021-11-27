local pn = ...
--Reset these envelopes.
setenv("keysetP1",0)
setenv("keysetP2",0)

local keyset = 0
local menuset = 0
local curIndex = 1

--Most of the commented out code is disabled for a reason. 
--Don't bother trying it.
-- -Inori

--[[local MainScrollerList = {
    "CONTINUE",
    "GAMEPLAY",
    "MENU",
    "FITNESS"
}]]

local MainScrollerList = {
    "CONTINUE",
}

--[[local MenuScrollerList = {
    "MenuBG",
    "BGM",
    "Wheel",
    "Back"
}]]

local MenuScrollerList = {
}



local t = Def.ActorFrame{}

local function MainScrollerItems(Player, idx)
    return Def.ActorFrame{
        Name="MSItem"..idx;
        BeginCommand=function(s) s:playcommand(idx == curIndex and "GainFocus" or "LoseFocus") end,
        MoveScrollerMessageCommand=function(s,p)
            if curIndex == idx then
                s:playcommand("GainFocus")
            else
                s:playcommand("LoseFocus")
            end
        end,
        Def.ActorFrame{
            Def.BitmapText{
                Font="_avenirnext lt pro bold 36px",
                InitCommand=function(s)
                    s:settext(MainScrollerList[idx]):diffuse(Color.Black):halign(0):zoom(1.2)
                end,
            };
            Def.Sprite{
                Texture=THEME:GetPathG("","_shared/garrows/_selectarrowg"),
                InitCommand=function(s) s:rotationy(180):x(-100):zoom(0.7):visible(false) end,
                GainFocusCommand=function(s) s:visible(true) end,
                LoseFocusCommand=function(s) s:visible(false) end,
            };
            Def.Sprite{
                Texture="icons",
                InitCommand=function(s) s:pause():setstate(idx-1):x(-40) end,
            }
        };
    };
end

local MainItemList = {};
for i=1,#MainScrollerList do
    MainItemList[#MainItemList+1] = MainScrollerItems(MainScrollerList[i],i)
end

local function MenuScrollerItems(Player, idx)
    return Def.ActorFrame{
        Name="MSItem"..idx;
        BeginCommand=function(s) s:playcommand(idx == curIndex and "GainFocus" or "LoseFocus") end,
        MoveScrollerMessageCommand=function(s,p)
            if curIndex == idx then
                s:playcommand("GainFocus")
            else
                s:playcommand("LoseFocus")
            end
        end,
        Def.ActorFrame{
            Def.BitmapText{
                Font="_avenirnext lt pro bold 36px",
                InitCommand=function(s)
                    s:settext(MenuScrollerList[idx]):diffuse(Color.Black):halign(0):zoom(1.2)
                end,
            };
            Def.Sprite{
                Texture=THEME:GetPathG("","_shared/garrows/_selectarrowg"),
                InitCommand=function(s) s:rotationy(180):x(-100):zoom(0.7):visible(false) end,
                GainFocusCommand=function(s) s:visible(true) end,
                LoseFocusCommand=function(s) s:visible(false) end,
            };
        };
    };
end

local MenuItemList = {};
for i=1,#MenuScrollerList do
    MenuItemList[#MenuItemList+1] = MenuScrollerItems(MenuScrollerList[i],i)
end

t[#t+1] = Def.ActorScroller{
    Name = 'MainScroller';
    NumItemsToDraw=20;

    InitCommand=function(s) s:xy(-80,-10):SetSecondsPerItem(0.15):diffusealpha(0) end,
    OnCommand=function(s) s:sleep(0.7):diffusealpha(1) end,
    OffCommand=function(self)
        self:diffusealpha(0)
    end;
    TransformFunction=function(self,offsetFromCenter,itemIndex,numItems)
        self:y((offsetFromCenter * 75));
    end;
    children=MainItemList,
};

t[#t+1] = Def.BitmapText{
    Name="Wait",
    Font="_avenirnext lt pro bold 36px",
    Text="Please wait...",
    InitCommand=function(s) s:diffuse(Color.Black) end,
    OffCommand=function(s) s:sleep(0.1):linear(0.1):diffusealpha(0) end,
};

t[#t+1] = Def.ActorScroller{
    Name = 'MenuScroller';
    NumItemsToDraw=20;

    InitCommand=function(s) s:xy(-80,-10):SetSecondsPerItem(0.15):diffusealpha(0) end,
    OnCommand=function(s) s:sleep(0.7):diffusealpha(1) end,
    OffCommand=function(self)
        self:diffusealpha(0)
    end;
    TransformFunction=function(self,offsetFromCenter,itemIndex,numItems)
        self:y((offsetFromCenter * 75));
    end;
    children=MenuItemList,
};

local function UpdateInternal(s,Player)
    local c = s:GetChildren();
    curIndex = 1
    c.Wait:visible(false)
    if GAMESTATE:IsHumanPlayer(Player) then
        if menuset == 0 then
            c.MainScroller:visible(true)
            c.MenuScroller:visible(false)
        elseif menuset == 3 then
            c.MainScroller:visible(false)
            c.MenuScroller:visible(true)
        else
            c.MainScroller:visible(false)
        end
        if getenv("keyset"..ToEnumShortString(Player)) == 1 then
            c.Wait:visible(true)
            c.MainScroller:visible(false)
            c.MenuScroller:visible(false)
        end
    end
end

return Def.ActorFrame{
    Def.ActorFrame{
        Def.Sprite{
            Texture=THEME:GetPathG("","ScreenSelectProfile/BG01"),
            InitCommand=function(s) s:zoomy(0) end,
            OnCommand=function(s) s:sleep(0.3):linear(0.3):zoomy(1) end,
            OffCommand=function(s) s:sleep(0.3):linear(0.1):zoomy(0) end,
        };
        Def.ActorFrame{
            Name="Topper",
            InitCommand=function(s) s:y(-292) end,
            OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(-292) end,
            OffCommand=function(s) s:sleep(0.3):linear(0.1):y(0):sleep(0):diffusealpha(0) end,
            Def.Sprite{
                Texture=THEME:GetPathG("","ScreenSelectProfile/BGTOP_"..ToEnumShortString(pn));
                InitCommand=function(s) s:valign(1) end,
            };
        };
        Def.ActorFrame{
            Name="Bottom",
            OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(286) end,
            OffCommand=function(s) s:sleep(0.3):linear(0.1):y(0):sleep(0):diffusealpha(0) end,
            Def.Sprite{
                Texture=THEME:GetPathG("","ScreenSelectProfile/BGBOTTOM"),
                InitCommand=function(s) s:valign(0) end,
            };
            Def.Sprite{
                Texture=THEME:GetPathG("","ScreenSelectProfile/start game"),
                InitCommand=function(s) s:valign(0):diffusealpha(0) end,
                OnCommand=function(s) s:sleep(0.8):diffusealpha(1) end,
            };
        };
    };
    Def.ActorFrame{
        InitCommand=function(s) s:y(-150):diffusealpha(0):zoom(0.9) end,
        OnCommand=function(s) s:sleep(0.7):linear(0.1):diffusealpha(1):zoom(1.1):linear(0.1):zoom(1) end,
        OffCommand=function(s) s:diffusealpha(0) end,
        Def.Sprite{
            Texture=THEME:GetPathG("","ScreenSelectProfile/card"),
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold 25px",
            Text=PROFILEMAN:GetProfile(pn):GetDisplayName(),
            InitCommand=function(s) s:xy(-220,-15):halign(0):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5"))
                :maxwidth(400):zoom(1.1)
            end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold 25px",
            Text=string.upper(string.sub(PROFILEMAN:GetProfile(pn):GetGUID(),1,4).."-"..string.sub(PROFILEMAN:GetProfile(pn):GetGUID(),5,8)),
            InitCommand=function(s) s:xy(-220,18):halign(0):zoom(0.8):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5"))
                :maxwidth(400)
            end,
        }
    };
    t..{
        CodeMessageCommand=function(s,p)
            if pn ~= p.PlayerNumber then return end
            if p.Name == "Back" then
                SCREENMAN:GetTopScreen():Cancel()
                MESSAGEMAN:Broadcast("Back")
            elseif p.Name == 'Start' or p.Name == 'Center' then
                MESSAGEMAN:Broadcast("Start")
                if menuset == 0 then
                    if curIndex == 1 then
                        setenv("keyset"..ToEnumShortString(pn),1)
                        MESSAGEMAN:Broadcast("Continue")
                        UpdateInternal(s,p.PlayerNumber)
                    else
                        menuset = curIndex
                        UpdateInternal(s,p.PlayerNumber)
                    end
                elseif menuset == 3 then
                    if curIndex == 4 then
                        menuset = 0
                        UpdateInternal(s,p.PlayerNumber)
                    end
                end
            end
            if p.Name == "Down" or p.Name == "Down2" then
                if menuset == 0 then
                    if curIndex >= #MainScrollerList then
                        curIndex= #MainScrollerList
                    else
                        curIndex = curIndex+1
                        MESSAGEMAN:Broadcast("Direction")
                    end
                elseif menuset == 3 then
                    if curIndex >= #MenuScrollerList then
                        curIndex = #MenuScrollerList
                    else
                        curIndex = curIndex+1
                        MESSAGEMAN:Broadcast("Direction")
                    end
                end
            elseif p.Name == "Up" or p.Name == "Up2" then
                if curIndex == 1 then
                    curIndex = 1 
                else
                    curIndex = curIndex-1
                    MESSAGEMAN:Broadcast("Direction")
                end
            end
            MESSAGEMAN:Broadcast("MoveScroller")
        end,
        UpdateMessageCommand=function(s)
            UpdateInternal(s,pn)
        end,
        OnCommand=function(s)
            UpdateInternal(s,pn)
        end,
    };
}