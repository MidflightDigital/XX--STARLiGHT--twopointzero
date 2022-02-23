local jk = LoadModule"Jacket.lua"

if not GAMESTATE:IsCourseMode() then
	local Handle = RageFileUtil.CreateRageFile();
	local pass = Handle:Open(THEME:GetCurrentThemeDirectory().."NowPlaying.txt", 2);
	local song = GAMESTATE:GetCurrentSong():GetDisplayMainTitle();
	local art = GAMESTATE:GetCurrentSong():GetDisplayArtist();
	local diff = GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber())
	local diff2
	local diffname = diff:GetDifficulty()
	local diffname2;
	local meter = diff:GetMeter()
	local meter2;
	if GAMESTATE:GetNumPlayersEnabled() == 2 then
		diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
		diff2 = GAMESTATE:GetCurrentSteps(PLAYER_2)
		diffname = diff:GetDifficulty()
		diffname2 = diff2:GetDifficulty()
		meter = diff:GetMeter()
		meter2 = diff2:GetMeter()
		if pass then
			Handle:Write(art.." - "..song.." - "..THEME:GetString("CustomDifficulty",ToEnumShortString(diffname)).." "..meter.." | "..THEME:GetString("CustomDifficulty",ToEnumShortString(diffname2)).." "..meter2);
			Handle:Flush();
		end;
	else
		if pass then
			Handle:Write(art.." - "..song.." - "..THEME:GetString("CustomDifficulty",ToEnumShortString(diffname)).." "..meter);
			Handle:Flush();
		end;
	end
	Handle:Close();
	
end;

local t = Def.ActorFrame {
	Def.Sprite{
		Texture=THEME:GetPathB("","EX.png"),
		InitCommand=function(s) s:visible(GAMESTATE:IsAnExtraStage()):Center() end,
		OnCommand=function(s) s:sleep(0.2):linear(0.1):diffusealpha(0) end,
	};
	loadfile(THEME:GetPathB("","_StageDoors"))()..{
		OnCommand=function(s) s:playcommand("AnOn") end,
	};
	loadfile(THEME:GetPathB("ScreenStageInformation","decorations/SoundStage.lua")(),
};
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:y(SCREEN_CENTER_Y);
	end;
	-- Door sound
	Def.Sound{
		File=GetMenuMusicPath "stage",
		OnCommand=function(self) self:sleep(0.25):queuecommand("Play") end,
		PlayCommand=function(self)
			self:play();
		end;
	};
	Def.Sound{
		File=THEME:GetPathS( "", "_Cheer" ),
		OnCommand=function(self)
			if ThemePrefs.Get("MenuMusic") ~= "leeium" then
				self:sleep(0.2):queuecommand("Play")
			end
		end;
		PlayCommand=function(s) s:play() end,
	};
};
--song jacket--
t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:Center():diffusealpha(0):zoom(4) end,
	OnCommand=function(s)
		if GAMESTATE:IsCourseMode() then
			local ent = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntries()
			s:GetChild("Actual Jacket"):Load(jk.GetSongGraphicPath(ent[1]:GetSong()))
			s:GetChild("Blend Jacket"):Load(jk.GetSongGraphicPath(ent[1]:GetSong()))
		else
			s:GetChild("Actual Jacket"):Load(jk.GetSongGraphicPath(GAMESTATE:GetCurrentSong()))
			s:GetChild("Blend Jacket"):Load(jk.GetSongGraphicPath(GAMESTATE:GetCurrentSong()))
		end
		s:GetChild("Actual Jacket"):scaletofit(-310,-310,310,310)
		s:GetChild("Blend Jacket"):scaletofit(-310,-310,310,310)
		s:sleep(2.5):linear(0.2):diffusealpha(1):zoom(0.9):linear(0.1):zoom(1):sleep(3)
	end,
	Def.Quad{
		InitCommand=function(s) s:diffuse(Color.Black)
			s:setsize(628,628)
		end,
	};
	Def.Sprite {
		Name="Actual Jacket",
	},
	Def.Sprite {
		Name="Blend Jacket",
		InitCommand=function(s) 
			s:blend(Blend.Add):diffusealpha(0)
		end,
		OnCommand=function(s)
			s:sleep(2.7):diffusealpha(0.75):linear(0.5):zoom(4):diffusealpha(0)
		end,
	};
};
t[#t+1] = LoadActor("StageDisplay");

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	if not GAMESTATE:IsCourseMode() then
		t[#t+1] = LoadActor("record", pn)
	end
	t[#t+1] = Def.Actor{
		OnCommand=function(self)
			if GAMESTATE:GetPlayMode() == "PlayMode_Oni" or GAMESTATE:IsExtraStage() then
				GAMESTATE:ApplyPreferredModifiers(pn,"4 lives,battery,failimmediate")
			elseif GAMESTATE:IsExtraStage2() then
				GAMESTATE:ApplyPreferredModifiers(pn,"1 lives,battery,failimmediate")
			end
		end;
	};
end

return t
