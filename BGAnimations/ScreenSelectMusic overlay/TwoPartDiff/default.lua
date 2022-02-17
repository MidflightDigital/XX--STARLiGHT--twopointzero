--This file uses AddChildFromPath since I need to load as many actors as there are steps
--Thus there are no constructors, it will just take the current song and display for as many
--joined players. And do a lot of crazy stuff to handle two actorframes.
local X_SPACING = 300


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
		frame[pn]:GetChild(i):stoptweening():decelerate(.2):x((i-selection[pn])*X_SPACING):GetChild("Highlight"):visible(is_focus)
	end;
end;

local function genScrollerFrame(player)
	local f = Def.ActorFrame{}
	for i,steps in ipairs(songSteps) do
		local diff = steps:GetDifficulty();
		f[i] = Def.ActorFrame{
			Name=i;
			InitCommand=function(s) s:x((i-center)*X_SPACING) end,
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
				Text=steps:GetMeter();
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
				InitCommand=function(s) s:visible(i==selection[player]):diffuseramp():effectcolor1(color("1,1,1,0")):effectcolor2(color("1,1,1,1")):effectclock("beatnooffset") end,
				["OK"..player.."MessageCommand"]=function(s)
					s:stopeffect()
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
}

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s)
			s:x(_screen.cx)
			if GAMESTATE:GetNumPlayersEnabled() == 2 then
				s:y(pn==PLAYER_1 and _screen.cy-200 or _screen.cy+200)
			else
				s:y(_screen.cy)
			end
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
		Def.Sprite{ Texture="backer";
			StartSelectingStepsMessageCommand=function(s) s:cropleft(0.5):cropright(0.5):decelerate(0.3):cropleft(0):cropright(0) end,
			OffCommand=function(s) s:sleep(1.2):decelerate(0.3):cropleft(0.5):cropright(0.5) end,
			RemoveCommand=function(s) s:sleep(0.2):decelerate(0.3):cropleft(0.5):cropright(0.5) end,
		};
		Def.Sprite{
			Texture="controls",
			InitCommand=function(s) s:y(-80) end,
			StartSelectingStepsMessageCommand=function(s) s:cropleft(0.5):cropright(0.5):decelerate(0.3):cropleft(0):cropright(0) end,
			OffCommand=function(s) s:sleep(1.2):decelerate(0.3):cropleft(0.5):cropright(0.5) end,
			RemoveCommand=function(s) s:sleep(0.2):decelerate(0.3):cropleft(0.5):cropright(0.5) end,
		},
		genScrollerFrame(pn)..{
			InitCommand=function(s)
				frame[pn] = s;
				adjustScrollerFrame(pn)
			end,
			StartSelectingStepsMessageCommand=function(s) s:addx(pn==PLAYER_1 and -SCREEN_WIDTH*2 or SCREEN_WIDTH*2)
				:decelerate(1):addx(pn==PLAYER_1 and SCREEN_WIDTH*2 or -SCREEN_WIDTH*2)
			end,
			OffCommand=function(s) s:sleep(1):decelerate(1):addx(pn==PLAYER_1 and SCREEN_WIDTH*2 or -SCREEN_WIDTH*2) end,
			RemoveCommand=function(s) s:decelerate(1):addx(pn==PLAYER_1 and SCREEN_WIDTH*2 or -SCREEN_WIDTH*2) end,
		};
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
	for i=1,2 do

		local u = Def.Sprite{
			Texture=THEME:GetPathG("","_shared/garrows/_selectarroww"),
			InitCommand=function(s)
				if GAMESTATE:GetNumPlayersEnabled() == 2 then
					s:y(pn==PLAYER_1 and _screen.cy-200 or _screen.cy+200)
				else
					s:y(_screen.cy)
				end
				if i==2 then s:zoomx(-1) end
				s:diffuse(color("#5bec19"))
			end,
			StartSelectingStepsMessageCommand=function(s)
				s:diffusealpha(0):x(_screen.cx):sleep(0.2):decelerate(0.5):x(i==1 and SCREEN_LEFT+100 or SCREEN_RIGHT-100):diffusealpha(1)
			end,
			OffCommand=function(s) s:decelerate(0.2):x(i==1 and SCREEN_LEFT-100 or SCREEN_RIGHT+100) end,
			RemoveCommand=function(s) s:playcommand("Off") end,
		}

		if i == 1 then
			u["TwoDiffLeft"..pn.."MessageCommand"]=function(s)
				s:finishtweening():diffuse(color("#f51a32"))
				:decelerate(0.2):x(SCREEN_LEFT+80):decelerate(0.2):x(SCREEN_LEFT+100):sleep(0):diffuse(color("#5bec19"))
			end
		else
			u["TwoDiffRight"..pn.."MessageCommand"]=function(s)
				s:finishtweening():diffuse(color("#f51a32"))
				:decelerate(0.2):x(SCREEN_RIGHT-80):decelerate(0.2):x(SCREEN_RIGHT-100):sleep(0):diffuse(color("#5bec19"))
			end
		end

		t[#t+1] = u

	end
end
return t;
