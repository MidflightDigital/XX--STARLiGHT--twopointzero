function GetLocalProfiles()
	local t = {}

	local NoProfileCard = Def.ActorFrame{
		Def.Sprite{
			Texture=THEME:GetPathG("","ScreenSelectProfile/card.png"),
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/25px",
			Text="Guest",
			InitCommand=function(s) s:xy(-220,-15):halign(0):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5"))
				:maxwidth(400):zoom(1.1)
			end,
		};
	}
	t[#t+1] = NoProfileCard

	for p = 0,PROFILEMAN:GetNumLocalProfiles()-1 do
		local profile=PROFILEMAN:GetLocalProfileFromIndex(p);
		local ProfileCard = Def.ActorFrame{
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/card.png"),
			};
			Def.BitmapText{
				Font="_avenirnext lt pro bold/25px",
				Text=profile:GetDisplayName(),
				InitCommand=function(s) s:xy(-220,-15):halign(0):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5"))
					:maxwidth(400):zoom(1.1)
				end,
			};
			Def.BitmapText{
				Font="_avenirnext lt pro bold/25px",
				Text=string.upper(string.sub(profile:GetGUID(),1,4).."-"..string.sub(profile:GetGUID(),5,8)),
				InitCommand=function(s) s:xy(-220,18):halign(0):zoom(0.8):diffuse(color("#b5b5b5")):diffusetopedge(color("#e5e5e5"))
					:maxwidth(400)
				end,
			}
		};
		t[#t+1]=ProfileCard;
	end
	return t;
end

local profnum = PROFILEMAN:GetNumLocalProfiles();
local MyGrooveRadar = LoadModule "MyGrooveRadar.lua"

local ver = ""
if ThemePrefs.Get("SV") == "onepointzero" then
  ver = "1_"
end

function LoadCard(cColor,cColor2,Player,IsJoinFrame)
	local t = Def.ActorFrame{
		Def.Sprite{
			Texture=THEME:GetPathG("","ScreenSelectProfile/BG01");
			InitCommand=function(s) s:zoomy(0) end,
			OnCommand=function(s) s:sleep(0.3):linear(0.3):zoomy(1) end,
			OffCommand=function(s) s:sleep(IsJoinFrame and 0 or 0.3):linear(0.1):zoomy(0) end,
		};
		Def.ActorFrame{
			Name="Topper",
			InitCommand=function(s) s:y(-292) end,
			OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(-292) end,
			OffCommand=function(s)
				s:sleep(IsJoinFrame and 0 or 0.3):linear(0.1):y(0):sleep(0):diffusealpha(0)
			end,
			Def.Sprite{
				InitCommand=function(s) s:valign(1) end,
				OnCommand=function(s)
					if ver == "1_" then
						s:Load(THEME:GetPathG("","ScreenSelectProfile/1_BGTOP"))
					else
						s:Load(THEME:GetPathG("","ScreenSelectProfile/BGTOP_"..ToEnumShortString(Player)))
					end
				end,
			};
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/TOP-LINE"),
				Condition=ver == "1_",
				InitCommand=function(self)
				  self:valign(1):diffuse(PlayerColor(Player));
				end;
			  };
			Def.BitmapText{
				Font="_handel gothic itc std Bold/18px";
				Condition=ver == "1_",
				InitCommand=function(self)
				  self:diffuse(PlayerColor(Player)):zoom(1.3):y(-26)
				  if Player == PLAYER_1 then
					self:settext("PLAYER 1")
				  else
					self:settext("PLAYER 2")
				  end;
				end;
			  };
		};
		Def.ActorFrame{
			Name="Bottom",
			OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(286) end,
			OffCommand=function(s)
				s:sleep(IsJoinFrame and 0 or 0.3):linear(0.1):y(0):sleep(0):diffusealpha(0)
			end,
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/"..ver.."BGBOTTOM"),
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

function LoadPlayerStuff(Player)
	local t = {};
	local pn = (Player == PLAYER_1) and 1 or 2

	t[#t+1] = Def.ActorFrame{
		Name = 'JoinFrame';
		LoadCard(Color('Outline'),Color.Black,Player,true);
		Def.Sprite{
			Texture=THEME:GetPathG("","ScreenSelectProfile/ScreenSelectProfile Start"),
			InitCommand=function(s) s:zoomy(0):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#A5A6A5")) end,
			OnCommand=function(s) s:zoomy(0):zoomx(0):sleep(0.5):linear(0.1):zoomx(1):zoomy(1) end,
			OffCommand=function(s) s:linear(0.1):zoomy(0):diffusealpha(0) end,
		}
	};

	t[#t+1] = Def.ActorFrame{
		Name="BigFrame";
		LoadCard(PlayerColor(),Color.White,Player,false)
	};
	t[#t+1] = Def.ActorFrame {
		Name = 'SmallFrame';
		InitCommand=function(s) s:y(120):hibernate(0.2) end,
		OnCommand=function(s) s:zoom(0):rotationz(-360):decelerate(0.4):zoom(1):rotationz(0) end,
        OffCommand=function(s) s:decelerate(0.3):rotationz(-360):zoom(0) end,
		Def.Sprite{Texture=THEME:GetPathG("","_shared/Radar/"..ver.."GrooveRadar base"),};
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/Radar/"..ver.."sweep"),
			InitCommand = function(s) s:zoom(1.275):spin():effectmagnitude(0,0,100) end,
        	OnCommand = function(s) s:hibernate(0.4) end,
        	OffCommand=function(s) s:finishtweening():sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
		};
	};
	t[#t+1] = Def.BitmapText{
		Font="_avenirnext lt pro bold/25px",
		Name = 'SelectedProfileText';
    	InitCommand=function(self) self:y(120):diffusealpha(0):maxwidth(400):strokecolor(Alpha(Color.Black,0.5)) end,
		OnCommand=function(s) s:sleep(0.7):linear(0.2):diffusealpha(0.75) end,
    	OffCommand=function(self)
      		self:diffusealpha(0)
    	end;
	};
	t[#t+1] = Def.ActorScroller{
		Name = 'Scroller';
		NumItemsToDraw=4;
		InitCommand=function(s) s:y(-150):SetFastCatchup(true):SetMask(300,58):SetSecondsPerItem(0.15)
			:diffusealpha(0):SetDrawByZPosition(true)
		end,
		OnCommand=function(s) s:sleep(0.5):diffusealpha(1) end,
   		OffCommand=function(self)
      		self:diffusealpha(0)
    	end;
		TransformFunction=function(s,o,i,n)
			local focus = scale(math.abs(o),0,5,1,0);
			s:visible(false)
			s:x(math.floor(o*10))
			s:y(math.floor(o*20))
			s:z(-math.abs(o))
		end,
		OffCommand=function(s) s:linear(0.3):diffusealpha(0) end,
		children = GetLocalProfiles()
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
		Def.Sprite{
			Texture=THEME:GetPathG("","MenuTimer frame"),
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

	local GR = {
		{-1,-122, "Stream"}, --STREAM
		{-120,-43, "Voltage"}, --VOLTAGE
		{-108,72, "Air"}, --AIR
		{108,72, "Freeze"}, --FREEZE
		{120,-43, "Chaos"}, --CHAOS
	};

	for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
		t[#t+1] = loadfile(THEME:GetPathG("ScreenSelectProfile", "GrooveRadar" ))(1,0.2,0.2,0.2,0.5,Player,'single')..{
			Name = "GVR"..ToEnumShortString(Player).."S";
			InitCommand=function(s) s:xy(0,120):zoom(1):diffusealpha(0):diffuse(PlayerColor(PLAYER_1)) end,
			OnCommand=function(s) s:sleep(0.9):linear(0.05):diffusealpha(1) end,
			OffCommand=function(s) s:sleep(0.2):linear(0.2):diffusealpha(0) end,
		};
		t[#t+1] = loadfile(THEME:GetPathG("ScreenSelectProfile", "GrooveRadar" ))(1,0.2,0.2,0.2,0.5,Player,'double')..{
			Name = "GVR"..ToEnumShortString(Player).."D";
			InitCommand=function(s) s:xy(0,120):zoom(1):diffusealpha(0):diffuse(PlayerColor(PLAYER_2)) end,
			OnCommand=function(s) s:sleep(0.9):linear(0.05):diffusealpha(1) end,
			OffCommand=function(s) s:sleep(0.2):linear(0.2):diffusealpha(0) end,
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
					Texture=THEME:GetPathG("","_shared/Radar/"..ver.."Rlabels"),
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
end

-- here's a (messy) fix for one player's selection ending the screen,
-- at least until this whole thing is rewritten to be... Not this
local ready = {}
local function AllPlayersReady()
	for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
		if not ready[pn] then
			return false
		end
	end
	-- if it hasn't returned false by now, surely it must be true, right? RIGHT???
	return true
end

function UpdateInternal3(self, Player)
	local pn = (Player == PLAYER_1) and 1 or 2;
	local frame = self:GetChild(string.format('P%uFrame', pn));
	local scroller = frame:GetChild('Scroller');
	local joinframe = frame:GetChild('JoinFrame');
	local smallframe = frame:GetChild('SmallFrame');
	local bigframe = frame:GetChild('BigFrame');
	local seltext = frame:GetChild('SelectedProfileText')
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

	if GAMESTATE:IsHumanPlayer(Player) then
		frame:visible(true);
		if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
			local ind = SCREENMAN:GetTopScreen():GetProfileIndex(Player);
			local set_ind;

			if Player == PLAYER_1 then
				set_ind = {PLAYER_1,PLAYER_2};
			else
				set_ind = {PLAYER_2,PLAYER_1};
			end;
			--using profile if any
			if SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[1]) == SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[2]) then
				if ready[PLAYER_1] and not ready[PLAYER_2] then
					if SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[1]) == profnum then
						SCREENMAN:GetTopScreen():SetProfileIndex(set_ind[2], SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[2])-1 );
					else
						SCREENMAN:GetTopScreen():SetProfileIndex(set_ind[2], SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[2])+1 );
					end
				elseif ready[PLAYER_2] and not ready[PLAYER_1] then
					if SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[2]) == profnum then
						SCREENMAN:GetTopScreen():SetProfileIndex(set_ind[1], SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[1])-1 );
					else
						SCREENMAN:GetTopScreen():SetProfileIndex(set_ind[1], SCREENMAN:GetTopScreen():GetProfileIndex(set_ind[1])+1 );
					end
				end
			end
			joinframe:visible(false);
			smallframe:visible(true);
			bigframe:visible(true);
			seltext:visible(true);
			scroller:visible(true);
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
			
			if ind > 0 then
				scroller:SetDestinationItem(ind);
				seltext:settext(PROFILEMAN:GetLocalProfileFromIndex(ind-1):GetDisplayName());

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
				if SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0) then
					scroller:SetDestinationItem(0);
					smallframe:visible(false);
					seltext:settext('No profile');
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
				else
					joinframe:visible(true);
					smallframe:visible(false);
					bigframe:visible(false);
					scroller:visible(false);
					seltext:settext('No profile');
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
		else
			--using card
			smallframe:visible(false);
			scroller:visible(false);
			seltext:settext('CARD');
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
			SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0)
		end;
	else
		joinframe:visible(true);
		scroller:visible(false);
		seltext:visible(false);
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

