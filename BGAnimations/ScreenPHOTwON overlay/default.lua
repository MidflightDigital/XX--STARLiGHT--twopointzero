--Taken from Project XV Epsilon, customized for STARLight, Inori

local curState = "MenuState_Main";

local MenuState = {
  MenuState_Main,
  MenuState_MenuBG,
  MenuState_BGM,
  MenuState_Wheel,
  MenuState_Gameplay,
};

local curIndex = 1;
local MenuChoices = {
  "MenuBG",
  "BGM",
  "Wheel",
  "Gameplay",
  "Back"
};

local menuC;
local wait = 0;

local t = Def.ActorFrame{
    OnCommand=function(s)
        SCREENMAN:GetTopScreen():lockinput(1)
        s:sleep(1):queuecommand("UpdateWait")
    end,
    UpdateWaitCommand=function(s)
        wait = 1
    end,
    InitCommand=function(self)
        menuC = self:GetChildren();
    end;
	Def.Actor{
		Name="MenuController";
		MenuInputMessageCommand=function(self,param)
			if GAMESTATE:IsHumanPlayer(param.Player) then
				if curState == "MenuState_Main" then
                    if param.Input == "Start" then
                        if wait ~= 0 then
						    if curIndex <= 3 then
						    	curState = "MenuState_"..MenuChoices[curIndex]
						    elseif curIndex == 4 then
						    	curState = "MenuState_Gameplay";
						    	SCREENMAN:AddNewScreenToTop("ScreenOptionsTheme","SM_GoToNextScreen")
            			    elseif curIndex == 5 then
						    	  SCREENMAN:GetTopScreen():SetNextScreenName(Branch.FirstScreen()):StartTransitioningScreen("SM_GoToNextScreen")
						    	  SOUND:StopMusic()
						    end;
                            MESSAGEMAN:Broadcast("MenuStateChanged",{ NewState = curState; });
                        end
					elseif param.Input == "Back" then
						-- in MenuState_Main, we quit.
						SCREENMAN:GetTopScreen():Cancel()
					elseif param.Input == "Up" or param.Input == "Left" then
						if curIndex == 1 then curIndex = #MenuChoices;
						else curIndex = curIndex - 1;
						end;

						local curItemName = MenuChoices[curIndex];
						local lastIndex = (curIndex == #MenuChoices) and 1 or curIndex+1;
						local prevItemName = MenuChoices[lastIndex];

						MESSAGEMAN:Broadcast("MainMenuFocusChanged",{Gain = curItemName, Lose = prevItemName});
						menuC[curItemName]:playcommand("GainFocus");
						menuC[prevItemName]:playcommand("LoseFocus");
					elseif param.Input == "Down" or param.Input == "Right" then
						if curIndex == #MenuChoices then curIndex = 1;
						else curIndex = curIndex + 1;
						end;

						local curItemName = MenuChoices[curIndex];
						local lastIndex = (curIndex == 1) and #MenuChoices or curIndex-1;
						local prevItemName = MenuChoices[lastIndex];

						MESSAGEMAN:Broadcast("MainMenuFocusChanged",{Gain = curItemName, Lose = prevItemName});
						menuC[curItemName]:playcommand("GainFocus");
						menuC[prevItemName]:playcommand("LoseFocus");
					else
						--Trace("Input ".. param.Input .." not implemented on main menu");
					end;
				else
					-- if we're not on the main menu, we want to send the
					-- input messages so effort isn't duplicated elsewhere.
					local inputParam = {
						Player = param.Player,
						Input = param.Input,
						Choice = curChoice,
						MenuState = curState
					};
					-- broadcast an input message so other elements can access it
					MESSAGEMAN:Broadcast("PlayerMenuInput",inputParam);
				end;
			end;
		end;
		MenuUpP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_1, Input = "Up", }); end;
		MenuUpP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_2, Input = "Up", }); end;
		MenuDownP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_1, Input = "Down", }); end;
		MenuDownP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_2, Input = "Down", }); end;
		MenuLeftP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_1, Input = "Left", }); end;
		MenuLeftP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_2, Input = "Left", }); end;
		MenuRightP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_1, Input = "Right", }); end;
		MenuRightP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_2, Input = "Right", }); end;
		-- via codes
		CodeMessageCommand=function(self,param)
			MESSAGEMAN:Broadcast("MenuInput", { Player = param.PlayerNumber, Input = param.Name })
		end;
		MenuStateChangedMessageCommand=function(self,param)
			local curItemName = MenuChoices[curIndex];
			if param.NewState == 'MenuState_Main' then
				menuC[curItemName]:playcommand("FinishedEditing");
				-- restore all dimmed items
				for idx, nam in pairs(MenuChoices) do
					if nam ~= "Exit" and nam ~= curItemName then
						menuC[nam]:playcommand("UnfocusedOut");
					end;
				end;
			else
				menuC[curItemName]:playcommand("StartedEditing");
				-- dim all non-selected items
				for idx, nam in pairs(MenuChoices) do
					if nam ~= "Exit" and nam ~= curItemName then
						menuC[nam]:playcommand("UnfocusedIn");
					end;
				end;
			end;
			curState = param.NewState;
		end;
	};
};


local MainTilePlacements = {
    {_screen.cx-266,_screen.cy-236,"MenuBG"},
    {_screen.cx+266,_screen.cy-236,"BGM"},
    {_screen.cx-266,_screen.cy-20,"Wheel"},
    {_screen.cx+266,_screen.cy-20,"Gameplay"},
    {_screen.cx+0,_screen.cy+192,"Back"}
}

for i,v in pairs(MainTilePlacements) do
    t[#t+1] = Def.ActorFrame{
        Name=v[3];
        Def.ActorFrame{
            InitCommand=function(s) s:xy(v[1],v[2]) end,
            OnCommand=function(s) s:diffusealpha(0):decelerate(0.1):diffusealpha(1) end,
            BeginCommand=function(s) s:playcommand(i == curIndex and "GainFocus" or "LoseFocus") end,
            GainFocusCommand=function(s) s:zoom(1.1) end,
            LoseFocusCommand=function(s) s:zoom(1) end,
            StartedEditingCommand=function(s) s:decelerate(0.1):diffusealpha(0) end,
            FinishedEditingCommand=function(s) s:accelerate(0.1):diffusealpha(1) end,
            UnfocusedInCommand=function(s) s:queuecommand("StartedEditing") end,
            UnfocusedOutCommand=function(s) s:queuecommand("FinishedEditing") end,
            Def.Sprite{
                Texture="MenuItems/HL.png",
                
                GainFocusCommand=function(s) s:diffusealpha(1) end,
                LoseFocusCommand=function(s) s:diffusealpha(0) end,
            };
            Def.Sprite{
                Texture="MenuItems/"..v[3]..".png";
            };
        };
    };
end
t[#t+1] = loadfile(THEME:GetPathB("ScreenPHOTwON","overlay/MenuBG"))();
t[#t+1] = loadfile(THEME:GetPathB("ScreenPHOTwON","overlay/BGM"))();
t[#t+1] = loadfile(THEME:GetPathB("ScreenPHOTwON","overlay/Wheel"))();

return t;
