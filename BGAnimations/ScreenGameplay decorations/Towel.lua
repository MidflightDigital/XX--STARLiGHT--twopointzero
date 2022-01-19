local function FilterUpdate(self)
	local song = GAMESTATE:GetCurrentSong();
	if song then


		local start = song:GetFirstBeat();
		local last = song:GetLastBeat();
		
		if (GAMESTATE:GetSongBeat() >= last) then
			self:visible(false);
		elseif (GAMESTATE:GetSongBeat() >= start-16) then
			self:visible(true);
		else
			self:visible(false);
		end;


	end;
end;

local t = Def.ActorFrame{
	InitCommand=function(s) s:SetUpdateFunction(FilterUpdate) end,
};
local pn = ...
local numPlayers = GAMESTATE:GetNumPlayersEnabled()
local center1P = PREFSMAN:GetPreference("Center1Player")
local style = GAMESTATE:GetCurrentStyle();
local styleType = ToEnumShortString(style:GetStyleType());


local Options = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString('ModsLevel_Preferred');

local function InitCoverPos(self, player, pos, Mode, TwoCoverMode, Flip)
    local profileID = GetProfileIDForPlayer(player)
    self:zoom(1.1):xy(pos,_screen.cy):rotationx(Flip)
    local pPrefs = ProfilePrefs.Read(profileID)
    local selfy = tonumber(pPrefs.TowelPos);
	
	if TwoCoverMode then --Hidden+&Sudden+
		if selfy > 0 then
			selfy = 0;
		end
	end
	
	
	if GAMESTATE:PlayerIsUsingModifier(player,'reverse') then
		if Mode == "Hidden+" then
			self:y(SCREEN_CENTER_Y+SCREEN_HEIGHT/2-selfy)
		elseif Mode == "Sudden+" then
			self:y(SCREEN_CENTER_Y-SCREEN_HEIGHT/2+selfy)
		end
	else
		if Mode == "Hidden+" then
			self:y(SCREEN_CENTER_Y-SCREEN_HEIGHT/2+selfy)
		elseif Mode == "Sudden+" then
			self:y(SCREEN_CENTER_Y+SCREEN_HEIGHT/2-selfy)
		end
	end;
end

local function ControlCoverPos(self, params, player, Mode, TwoCoverMode)
    if params.PlayerNumber == player then
        local profileID = GetProfileIDForPlayer(player)
		local pPrefs = ProfilePrefs.Read(profileID)
        if params.Name == "AppearancePlusShow" then
			if pPrefs.Towel == true then
				pPrefs.Towel = false
			else
				pPrefs.Towel= true
			end;
			self:visible(pPrefs.Towel)
			local overlay = SCREENMAN:GetTopScreen()
			overlay:GetChild("sound"):playforplayer(player)
        end;
        local yDelta = 0;
		
		if TwoCoverMode then --Hidden+&Sudden+
			if (params.Name == "AppearancePlusHarsher" and PREFSMAN:GetPreference("OnlyDedicatedMenuButtons")) or params.Name == "AppearancePlusHarsher2" then
				yDelta = 5;
			elseif (params.Name == "AppearancePlusEasier" and PREFSMAN:GetPreference("OnlyDedicatedMenuButtons")) or params.Name == "AppearancePlusEasier2" then
				yDelta = -5;
			end;
		else
			if (params.Name == "AppearancePlusHarsher" and PREFSMAN:GetPreference("OnlyDedicatedMenuButtons")) or params.Name == "AppearancePlusHarsher2" then
				yDelta = 10;
			elseif (params.Name == "AppearancePlusEasier" and PREFSMAN:GetPreference("OnlyDedicatedMenuButtons")) or params.Name == "AppearancePlusEasier2" then
				yDelta = -10;
			end;
        end

        local TowelPos = tonumber(pPrefs.TowelPos);

        selfy = TowelPos+yDelta;
		
		if TwoCoverMode then --Hidden+&Sudden+
			if selfy >0 then 
				selfy = 0
			elseif selfy < -SCREEN_HEIGHT/2 then
				selfy = -SCREEN_HEIGHT/2
			end;
		else
			if selfy >SCREEN_HEIGHT/2 then 
				selfy = SCREEN_HEIGHT/2
			elseif selfy < -SCREEN_HEIGHT/2 then
				selfy = -SCREEN_HEIGHT/2
			end;
		end	
		self:linear(0.1);
		
		if GAMESTATE:PlayerIsUsingModifier(player,'reverse') then
			if Mode == "Hidden+" then
				self:y(SCREEN_HEIGHT-selfy);
			elseif Mode == "Sudden+" then
				self:y(selfy);
			end
		else
			if Mode == "Hidden+" then
				self:y(selfy);
			elseif Mode == "Sudden+" then
				self:y(SCREEN_HEIGHT-selfy);
			end
		end;
		pPrefs.TowelPos = selfy
		ProfilePrefs.Save(profileID)
    end
