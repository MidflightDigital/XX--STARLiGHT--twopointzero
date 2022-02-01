--[[
This script was taken from KENp's DDR X2 theme
and was recoded by FlameyBoy and Inorizushi
]]--

local ProfileInfoCache = {}
setmetatable(ProfileInfoCache, {__index =
function(table, ind)
    local out = {}
    local prof = PROFILEMAN:GetLocalProfileFromIndex(ind-1)
    out.DisplayName = prof:GetDisplayName()
    out.UserTable = prof:GetUserTable()
    rawset(table, ind, out)
    return out
end
})

local profnum = PROFILEMAN:GetNumLocalProfiles();
local keyset = {0,0}

--�d�����e����---------------------------
function LoadCard(cColor,cColor2,Player,IsJoinFrame)
	local t = Def.ActorFrame {
		LoadActor( THEME:GetPathG("","ScreenSelectProfile/BG01") ) .. {
			InitCommand=function(self)
				self:shadowlength(0):zoomy(0)
			end;
			OnCommand=function(s) s:sleep(0.3):linear(0.3):zoomy(1) end,
			OffCommand=function(self)
				if IsJoinFrame then
					self:linear(0.1):zoomy(0)
				else
					self:sleep(0.3):linear(0.1):zoomy(0)
				end
			end;
		};
		LoadActor( THEME:GetPathG("","ScreenSelectProfile/card") )..{
			Name = 'Card';
			InitCommand=function(s) s:diffusealpha(0):zoom(0.75):y(-150) end,
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
    Def.ActorFrame{
      Name="Topper";
      InitCommand=function(self)
        self:shadowlength(0):y(-292)
      end;
      OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(-292) end,
      OffCommand=function(self)
				if IsJoinFrame then
					self:linear(0.1):y(0):sleep(0):diffusealpha(0)
				else
					self:sleep(0.3):linear(0.1):y(0)
				end
			end;
      LoadActor( THEME:GetPathG("","ScreenSelectProfile/BGTOP_"..ToEnumShortString(Player)) )..{
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
				if IsJoinFrame then
					self:linear(0.1):y(0):sleep(0):diffusealpha(0)
				else
					self:sleep(0.3):linear(0.1):y(0)
				end
			end;
      LoadActor( THEME:GetPathG("","ScreenSelectProfile/BGBOTTOM") )..{
        InitCommand=function(s) s:valign(0) end,
      };
      LoadActor( THEME:GetPathG("","ScreenSelectProfile/start game") )..{
        InitCommand=function(s) s:valign(0):diffusealpha(0) end,
        OnCommand=function(s) s:sleep(0.8):diffusealpha(1) end,
      };
    };
	};

	return t
end

function LoadPlayerStuff(Player)

	local t = {};
	local pn = (Player == PLAYER_1) and 1 or 2;


	t[#t+1] = Def.ActorFrame {
		Name = 'JoinFrame';
		LoadCard(Color('Outline'),color('0,0,0,0'),Player,true);

		LoadActor( THEME:GetPathG("ScreenSelectProfile/ScreenSelectProfile","Start") ) .. {
			InitCommand=function(s) s:zoomy(0):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#A5A6A5")) end,
			OnCommand=function(s) s:zoomy(0):zoomx(0):sleep(0.5):linear(0.1):zoomx(1):zoomy(1) end,
			OffCommand=function(s) s:linear(0.1):zoomy(0):diffusealpha(0) end,
		};

	};

	t[#t+1] = Def.ActorFrame {
		Name = 'BigFrame';
		LoadCard(PlayerColor(),color('1,1,1,1'),Player,false);
	};
	t[#t+1] = Def.ActorFrame {
		Name = 'SmallFrame';
		InitCommand=function(s) s:y(120):hibernate(0.2) end,
		OnCommand=function(s) s:zoom(0):rotationz(-360):decelerate(0.4):zoom(1):rotationz(0) end,
        OffCommand=function(s) s:decelerate(0.3):rotationz(-360):zoom(0) end,
		Def.Sprite{Texture="GrooveRadar base",};
		Def.Sprite{
			Texture="sweep",
			InitCommand = function(s) s:zoom(1.275):spin():effectmagnitude(0,0,100) end,
        	OnCommand = function(s) s:hibernate(0.4) end,
        	OffCommand=function(s) s:finishtweening():sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
		};
	};


	t[#t+1] = Def.ActorFrame {
		Name = "EffectFrame";
	};
	--�U���d��-----------------
	t[#t+1] = LoadFont("_avenirnext lt pro bold/25px") .. {
		Name = 'SelectedProfileText';
    InitCommand=function(self) self:xy(5,-164):zoom(0.9):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5")):diffusealpha(0):maxwidth(400) end,
	OnCommand=function(s) s:sleep(0.7):linear(0.2):diffusealpha(1) end,
    OffCommand=function(self)
      self:diffusealpha(0)
    end;
	};

	t[#t+1] = Def.BitmapText{
		Font="_avenirnext lt pro bold/25px",
		Name = 'selectPlayerUID';
		InitCommand=function(s) s:zoom(0.9):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5")):diffusealpha(0):xy(5,-112) end,
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
		LoadActor(THEME:GetPathG("","MenuTimer frame"))..{ InitCommand=function(s) s:xy(11,25) end,};
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

	local GR = {
		{-1,-122, "Stream"}, --STREAM
		{-120,-43, "Voltage"}, --VOLTAGE
		{-108,72, "Air"}, --AIR
		{108,72, "Freeze"}, --FREEZE
		{120,-43, "Chaos"}, --CHAOS
	};

	for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
		t[#t+1] = LoadActor( THEME:GetPathG("ScreenSelectProfile", "GrooveRadar" ),1,0.2,0.2,0.2,0.5,Player,'single')..{
			Name = "GVR"..ToEnumShortString(Player).."S";
			  InitCommand=cmd(xy,0,120;zoom,1;diffusealpha,0;diffuse,PlayerColor(PLAYER_1));
			OnCommand=cmd(sleep,0.9;linear,0.05;diffusealpha,1;);
			OffCommand=cmd(sleep,0.2;linear,0.2;diffusealpha,0);
		};
		t[#t+1] = LoadActor( THEME:GetPathG("ScreenSelectProfile", "GrooveRadar" ),1,0.2,0.2,0.2,0.5,Player,'double')..{
			Name = "GVR"..ToEnumShortString(Player).."D";
			  InitCommand=cmd(xy,0,120;zoom,1;diffusealpha,0;diffuse,PlayerColor(PLAYER_2));
			OnCommand=cmd(sleep,0.9;linear,0.05;diffusealpha,1;);
			OffCommand=cmd(sleep,0.2;linear,0.2;diffusealpha,0);
		};

		for i,v in ipairs(GR) do
			t[#t+1] = Def.ActorFrame{
				Name="GVRD"..ToEnumShortString(Player).."Value_"..v[3],
				OnCommand=function(s)
					s:xy(v[1],v[2]+140)
					:diffusealpha(0):addx(-10):sleep(0.1+i/10):linear(0.1):diffusealpha(1):addx(10)
				end,
				OffCommand=function(s)
					s:sleep(i/20):linear(0.1):diffusealpha(0):addx(-10)
				end;
				Def.Sprite{
					Texture=THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler/RLabels"),
					OnCommand=function(s) s:animate(0):setstate(i-1) end,
				};
			};
			t[#t+1] = Def.BitmapText{
				Name="GVRD"..ToEnumShortString(Player).."SingleValue_"..v[3],
				Font="Common normal",
				InitCommand=function(s) s:halign(1):diffuse(PlayerColor(PLAYER_1)):strokecolor(Color.Black) end,
				OnCommand=function(s)
					s:xy(v[1]-20,v[2]+110)
					:diffusealpha(0):addx(-10):sleep(0.1+i/10):linear(0.1):diffusealpha(1):addx(10)
				end,
				OffCommand=function(s)
					s:sleep(i/20):linear(0.1):diffusealpha(0):addx(-10)
				end;
			};
			t[#t+1] = Def.BitmapText{
				Name="GVRD"..ToEnumShortString(Player).."DoubleValue_"..v[3],
				Font="Common normal",
				InitCommand=function(s) s:halign(1):diffuse(PlayerColor(PLAYER_2)):strokecolor(Color.Black) end,
				OnCommand=function(s)
					s:xy(v[1]+40,v[2]+110)
					:diffusealpha(0):addx(-10):sleep(0.1+i/10):linear(0.1):diffusealpha(1):addx(10)
				end,
				OffCommand=function(s)
					s:sleep(i/20):linear(0.1):diffusealpha(0):addx(-10)
				end;
			}
		end
	end
	return t;
end;

function UpdateInternal3(self, Player)

	local pn = (Player == PLAYER_1) and 1 or 2;
	local frame = self:GetChild(string.format('P%uFrame', pn));
	local seltext = frame:GetChild('SelectedProfileText');
	local joinframe = frame:GetChild('JoinFrame');
	local smallframe = frame:GetChild('SmallFrame');
	local bigframe = frame:GetChild('BigFrame');
	local selectPlayerUID = frame:GetChild('selectPlayerUID');
	local SelectTimer = frame:GetChild('SelectTimer');

	local selGVRS = (Player == PLAYER_1) and frame:GetChild('GVRP1S') or frame:GetChild('GVRP2S')
	local selGVRD = (Player == PLAYER_1) and frame:GetChild('GVRP1D') or frame:GetChild('GVRP2D')

	local selGVRValue_Stream = (Player==PLAYER_1) and frame:GetChild('GVRDP1Value_Stream') or frame:GetChild('GVRDP2Value_Stream');
	local selGVRValue_Voltage = (Player==PLAYER_1) and frame:GetChild('GVRDP1Value_Voltage') or frame:GetChild('GVRDP2Value_Voltage');
	local selGVRValue_Air = (Player==PLAYER_1) and frame:GetChild('GVRDP1Value_Air') or frame:GetChild('GVRDP2Value_Air');
	local selGVRValue_Freeze = (Player==PLAYER_1) and frame:GetChild('GVRDP1Value_Freeze') or frame:GetChild('GVRDP2Value_Freeze');
	local selGVRValue_Chaos = (Player==PLAYER_1) and frame:GetChild('GVRDP1Value_Chaos') or frame:GetChild('GVRDP2Value_Chaos');
	local selGVRSingleValue_Stream = (Player==PLAYER_1) and frame:GetChild('GVRDP1SingleValue_Stream') or frame:GetChild('GVRDP2SingleValue_Stream');
	local selGVRSingleValue_Voltage = (Player==PLAYER_1) and frame:GetChild('GVRDP1SingleValue_Voltage') or frame:GetChild('GVRDP2SingleValue_Voltage');
	local selGVRSingleValue_Air = (Player==PLAYER_1) and frame:GetChild('GVRDP1SingleValue_Air') or frame:GetChild('GVRDP2SingleValue_Air');
	local selGVRSingleValue_Freeze = (Player==PLAYER_1) and frame:GetChild('GVRDP1SingleValue_Freeze') or frame:GetChild('GVRDP2SingleValue_Freeze');
	local selGVRSingleValue_Chaos = (Player==PLAYER_1) and frame:GetChild('GVRDP1SingleValue_Chaos') or frame:GetChild('GVRDP2SingleValue_Chaos');

	local selGVRDoubleValue_Stream = (Player==PLAYER_1) and frame:GetChild('GVRDP1DoubleValue_Stream') or frame:GetChild('GVRDP2DoubleValue_Stream');
	local selGVRDoubleValue_Voltage = (Player==PLAYER_1) and frame:GetChild('GVRDP1DoubleValue_Voltage') or frame:GetChild('GVRDP2DoubleValue_Voltage');
	local selGVRDoubleValue_Air = (Player==PLAYER_1) and frame:GetChild('GVRDP1DoubleValue_Air') or frame:GetChild('GVRDP2DoubleValue_Air');
	local selGVRDoubleValue_Freeze = (Player==PLAYER_1) and frame:GetChild('GVRDP1DoubleValue_Freeze') or frame:GetChild('GVRDP2DoubleValue_Freeze');
	local selGVRDoubleValue_Chaos = (Player==PLAYER_1) and frame:GetChild('GVRDP1DoubleValue_Chaos') or frame:GetChild('GVRDP2DoubleValue_Chaos');
	--MyGrooveRadar
	local selPlayerUID;

	local PcntLarger;
	--local selMostCoursePlayed = frame:GetChild('selectedMostCoursePlayed');
	if GAMESTATE:IsHumanPlayer(Player) then
		frame:visible(true);
		if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
			local ind = SCREENMAN:GetTopScreen():GetProfileIndex(Player);
			local set_ind;
			local key_ind;

			if Player == PLAYER_1 then
				set_ind = {PLAYER_1,PLAYER_2};
				key_ind = {keyset[1],keyset[2]};
			else
				set_ind = {PLAYER_2,PLAYER_1};
				key_ind = {keyset[2],keyset[1]};
			end;
			if SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[1]) == SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[2]) then
				if key_ind[1] == 1 and key_ind[2] < 1 then
					if SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[1]) == profnum then
						SCREENMAN:GetTopScreen():SetProfileIndex(set_ind[2], SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[2])-1 );
					else SCREENMAN:GetTopScreen():SetProfileIndex(set_ind[2], SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[2])+1 );
					end
				end
			end
			if keyset[pn] < 1 then
				--using profile if any
				joinframe:visible(false);
				smallframe:visible(true);
				bigframe:visible(false);
				seltext:visible(true);
				SelectTimer:visible(true)
				selectPlayerUID:visible(true);
				selGVRValue_Stream:visible(true)
				selGVRValue_Voltage:visible(true)
				selGVRValue_Air:visible(true)
				selGVRValue_Freeze:visible(true)
				selGVRValue_Chaos:visible(true)
				selGVRSingleValue_Stream:visible(true)
				selGVRSingleValue_Voltage:visible(true)
				selGVRSingleValue_Air:visible(true)
				selGVRSingleValue_Freeze:visible(true)
				selGVRSingleValue_Chaos:visible(true)
				selGVRDoubleValue_Stream:visible(true)
				selGVRDoubleValue_Voltage:visible(true)
				selGVRDoubleValue_Air:visible(true)
				selGVRDoubleValue_Freeze:visible(true)
				selGVRDoubleValue_Chaos:visible(true)
			else
				joinframe:visible(false);
				smallframe:visible(true);
				bigframe:visible(false);
				seltext:visible(true);
				SelectTimer:visible(true)
				selectPlayerUID:visible(true);
				selGVRValue_Stream:visible(true)
				selGVRValue_Voltage:visible(true)
				selGVRValue_Air:visible(true)
				selGVRValue_Freeze:visible(true)
				selGVRValue_Chaos:visible(true)
				selGVRSingleValue_Stream:visible(true)
				selGVRSingleValue_Voltage:visible(true)
				selGVRSingleValue_Air:visible(true)
				selGVRSingleValue_Freeze:visible(true)
				selGVRSingleValue_Chaos:visible(true)
				selGVRDoubleValue_Stream:visible(true)
				selGVRDoubleValue_Voltage:visible(true)
				selGVRDoubleValue_Air:visible(true)
				selGVRDoubleValue_Freeze:visible(true)
				selGVRDoubleValue_Chaos:visible(true)
				frame:queuecommand("Off")
			end

			if ind > 0 then
				local profile = PROFILEMAN:GetLocalProfileFromIndex(ind-1);

				bigframe:visible(true);
				SelectTimer:visible(true)
				seltext:settext(ProfileInfoCache[ind].DisplayName);

				selPlayerUID = PROFILEMAN:GetLocalProfileFromIndex(ind-1):GetGUID();
				selectPlayerUID:settext(string.upper(string.sub(selPlayerUID,1,4).."-"..string.sub(selPlayerUID,5,8)));

				local RadarValueTableSingle = {};
				local RadarValueTableDouble = {};

				local profileID = PROFILEMAN:GetLocalProfileIDFromIndex(ind-1)
				local prefs = ProfilePrefs.Read(profileID)
				if SN3Debug then
					ProfilePrefs.Save(profileID)
				end

				----------Single Radar
				--Stream--
				RadarValueTableSingle[1] = MyGrooveRadar.GetRadarData(profileID, 'single', 'stream')
                selGVRSingleValue_Stream:settext(string.format("%0.0f", RadarValueTableSingle[1]*100));
                --Voltage--
                RadarValueTableSingle[2] = MyGrooveRadar.GetRadarData(profileID, 'single', 'voltage')
                selGVRSingleValue_Voltage:settext(string.format("%0.0f", RadarValueTableSingle[2]*100));
                --Air--
                RadarValueTableSingle[3] = MyGrooveRadar.GetRadarData(profileID, 'single', 'air')
                selGVRSingleValue_Air:settext(string.format("%0.0f", RadarValueTableSingle[3]*100));
				--Freeze--
                RadarValueTableSingle[4] = MyGrooveRadar.GetRadarData(profileID, 'single', 'freeze')
                selGVRSingleValue_Freeze:settext(string.format("%0.0f", RadarValueTableSingle[4]*100));
				--Chaos--
                RadarValueTableSingle[5] = MyGrooveRadar.GetRadarData(profileID, 'single', 'chaos')
                selGVRSingleValue_Chaos:settext(string.format("%0.0f", RadarValueTableSingle[5]*100));
        ----------Doubles Radar
        --Stream--
                RadarValueTableDouble[1] = MyGrooveRadar.GetRadarData(profileID, 'double', 'stream')
                selGVRDoubleValue_Stream:settext(string.format("%0.0f", RadarValueTableDouble[1]*100));
        --Voltage--
                RadarValueTableDouble[2] = MyGrooveRadar.GetRadarData(profileID, 'double', 'voltage')
                selGVRDoubleValue_Voltage:settext(string.format("%0.0f", RadarValueTableDouble[2]*100));
        --Air--
                RadarValueTableDouble[3] = MyGrooveRadar.GetRadarData(profileID, 'double', 'air')
                selGVRDoubleValue_Air:settext(string.format("%0.0f", RadarValueTableDouble[3]*100));
        --Freeze--
                RadarValueTableDouble[4] = MyGrooveRadar.GetRadarData(profileID, 'double', 'freeze')
                selGVRDoubleValue_Freeze:settext(string.format("%0.0f", RadarValueTableDouble[4]*100));
        --Chaos--
                RadarValueTableDouble[5] = MyGrooveRadar.GetRadarData(profileID, 'double', 'chaos')
				selGVRDoubleValue_Chaos:settext(string.format("%0.0f", RadarValueTableDouble[5]*100));
				
				-- Save the past values, which we will need later
				local pastValues = GetOrCreateChild(GAMESTATE:Env(), 'PastRadarValues')
				pastValues[Player] = DeepCopy(MyGrooveRadar.GetRadarTable(profileID))

			else
				if SCREENMAN:GetTopScreen():SetProfileIndex(Player, 1) then
					self:queuecommand('UpdateInternal2');
				else
					joinframe:visible(false);
					smallframe:visible(true);
					bigframe:visible(true);
					SelectTimer:visible(false)
					seltext:settext('No profile');
					selectPlayerUID:settext('------------');
					selGVRValue_Stream:visible(false)
					selGVRValue_Voltage:visible(false)
					selGVRValue_Air:visible(false)
					selGVRValue_Freeze:visible(false)
					selGVRValue_Chaos:visible(false)
					selGVRSingleValue_Stream:visible(false)
					selGVRSingleValue_Voltage:visible(false)
					selGVRSingleValue_Air:visible(false)
					selGVRSingleValue_Freeze:visible(false)
					selGVRSingleValue_Chaos:visible(false)
					selGVRDoubleValue_Stream:visible(false)
					selGVRDoubleValue_Voltage:visible(false)
					selGVRDoubleValue_Air:visible(false)
					selGVRDoubleValue_Freeze:visible(false)
					selGVRDoubleValue_Chaos:visible(false)
				end;
			end;
		else
			--using card
			if keyset[pn] < 1 then
				--using profile if any
				joinframe:visible(false);
				smallframe:visible(true);
				bigframe:visible(true);
				seltext:visible(true);
				SelectTimer:visible(true)
				selGVRValue_Stream:visible(true)
				selGVRValue_Voltage:visible(true)
				selGVRValue_Air:visible(true)
				selGVRValue_Freeze:visible(true)
				selGVRValue_Chaos:visible(true)
				selGVRSingleValue_Stream:visible(true)
				selGVRSingleValue_Voltage:visible(true)
				selGVRSingleValue_Air:visible(true)
				selGVRSingleValue_Freeze:visible(true)
				selGVRSingleValue_Chaos:visible(true)
				selGVRDoubleValue_Stream:visible(true)
				selGVRDoubleValue_Voltage:visible(true)
				selGVRDoubleValue_Air:visible(true)
				selGVRDoubleValue_Freeze:visible(true)
				selGVRDoubleValue_Chaos:visible(true)
			else
				joinframe:visible(false);
				smallframe:visible(true);
				bigframe:visible(true);
				seltext:visible(true);
				SelectTimer:visible(true)
				selectPlayerUID:visible(true);
				selGVRValue_Stream:visible(true)
				selGVRValue_Voltage:visible(true)
				selGVRValue_Air:visible(true)
				selGVRValue_Freeze:visible(true)
				selGVRValue_Chaos:visible(true)
				selGVRSingleValue_Stream:visible(true)
				selGVRSingleValue_Voltage:visible(true)
				selGVRSingleValue_Air:visible(true)
				selGVRSingleValue_Freeze:visible(true)
				selGVRSingleValue_Chaos:visible(true)
				selGVRDoubleValue_Stream:visible(true)
				selGVRDoubleValue_Voltage:visible(true)
				selGVRDoubleValue_Air:visible(true)
				selGVRDoubleValue_Freeze:visible(true)
				selGVRDoubleValue_Chaos:visible(true)
				frame:queuecommand("Off")
			end
			local text;
			if MEMCARDMAN:GetName(Player) ~= "" then
				text = MEMCARDMAN:GetName(Player)
			else
				text = "No Name"
			end
			seltext:settext(text);
			SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0);
		end;
	else
		joinframe:visible(true);
		seltext:visible(false);
		selectPlayerUID:visible(false);
		smallframe:visible(false);
		bigframe:visible(false);
		SelectTimer:visible(false)
		selGVRValue_Stream:visible(false)
		selGVRValue_Voltage:visible(false)
		selGVRValue_Air:visible(false)
		selGVRValue_Freeze:visible(false)
		selGVRValue_Chaos:visible(false)
		selGVRSingleValue_Stream:visible(false)
		selGVRSingleValue_Voltage:visible(false)
		selGVRSingleValue_Air:visible(false)
		selGVRSingleValue_Freeze:visible(false)
		selGVRSingleValue_Chaos:visible(false)
		selGVRDoubleValue_Stream:visible(false)
		selGVRDoubleValue_Voltage:visible(false)
		selGVRDoubleValue_Air:visible(false)
		selGVRDoubleValue_Freeze:visible(false)
		selGVRDoubleValue_Chaos:visible(false)
	end;
