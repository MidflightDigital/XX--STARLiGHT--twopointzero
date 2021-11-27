local x = Def.ActorFrame{

	CodeMessageCommand = function(self, params)
		if params.Name == 'Start' or params.Name == 'Center' then
			SOUND:PlayOnce(THEME:GetPathS("Common","start"))
			SOUND:PlayOnce(THEME:GetPathS("","Profile_start"))
			SCREENMAN:GetTopScreen():Finish()
		end;
	end;

};

function LoadPlayerStuff(Player)

	local t = {};
	local pn = (Player == PLAYER_1) and 1 or 2;
	local strpn = tostring(pn);

	t[#t+1] = Def.ActorFrame {
		Name = 'JoinFrame';
	};

	t[#t+1] = Def.ActorFrame {
		Name = 'BigFrame';
		LoadCard(PlayerColor(),color('1,1,1,1'),Player,true);
	};
	t[#t+1] = Def.ActorFrame {
		Name = 'SmallFrame';
		InitCommand=function(s) s:y(5) end,
	};



	t[#t+1] = Def.ActorFrame {
		Name = "EffectFrame";
	};

	t[#t+1] = Def.Sprite{
		Texture=THEME:GetPathG("","ScreenSelectProfile/card"),
		Name = "CardBG";
		InitCommand=function(s) s:diffusealpha(0):zoom(0.75) end,
		OnCommand=function(self)
			if IsJoinFrame then
				self:linear(0.3):diffusealpha(0)
			else
				self:sleep(0.7):linear(0.1):diffusealpha(1):zoom(1.1):linear(0.1):zoom(1)
			end
		end;
		OffCommand=function(self)
			self:diffusealpha(0)
		end;
	};
	t[#t+1] = Def.Sprite{
		Texture=THEME:GetPathG("","ScreenSelectProfile/noprofile datasave"),
		Name = "NoData",
		InitCommand=function(s) s:diffusealpha(0):zoom(0.75) end,
		OnCommand=function(self)
			if IsJoinFrame then
				self:linear(0.3):diffusealpha(0)
			else
				self:sleep(0.7):linear(0.1):diffusealpha(1):zoom(1.1):linear(0.1):zoom(1)
			end
		end;
		OffCommand=function(self)
			self:diffusealpha(0)
		end;
	};
	t[#t+1] = LoadFont("_avenirnext lt pro bold 25px") .. {
		Name = 'SelectedProfileText';
    InitCommand=function(self)
      self:xy(-220,-15):halign(0):zoom(1.1):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5")):diffusealpha(0):maxwidth(400)
    end;
	OnCommand=function(s) s:sleep(0.7):linear(0.2):diffusealpha(1) end,
    OffCommand=function(s) s:diffusealpha(0) end,
	};

	t[#t+1] = LoadFont("_avenirnext lt pro bold 25px") .. {
		Name = 'selectPlayerUID';
		InitCommand=function(s) s:zoom(0.8):halign(0):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5"))
			:diffusealpha(0):xy(-220,18)
		end,
		OnCommand=function(s)
			if IsJoinFrame then
				s:linear(0.3):diffusealpha(0)
			else
				s:sleep(0.7):linear(0.1):diffusealpha(1):zoom(1.1):linear(0.1):zoom(1)
			end
		end;
		OffCommand=function(s) s:diffusealpha(0) end,
	};
	t[#t+1] = Def.ActorFrame{
		Name = 'SelectTimer';
		InitCommand=function(s)
			s:xy(180,-340)
			if PREFSMAN:GetPreference("MenuTimer") then
				s:zoom(1)
			else
				s:zoom(0)
			end
		end,
		OnCommand=function(s) s:diffusealpha(0):sleep(0.7):linear(0.2):diffusealpha(1) end,
		OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
		loadfile(THEME:GetPathG("","MenuTimer frame"))()..{
			InitCommand=function(s) s:xy(11,25) end,
		};
		Def.BitmapText{
			Font="MenuTimer numbers";
			OnCommand=function(s) s:xy(-34,0):skewx(-0.1):queuecommand("Update") end,
			UpdateCommand=function(s)
				local MenuT = SCREENMAN:GetTopScreen():GetChild("Timer")
				local time = MenuT:GetSeconds()
				if PREFSMAN:GetPreference("MenuTimer") then
					local digit = math.floor(time/10)
					s:settext(string.format("%01d",digit))
					if time <= 10 then
						s:diffuseshift():effectperiod(1):effectcolor1(Color.White):effectcolor2(Color.Red):sleep(1):queuecommand("Update")
					elseif time <=5 then
						s:diffuseshift():effectperiod(0.2):effectcolor1(Color.White):effectcolor2(Color.Red):sleep(1):queuecommand("Update")
					else
						s:sleep(1):queuecommand("Update")
					end
				end
			end,
		};
		Def.BitmapText{
			Font="MenuTimer numbers";
			OnCommand=function(s) s:xy(32,-7):zoom(0.75):skewx(-0.1):queuecommand("Update") end,
			UpdateCommand=function(s)
				local MenuT = SCREENMAN:GetTopScreen():GetChild("Timer")
				local time = MenuT:GetSeconds()
				if PREFSMAN:GetPreference("MenuTimer") then
					local digit = math.mod(time,10)
					s:settext(string.format("%01d",digit))
					if time <= 10 then
						s:diffuseshift():effectperiod(1):effectcolor1(Color.White):effectcolor2(Color.Red):sleep(1):queuecommand("Update")
					elseif time <=5 then
						s:diffuseshift():effectperiod(0.2):effectcolor1(Color.White):effectcolor2(Color.Red):sleep(1):queuecommand("Update")
					else
						s:sleep(1):queuecommand("Update")
					end
				end
			end,
		};
	};
	return t;
