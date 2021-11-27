local profiles = PROFILEMAN:GetLocalProfileIDs()

local ProfileInfoCache = {}
setmetatable(ProfileInfoCache, {__index =
function(table, ind)
    local out = {}
    local prof = PROFILEMAN:GetLocalProfileFromIndex(ind)
    out.DisplayName = prof:GetDisplayName()
    out.UserTable = prof:GetUserTable()
    rawset(table, ind, out)
    return out
end
})

local keyset = {0,0}
local menuset = {0,0}
local curIndex = {1,1}

local MainScrollerList = {
    "CONTINUE",
    "GAMEPLAY",
    "CHARACTER",
    "FITNESS"
}

local MenuScrollerList = {
    "MenuBG",
    "BGM",
    "Wheel"
}

function LoadCard(cColor,cColor2,Player,IsJoinFrame)
    local t = Def.ActorFrame{
        Def.Sprite{
            Texture=THEME:GetPathG("","ScreenSelectProfile/BG01"),
            InitCommand=function(s) s:zoomy(0) end,
            OnCommand=function(s) s:sleep(0.3):linear(0.3):zoomy(1) end,
            OffCommand=function(s) s:sleep(0.3):linear(0.1):zoomy(0) end,
        };
        Def.ActorFrame{
            Name="Topper";
            InitCommand=function(s) s:shadowlength(0):y(-292) end,
            OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(-292) end,
            OffCommand=function(s) s:sleep(0.3):linear(0.1):y(0):sleep(0):diffusealpha(0) end,
            Def.Sprite{
                Texture=THEME:GetPathG("","ScreenSelectProfile/BG_TOP"..ToEnumShortString(Player)),
                InitCommand=function(s) s:valign(1) end,
            };
          };
          Def.ActorFrame{
            Name="Bottom";
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
    return t
end

local function MainScrollerItems(Player, idx)
    local pn = (Player == PLAYER_1) and 1 or 2
    return Def.ActorFrame{
        Name="MSItem"..idx;
        BeginCommand=function(s) s:playcommand(idx == curIndex[pn] and "GainFocus" or "LoseFocus") end,
        MoveScrollerMessageCommand=function(s,p)
            if curIndex[pn] == idx then
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

local function MenuScrollerItems(Player, idx)
    local pn = (Player == PLAYER_1) and 1 or 2
    return Def.ActorFrame{
        Name="MenuSItem"..idx;
        BeginCommand=function(s) s:playcommand(idx == curIndex[pn] and "GainFocus" or "LoseFocus") end,
        MoveScrollerMessageCommand=function(s,p)
            if curIndex[pn] == idx then
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

local MainItemList = {};
for i=1,#MainScrollerList do
    MainItemList[#MainItemList+1] = MainScrollerItems(MainScrollerList[i],i)
end

local MenuItemList = {};
for i=1,#MenuScrollerList do
    MenuItemList[#MenuItemList+1] = MenuScrollerItems(MenuScrollerList[i],i)
end

function LoadPlayerStuff(Player)
    local t = {};
    local pn = (Player == PLAYER_1) and 1 or 2

    t[#t+1] = Def.ActorFrame{
        Name = 'BigFrame';
        LoadCard(PlayerColor(),color('1,1,1,1'),Player,false);
    };
    t[#t+1] = LoadActor( THEME:GetPathG("","ScreenSelectProfile/card") )..{
        Name = 'Card';
        InitCommand=function(s) s:y(-150):diffusealpha(0) end,
        OnCommand=function(s) s:sleep(0.7):linear(0.2):diffusealpha(1) end,
        OffCommand=function(self)
            self:diffusealpha(0)
        end;
    };
    t[#t+1] = LoadFont("_avenirnext lt pro bold 25px") .. {
        Name = "PName",
        InitCommand=function(self) self:xy(5,-164):zoom(0.9):diffuse(color("#b5b5b5"))
            :diffusetopedge(color("#e5e5e5")):maxwidth(400):diffusealpha(0)
        end,
        OnCommand=function(s) s:sleep(0.7):linear(0.2):diffusealpha(1) end,
        OffCommand=function(self)
            self:diffusealpha(0)
        end;
    };

    t[#t+1] = Def.BitmapText{
        Font="_avenirnext lt pro bold 25px",
        Name ="PID",
        InitCommand=function(s) s:zoom(0.9):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5")):diffusealpha(0):xy(5,-112) end,
    	OnCommand=function(self)
        	self:sleep(0.7):linear(0.1):diffusealpha(1):zoom(1.1):linear(0.1):zoom(1)
    	end;
    	OffCommand=function(self)
      		self:diffusealpha(0)
    	end;
    }

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
    return t;
end

function UpdateInternal(s,Player)
    
    local pn = (Player == PLAYER_1) and 1 or 2;
    local c = s:GetChild(string.format('P%uFrame', pn)):GetChildren()
    if GAMESTATE:IsHumanPlayer(Player) then
        c.BigFrame:visible(true)
        if menuset[pn] == 0 then
            c.MainScroller:visible(true)
            c.MenuScroller:visible(false)
            if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
                c.PName:settext(PROFILEMAN:GetPlayerName(Player))
                local UID = PROFILEMAN:GetProfile(Player):GetGUID()
                c.PID:settext(string.upper(string.sub(UID,1,4).."-"..string.sub(UID,5,8)));
            end
        elseif menuset[pn] == 2 then
            c.MainScroller:visible(false)
            c.MenuScroller:visible(true)
            if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
                c.PName:settext(PROFILEMAN:GetPlayerName(Player))
                local UID = PROFILEMAN:GetProfile(Player):GetGUID()
                c.PID:settext(string.upper(string.sub(UID,1,4).."-"..string.sub(UID,5,8)));
            end
        end
    else
        c.BigFrame:visible(false)
        c.Card:visible(false)
        c.MainScroller:visible(false)
        c.MenuScroller:visible(false)
    end
end

local t = Def.ActorFrame{
    OnCommand=function(self, params)
        self:queuecommand('UpdateInternal2');
    end;
    CodeMessageCommand=function(s,p)
        local pn = (p.Player == PLAYER_1) and 1 or 2;
        if p.Name == 'Back' then
            SCREENMAN:GetTopScreen():Cancel()
        end
        if p.Name == 'Start' or p.Name == 'Center' then
            MESSAGEMAN:Broadcast("StartButton");
            if menuset[pn] == 0 then
                if GAMESTATE:IsHumanPlayer(p.PlayerNumber) then
                    if curIndex[pn] == 1 then
                        keyset[pn] = 1
                        UpdateInternal(s,p.PlayerNumber)
                        if GAMESTATE:GetNumPlayersEnabled() == 2 then
                            if keyset[1] == 1 and keyset[2] == 1 then
                                SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
                            end
                        else
                            SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
                        end
                    else
                        menuset[pn] = curIndex[pn]-1
                        UpdateInternal(s,p.PlayerNumber)
                    end
                end
            else
                UpdateInternal(s,p.PlayerNumber)
            end
        end
        if GAMESTATE:IsHumanPlayer(p.PlayerNumber) then
            if p.Name == "Down" or p.Name == "Down2" then
                if menuset[pn] == 0 then
                    if curIndex[pn] >= #MainScrollerList then
                        curIndex[pn] = #MainScrollerList
                    else
                        curIndex[pn] = curIndex[pn]+1
                        MESSAGEMAN:Broadcast("DirectionButton");
                    end
                elseif menuset[pn] == 2 then
                    if curIndex[pn] >= #MenuScrollerList then
                        curIndex[pn] = #MenuScrollerList
                    else
                        curIndex[pn] = curIndex[pn]+1
                        MESSAGEMAN:Broadcast("DirectionButton");
                    end
                end
            elseif p.Name == "Up" or p.Name == "Up2" then
                if curIndex[pn] == 1 then
                    curIndex[pn] = 1 
                else
                    curIndex[pn] = curIndex[pn]-1
                    MESSAGEMAN:Broadcast("DirectionButton");
                end
            end
        end
        MESSAGEMAN:Broadcast("MoveScroller")
    end,
    children = {
        Def.Sprite{
			Texture=THEME:GetPathG("","ScreenSelectProfile/Cab outline");
			InitCommand=function(s) s:Center() end,
			OffCommand=function(s) s:diffusealpha(0):sleep(0.1):diffusealpha(0.5):sleep(0.1):diffusealpha(0):sleep(0.12):diffusealpha(1):linear(0.2):diffusealpha(0) end,
		};
        Def.ActorFrame{
            Name = 'P1Frame',
            InitCommand=function(s)
				if IsUsingWideScreen() then
					s:x(_screen.cx-480)
				else
					s:x(_screen.cx-400)
				end
				s:y(_screen.cy-2) 
			end,
            children = LoadPlayerStuff(PLAYER_1),
        };
        Def.ActorFrame{
            Name = 'P2Frame',
            InitCommand=function(s)
				if IsUsingWideScreen() then
					s:x(_screen.cx+480)
				else
					s:x(_screen.cx+400)
				end
				s:y(_screen.cy-2) 
			end,
            children = LoadPlayerStuff(PLAYER_2)
        };
        -- sounds
	    Def.Actor{
		    StartButtonMessageCommand=function(s)
		    	SOUND:PlayOnce(THEME:GetPathS("Common","start"))
		    	SOUND:PlayOnce(THEME:GetPathS("","Profile_start"))
		    end,
	    };
	    LoadActor( THEME:GetPathS("Common","cancel") )..{
		    BackButtonMessageCommand=function(s) s:play() end,
	    };
	    LoadActor( THEME:GetPathS("","Profile_Move") )..{
            DirectionButtonMessageCommand=function(s)
                s:play()
            end,
	    };
	    Def.Actor{
		    OffCommand=function(s)
		    	SOUND:DimMusic(0.5,math.huge)
		end,
	    }
    };
    UpdateInternal2Command=function(s)
        UpdateInternal(s,PLAYER_1)
        UpdateInternal(s,PLAYER_2)
    end;
}

return t;