--　FullCombo base from moonlight by AJ 187

local pn = ...;
assert(pn);
local t = Def.ActorFrame{};
local Center1Player = PREFSMAN:GetPreference('Center1Player');
local NumPlayers = GAMESTATE:GetNumPlayersEnabled();
local NumSides = GAMESTATE:GetNumSidesJoined();
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
local st = GAMESTATE:GetCurrentStyle():GetStepsType();

local function GetPosition(pn)
--[[	if Center1Player and NumPlayers == 1 and NumSides == 1 then return SCREEN_CENTER_X; end;
	local strPlayer = (NumPlayers == 1) and "OnePlayer" or "TwoPlayers";
	local strSide = (NumSides == 1) and "OneSide" or "TwoSides";
	return THEME:GetMetric("ScreenGameplay","Player".. ToEnumShortString(pn) .. strPlayer .. strSide .."X");--]]
	if st == "StepsType_Dance_Double" or st == "StepsType_Dance_Solo" or Center1Player then return SCREEN_WIDTH/2;
	else
	local strPlayer = (NumPlayers == 1) and "OnePlayer" or "TwoPlayers";
	local strSide = (NumSides == 1) and "OneSide" or "TwoSides";
	return THEME:GetMetric("ScreenGameplay","Player".. ToEnumShortString(pn) .. strPlayer .. strSide .."X");
end;
end;

local function GradationWidth()
	if st == "StepsType_Dance_Double" then return (2);
	elseif st == "StepsType_Dance_Solo" then return (1.5);
	else return (1);
	end;
end;

local function DownGradationWidth()
	if st == "StepsType_Dance_Double" then return (SCREEN_WIDTH);
	elseif st == "StepsType_Dance_Solo" then return (384);
	else return (256);
	end;
end;

local function TextZoom()
	if st == "StepsType_Dance_Double" then return (1.61);
	elseif st == "StepsType_Dance_Solo" then return (1.3);
	else return (1);
	end;
end;

-- FullComboColor base from Default Extended by A.C
local function GetFullComboEffectColor(pss)
	local r;
		if pss:FullComboOfScore('TapNoteScore_W1') == true then
			r=color("#ffffff");
		elseif pss:FullComboOfScore('TapNoteScore_W2') == true then
			r=color("#fafc44");
		elseif pss:FullComboOfScore('TapNoteScore_W3') == true then
			r=color("#06fd32");
		elseif pss:FullComboOfScore('TapNoteScore_W4') == true then
			r=color("#3399ff");
		end;
	return r;
end;

-- FullComboColor2 Ring
local function GetFullComboEffectColor2(pss)
	local r;
		if pss:FullComboOfScore('TapNoteScore_W1') == true then
			r=color("#fefed0");
		elseif pss:FullComboOfScore('TapNoteScore_W2') == true then
			r=color("#f8fd6d");
		elseif pss:FullComboOfScore('TapNoteScore_W3') == true then
			r=color("#01e603");
		elseif pss:FullComboOfScore('TapNoteScore_W4') == true then
			r=color("#3399ff");
		end;
	return r;
end;

-- Sound
t[#t+1] = LoadActor("Combo_Splash") .. {
	OffCommand=function(self)
		if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
			self:play();
		end;
	end;
};

