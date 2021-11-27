local args = {...};
local pn = args[1];

local screen = SCREENMAN:GetTopScreen();

local function p(text)
    return text:gsub("%%", ToEnumShortString(pn));
end

local function base_x()
	if pn == PLAYER_1 then
		if IsUsingWideScreen() then
			return SCREEN_CENTER_X-566;
		else
			return SCREEN_CENTER_X-360;
		end
    elseif pn == PLAYER_2 then
        if IsUsingWideScreen() then
			return SCREEN_CENTER_X+566;
		else
			return SCREEN_CENTER_X+360;
		end
    else
        error("Pass a valid player number, dingus.",2)
    end
end

local screen = SCREENMAN:GetTopScreen();

local rownames = {
	"Speed",
	"Accel",
	"AppearancePlus",
	"Turn",
	"Step Zone",
	"Scroll",
	"NoteSkins",
	"Remove",
	"Freeze",
	"Jump",
	"Filter",
	"Gauge",
	"Characters",
	"Exit"
};

local function GetOptionName(screen, idx)
    return screen:GetOptionRow(idx-1):GetName();
end

local exitIndex = #rownames

function setting(self,screen)
	local index = screen:GetCurrentRowIndex(pn);
	local row = screen:GetOptionRow(index);
	local name = row:GetName();
	local choice = row:GetChoiceInRowWithFocus(pn);
	if name ~= "Exit" then
		if THEME:GetMetric( "ScreenOptionsMaster",name.."Explanation" ) then
			self:settext(THEME:GetString("OptionItemExplanations",name..tostring(choice)));
		else self:settext("");
		end;
	end;
end;

local speedmod_def = {
	x = { upper=20,   increment=0.05 },
	C = { upper=2000, increment=5 },
	M = { upper=2000, increment=5 }
}

local song = GAMESTATE:GetCurrentSong()

local ChangeSpeedMod = function(pn, direction)
	local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
	local speedmod, mode= GetSpeedModeAndValueFromPoptions(pn)
	local increment   = speedmod_def[mode].increment
	local upper_bound = speedmod_def[mode].upper

	-- increment/decrement and apply modulo to wrap around if we exceed the upper_bound or hit 0
	speedmod = ((speedmod+(increment*direction))-increment) % upper_bound + increment
	-- round the newly changed SpeedMod to the nearest appropriate increment
	speedmod = increment * math.floor(speedmod/increment + 0.5)
	SCREENMAN:SystemMessage(speedmod)

	setenv(pn.."speedmod")
	if mode == "x" then
		poptions:ScrollSpeed(speedmod)
	elseif mode == "C" then
		poptions:ScrollBPM(speedmod)
	elseif mode == "m" then
		poptions:MaxScrollBPM(speedmod)
	end
end


