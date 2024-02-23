--This file uses AddChildFromPath since I need to load as many actors as there are steps
--Thus there are no constructors, it will just take the current song and display for as many
--joined players. And do a lot of crazy stuff to handle two actorframes.
local Y_SPACING = 140
local Radar = LoadModule "DDR Groove Radar.lua"


--local song = SONGMAN:FindSong("Ace For Aces")
local song = GAMESTATE:GetCurrentSong()
local songSteps = SongUtil.GetPlayableSteps(song)

assert(#songSteps>0,"Hey idiot, this song has no steps for your game mode")
local numDiffs = #songSteps
--Is defining this even necessary?
local center = math.ceil(numDiffs/2)

--This is the variable for holding the frame after it's compiled
local frame = {
	["PlayerNumber_P1"] = nil,
	["PlayerNumber_P2"] = nil
}
--Take a wild guess.
local selection = {
	["PlayerNumber_P1"] = nil,
	["PlayerNumber_P2"] = nil
}

local compareSteps = LoadModule "StepsUtil.lua".CompareSteps
for pn in EnabledPlayers() do
	local playerSteps = GAMESTATE:GetCurrentSteps(pn)
	for i=1,#songSteps do
		if compareSteps(playerSteps, songSteps[i]) == 0 then
			selection[pn] = i
		end
	end
	assert(selection[pn], "couldn't set selection for "..pn)
end

local function adjustScrollerFrame(pn)
	for i=1,numDiffs do
		local is_focus = (i == selection[pn])
		frame[pn]:GetChild(i):stoptweening():decelerate(.2):zoom(is_focus and 1.2 or 1):GetChild("Highlight"):visible(is_focus)
	end;
end;

local function genScrollerFrame(player)
	local f = Def.ActorFrame{}
	for i,steps in ipairs(songSteps) do
		local diff = steps:GetDifficulty();
		f[i] = Def.ActorFrame{
			Name=i;
			InitCommand=function(s) s:y((i-center)*Y_SPACING) end,
			["OK"..player.."MessageCommand"]=function(s)
				if i ~= selection[player] then
					s:diffuse(color("0.3,0.3,0.3,1"))
				end
			end,
			OffCommand=function(s) s:playcommand("OK"..player) end,
			--Def.Sprite{ Texture="dummy"; };
			Def.Sprite{
				Texture=THEME:GetString("CustomDifficulty",ToEnumShortString(diff));
			};
			Def.BitmapText{
				Font="_avenirnext lt pro bold/46px",
				Text=IsMeterDec(steps:GetMeter()),
				InitCommand=function(s)
					s:y(-15):diffuse(CustomDifficultyTwoPartToColor(diff))
				end,
			};
			Def.BitmapText{
				Font="CFBPMDisplay",
				Text=steps:GetAuthorCredit(),
				InitCommand=function(s)
					s:y(-40):diffuse(CustomDifficultyTwoPartToColor(diff)):maxwidth(200):zoom(0.65)
				end,
			};
			Def.Sprite{
				Texture="cursor";
				Name="Highlight";
				InitCommand=function(s) s:visible(i==selection[player]):diffuseramp():effectcolor1(Alpha(PlayerColor(player),0)):effectcolor2(Alpha(PlayerColor(player),1)):effectclock("beatnooffset") end,
				["OK"..player.."MessageCommand"]=function(s)
					s:stopeffect():diffuse(PlayerColor(player))
				end,
			};
			Def.Sprite{
				Texture="lamp",
				InitCommand=function(s) s:queuecommand("Set"):visible(false) end,
				SetCommand=function(s)
					local profile;
					local st = GAMESTATE:GetCurrentStyle():GetStepsType()
					local steps = song:GetOneSteps(st,diff)

					if PROFILEMAN:IsPersistentProfile(player) then
						profile = PROFILEMAN:GetProfile(player)
					else
						profile = PROFILEMAN:GetMachineProfile()
					end

					local scorelist = profile:GetHighScoreList(song,steps)
					local scores = scorelist:GetHighScores()
					local topscore;

					if scores[1] then
						topscore = scores[1];
						assert(topscore);
                		local misses = topscore:GetTapNoteScore("TapNoteScore_Miss")+topscore:GetTapNoteScore("TapNoteScore_CheckpointMiss")
                		local boos = topscore:GetTapNoteScore("TapNoteScore_W5")
                		local goods = topscore:GetTapNoteScore("TapNoteScore_W4")
                		local greats = topscore:GetTapNoteScore("TapNoteScore_W3")
                		local perfects = topscore:GetTapNoteScore("TapNoteScore_W2")
                		local marvelous = topscore:GetTapNoteScore("TapNoteScore_W1")
						if (misses+boos) == 0 and scores[1]:GetScore() > 0 and (marvelous+perfects)>0 then
							if (greats+perfects) == 0 then
								s:diffuse(FullComboEffectColor["JudgmentLine_W1"]):glowblink():effectperiod(0.20)
							elseif greats == 0 then
								s:diffuse(GameColor.Judgment["JudgmentLine_W2"]):glowshift();
							elseif (misses+boos+goods) == 0 then
								s:diffuse(GameColor.Judgment["JudgmentLine_W3"]):stopeffect();
							elseif (misses+boos) == 0 then
								s:diffuse(GameColor.Judgment["JudgmentLine_W4"]):stopeffect();
							end;
							s:visible(true)
						else
							if topscore:GetGrade() ~= 'Grade_Failed' then
								s:visible(true):diffuse(color("#f70b9e"))
							else
								s:visible(true):diffuse(color("#555452"))
							end
						end
					else
						s:visible(false)
					end
				end
			},
			Def.Sprite{
				Texture="../_ShockArrow/ShockArrowText",
				InitCommand=function(s) s:y(10):visible(false):zoom(0.3):glowblink():effectcolor1(color("1,1,1,0.6")):effectcolor2(color("1,1,1,0")):effectperiod(0.15):queuecommand("Set") end,
				SetCommand=function(s)
					local song = GAMESTATE:GetCurrentSong()
					local st = GAMESTATE:GetCurrentStyle():GetStepsType()
					if song then
						local steps = song:GetOneSteps(st,diff)
						if steps then
							if steps:GetRadarValues(player):GetValue('RadarCategory_Mines') >= 1 then
								s:visible(true)
							else
								s:visible(false)
							end
						else
							s:visible(false)
						end
					else
						s:visible(false)
					end
				end,
			}
		};
	end;
	return f;
end;

local function RadarPanel(pn)
    local GR = {
        {-1,-122, "Stream"}, --STREAM
        {-120,-43, "Voltage"}, --VOLTAGE
        {-108,72, "Air"}, --AIR
        {108,72, "Freeze"}, --FREEZE
        {120,-43, "Chaos"}, --CHAOS
    };
    local t = Def.ActorFrame{
		StartSelectingStepsMessageCommand=function(s) s:queuecommand("Set") end,
		ChangeStepsMessageCommand=function(s) s:queuecommand("Set") end,
	};
    t[#t+1] = Def.ActorFrame{
        Def.ActorFrame{
            Name="Radar",
            Def.Sprite{
                Texture=THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler/GrooveRadar base.png"),
            };
            Def.Sprite{
                Texture=THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler/sweep.png"),
                InitCommand = function(s) s:zoom(1.35):spin():effectmagnitude(0,0,100) end,
            };
            Radar.create_ddr_groove_radar("radar",0,0,pn,125,Alpha(PlayerColor(pn),0.25));
        };
    };
    for i,v in ipairs(GR) do
        t[#t+1] = Def.ActorFrame{
            InitCommand=function(s)
                s:xy(v[1],v[2])
            end;
            Def.Sprite{
                Texture=THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler/RLabels"),
                InitCommand=function(s) s:animate(0):setstate(i-1) end,
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/20px";
                SetCommand=function(s)
                    local song = GAMESTATE:GetCurrentSong();
                    if song then
                        local steps = GAMESTATE:GetCurrentSteps(pn)
                        local value = lookup_ddr_radar_values(song, steps, pn)[i]
                        s:settext(math.floor(value*100+0.5))
                    else
                        s:settext("")
                    end
                    s:strokecolor(color("#1f1f1f")):y(28)
                end,
            };
        };
    end
    return t
end


local keyset={false,false}

local function DiffInputHandler(event)
	local pn= event.PlayerNumber
	local button = event.button
	if event.type == "InputEventType_Release" then return end
	--[=[--SOUND:PlayOnce(THEME:GetPathS("_MusicWheel","Change"),true)
	if (button == "MenuUp" or button == "MenuLeft") and selection[pn] > 1 and GAMESTATE:IsPlayerEnabled(pn) and keyset[pn] ~= 1 then
		SOUND:PlayOnce(THEME:GetPathS("","ScreenSelectMusic difficulty harder"));
		selection[pn] = selection[pn] - 1
		GAMESTATE:SetCurrentSteps(pn,songSteps[selection[pn]])
		GAMESTATE:SetPreferredDifficulty(pn,songSteps[selection[pn]]:GetDifficulty())
		adjustScrollerFrame(pn)
		MESSAGEMAN:Broadcast("TwoDiffLeft"..pn)
		return false;
	elseif (button == "MenuDown" or button == "MenuRight") and selection[pn] < numDiffs and GAMESTATE:IsPlayerEnabled(pn) and keyset[pn] ~= 1 then
		SOUND:PlayOnce(THEME:GetPathS("","ScreenSelectMusic difficulty harder"));
		selection[pn] = selection[pn] + 1
		GAMESTATE:SetCurrentSteps(pn,songSteps[selection[pn]])
		GAMESTATE:SetPreferredDifficulty(pn,songSteps[selection[pn]]:GetDifficulty())
		MESSAGEMAN:Broadcast("TwoDiffRight"..pn)
		adjustScrollerFrame(pn)
		return true;
	--]=]
	--elseif (button == "Start") and GAMESTATE:IsPlayerEnabled(pn) then
	if (button == "Start") and GAMESTATE:IsPlayerEnabled(pn) and not keyset[pn] and getenv("OPList") == 0 then
		keyset[pn] = true
		MESSAGEMAN:Broadcast("OK"..pn)
	end;
end;

local t = Def.ActorFrame{
	Name="TwoPartDiff",
	InitCommand=function(s) s:visible(ThemePrefs.Get("ShowDiffSelect")) end,
	OnCommand=function(s) s:playcommand("Off") end,
	StartSelectingStepsMessageCommand=function(s)
		s:sleep(0.5):queuecommand("Add")
		diffisopen = 1
	end,
	SongUnchosenMessageCommand=function(s)
		s:playcommand("Remove")
	end,
	RemoveCommand=function(s) SCREENMAN:GetTopScreen():RemoveInputCallback(DiffInputHandler)
		diffisopen = 0
		setenv("OPStop",1)
	end,
	AddCommand=function(s)
		SCREENMAN:GetTopScreen():AddInputCallback(DiffInputHandler)
		setenv("OPStop",0)
	end,
	OffCommand=function(s)
		s:playcommand("Remove")
	end,
	Def.Sprite{
		Texture="base.png",
		InitCommand=function(s) s:visible(false):Center() end,
	}
}

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s)
			s:xy(pn==PLAYER_1 and SCREEN_LEFT+(SCREEN_WIDTH/4.9) or SCREEN_RIGHT-(SCREEN_WIDTH/4.9),_screen.cy+30)
		end,
		ChangeStepsMessageCommand = function(_, param)
			if param.Player ~= pn then return end
			local dir = param.Direction
			selection[pn] = selection[pn] + dir
			adjustScrollerFrame(pn)

			local msg
			if dir < 0 then
				msg = "TwoDiffLeft"
			elseif dir > 0 then
				msg = "TwoDiffRight"
			else return end
			return MESSAGEMAN:Broadcast(msg..pn)
		end,
		genScrollerFrame(pn)..{
			InitCommand=function(s)
				frame[pn] = s;
				adjustScrollerFrame(pn)
				s:xy(pn==PLAYER_1 and 400 or -400,-40)
			end,
			StartSelectingStepsMessageCommand=function(s) s:addy(pn==PLAYER_1 and -SCREEN_HEIGHT*2 or SCREEN_HEIGHT*2)
				:decelerate(1):addy(pn==PLAYER_1 and SCREEN_HEIGHT*2 or -SCREEN_HEIGHT*2)
			end,
			RemoveCommand=function(s) s:sleep(0.7):accelerate(1):addy(pn==PLAYER_1 and SCREEN_HEIGHT*2 or -SCREEN_HEIGHT*2) end,
		};
		Def.ActorFrame{
			StartSelectingStepsMessageCommand=function(s) s:addx(pn==PLAYER_1 and -800 or 800):decelerate(0.5):addx(pn==PLAYER_1 and 800 or -800) end,
			RemoveCommand=function(s) s:sleep(0.7):accelerate(1):addx(pn==PLAYER_1 and -800 or 800) end,
			Def.ActorFrame{
				Name="WINDOW FRAME",
				InitCommand=function(s)
					s:zoomx(pn==PLAYER_2 and -1 or 1)
				end,
				Def.Sprite{ Texture="WINDOW INNER";
					InitCommand=function(s) s:diffuse(color("#333333")):y(14) end,
				};
				Def.Sprite{ Texture="WINDOW FRAME"};
			};
			Def.ActorFrame{
				Name="DIFF HEADER",
				--Blaze it
				InitCommand=function(s) s:y(-420) end,
				Def.Sprite{
					Texture="Header Box",
					InitCommand=function(s) s:zoomx(pn==PLAYER_2 and -1 or 1) end,
				},
				Def.Sprite{
					Texture="Diff Text",
				}
			};
			RadarPanel(pn)..{
				InitCommand=function(s) s:diffusealpha(0) end,
				StartSelectingStepsMessageCommand=function(s) s:sleep(0.4):smooth(0.1):diffusealpha(0.5)
					:smooth(0.1):diffusealpha(0.3):decelerate(0.3):diffusealpha(1)
				end,
			};
			loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/TwoPartDiff/_Diff.lua"))(pn)..{
				InitCommand=function(s) s:y(-360) end,
				StartSelectingStepsMessageCommand=function(s) s:queuecommand("Set") end,
				ChangeStepsMessageCommand=function(s) s:queuecommand("Set") end,
			};
		};
		--Yes I'm loading a version of the diff list that literally only has the frame removed. Fight me.
		Def.BitmapText{
			Font="_avenirnext lt pro bold/25px",
			Text="Please wait...",
			InitCommand=function(s) s:diffusealpha(0):y(60):strokecolor(Color.Black):sleep(0.4) end,
			AnimCommand=function(s) s:finishtweening():cropright(0.2):linear(0.5):cropright(0):queuecommand("Anim") end,
			["OK"..pn.."MessageCommand"]=function(s)
				s:x(-100):decelerate(0.4):x(0):diffusealpha(1):queuecommand("Anim")
			end,
			OffCommand=function(s) 
				s:settext("O.K.!")
				:finishtweening():diffusealpha(1):sleep(1):decelerate(0.3):diffusealpha(0)
			end,
		};
	}
end
return t;