-- Parts
t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:x(GetPosition(pn)):diffusealpha(0) end,
	OffCommand = function(self)
		if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
			self:diffuse(GetFullComboEffectColor(pss));
		end;
	end;

	-- Note flash star
	Def.ActorFrame{
		InitCommand=function(self)
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y(SCREEN_CENTER_Y+152);
				self:addy(80);
			else
				self:y(SCREEN_CENTER_Y-160);
				self:addy(-80);
			end;
			self:diffusealpha(1);
		end;
		-- Left - down in single
		LoadActor("Star") .. {
			InitCommand=function(s) s:blend("BlendMode_Add"):diffusealpha(1) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(1);
					self:addx(-48);
					self:rotationz(-25);
					self:zoom(2);
					self:linear(0.5);
					self:zoom(0.3);
					self:rotationz(65);
					self:linear(0.25);
					self:zoom(0);
					self:rotationz(155);
				end;
			end;
		};
		-- Right - up in single
		LoadActor("Star") .. {
			InitCommand=function(s) s:blend("BlendMode_Add"):diffusealpha(1) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(1);
					self:addx(48);
					self:rotationz(35);
					self:zoom(2);
					self:linear(0.5);
					self:zoom(0.3);
					self:rotationz(-55);
					self:linear(0.25);
					self:zoom(0);
					self:rotationz(-145);
				end;
			end;
		};
		-- Left2 - left in single
		LoadActor("Star") .. {
			InitCommand=function(s) s:blend("BlendMode_Add"):diffusealpha(1) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(1);
					self:addx(-144);
					self:rotationz(-60);
					self:zoom(2);
					self:linear(0.5);
					self:zoom(0.3);
					self:rotationz(30);
					self:linear(0.25);
					self:zoom(0);
					self:rotationz(120);
				end;
			end;
		};
		-- Right2 - right in single
		LoadActor("Star") .. {
			InitCommand=function(s) s:blend("BlendMode_Add"):diffusealpha(1) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(1);
					self:addx(144);
					self:rotationz(90);
					self:zoom(2);
					self:linear(0.5);
					self:zoom(0.3);
					self:rotationz(0);
					self:linear(0.25);
					self:zoom(0);
					self:rotationz(-90);
				end;
			end;
		};
		-- Left3 Solo and Double
		LoadActor("Star") .. {
			InitCommand=function(s) s:blend("BlendMode_Add"):diffusealpha(1) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(1);
					self:addx(-240);
					self:rotationz(-15);
					self:zoom(2);
					self:linear(0.5);
					self:zoom(0.3);
					self:rotationz(75);
					self:linear(0.25);
					self:zoom(0);
					self:rotationz(165);
				end;
			end;
			Condition=st == "StepsType_Dance_Double" or st == "StepsType_Dance_Solo";
		};
		-- Right3 Solo and Double
		LoadActor("Star") .. {
			InitCommand=function(s) s:blend("BlendMode_Add"):diffusealpha(1) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(1);
					self:addx(240);
					self:rotationz(90);
					self:zoom(2);
					self:linear(0.5);
					self:zoom(0.3);
					self:rotationz(0);
					self:linear(0.25);
					self:zoom(0);
					self:rotationz(-90);
				end;
			end;
			Condition=st == "StepsType_Dance_Double" or st == "StepsType_Dance_Solo";
		};
		-- Left4 Double
		LoadActor("Star") .. {
			InitCommand=function(s) s:blend("BlendMode_Add"):diffusealpha(1) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(1);
					self:addx(-336);
					self:rotationz(-60);
					self:zoom(2);
					self:linear(0.5);
					self:zoom(0.3);
					self:rotationz(30);
					self:linear(0.25);
					self:zoom(0);
					self:rotationz(120);
				end;
			end;
			Condition=st == "StepsType_Dance_Double";
		};
		-- Right4 Double
		LoadActor("Star") .. {
			InitCommand=function(s) s:blend("BlendMode_Add"):diffusealpha(1) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(1);
					self:addx(336);
					self:rotationz(35);
					self:zoom(2);
					self:linear(0.5);
					self:zoom(0.3);
					self:rotationz(-55);
					self:linear(0.25);
					self:zoom(0);
					self:rotationz(-145);
				end;
			end;
			Condition=st == "StepsType_Dance_Double";
		};
	};

	-- Up gradation
	LoadActor("Down") .. {
		InitCommand=function(s) s:valign(1) end,
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
					self:y(SCREEN_BOTTOM);
					self:diffusealpha(0.5);
					self:zoomx(GradationWidth());
					self:zoomy(1);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(GradationWidth()+0.25);
					self:zoomy(2);
					self:linear(0.25);
					self:zoomx(GradationWidth());
					self:zoomy(1.5);
					self:diffusealpha(0);
				else
					self:y(SCREEN_TOP);
					self:diffusealpha(0.5);
					self:zoomx(GradationWidth());
					self:zoomy(-1);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(GradationWidth()+0.25);
					self:zoomy(-2);
					self:linear(0.25);
					self:zoomx(GradationWidth());
					self:zoomy(-1.5);
					self:diffusealpha(0);
				end;
			end;
		end;
	};

	-- Slim light
	Def.ActorFrame{
		InitCommand=function(self)
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y(SCREEN_CENTER_Y+152);
			else
				self:y(SCREEN_CENTER_Y-160);
			end;
		end;
		-- Center
		LoadActor("Slim") .. {
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(0.5);
					self:zoomx(0);
					self:zoomy(0.5);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(1);
					self:zoomy(1.75);
					self:linear(0.25);
					self:zoomx(0);
					self:zoomy(0.5);
					self:diffusealpha(0);
				end;
			end;
		};
		-- Left
		LoadActor("Slim") .. {
			InitCommand=function(s) s:addx(-64) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(0.5);
					self:zoomx(0);
					self:zoomy(0.5);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(1);
					self:zoomy(1.75);
					self:linear(0.25);
					self:zoomx(0);
					self:zoomy(0.5);
					self:diffusealpha(0);
				end;
			end;
		};
		-- Right
		LoadActor("Slim") .. {
			InitCommand=function(s) s:addx(64) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(0.5);
					self:zoomx(0);
					self:zoomy(0.5);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(1);
					self:zoomy(1.75);
					self:linear(0.25);
					self:zoomx(0);
					self:zoomy(0.5);
					self:diffusealpha(0);
				end;
			end;
		};
		-- Solo and Double left
		LoadActor("Slim") .. {
			InitCommand=function(s) s:addx(-128) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(0.5);
					self:zoomx(0);
					self:zoomy(0.5);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(1);
					self:zoomy(1.75);
					self:linear(0.25);
					self:zoomx(0);
					self:zoomy(0.5);
					self:diffusealpha(0);
				end;
			end;
			Condition=st == "StepsType_Dance_Double" or st == "StepsType_Dance_Solo";
		};
		-- Solo and Double right
		LoadActor("Slim") .. {
			InitCommand=function(s) s:addx(128) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(0.5);
					self:zoomx(0);
					self:zoomy(0.5);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(1);
					self:zoomy(1.75);
					self:linear(0.25);
					self:zoomx(0);
					self:zoomy(0.5);
					self:diffusealpha(0);
				end;
			end;
			Condition=st == "StepsType_Dance_Double" or st == "StepsType_Dance_Solo";
		};
		-- Double left
		LoadActor("Slim") .. {
			InitCommand=function(s) s:addx(-192) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(0.5);
					self:zoomx(0);
					self:zoomy(0.5);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(1);
					self:zoomy(1.75);
					self:linear(0.25);
					self:zoomx(0);
					self:zoomy(0.5);
					self:diffusealpha(0);
				end;
			end;
			Condition=st == "StepsType_Dance_Double";
		};
		-- Double right
		LoadActor("Slim") .. {
			InitCommand=function(s) s:addx(192) end,
			OffCommand=function(self)
				if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
					self:diffusealpha(0.5);
					self:zoomx(0);
					self:zoomy(0.5);
					self:linear(0.25);
					self:diffusealpha(0.25);
					self:zoomx(1);
					self:zoomy(1.75);
					self:linear(0.25);
					self:zoomx(0);
					self:zoomy(0.5);
					self:diffusealpha(0);
				end;
			end;
			Condition=st == "StepsType_Dance_Double";
		};
	};

	-- Star
	LoadActor("Star") .. {
		InitCommand=function(s) s:blend(Blend.Add) end,
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
					self:y(SCREEN_CENTER_Y+152);
					self:diffusealpha(1);
					self:zoomx(0);
					self:linear(0.1);
					self:zoomx(4);
					self:zoomy(1);
					self:linear(0.12);
					self:zoomx(1);
					self:addy(-120);
					self:linear(0.36);
					self:addy(-720);
				else
					self:y(SCREEN_CENTER_Y-160);
					self:diffusealpha(1);
					self:zoomx(0);
					self:linear(0.1);
					self:zoomx(4);
					self:zoomy(1);
					self:linear(0.12);
					self:zoomx(1);
					self:addy(120);
					self:linear(0.36);
					self:addy(720);
				end;
			end;
		end;
	};

	-- Down gradation
	LoadActor("Down") .. {
		InitCommand=function(s) s:valign(1) end,
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
					self:y(SCREEN_TOP);
					self:diffusealpha(0);
					self:sleep(0.48);
					self:diffusealpha(0.5);
					self:zoomto(64,0);
					self:linear(0.5);
					self:zoomto(DownGradationWidth()+52,-480);
					self:linear(0.3);
					self:diffusealpha(0);
					self:zoomto(DownGradationWidth(),-480);
				else
					self:y(SCREEN_BOTTOM);
					self:diffusealpha(0);
					self:sleep(0.48);
					self:diffusealpha(0.5);
					self:zoomto(64,0);
					self:linear(0.5);
					self:zoomto(DownGradationWidth()+52,480);
					self:linear(0.3);
					self:diffusealpha(0);
					self:zoomto(DownGradationWidth(),480);
				end;
			end;
		end;
	};

	-- Left gradation
	LoadActor("Gradation") .. {
		InitCommand=function(s) s:align(0,1) end,
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
					self:y(SCREEN_BOTTOM);
					self:addx(46);
					self:zoomx(0.75);
					self:zoomy(-0.5);
					self:diffusealpha(0);
					self:sleep(0.24);
					self:diffusealpha(1);
					self:linear(0.24);
					self:zoomy(-1);

					self:linear(0.5);
					self:zoomx(1);
					self:addx(-14);
					self:linear(0.1);
					self:addx(-28);
					self:linear(0.2);
					self:addx(-GradationWidth()*128-64);
					self:diffusealpha(0);
				else
					self:y(SCREEN_TOP);
					self:addx(46);
					self:zoomx(0.75);
					self:zoomy(0.5);
					self:diffusealpha(0);
					self:sleep(0.24);
					self:diffusealpha(1);
					self:linear(0.24);
					self:zoomy(1);

					self:linear(0.5);
					self:zoomx(1);
					self:addx(-14);
					self:linear(0.1);
					self:addx(-28);
					self:linear(0.2);
					self:addx(-GradationWidth()*128-64);
					self:diffusealpha(0);
				end;
			end;
		end;
	};

	-- Right gradation
	LoadActor("Gradation") .. {
		InitCommand=function(s) s:align(0,1) end,
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
					self:y(SCREEN_BOTTOM);
					self:addx(-46);
					self:zoomx(-0.75);
					self:zoomy(-0.5);
					self:diffusealpha(0);
					self:sleep(0.24);
					self:diffusealpha(1);
					self:linear(0.24);
					self:zoomy(-1);

					self:linear(0.5);
					self:zoomx(-1);
					self:addx(14);
					self:linear(0.1);
					self:addx(28);
					self:linear(0.2);
					self:addx(GradationWidth()*128+64);
					self:diffusealpha(0);
				else
					self:y(SCREEN_TOP);
					self:addx(-46);
					self:zoomx(-0.75);
					self:zoomy(0.5);
					self:diffusealpha(0);
					self:sleep(0.24);
					self:diffusealpha(1);
					self:linear(0.24);
					self:zoomy(1);

					self:linear(0.5);
					self:zoomx(-1);
					self:addx(14);
					self:linear(0.1);
					self:addx(28);
					self:linear(0.2);
					self:addx(GradationWidth()*128+64);
					self:diffusealpha(0);
				end;
			end;
		end;
	};

	-- Double only left gradation2
	LoadActor("Gradation") .. {
		InitCommand=function(s) s:halign(1) end,
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				self:y(SCREEN_CENTER_Y);
				self:addx(46);
				self:diffusealpha(0);
				self:zoomx(0.75);
				self:sleep(0.98);
				self:linear(0.1);
				self:diffusealpha(1);
				self:zoomx(1);
				self:addx(-14);
				self:linear(0.1);
				self:addx(-28);
				self:linear(0.2);
				self:addx(-GradationWidth()*128-64);
				self:diffusealpha(0);
			end;
		end;
		Condition=st == "StepsType_Dance_Double";
	};

	-- Double only right gradation2
	LoadActor("Gradation") .. {
		InitCommand=function(s) s:halign(1) end,
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				self:y(SCREEN_CENTER_Y);
				self:addx(-46);
				self:diffusealpha(0);
				self:zoomx(-0.75);
				self:sleep(0.98);
				self:linear(0.1);
				self:diffusealpha(1);
				self:zoomx(-1);
				self:addx(14);
				self:linear(0.1);
				self:addx(28);
				self:linear(0.2);
				self:addx(GradationWidth()*128+64);
				self:diffusealpha(0);
			end;
		end;
		Condition=st == "StepsType_Dance_Double";
	};

	-- Ring star
	LoadActor( "Star" ) .. {
		InitCommand=function(self)
			self:zoom(0);
			self:blend(Blend.Add);
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y(SCREEN_CENTER_Y+86);
			else
				self:y(SCREEN_CENTER_Y-98);
			end;
		end;
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				self:sleep(0.65);
				self:diffusealpha(1);
				self:zoomx(2);
				self:zoomy(0);
				self:linear(0.1);
				self:zoomy(2);
				self:rotationz(0);
				self:linear(0.5);
				self:zoom(1.2);
				self:diffusealpha(0.4);
				self:rotationz(90);
				self:linear(0.05);
				self:diffusealpha(0);
			end;
		end;
	};

	-- Ring star highlight
	LoadActor( "SStar" ) .. {
		InitCommand=function(self)
			self:zoom(0);
			self:blend(Blend.Add);
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y(SCREEN_CENTER_Y+86);
			else
				self:y(SCREEN_CENTER_Y-98);
			end;
		end;
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				self:diffuse(color("#ffffff"));
				self:sleep(0.65);
				self:diffusealpha(0.8);
				self:zoomx(2);
				self:zoomy(0);
				self:linear(0.1);
				self:zoomy(2);
				self:rotationz(0);
				self:linear(0.5);
				self:zoom(1.2);
				self:rotationz(90);
				self:diffusealpha(0.4);
				self:linear(0.05);
				self:diffusealpha(0);
			end;
		end;
	};


	-- Ring
	LoadActor( "Fullcombo01" ) .. {
		InitCommand=function(self)
			self:zoom(0);
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y(SCREEN_CENTER_Y+86);
			else
				self:y(SCREEN_CENTER_Y-98);
			end;
		end;
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				self:diffuse(GetFullComboEffectColor2(pss));
				self:sleep(0.65);
				self:zoomx(2);
				self:zoomy(0);
				self:linear(0.1);
				self:zoomy(2);
				self:rotationz(0);
				self:linear(0.5);
				self:zoom(1.2);
				self:rotationz(90);
				self:linear(0.15);
				self:zoomy(0);
				self:zoomx(0.5);
				self:diffusealpha(0);
			end;
		end;
	};

	-- Ring bar
	LoadActor( "Fullcombo02" ) .. {
		InitCommand=function(self)
			self:zoom(0);
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y(SCREEN_CENTER_Y+86);
			else
				self:y(SCREEN_CENTER_Y-98);
			end;
		end;
		OffCommand=function(self)
			if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
				self:diffuse(GetFullComboEffectColor2(pss));
				self:sleep(0.65);
				self:zoomx(4);
				self:zoomy(0);
				self:linear(0.1);
				self:zoomy(4);
				self:rotationz(0);
				self:linear(0.5);
				self:zoom(1.25);
				self:rotationz(-90);
				self:linear(0.15);
				self:zoomy(0);
				self:zoomx(0.5);
				self:diffusealpha(0);
			end;
		end;
	};

};