local function MakeRow(rownames, idx)
    --the first row begins with focus
    local hasFocus = idx == 1;
    local function IsExitRow()
        return idx == exitIndex;
    end
	return Def.ActorFrame{
		Name="Row"..idx;
		--InitCommand=function(s) s:y(-300+46*(idx-1)); end;
		InitCommand=function(s) s:y(-300+49*(idx-1)); end;
		OnCommand=function(self)
			self:playcommand(hasFocus and "GainFocus" or "LoseFocus");
		end;
		ChangeRowMessageCommand=function(self,param)
            if param.PlayerNumber ~= pn then return end
			if param.RowIndex+1 == idx then
                if not hasFocus then
                    hasFocus = true;
				    self:stoptweening();
				    self:queuecommand("GainFocus");
                end;
			elseif hasFocus then
                hasFocus = false;
				self:queuecommand("LoseFocus");
			end;
		end;
		Def.Quad{
			InitCommand=function(s) s:setsize(616,39) end,
			GainFocusCommand=function(self)
                if not IsExitRow() then
				    local screen = SCREENMAN:GetTopScreen();
				    if screen then
                        self:diffusealpha(0.25)
				    end;
                end;
			end;
			LoseFocusCommand=function(s) s:diffusealpha(0) end,
		};
		Def.Sprite{
			Texture="Exit";
			InitCommand=function(s) s:y(-340):zoomy(0):draworder(100) end,
			GainFocusCommand=function(self)
                if IsExitRow() then
                    self:decelerate(0.1):zoomy(1):diffusealpha(1);                
                end;
			end;
			LoseFocusCommand=function(self)
				self:accelerate(0.1):zoomy(0):diffusealpha(1)
			end;
			OffCommand=function(self)
				self:Load(THEME:GetPathB("","ScreenPlayerOptions underlay/OK.png"));
			end;
		};
		LoadFont("_avenirnext lt pro bold 25px")..{
			Name="Row Name";
            Text="";
			InitCommand=function(s) s:x(-260):uppercase(true):halign(0):zoom(0.9):strokecolor(color("0,0,0,0.25")) end,
			OnCommand=function(s) s:queuecommand("Set") end,
			SetCommand=function(self)
                if not IsExitRow() then
					local screen = SCREENMAN:GetTopScreen();
					local song = GAMESTATE:GetCurrentSong()
					if screen then
						if GetOptionName(screen,idx) == "Speed" then
							if song then
								local speedmult = screen:GetOptionRow(0):GetChoiceInRowWithFocus(pn)
								local speedstring = THEME:GetString("OptionItemNames","Speed"..speedmult)
								local speedsub = string.gsub(speedstring, "x", "")
								if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
									text = "?"
								else
									local dispBPMs = song:GetDisplayBpms()
									local BPM1Mod = math.floor(dispBPMs[1]*speedsub)
									if song:IsDisplayBpmConstant() then
										text = BPM1Mod
									else
										local BPM2Mod = math.floor(dispBPMs[2]*speedsub)
										text = BPM1Mod.." - "..BPM2Mod
									end
								end
								self:settext("Speed".." ("..text..")");
							else
								self:settext("Speed")
							end
						else
							self:settext(GetOptionName(screen, idx));
						end
                    else
                        --okay my theory here is if the top screen isn't ready
                        --yet for some reason we should keep trying until it is.
                        --is that right? -tertu
                        self:queuecommand("Set");
                    end;
                end;
			end;
			GainFocusCommand=function(s) s:finishtweening():diffuse(color("1,1,1,1")):linear(0.2):diffuse(color("#8080ff")) end,
			LoseFocusCommand=function(s) s:finishtweening():linear(0.2):diffuse(color("1,1,1,1")) end,
			[p"MenuLeft%MessageCommand"]=function(s) s:playcommand("Set") end,
			[p"MenuRight%MessageCommand"]=function(s) s:playcommand("Set") end,
		};
		LoadFont("_avenirnext lt pro bold 25px")..{
			InitCommand=function(s) s:x(200):uppercase(true):zoom(0.9):maxwidth(150) end,
			OnCommand=function(s) s:queuecommand("Set") end,
			SetCommand=function(self)
                if IsExitRow() then return end;
				local screen = SCREENMAN:GetTopScreen();
				if screen then
					local SongOrCourse;
					if GAMESTATE:IsCourseMode() then
						SongOrCourse = GAMESTATE:GetCurrentCourse()
					else
						SongOrCourse = GAMESTATE:GetCurrentSong()
					end
                    local name = GetOptionName(screen, idx);
                    local choice = screen:GetOptionRow(idx-1):GetChoiceInRowWithFocus(pn);
                    local function ChoiceToText(choice)
                        if THEME:GetMetric("ScreenOptionsMaster",name.."Explanation") then
                            return THEME:GetString("OptionItemNames",name..tostring(choice))
                        else
                            return ""
                        end
                    end
					--if name ~= "NoteSkins" and name ~= "Steps" and name ~= "Characters" and name ~= "Speed" then
					if name ~= "NoteSkins" and name ~= "Steps" and name ~= "Characters" then
                        --normal option, handle default choice coloring.
                        local ChoiceText = ChoiceToText(choice)
                        --for most options, 0 is the default choice, for Speed it is 3.
						if ChoiceText and ChoiceText == ChoiceToText(name == "Speed" and 3 or 0) 
                        then
							self:diffuse(color("#07ff07")):diffusetopedge(color("#79ec79"));
						else
							self:diffuse(color("1,1,1,1"));
						end;
						self:settext(ChoiceText);
					--[[elseif name == "Speed" then
						local speed, mode= GetSpeedModeAndValueFromPoptions(pn)
						self:settext(getenv(pn.."speedmod"))]]
					elseif name == "NoteSkins" then
						--self:settext(choice)
						--Wow that actually worked lol, add 1 to choice otherwise it shows the noteskin before the actual chosen one. -Inori
						self:settext(NOTESKIN:GetNoteSkinNames()[choice+1])
					elseif name == "Steps" then
						local difftable = SongOrCourse:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())
						local diff = difftable[choice+1]
						self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff:GetDifficulty())));
						self:diffuse(CustomDifficultyToColor(diff:GetDifficulty()))
						--self:diffuse(color(diffcolor[limited_choice]));
					elseif name == "Characters" then
						if choice == 0 then
							self:settext(THEME:GetString('OptionNames','Off'))
						elseif choice == 1 then
							self:settext("RANDOM")
						else
							self:settext(Characters.GetAllCharacterNames()[choice-1])
						end;
					else
						self:settext("");
					end;
				end;
			end;
	    [p"MenuLeft%MessageCommand"]=function(s) 
			local screen = SCREENMAN:GetTopScreen();
			if screen then
				local name = GetOptionName(screen, idx);
                 local choice = screen:GetOptionRow(idx-1):GetChoiceInRowWithFocus(pn);
				if name == "Speed" then
					ChangeSpeedMod(pn, -1)
				end
			end
			s:queuecommand("Set") 
		end,
		[p"MenuRight%MessageCommand"]=function(s)
			local screen = SCREENMAN:GetTopScreen();
			if screen then
				local name = GetOptionName(screen, idx);
                 local choice = screen:GetOptionRow(idx-1):GetChoiceInRowWithFocus(pn);
				if name == "Speed" then
					ChangeSpeedMod(pn, 1)
				end
			end
			s:queuecommand("Set")
		end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
		};
		Def.ActorFrame{
			InitCommand=function(s) s:x(200) end,
			GainFocusCommand=function(self)
                self:visible(not IsExitRow());
			end;
			LoseFocusCommand=function(s) s:visible(false) end,
			Def.Sprite{
				Texture="arrow",
				InitCommand=function(s) s:x(-80):diffusealpha(1):bounce():effectmagnitude(3,0,0):effectperiod(1) end,
			    [p"MenuLeft%MessageCommand"]=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
			};
			Def.Sprite{
				Texture="arrow",
				InitCommand=function(s) s:x(80):zoomx(-1):diffusealpha(1):bounce():effectmagnitude(-3,0,0):effectperiod(1) end,
				[p"MenuRight%MessageCommand"]=function(s) s:finishtweening():diffuse(color("#8080ff")):sleep(0.3):linear(0.4):diffuse(color("1,1,1,1")) end,
			};
		};
	};
