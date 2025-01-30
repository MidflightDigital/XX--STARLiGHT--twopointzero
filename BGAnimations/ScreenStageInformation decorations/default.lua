local jk = LoadModule 'Jacket.lua'

if not GAMESTATE:IsCourseMode() then
	local Handle = RageFileUtil.CreateRageFile()
	local pass = Handle:Open(THEME:GetCurrentThemeDirectory() .. 'NowPlaying.txt', 2)
	local song = GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
	local art = GAMESTATE:GetCurrentSong():GetDisplayArtist()
	local diff = GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber())
	local diff2
	local diffname = diff:GetDifficulty()
	local diffname2
	local meter = diff:GetMeter()
	local meter2
	
	if GAMESTATE:GetNumPlayersEnabled() == 2 then
		diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
		diff2 = GAMESTATE:GetCurrentSteps(PLAYER_2)
		diffname = diff:GetDifficulty()
		diffname2 = diff2:GetDifficulty()
		meter = diff:GetMeter()
		meter2 = diff2:GetMeter()
		
		if pass then
			Handle:Write(art..' - '..song..' - '..THEME:GetString('CustomDifficulty',ToEnumShortString(diffname))..' '..meter..' | '..THEME:GetString('CustomDifficulty',ToEnumShortString(diffname2))..' '..meter2)
			Handle:Flush()
		end;
	else
		if pass then
			Handle:Write(art..' - '..song..' - '..THEME:GetString('CustomDifficulty',ToEnumShortString(diffname))..' '..meter)
			Handle:Flush()
		end
	end
	Handle:Close()
end

local t = Def.ActorFrame {
	OnCommand=function(s)
		LoadFromProfilePrefs()
	end,
	Def.Sprite {
		Texture=THEME:GetPathB('', 'EX.png'),
		InitCommand=function(s) s:visible(IsAnExtraStage()):Center() end,
		OnCommand=function(s) s:sleep(0.2):linear(0.1):diffusealpha(0) end,
	},
	loadfile(THEME:GetPathB('', '_StageDoors'))() .. {
		OnCommand=function(s) s:playcommand('AnOn') end,
	},
	Def.Actor {
		OnCommand=function(s)
			s:sleep(1.75):queuecommand('Play')
		end,
		PlayCommand=function(s)
			local curStage = GAMESTATE:GetCurrentStageIndex()+1
			local stageName = 'event'
			
			if not GAMESTATE:IsEventMode() then
				if IsFinalStage() then
					stageName = 'final'
				elseif IsExtraStage1() then
					stageName = 'extra1'
				elseif IsExtraStage2() then
					stageName = 'extra2'
				else
					stageName = curStage
				end
			end
			
			SOUND:PlayAnnouncer('stage ' .. stageName)
		end,
	},
};

t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:y(SCREEN_CENTER_Y)
	end,
	-- Door sound
	Def.Sound{
		File=GetMenuMusicPath 'stage',
		OnCommand=function(self) self:sleep(0.5):queuecommand('Play') end,
		PlayCommand=function(self)
			self:play();
		end;
	},
	Def.Actor {
		OnCommand=function(self)
			if ThemePrefs.Get('MenuMusic') ~= 'leeium' then
				self:sleep(0.2):queuecommand('Play')
			end
		end;
		PlayCommand=function(s)
			SOUND:PlayOnce(THEME:GetPathS('', '_Cheer'))
		end,
	},
};
--song jacket--
t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:Center():diffusealpha(0):zoom(4) end,
	OnCommand=function(s)
		if GAMESTATE:IsCourseMode() then
			local ent = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntries()
			s:GetChild('Actual Jacket'):Load(jk.GetSongGraphicPath(ent[1]:GetSong()))
			s:GetChild('Blend Jacket'):Load(jk.GetSongGraphicPath(ent[1]:GetSong()))
		else
			s:GetChild('Actual Jacket'):Load(jk.GetSongGraphicPath(GAMESTATE:GetCurrentSong()))
			s:GetChild('Blend Jacket'):Load(jk.GetSongGraphicPath(GAMESTATE:GetCurrentSong()))
		end
		s:GetChild('Actual Jacket'):scaletofit(-310,-310,310,310)
		s:GetChild('Blend Jacket'):scaletofit(-310,-310,310,310)
		s:sleep(1):linear(0.2):diffusealpha(1):zoom(0.9):linear(0.1):zoom(1)
	end,
	Def.Quad{
		InitCommand=function(s) s:diffuse(Color.Black)
			s:setsize(628,628)
		end,
	},
	Def.Sprite {
		Name='Actual Jacket',
	},
	Def.Sprite {
		Name='Blend Jacket',
		InitCommand=function(s) 
			s:blend(Blend.Add):diffusealpha(0)
		end,
		OnCommand=function(s)
			s:sleep(1.2):diffusealpha(0.75):linear(0.5):zoom(4):diffusealpha(0)
		end,
	},
};

t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:Center() end,
	
	Def.Sprite {
		InitCommand=function(s) s:diffusealpha(0) end,
		OnCommand=function(s) s:playcommand('Set'):sleep(1.8):linear(0.05):diffusealpha(1):sleep(2.95):linear(0.2):diffusealpha(0) end,
		SetCommand=function(s)
			if getenv('FixStage') == 1 then
				s:Load(THEME:GetPathG('', '_stages/' .. THEME:GetString('CustStageSt',CustStageCheck())..'.png') );
			else
				if GAMESTATE:IsCourseMode() then
					stageName = '1st'
				else
					stageName = ToEnumShortString(GetCurrentStage())
				end
				
				if FILEMAN:DoesFileExist(THEME:GetPathG('', '_stages/' .. stageName ..'.png')) then
					s:Load(THEME:GetPathG('', '_stages/' .. stageName ..'.png') )
				end
			end
		end,
	},
	Def.Sprite{
		Texture='star',
		InitCommand=function(s) s:diffusealpha(0) end,
		OnCommand=function(s) s:sleep(1.8):linear(0.05):diffusealpha(1):linear(0.2):diffusealpha(0) end,
	},
	Def.Quad{
		InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):diffusealpha(0):blend(Blend.Add) end,
		OnCommand=function(s) s:sleep(1.8):linear(0.05):diffusealpha(0.25):linear(0.2):diffusealpha(0) end,
	},
	Def.Sprite{
		Texture='arrow',
		OnCommand=function(s) s:x(1700):sleep(1.6):linear(0.4):x(-1700) end,
	},
	Def.Sprite{
		Texture='arrow',
		InitCommand=function(s) s:zoomx(-1) end,
		OnCommand=function(s) s:x(-1700):sleep(1.6):linear(0.4):x(1700) end,
	},
};

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	if not GAMESTATE:IsCourseMode() then
		t[#t+1] = loadfile(THEME:GetPathB("ScreenStageInformation","decorations/record.lua"))(pn);
	end
end

return t