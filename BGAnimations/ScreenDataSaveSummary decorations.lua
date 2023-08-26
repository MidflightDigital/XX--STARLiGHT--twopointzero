--Update Internal Stuff
local function UpdateInternal(self, Player)
	--local pn = (Player == PLAYER_1) and 1 or 2
	local style = (GAMESTATE:GetCurrentStyle():GetStepsType() == 'StepsType_Dance_Single') and 'S' or 'D'
	local card = self:GetChild('CardBG')
	local seltext = self:GetChild('SelectedProfileText')
	local selectPlayerUID = self:GetChild('selectPlayerUID')
	local joinframe = self:GetChild('JoinFrame')
	local smallframe = self:GetChild('SmallFrame')
	local bigframe = self:GetChild('BigFrame')
	local nodata = self:GetChild('NoData')
	local SelectTimer = self:GetChild('SelectTimer')
	bigframe:visible(true)
	card:visible(false)
	SelectTimer:visible(true)
	selPlayerUID = PROFILEMAN:GetProfile(Player):GetGUID()
	
	if PROFILEMAN:IsPersistentProfile(Player) then
		card:visible(true)
		nodata:visible(false)
		seltext:settext(PROFILEMAN:GetProfile(Player):GetDisplayName())
		selectPlayerUID:settext(string.upper(string.sub(selPlayerUID,1,4)..'-'..string.sub(selPlayerUID,5,8)))
	else
		card:visible(false)
		nodata:visible(true)
		seltext:settext('')
		selectPlayerUID:settext('')
	end

	local selPlayerProf = PROFILEMAN:GetProfile(Player)

	local stype = GAMESTATE:GetCurrentStyle():GetStyleType()
	local style = ((stype == 'StyleType_OnePlayerTwoSides') or (stype == 'StyleType_TwoPlayersSharedSides'))
		and 'double'
		or 'single'
	GAMESTATE:StoreRankingName(Player,PROFILEMAN:GetProfile(Player):GetDisplayName())
end

