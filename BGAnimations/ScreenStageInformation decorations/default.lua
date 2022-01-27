local jk = LoadModule"Jacket.lua"

local t = Def.ActorFrame {
	--LoadActor("BranchHandler.lua");
	LoadActor(THEME:GetPathB("","EX.png"))..{
		InitCommand=function(s) s:visible(GAMESTATE:IsAnExtraStage()):Center() end,
		OnCommand=function(s) s:sleep(0.2):linear(0.1):diffusealpha(0) end,
	};
	LoadActor(THEME:GetPathB("","_StageDoors"))..{
		OnCommand=function(s) s:playcommand("AnOn") end,
	};
	LoadActor("SoundStage");
};
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:y(SCREEN_CENTER_Y);
	end;
	-- Door sound
	LoadActor(GetMenuMusicPath "stage" ) .. {
		OnCommand=function(self) self:sleep(0.25):queuecommand("Play") end,
		PlayCommand=function(self)
			self:play();
		end;
	};
	LoadActor(THEME:GetPathS( "", "_Cheer" ) ) .. {
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
		s:sleep(2.5):linear(0.2):diffusealpha(1):zoom(0.9):linear(0.1):zoom(1):sleep(3)
	end,
	Def.Quad{
		InitCommand=function(s) s:diffuse(Color.Black)
			s:setsize(628,628)
		end,
	};
	Def.Sprite {
		OnCommand=function(s) 
			if GAMESTATE:IsCourseMode() then
				local ent = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntries()
				s:Load(jk.GetSongGraphicPath(ent[1]:GetSong()))
			else
				s:Load(jk.GetSongGraphicPath(GAMESTATE:GetCurrentSong()))
			end
			s:scaletofit(-310,-310,310,310)
		end,	
	};
	Def.Sprite {
		BeginCommand=function(s) 
			s:blend(Blend.Add)
			if GAMESTATE:IsCourseMode() then
				local ent = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntries()
				s:Load(jk.GetSongGraphicPath(ent[1]:GetSong())):setsize(620,620)
			else
				s:Load(jk.GetSongGraphicPath(GAMESTATE:GetCurrentSong())):setsize(620,620)
				
			end
			s:diffusealpha(0)
		end,
		OnCommand=function(s)
			s:sleep(2.7):diffusealpha(0.5):linear(0.5):zoom(2):diffusealpha(0)
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