end;

local RowList = {};
for i=1,#rownames do
	RowList[#RowList+1] = MakeRow(rownames[i],i)
end;

local t = Def.ActorFrame{
	InitCommand=function(s) s:xy(base_x(),SCREEN_CENTER_Y-7) end,
	OnCommand=function(s) s:player(pn):addy(SCREEN_HEIGHT):sleep(0.2):decelerate(0.2):addy(-SCREEN_HEIGHT) end,
	OffCommand=function(s) s:accelerate(0.2):addy(-SCREEN_HEIGHT) end,
	Def.ActorFrame{
		Def.Sprite{
			Texture="Backer",
		};
		Def.ActorFrame{
			InitCommand=function(s) s:y(-364) end,
			Def.Sprite{
				Texture="top",
			};
			Def.Sprite{
				Texture="color",
				InitCommand=function(s) s:y(12):diffuse(color("#75daff")) end,
			};
		};
	};
    Def.ActorFrame{children=RowList};
	Def.ActorFrame{
		InitCommand=function(s) s:y(396) end,
		OnCommand=function(s) s:diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):linear(0.05):diffusealpha(1) end,
		OffCommand=function(s) s:diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05) end,
		Def.Sprite{
			Texture="exp.png",
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold 25px",
	    	InitCommand=function(s) s:y(-6):maxwidth(400):zoom(1.3) end,
			BeginCommand=function(s) s:queuecommand("Set") end,
	    	SetCommand=function(self)
	      		local screen = SCREENMAN:GetTopScreen();
	      		if screen then
	        		setting(self,screen);
	      		end;
	    	end;
	    	[p"MenuLeft%MessageCommand"]=function(s) s:playcommand("Set") end,
	    	[p"MenuRight%MessageCommand"]=function(s) s:playcommand("Set") end,
	    	ChangeRowMessageCommand=function(s,param)
        	    if param.PlayerNumber == pn then s:playcommand "Set"; end;
        	end;
	  	};
	};
};

return t;