local function LoadCard(cColor,cColor2,Player,IsJoinFrame)
	local t = Def.ActorFrame{
		Def.Sprite{
			Texture=THEME:GetPathG("","ScreenSelectProfile/BG01");
			InitCommand=function(s) s:zoomy(0) end,
			OnCommand=function(s) s:sleep(0.3):linear(0.3):zoomy(1) end,
			['Player' .. pname(Player) .. 'FinishMessageCommand']=function(s) s:sleep(0.3):linear(0.1):zoomy(0) end,
		};
		Def.ActorFrame{
			Name="Topper",
			InitCommand=function(s) s:y(-292) end,
			OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(-292) end,
			['Player' .. pname(Player) .. 'FinishMessageCommand']=function(s)
				s:sleep(0.3):linear(0.1):y(0):sleep(0):diffusealpha(0)
			end,
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/BGTOP_"..ToEnumShortString(Player));
				InitCommand=function(s) s:valign(1) end,
			};
		};
		Def.ActorFrame{
			Name="Bottom",
			OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(286) end,
			['Player' .. pname(Player) .. 'FinishMessageCommand']=function(s)
				s:sleep(0.3):linear(0.1):y(0):sleep(0):diffusealpha(0)
			end,
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
	return t;
end

local function LoadPlayerStuff(Player)
	local x = {}

	x[#x+1] = Def.ActorFrame {
		Name='JoinFrame', 
	};
	x[#x+1] = Def.ActorFrame {
		Name='BigFrame', 
		LoadCard(PlayerColor(),color('1,1,1,1'),Player,true),
	};
	x[#x+1] = Def.ActorFrame {
		Name='SmallFrame', 
		InitCommand=function(s) s:y(5) end,
	};
	x[#x+1] = Def.ActorFrame {
		Name='EffectFrame', 
	};
	x[#x+1] = Def.Sprite {
		Texture=THEME:GetPathG('', 'ScreenSelectProfile/card'),
		Name='CardBG', 
		InitCommand=function(s) s:diffusealpha(0):zoom(0.75) end,
		OnCommand=function(self)
			self:sleep(0.7):linear(0.1):diffusealpha(1):zoom(1.1):linear(0.1):zoom(1)
		end,
		['Player' .. pname(Player) .. 'FinishMessageCommand']=function(self)
			self:sleep(0.3):diffusealpha(0)
		end,
	};
	x[#x+1] = Def.Sprite {
		Texture=THEME:GetPathG('', 'ScreenSelectProfile/noprofile datasave'),
		Name='NoData', 
		InitCommand=function(s) s:diffusealpha(0):zoom(0.75) end,
		OnCommand=function(self)
			self:sleep(0.7):linear(0.1):diffusealpha(1):zoom(1.1):linear(0.1):zoom(1)
		end,
		['Player' .. pname(Player) .. 'FinishMessageCommand']=function(self)
			self:sleep(0.3):diffusealpha(0)
		end,
	};
	x[#x+1] = Def.BitmapText{
		Font='_avenirnext lt pro bold/25px',
		Name='SelectedProfileText', 
		InitCommand=function(self)
			self:xy(-220,-15):halign(0):zoom(1.1):diffuse(color('#b5b5b5')):diffusetopedge(color('#e5e5e5')):diffusealpha(0):maxwidth(400)
		end,
		OnCommand=function(s) s:sleep(0.7):linear(0.2):diffusealpha(1) end,
		['Player' .. pname(Player) .. 'FinishMessageCommand']=function(s) s:sleep(0.3):diffusealpha(0) end,
	};
	x[#x+1] = Def.BitmapText{
		Font='_avenirnext lt pro bold/25px',
		Name='selectPlayerUID', 
		InitCommand=function(s) s:zoom(0.8):halign(0):diffuse(color('#b5b5b5')):diffusetopedge(color('#e5e5e5'))
			:diffusealpha(0):xy(-220,18)
		end,
		OnCommand=function(s)
			s:sleep(0.7):linear(0.1):diffusealpha(1):zoom(1.1):linear(0.1):zoom(1)
		end,
		['Player' .. pname(Player) .. 'FinishMessageCommand']=function(s) s:sleep(0.3):diffusealpha(0) end,
	};
	x[#x+1] = Def.ActorFrame {
		Name='SelectTimer', 
		InitCommand=function(s)
			s:xy(180,-340)
			if PREFSMAN:GetPreference('MenuTimer') then
				s:zoom(1)
			else
				s:zoom(0)
			end
		end,
		OnCommand=function(s) s:diffusealpha(0):sleep(0.7):linear(0.2):diffusealpha(1) end,
		['Player' .. pname(Player) .. 'FinishMessageCommand']=function(s) s:linear(0.2):diffusealpha(0) end,
		loadfile(THEME:GetPathG('', 'MenuTimer frame'))() .. {
			InitCommand=function(s) s:xy(11,25) end,
		},
		Def.BitmapText {
			Font='MenuTimer numbers', 
			OnCommand=function(s)
				if PREFSMAN:GetPreference('MenuTimer') then
					local MenuT = SCREENMAN:GetTopScreen():GetChild('Timer')
					local time = MenuT:GetSeconds()-2
					local digit = math.floor(time/10)
					s:xy(-34,22):skewx(-0.1):settext(string.format('%01d', digit)):sleep(2):queuecommand('Update')
				end
			end,
			UpdateCommand=function(s)
				local MenuT = SCREENMAN:GetTopScreen():GetChild('Timer')
				local time = MenuT:GetSeconds()
				if PREFSMAN:GetPreference('MenuTimer') then
					local digit = math.floor(time/10)
					s:settext(string.format('%01d', digit))
					if time <= 10 then
						s:diffuseshift():effectperiod(1):effectcolor1(Color.White):effectcolor2(Color.Red):sleep(1):queuecommand('Update')
					elseif time <=5 then
						s:diffuseshift():effectperiod(0.2):effectcolor1(Color.White):effectcolor2(Color.Red):sleep(1):queuecommand('Update')
					else
						s:sleep(1):queuecommand('Update')
					end
				end
			end,
		},
		Def.BitmapText {
			Font='MenuTimer numbers', 
			OnCommand=function(s)
				if PREFSMAN:GetPreference('MenuTimer') then
					local MenuT = SCREENMAN:GetTopScreen():GetChild('Timer')
					local time = MenuT:GetSeconds()-2
					local digit = math.mod(time,10)
					s:xy(32,14):zoom(0.75):skewx(-0.1):settext(string.format('%01d', digit)):sleep(2):queuecommand('Update')
				end
			end,
			UpdateCommand=function(s)
				local MenuT = SCREENMAN:GetTopScreen():GetChild('Timer')
				local time = MenuT:GetSeconds()
				if PREFSMAN:GetPreference('MenuTimer') then
					local digit = math.mod(time,10)
					s:settext(string.format('%01d', digit))
					if time <= 10 then
						s:diffuseshift():effectperiod(1):effectcolor1(Color.White):effectcolor2(Color.Red):sleep(1):queuecommand('Update')
					elseif time <=5 then
						s:diffuseshift():effectperiod(0.2):effectcolor1(Color.White):effectcolor2(Color.Red):sleep(1):queuecommand('Update')
					else
						s:sleep(1):queuecommand('Update')
					end
				end
			end,
		},
	};
	
	return x
end

local t = LoadFallbackB();

t[#t+1] = Def.Sound {
	File=THEME:GetPathS('', 'Profile_In'),
	OnCommand=function(s) s:play() end,
};

local mode = {}
local numPlayers = GAMESTATE:GetNumPlayersEnabled()

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	mode[pn] = 0
	
	t[#t+1] = Def.Actor {
		CodeMessageCommand=function(self, params)
			if params.PlayerNumber == pn then
				if params.Name == 'Start' then
					if mode[pn] == 0 then
						SOUND:PlayOnce(THEME:GetPathS('', 'Profile_start'))
						MESSAGEMAN:Broadcast('Player' .. pname(pn) .. 'Finish')
						mode[pn] = 1
					end
					
					if (numPlayers == 1 and mode[pn] == 1) or (numPlayers == 2 and (mode[PLAYER_1] == 1 and mode[PLAYER_2] == 1)) then
						mode[pn] = -1
						self:sleep(0.5):queuecommand('Next')
					end
				end
			end
		end,
		NextCommand=function()
			SCREENMAN:GetTopScreen():StartTransitioningScreen('SM_BeginFadingOut')
			SCREENMAN:GetTopScreen():PostScreenMessage('SM_GoToNextScreen', 1)
		end,
		OffCommand=function()
			if mode[pn] == 0 then
				MESSAGEMAN:Broadcast('Player' .. pname(pn) .. 'Finish')
			end
		end,
	};
	t[#t+1] = Def.ActorFrame {
		Name=pname(pn) .. 'Frame', 
		InitCommand=function(s) s:Center():addx(pn==PLAYER_1 and -402 or 402):addy(-2) end,
		OnCommand=function(self) UpdateInternal(self, pn) end,
		children = LoadPlayerStuff(pn),
	};
end

return t