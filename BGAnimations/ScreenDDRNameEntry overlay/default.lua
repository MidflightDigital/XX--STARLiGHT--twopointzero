--[[local panes = Def.ActorFrame{};

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
    panes[#panes+1] = loadfile(THEME:GetPathB("ScreenDDRNameEntry","overlay/nameEntry"))(pn)..{
        InitCommand=function(s)
            if IsUsingWideScreen() then
                s:x(_screen.cx-480)
            else
                s:x(_screen.cx-400)
            end
            s:y(_screen.cy-2) 
        end,
    };
end]]

local function LoadPlayerStuff(pn)
    local t = Def.ActorFrame{};
    t[#t+1] = Def.ActorFrame{
        Name="JoinFrame";
        Def.ActorFrame{
			InitCommand=function(self)
				self:shadowlength(0):zoomy(0)
			end;
			OnCommand=function(s) s:sleep(0.3):linear(0.3):zoomy(1) end,
			OffCommand=function(self)
				self:linear(0.1):zoomy(0)
			end;
			Def.Sprite{
                Texture=THEME:GetPathG("","ScreenSelectProfile/BG01"),
            };
		};
		Def.ActorFrame{
			InitCommand=function(s) s:y(-292) end,
			OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(-292) end,
     		OffCommand=function(self)
				self:linear(0.1):y(0):sleep(0):diffusealpha(0)
			end;
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/BGTOP_"..ToEnumShortString(pn)),
				InitCommand=function(s) s:valign(1) end,
			};
		};
		Def.ActorFrame{
			Name="Bottom";
			InitCommand=function(self)
			  self:shadowlength(0)
			end;
			OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(286) end,
			OffCommand=function(self)
				self:linear(0.1):y(0):sleep(0):diffusealpha(0)
			end;
			Def.Sprite{
                Texture=THEME:GetPathG("","ScreenSelectProfile/BGBOTTOM"),
			    InitCommand=function(s) s:valign(0) end,
			};
        };
        Def.Sprite{
            Texture=THEME:GetPathG("","ScreenSelectProfile/ScreenSelectProfile Start.png"),
            InitCommand=function(s) s:zoomy(0):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#A5A6A5")) end,
			OnCommand=function(s) s:zoomy(0):zoomx(0):sleep(0.5):linear(0.1):zoomx(1):zoomy(1) end,
			OffCommand=function(s) s:linear(0.1):zoomy(0):diffusealpha(0) end,
        }
    };

    t[#t+1] = Def.ActorFrame{
        Name='BigFrame';
        loadfile(THEME:GetPathB("ScreenDDRNameEntry","overlay/nameEntry"))(pn);
    };
    return t;
end

local function Update(self, Player)
    local pn = Player == PLAYER_1 and 1 or 2
    local frame = self:GetChild(string.format('P%uFrame',pn))
    local joinframe = frame:GetChild('JoinFrame')
    local bigframe = frame:GetChild('BigFrame')
    if GAMESTATE:IsHumanPlayer(Player) then
        if getenv("keysetSDDRN"..ToEnumShortString(Player)) < 1 then
            bigframe:visible(true)
            joinframe:visible(false)
            setenv("SDDRNJoined"..Player,1)
        else
            bigframe:visible(true)
            joinframe:visible(false)
            frame:sleep(0.5):queuecommand("Off")
        end
    else
        bigframe:visible(false)
        joinframe:visible(true)
        setenv("SDDRNJoined"..Player,0)
    end
        --[[if Player == PLAYER_1 then
            if getenv("keysetSDDRNP1") < 1 then
                bigframe:visible(true)
                joinframe:visible(false)
                setenv("SDDRNJoinedPlayerNumber_P1",1)
            else
                bigframe:visible(true)
                joinframe:visible(false)
                frame:queuecommand("Off")
            end
        end
        if Player == PLAYER_2 then
            if getenv("keysetSDDRNP2") < 1 then
                bigframe:visible(true)
                joinframe:visible(false)
                setenv("SDDRNJoinedPlayerNumber_P2",1)
            else
                bigframe:visible(true)
                joinframe:visible(false)
                frame:queuecommand("Off")
            end
        end
    else
        bigframe:visible(false)
        joinframe:visible(true)
        setenv("SDDRNJoined"..Player,0)
    end]]
end

return Def.ActorFrame{
    SDDNFinishedMessageCommand=function(s) SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen") end,
    NextScreenCommand=function(s)
        SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
    end,
    CodeMessageCommand=function(s,p)
        if p.Name == 'Start' then
            if not GAMESTATE:IsHumanPlayer(p.PlayerNumber) then
                SOUND:PlayOnce(THEME:GetPathS("Common","start"))
                GAMESTATE:JoinPlayer(p.PlayerNumber)
                s:queuecommand("UpdateInternal2")
            else
                if GAMESTATE:GetNumPlayersEnabled() > 1 then
                    s:queuecommand("UpdateInternal2")
                end
            end
        end
        if p.Name == 'Back' then
            if GAMESTATE:GetNumPlayersEnabled() == 0 then
                SCREENMAN:GetTopScreen():Cancel();
            else
                SOUND:PlayOnce(THEME:GetPathS("Common","cancel"))
                GAMESTATE:UnjoinPlayer(p.PlayerNumber)
                s:queuecommand("UpdateInternal2")
            end
        end
    end,
    PlayerJoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
    end;
    PlayerUnjoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	OnCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;
    UpdateInternal2Command=function(self)
		Update(self, PLAYER_1);
		Update(self, PLAYER_2);
	end;
    children = {
        Def.ActorFrame{
            Name = 'P1Frame';
            InitCommand=function(s)
                if IsUsingWideScreen() then
                    s:x(_screen.cx-480)
                else
                    s:x(_screen.cx-400)
                end
                s:y(_screen.cy-2) 
            end,
            PlayerJoinedMessageCommand=function(self,param)
                if param.Player == PLAYER_1 then
                    self:zoomx(1):zoomy(0.15):linear(0.175):zoomy(1)
                end
            end,
            children = LoadPlayerStuff(PLAYER_1)
        };
        Def.ActorFrame{
            Name = 'P2Frame';
            InitCommand=function(s)
                if IsUsingWideScreen() then
                    s:x(_screen.cx+480)
                else
                    s:x(_screen.cx+400)
                end
                s:y(_screen.cy-2) 
            end,
            PlayerJoinedMessageCommand=function(self,param)
                if param.Player == PLAYER_2 then
                    self:zoomx(1):zoomy(0.15):linear(0.175):zoomy(1)
                end
            end,
            children = LoadPlayerStuff(PLAYER_2)
        };
    }
}