local t = Def.ActorFrame{
	StorageDevicesChangedMessageCommand=function(s,p)
		s:queuecommand('UpdateInternal2');
	end,
	CodeMessageCommand=function(s,p)
		if p.Name == "Start" or p.Name == "Center" then
			MESSAGEMAN:Broadcast("StartButton")
			if not GAMESTATE:IsHumanPlayer(p.PlayerNumber) then
				if GAMESTATE:EnoughCreditsToJoin() then
					if GAMESTATE:GetCoinMode() == "CoinMode_Pay" then
						GAMESTATE:InsertCoin(-1)
					end
					SCREENMAN:GetTopScreen():SetProfileIndex(p.PlayerNumber, -1);
					s:queuecommand("UpdateInternal2")
				end
			else
				ready[p.PlayerNumber] = true
				s:queuecommand('UpdateInternal2');
				if AllPlayersReady() then
					if SCREENMAN:GetTopScreen():GetProfileIndex(p.PlayerNumber) == 0 then
						SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
					else
						SCREENMAN:GetTopScreen():Finish()
					end
				end
			end
		end
		if p.Name == 'Up' or p.Name == 'Up2' or p.Name == 'Up3' or p.Name == 'Up4' or p.Name == 'DownLeft' then
			if GAMESTATE:IsHumanPlayer(p.PlayerNumber) and not ready[p.PlayerNumber] then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(p.PlayerNumber)
				if ind >= 1 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(p.PlayerNumber,ind-1) then
						MESSAGEMAN:Broadcast("DirectionButton")
						s:queuecommand("UpdateInternal2")
					end
				end
			end
		end
		if p.Name == 'Down' or p.Name == 'Down2' or p.Name == 'Down3' or p.Name == 'Down4' or p.Name == 'DownRight' then
			if GAMESTATE:IsHumanPlayer(p.PlayerNumber) and not ready[p.PlayerNumber] then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(p.PlayerNumber);
				if ind >= 0 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(p.PlayerNumber, ind + 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton");
						s:queuecommand('UpdateInternal2');
					end;
				end;
			end;
		end;
		if p.Name == 'Back' then
			if GAMESTATE:GetNumPlayersEnabled()==0 then
				SCREENMAN:GetTopScreen():Cancel();
			else
				MESSAGEMAN:Broadcast("BackButton")
				-- Allow... erm... un-readying a player.
				if ready[p.PlayerNumber] then
					ready[p.PlayerNumber] = false
				else
					SCREENMAN:GetTopScreen():SetProfileIndex(p.PlayerNumber, -2);
				end
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

	children = {
		Def.Sprite{
			Texture=THEME:GetPathG("","ScreenSelectProfile/Cab outline");
			InitCommand=function(s) s:Center():diffusealpha(0) end,
			OnCommand=function(s) s:sleep(0.2):diffusealpha(0.5):sleep(0.1):diffusealpha(0):sleep(0.12):diffusealpha(0.2):linear(0.2):diffusealpha(1) end,
			OffCommand=function(s) s:diffusealpha(0):sleep(0.1):diffusealpha(0.5):sleep(0.1):diffusealpha(0):sleep(0.12):diffusealpha(1):linear(0.2):diffusealpha(0) end,
		};
		Def.ActorFrame{
			Name="P1Frame";
			InitCommand=function(s) s:xy(IsUsingWideScreen() and _screen.cx-480 or _screen.cx-400,_screen.cy-2) end,
			OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
			children = LoadPlayerStuff(PLAYER_1);
		};
		Def.ActorFrame{
			Name="P2Frame";
			InitCommand=function(s) s:xy(IsUsingWideScreen() and _screen.cx+480 or _screen.cx+400,_screen.cy-2) end,
			OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
			children = LoadPlayerStuff(PLAYER_2);
		};
		-- sounds
		Def.Sound{
			File=THEME:GetPathS("Common","start"),
			StartButtonMessageCommand=function(self) self:play() end;
		};
		Def.Sound{
			File=THEME:GetPathS("Common","cancel"),
			BackButtonMessageCommand=function(self) self:play() end;
		};
		Def.Sound{
			File=THEME:GetPathS("Common","value"),
			DirectionButtonMessageCommand=function(self) self:play() end;
		};
		--[[Def.Quad{
			InitCommand=function(s) s:FullScreen():diffuse(Color.Black) end,
			OnCommand=function(s)
				s:diffusealpha(1):sleep(0.1):linear(0.2):diffusealpha(0)
			end,
		}]]
	};
}

return t;