end

local function AddCoverLayer(FileName, player, pos, Mode, TwoCoverMode, Flip)
	t[#t+1] = Def.Sprite{
		Texture=FileName,
		InitCommand=function(self)
			InitCoverPos(self, player, pos, Mode, TwoCoverMode, Flip);
		end;
        CodeMessageCommand = function(self, params)
            ControlCoverPos(self, params, player, Mode, TwoCoverMode);
		end;
	};
end

local function AppearancePlusMain(pn)
	local player = pn;
	local pNum = (player == PLAYER_1) and 1 or 2
	local OptionString = Options
	local PlayerUID = PROFILEMAN:GetProfile(player):GetGUID()  
	
	local pos = SCREEN_CENTER_X;
	-- [ScreenGameplay] PlayerP#Player*Side(s)X
	if center1P then
		pos = SCREEN_CENTER_X
	else
		local metricName = string.format("PlayerP%i%sX",pNum,styleType)
		pos = THEME:GetMetric("ScreenGameplay",metricName)
    end
    
	local MyValue = ReadOrCreateAppearancePlusValueForPlayer(PlayerUID,MyValue);
	
	if MyValue == "Hidden" then
		GAMESTATE:AddPreferredModifiers(player,'Hidden');
	elseif MyValue == "Sudden" then	
		GAMESTATE:AddPreferredModifiers(player,'Sudden');
	elseif MyValue == "Stealth" then
		GAMESTATE:AddPreferredModifiers(player,'Stealth');
	elseif MyValue == "Hidden+" then
		
		if GAMESTATE:GetCurrentStyle():GetStepsType()=="StepsType_Dance_Single" then
			if not GAMESTATE:PlayerIsUsingModifier(player,'reverse') then
				AddCoverLayer("CoverSingle", player, pos, "Hidden+",false,180);
			else
				AddCoverLayer("CoverSingle", player, pos, "Hidden+",false,0);
			end
		elseif GAMESTATE:GetCurrentStyle():GetStepsType()=="StepsType_Dance_Double" then
			if not GAMESTATE:PlayerIsUsingModifier(player,'reverse') then
				AddCoverLayer("CoverDouble", player, pos, "Hidden+",false,180);
			else
				AddCoverLayer("CoverDouble", player, pos, "Hidden+",false,0);
			end
		end
	elseif MyValue == "Sudden+" then
		
		if GAMESTATE:GetCurrentStyle():GetStepsType()=="StepsType_Dance_Single" then
			if not GAMESTATE:PlayerIsUsingModifier(player,'reverse') then
				AddCoverLayer("CoverSingle", player, pos, "Sudden+",false,0);
			else
				AddCoverLayer("CoverSingle", player, pos, "Sudden+",false,180);
			end
		elseif GAMESTATE:GetCurrentStyle():GetStepsType()=="StepsType_Dance_Double" then
			if not GAMESTATE:PlayerIsUsingModifier(player,'reverse') then
				AddCoverLayer("CoverDouble", player, pos, "Sudden+",false,180);
			else
				AddCoverLayer("CoverDouble", player, pos, "Sudden+",false,0);
			end
		end
	elseif MyValue == "Hidden+&Sudden+" then
		
		if GAMESTATE:GetCurrentStyle():GetStepsType()=="StepsType_Dance_Single" then
			if not GAMESTATE:PlayerIsUsingModifier(player,'reverse') then
				AddCoverLayer("CoverSingle", player, pos, "Hidden+",true,0);
				AddCoverLayer("CoverSingle", player, pos, "Sudden+",true,180);
			else
				AddCoverLayer("CoverSingle", player, pos, "Sudden+",true,180);
				AddCoverLayer("CoverSingle", player, pos, "Hidden+",true,0);
			end
		elseif GAMESTATE:GetCurrentStyle():GetStepsType()=="StepsType_Dance_Double" then
			if not GAMESTATE:PlayerIsUsingModifier(player,'reverse') then
				AddCoverLayer("CoverDouble", player, pos, "Hidden+",true,0);
				AddCoverLayer("CoverDouble", player, pos, "Sudden+",true,180);
			else
				AddCoverLayer("CoverDouble", player, pos, "Sudden+",true,0);
				AddCoverLayer("CoverDouble", player, pos, "Hidden+",true,180);
			end
		end
	end
	
	
end;

AppearancePlusMain(pn)

return t;