-- Star highlight
t[#t+1] = LoadActor("SStar") .. {
	InitCommand=function(s) s:x(GetPosition(pn)):diffusealpha(0):blend(Blend.Add) end,
	OffCommand=function(self)
		if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y(SCREEN_CENTER_Y+152);
				self:diffusealpha(0.95);
				self:zoomx(0);
				self:linear(0.1);
				self:zoomx(4);
				self:zoomy(1);
				self:linear(0.12);
				self:zoomx(1);
				self:addy(-120);
				self:linear(0.36);
				self:addy(-720);
			else
				self:y(SCREEN_CENTER_Y-160);
				self:diffusealpha(0.95);
				self:zoomx(0);
				self:linear(0.1);
				self:zoomx(4);
				self:zoomy(1);
				self:linear(0.12);
				self:zoomx(1);
				self:addy(120);
				self:linear(0.36);
				self:addy(720);
			end;
		end;
	end;
};

-- FullCombo text pictures
t[#t+1] = Def.ActorFrame{
	InitCommand=function(self)
		if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
			self:y(SCREEN_CENTER_Y+57);
		else
			self:y(SCREEN_CENTER_Y-65);
		end;
		self:x(GetPosition(pn));
	end;

	-- Marvelous FullCombo
	Def.Sprite{
		OffCommand=function(self)
			if pss:FullComboOfScore('TapNoteScore_W1') then
				self:Load(THEME:GetPathB("ScreenGameplay","overlay/FullCombo/FCM.png"));
				self:diffusealpha(0);
				self:rotationz(-5);
				self:sleep(0.6);
				self:diffusealpha(1);
				self:zoomy(0);
				self:linear(0.1);
				self:zoom(TextZoom());
				self:linear(0.5);
				self:zoom(TextZoom()*1.15);
				self:linear(0.05);
				self:diffusealpha(0.66);
				self:zoomx(TextZoom()*1.165);
				self:linear(0.1);
				self:zoomy(0);
				self:zoomx(TextZoom()*1.195);
				self:diffusealpha(0);
			elseif pss:FullComboOfScore('TapNoteScore_W2') then
				self:Load(THEME:GetPathB("ScreenGameplay","overlay/FullCombo/FCP.png"));
				self:diffusealpha(0);
				self:rotationz(-5);
				self:sleep(0.6);
				self:diffusealpha(1);
				self:zoomy(0);
				self:linear(0.1);
				self:zoom(TextZoom());
				self:linear(0.5);
				self:zoom(TextZoom()*1.15);
				self:linear(0.05);
				self:diffusealpha(0.66);
				self:zoomx(TextZoom()*1.165);
				self:linear(0.1);
				self:zoomy(0);
				self:zoomx(TextZoom()*1.195);
				self:diffusealpha(0);
			elseif pss:FullComboOfScore('TapNoteScore_W3') then
				self:Load(THEME:GetPathB("ScreenGameplay","overlay/FullCombo/FCGr.png"));
				self:diffusealpha(0);
				self:rotationz(-5);
				self:sleep(0.6);
				self:diffusealpha(1);
				self:zoomy(0);
				self:linear(0.1);
				self:zoom(TextZoom());
				self:linear(0.5);
				self:zoom(TextZoom()*1.15);
				self:linear(0.05);
				self:diffusealpha(0.66);
				self:zoomx(TextZoom()*1.165);
				self:linear(0.1);
				self:zoomy(0);
				self:zoomx(TextZoom()*1.195);
				self:diffusealpha(0);
			elseif pss:FullComboOfScore('TapNoteScore_W4') then
				self:Load(THEME:GetPathB("ScreenGameplay","overlay/FullCombo/FCGo.png"));
				self:diffusealpha(0);
				self:rotationz(-5);
				self:sleep(0.6);
				self:diffusealpha(1);
				self:zoomy(0);
				self:linear(0.1);
				self:zoom(TextZoom());
				self:linear(0.5);
				self:zoom(TextZoom()*1.15);
				self:linear(0.05);
				self:diffusealpha(0.66);
				self:zoomx(TextZoom()*1.165);
				self:linear(0.1);
				self:zoomy(0);
				self:zoomx(TextZoom()*1.195);
				self:diffusealpha(0);
			else
				self:visible(false);
			end;
		end;
	};
};

return t;