end;


--Update Internal Stuff
function UpdateInternal(self, Player)
	local pn = (Player == PLAYER_1) and 1 or 2;
	local style = (GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Single") and "S" or "D";
	local card = self:GetChild('CardBG');
	local seltext = self:GetChild('SelectedProfileText');
	local selectPlayerUID = self:GetChild('selectPlayerUID');
	local joinframe = self:GetChild('JoinFrame');
	local smallframe = self:GetChild('SmallFrame');
	local bigframe = self:GetChild('BigFrame');
	local nodata = self:GetChild('NoData');
	local SelectTimer = self:GetChild('SelectTimer');

				bigframe:visible(true);
				card:visible(false);
				SelectTimer:visible(true)
				selPlayerUID = PROFILEMAN:GetProfile(Player):GetGUID();
				if PROFILEMAN:IsPersistentProfile(Player) then
					card:visible(true)
					nodata:visible(false)
					seltext:settext(PROFILEMAN:GetProfile(Player):GetDisplayName());
					selectPlayerUID:settext(string.upper(string.sub(selPlayerUID,1,4).."-"..string.sub(selPlayerUID,5,8)));
				else
					card:visible(false)
					nodata:visible(true)
					seltext:settext("")
					selectPlayerUID:settext("");
				end

				local selPlayerProf = PROFILEMAN:GetProfile(Player)

				local stype = GAMESTATE:GetCurrentStyle():GetStyleType()
				local style = ((stype == 'StyleType_OnePlayerTwoSides') or (stype == 'StyleType_TwoPlayersSharedSides'))
					and 'double'
					or 'single'
				GAMESTATE:StoreRankingName(Player,PROFILEMAN:GetProfile(Player):GetDisplayName())
end

if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
x[#x+1] = Def.ActorFrame {
			Name = 'P1Frame';
			InitCommand=function(s) s:xy(SCREEN_CENTER_X-402,SCREEN_CENTER_Y-2) end,
			OnCommand=function(self)
				UpdateInternal(self, PLAYER_1);
			end;
			children = LoadPlayerStuff(PLAYER_1);
		};
end
if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
x[#x+1] = Def.ActorFrame {
			Name = 'P2Frame';
			InitCommand=function(s) s:xy(SCREEN_CENTER_X+406,SCREEN_CENTER_Y-2) end,
			OnCommand=function(self)
				UpdateInternal(self, PLAYER_2);
			end;
			children = LoadPlayerStuff(PLAYER_2);
		};
end

x[#x+1] = Def.ActorFrame {
	Def.Actor{
		StartTransitioningCommand=function(s) SOUND:PlayOnce(THEME:GetPathS("","Profile_in")) end,
		BackButtonMessageCommand=function(s) SOUND:PlayOnce(THEME:GetPathS("Common","cancel")) end,
	}
};


return x;