end;

local screen = Var("LoadingScreen")

--�D�{��
local t = Def.ActorFrame {

	StorageDevicesChangedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	CodeMessageCommand = function(self, params)
		if params.Name == 'Start' or params.Name == 'Center' then
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				if GAMESTATE:GetNumPlayersEnabled() > 1 then
					if params.PlayerNumber == 'PlayerNumber_P1' then
						keyset[1] = 1
						self:queuecommand('UpdateInternal2');
					else
						keyset[2] = 1
						self:queuecommand('UpdateInternal2');
					end
				end
				MESSAGEMAN:Broadcast("StartButton");
				if GAMESTATE:GetNumPlayersEnabled() == 1 then
					self:queuecommand('UpdateInternal4')
					MESSAGEMAN:Broadcast("StartButton");
				else
					if keyset[1] == 1 and keyset[2] == 1 then
						self:queuecommand('UpdateInternal4')
						MESSAGEMAN:Broadcast("StartButton");
					end
				end
			else
				if GAMESTATE:EnoughCreditsToJoin() then
					if GAMESTATE:GetCoinMode() == "CoinMode_Pay" then
						GAMESTATE:InsertCoin(-1)
					end
					SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -1);
					MESSAGEMAN:Broadcast("StartButton");
				end
			end;
		end;
		if params.Name == 'Up' or params.Name == 'Up2' or params.Name == 'DownLeft' then
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(params.PlayerNumber);
				if ind > 1 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, ind - 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton");
						self:queuecommand('UpdateInternal2');
					end;
				end;
			end;
		end;
		if params.Name == 'Down' or params.Name == 'Down2' or params.Name == 'DownRight' then
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(params.PlayerNumber);
				if ind > 0 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, ind + 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton");
						self:queuecommand('UpdateInternal2');
					end;
				end;
			end;
		end;
		if params.Name == 'Back' then
			if GAMESTATE:GetNumPlayersEnabled()==0 then
				SCREENMAN:GetTopScreen():Cancel();
			else
				MESSAGEMAN:Broadcast("BackButton");
				SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -2);
			end;
		end;
	end;

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
		UpdateInternal3(self, PLAYER_1);
		UpdateInternal3(self, PLAYER_2);
	end;

	UpdateInternal4Command=function(self)
		if PROFILEMAN:GetNumLocalProfiles() >= 1 then
			SCREENMAN:GetTopScreen():Finish();
		else
			SCREENMAN:GetTopScreen():StartTransitioningScreen('SM_GoToNextScreen')
		end
	end;
	children = {
		Def.Sprite{
			Texture=THEME:GetPathG("","ScreenSelectProfile/Cab outline");
			InitCommand=function(s) s:Center():diffusealpha(0) end,
			OnCommand=function(s) s:sleep(0.2):diffusealpha(0.5):sleep(0.1):diffusealpha(0):sleep(0.12):diffusealpha(0.2):linear(0.2):diffusealpha(1) end,
		};
		Def.ActorFrame {
			Name = 'P1Frame';
			InitCommand=function(s)
				if IsUsingWideScreen() then
					s:x(_screen.cx-480)
				else
					s:x(_screen.cx-400)
				end
				s:y(_screen.cy-2) 
			end,
      		OnCommand=function(s) s:zoomx(0):linear(0.2):zoomx(1) end,
			PlayerJoinedMessageCommand=function(self,param)
				if param.Player == PLAYER_1 then
					self:zoomx(1):zoomy(0.15):linear(0.175):zoomy(1)
				end;
			end;
			children = LoadPlayerStuff(PLAYER_1);
		};
		Def.ActorFrame {
			Name = 'P2Frame';
			InitCommand=function(s)
				if IsUsingWideScreen() then
					s:x(_screen.cx+480)
				else
					s:x(_screen.cx+400)
				end
				s:y(_screen.cy-2) 
			end,
			OnCommand=function(s) s:zoomx(0):linear(0.2):zoomx(1) end,
			PlayerJoinedMessageCommand=function(self,param)
				if param.Player == PLAYER_2 then
					self:zoomx(1):zoomy(0.15):linear(0.175):zoomy(1)
				end;
			end;
			children = LoadPlayerStuff(PLAYER_2);
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
			DirectionButtonMessageCommand=function(s) s:play() end,
		};
		LoadActor(THEME:GetPathG(screen, "Header")) .. {
  			Name = "Header",
		};
	};
};


return t;
