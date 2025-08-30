local t = Def.ActorFrame {};
local style = GAMESTATE:GetCurrentStyle():GetStyleType()
local st = GAMESTATE:GetCurrentStyle():GetStepsType();
local show_cutins = GAMESTATE:GetCurrentSong() and (not GAMESTATE:GetCurrentSong():HasBGChanges()) or true;
local show_danger = PREFSMAN:GetPreference("ShowDanger")

local filter_color= color("0,0,0,0")
local screen = Var"LoadingScreen"

local x_table = {
  PlayerNumber_P1 = {SCREEN_CENTER_X+428},
  PlayerNumber_P2 = {SCREEN_CENTER_X-428}
}
	
--toasty loader
for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	local song
	if GAMESTATE:IsCourseMode() then
		song = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntries()[GAMESTATE:GetCurrentStageIndex()+1]:GetSong()
	else
		song = GAMESTATE:GetCurrentSong()
	end
	if show_cutins and st ~= 'StepsType_Dance_Double' and ThemePrefs.Get("CutIns") == true and song:HasBGChanges() == false then
		--use ipairs here because i think it expects P1 is loaded before P2
		if #Characters.GetAllCharacterNames() ~= 0 then
			t[#t+1] = Def.ActorFrame {
				loadfile(THEME:GetPathB("ScreenGameplay","underlay/Cutin.lua"))(pn) .. {
					OnCommand=function(s) s:setsize(450,SCREEN_HEIGHT) end,
					InitCommand=function(self)
						self:CenterY()
						if style == "StyleType_TwoPlayersTwoSides" or GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
							self:x(SCREEN_CENTER_X);
						else
							if PREFSMAN:GetPreference("Center1Player") then
								self:x(pn==PLAYER_1 and _screen.cx-600 or _screen.cx+600)
							else
								self:x(x_table[pn][1]);
							end
						end;
					end;
				};
			};
		end
	end;

	local profileID = GetProfileIDForPlayer(pn)
	local pPrefs = ProfilePrefs.Read(profileID)

	local style=GAMESTATE:GetCurrentStyle(pn)
	local filter_alpha = pPrefs.filter/100
	local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
	local width=(style:GetWidth(pn)*(NumColumns/1.7))

	if style:GetStyleType() == 'StyleType_OnePlayerTwoSides' then
		width = style:GetWidth(pn)*(NumColumns/3.7)
	end

	local X

	if PREFSMAN:GetPreference("Center1Player") and GAMESTATE:GetNumPlayersEnabled() == 1 then
		X = _screen.cx
	else
		X = ScreenGameplay_X(pn)
	end

	local DS = Def.ActorFrame {};

	--Danger Sidebars
	for i=1,2 do
		DS[#DS+1] = Def.ActorFrame {
			InitCommand=function(s)
				s:x(i==1 and ((-width/2)-10) or ((width/2)+10)):visible(show_danger)
			end,
			Def.Sprite {
				Texture="rope",
				InitCommand=function(s)
					s:customtexturerect(0,0,1,2):zoomtoheight(_screen.h):diffuseshift():effectcolor1(Color.White):effectcolor2(Alpha(Color.White,0.7)):effectperiod(0.5)
					if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
						s:texcoordvelocity(0,-0.5)
					elseif not GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
						s:texcoordvelocity(0,0.5)
					end;
				end,
			},
			Def.ActorFrame {
				InitCommand=function(s) s:rotationz(i==2 and 180 or 0) end,
				Def.Sprite {
					Texture="text",
				};
				Def.ActorFrame{
					InitCommand=function(s)
						s:pulseramp():effectmagnitude(1,1.2,1):effectperiod(0.5)
					end,
					Def.Sprite {
						Texture="text",
						InitCommand=function(s)
							s:diffuseramp():effectcolor1(color("1,1,1,0")):effectcolor2(color("1,1,1,0.8")):effectperiod(0.5)
						end,
					};
				}
			};
		};
	end

	t[#t+1] = Def.ActorFrame {
		InitCommand=function(s) s:xy(X,_screen.cy):diffusealpha(0) end,
		CurrentSongChangedMessageCommand=function(s) s:diffusealpha(0):sleep(BeginReadyDelay()+SongMeasureSec()):linear(0.2):diffusealpha(1):queuecommand("ShowBars") end,
		ChangeCourseSongInMessageCommand=function(s) s:playcommand('FilterOff') end,
		OffCommand=function(s) s:playcommand('FilterOff') end,
		FilterOffCommand=function(s)
			local song
			local dif = 0
			
			if GAMESTATE:IsCourseMode() then
				song = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntry(GAMESTATE:GetLoadingCourseSongIndex()-1):GetSong()
			else
				song = GAMESTATE:GetCurrentSong()
			end
			
			if song then
				local td = song:GetTimingData()
				local bpm = round(td:GetBPMAtBeat(song:GetLastBeat()),3)
				local m = 1
				
				if bpm >= 60 and bpm < 120 then
					m = 0.75
				elseif bpm < 60 then
					m = 0.5
				else
					--- 240 bpm and above
					for i=1, 3 do
						if bpm >= 240*(3-(i-1)) then
							m = 2*(3-(i-1))
							break
						end
					end
				end
				
				local timeSigs = split('=', td:GetTimeSignatures()[1])
				local n = timeSigs[2]
				local d = timeSigs[3]
				dif = 60/bpm*4*m*n/d
			end
			
			s:sleep(dif):linear(0.2):diffusealpha(0):queuecommand("DisableBars")
		end,
		
		Def.Quad {
			InitCommand=function(s)
				s:diffuse(filter_color):fadeleft(1/32):faderight(1/32)
			end,
			BeginCommand=function(s) s:playcommand("CurrentSongChangedMessage") end,
			CurrentSongChangedMessageCommand=function(s,p)
				s:setsize(width,_screen.h)
				if screen == "ScreenDemonstration" then
					s:diffusealpha(0.5)
				else
					s:diffusealpha(filter_alpha)
				end
			end,
			HealthStateChangedMessageCommand= function(self, param)
				if param.PlayerNumber ~= pn then return end
				local healthState = ToEnumShortString(param.HealthState)
				local diffuseColor, diffuseAlpha
				
				if healthState == 'Dead' and GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current'):FailSetting() == 'FailType_Immediate' then
					diffuseAlpha = 0
				elseif show_danger and (healthState == 'Danger' or healthState == 'Dead') then
					diffuseColor = color('#bb1300ff')
					diffuseAlpha = math.max(0.75, filter_alpha)
				else -- Hot and Alive, and if show_danger is false then and Danger and Dead too (if FailSetting is not Immediate)
					diffuseColor = filter_color
					diffuseAlpha = filter_alpha
				end
				
				if diffuseColor or diffuseAlpha then
					self:stoptweening():linear(0.1)
					if diffuseColor then self:diffuse(diffuseColor) end
					if diffuseAlpha then self:diffusealpha(diffuseAlpha) end
				end
			end,
		};
		--Is this hacky? Yes.
		--Does it work? ...Unfortunately also yes.
		Def.Actor{
			ShowBarsCommand=function(self)
				local notefield = SCREENMAN:GetTopScreen():GetChild("Player"..ToEnumShortString(pn)):GetChild("NoteField")
				local profileID = GetProfileIDForPlayer(pn)
				local pPrefs = ProfilePrefs.Read(profileID)
				if pPrefs.guidelines == true then
					notefield:SetBeatBars(true)
					notefield:SetStopBars(true)
					notefield:SetBpmBars(true)
				end
			end,
			DisableBarsCommand=function(self)
				local notefield = SCREENMAN:GetTopScreen():GetChild("Player"..ToEnumShortString(pn)):GetChild("NoteField")
				notefield:SetBeatBars(false)
				notefield:SetStopBars(false)
				notefield:SetBpmBars(false)
			end,
		},
		DS .. {
			InitCommand=function(s) s:diffusealpha(0) end,
			HealthStateChangedMessageCommand=function(self, param)
				if param.PlayerNumber ~= pn then return end
				local healthState = ToEnumShortString(param.HealthState)
				local failSetting = ToEnumShortString(GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current'):FailSetting())
				
				if healthState == 'Danger' or (healthState == 'Dead' and (failSetting ~= 'Immediate' and failSetting ~= 'ImmediateContinue')) then
					-- Only show danger bars if we can recover to clear the song. (i.e. Hide danger bars if we're dead and the song is guaranteed failed)
					self:stoptweening():linear(0.1):diffusealpha(1)
				else
					self:stoptweening():linear(0.1):diffusealpha(0)
				end
			end,
		};
	};

	-- 4th, 8th, and 16th bars alphas are currently not properly initialized from metrics and broken.
	-- This bug should be fixed by the next Outfox update. We can hotfix them here in Lua for now.
	if tonumber(VersionDate()) <= 20250804 and type(NoteField.SetBeatBarsAlpha) == 'function' then
		t[#t+1] = Def.Actor{
			OnCommand=function(self)
				local notefield = SCREENMAN:GetTopScreen():GetChild('Player'..ToEnumShortString(pn)):GetChild('NoteField')
				notefield:SetBeatBarsAlpha(
					tonumber(THEME:GetMetric('NoteField', 'BarMeasureAlpha')) or 0,
					tonumber(THEME:GetMetric('NoteField', 'Bar4thAlpha')) or 0,
					tonumber(THEME:GetMetric('NoteField', 'Bar8thAlpha')) or 0,
					tonumber(THEME:GetMetric('NoteField', 'Bar16thAlpha')) or 0
				)
			end
		}
	end
	
	--[[
	local StepsOrTrail
	if GAMESTATE:IsCourseMode() then
		StepsOrTrail = GAMESTATE:GetCurrentTrail(pn):GetTrailEntry(GAMESTATE:GetCurrentStageIndex()):GetSteps():GetTimingData()
	else
		StepsOrTrail = GAMESTATE:GetCurrentSteps(pn):GetTimingData()
	end
	--Unfortunately guidelines broke in Outfox 4.9.8 and it's still in a slightly buggy state anyways so they are currently disabled.
	--Feel free to try and figure out the issues. -Inori/tertu
	if pPrefs.guidelines == true then
		if StepsOrTrail:HasScrollChanges() or GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current'):Mini() ~= 0 then
			SCREENMAN:SystemMessage("Sorry! Guidelines currently don't support Scroll Changes or Mini.")
		else
			t[#t+1] = Def.ActorFrame {
				InitCommand=function(s)
					s:SetUpdateFunction(FilterUpdate)
				end,
				loadfile(THEME:GetPathB("ScreenGameplay","underlay/GuidePlus"))(pn) .. {
					InitCommand=function(s) 
						if GAMESTATE:GetCurrentStyle():GetStepsType() == 'StepsType_Dance_Double' and IsUsingWideScreen() == false then
							s:basezoom(0.9)
						end
						s:x(X):SetUpdateFunction(FilterUpdate)
						if GAMESTATE:GetCurrentStyle():GetStepsType() == 'StepsType_Dance_Double' and IsUsingWideScreen() == false then
							s:y(SCREEN_TOP+212)
						else
							if pPrefs.guidelines_top_aligned == true then
								s:y(SCREEN_TOP+110)
							else
								s:y(SCREEN_TOP+180)
							end
						end
						if GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):Reverse() == 1 then
							s:zoomy(-1)
							if GAMESTATE:GetCurrentStyle():GetStepsType() == 'StepsType_Dance_Double' and IsUsingWideScreen() == false then
								s:y(SCREEN_BOTTOM-228)
							else
								if pPrefs.guidelines_top_aligned == true then
									s:y(SCREEN_BOTTOM-120)
								else
									s:y(SCREEN_BOTTOM-190)
								end
							end
						end
					end,
				},
			}
		end
	end
	--]]
end

return t