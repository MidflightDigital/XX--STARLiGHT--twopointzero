--[[
pn = Which player's stats to display.
controller = which controller controls the panel
showInstructionsTab = If the fifth tab should also be shown. (It's too much work to replicate DDR 2014 exactly, so it's the fifth tab)
If showInstructionsTab is true, it will start on the instructions tab.

In DDR2014, two panels are loaded and P2 controller
moves the right panel, while P1 controller moves
the left panel.
]]
local pn  = ({...})[1]
local controller = ({...})[2]
local paneState = ({...})[3]
local tabCount = 3
local profileID = GetProfileIDForPlayer(pn)
local pPrefs = ProfilePrefs.Read(profileID)

local t = Def.ActorFrame{
    OnCommand=function(s) s:addy(800):sleep(0.3):linear(0.2):addy(-800) end,
	OffCommand=function(s) s:linear(0.2):addy(800)
		ProfilePrefs.Save(profileID)
	end,
    --Input handler
    CodeMessageCommand=function(s,p)
        if p.PlayerNumber==controller then
			if p.Name=="Left" then
				if paneState > 0 then
					SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change" ));
					paneState = paneState - 1;
				end;
			elseif p.Name=="Right" then
				if paneState < (tabCount-1) then
					SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change" ));
					paneState = paneState + 1;
				end;
			else
				SCREENMAN:SystemMessage("Unknown button: "..p.Name);
			end;
			if controller == PLAYER_1 then
				pPrefs.evalpane1 = paneState
			else
				pPrefs.evalpane2 = paneState
			end
        end;
    end, 
    Def.Sprite{
        Texture="_box",
    };
    Def.Sprite{
        Texture="box header 1x3.png",
        InitCommand=function(s) s:pause():y(-144):setstate(paneState) end,
        CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				self:setstate(paneState)
			end;
        end;
	};
	Def.Sprite{
        Texture="bottom 1x3.png",
        InitCommand=function(s) s:pause():y(200):setstate(paneState) end,
        CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				self:setstate(paneState)
			end;
        end;
	};
	Def.Sprite{
        Texture="instruct.png",
        InitCommand=function(s) s:y(220) end,
    };
    Def.ActorFrame{
		InitCommand=function(s)
			if paneState == 0 then
				s:diffusealpha(1);
			else
				s:diffusealpha(0);
			end;
		end,
        CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				if paneState == 0 then
					self:diffusealpha(1);
				else
					self:diffusealpha(0);
				end;
			end;
        end;
        loadfile(THEME:GetPathB("ScreenEvaluation","decorations/stats"))(pn);
    };
    --3rd pane, rankings
	loadfile(THEME:GetPathB("ScreenEvaluation","decorations/scoresUnified"))(pn)..{
		InitCommand=function(s) 
			s:diffusealpha(0):draworder(3):y(18)
			if paneState == 1 then
				s:diffusealpha(1);
			else
				s:diffusealpha(0);
			end;
		end,
		CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				if paneState == 1 then
					self:diffusealpha(1);
				else
					self:diffusealpha(0);
				end;
			end;
		end;
    };
    --4th pane, calories
	loadfile(THEME:GetPathB("ScreenEvaluation","decorations/kcalP1"))(pn)..{
		InitCommand=function(s)
			s:diffusealpha(0)
			if paneState == 2 then
				s:diffusealpha(1);
			else
				s:diffusealpha(0);
			end;
		end,
		CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				if paneState == 2 then
					self:diffusealpha(1);
				else
					self:diffusealpha(0);
				end;
			end;
		end;
	};
}

return t;