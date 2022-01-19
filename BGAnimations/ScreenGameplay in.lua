local t = Def.ActorFrame {};
local jk = LoadModule "Jacket.lua"
--BGVideo
	t[#t+1] = Def.ActorFrame {
		loadfile(THEME:GetPathB("ScreenWithMenuElements","background"))()..{
			InitCommand=function(s)
				s:visible(true)
			end,
			OnCommand=function(s) s:linear(0.25):diffusealpha(0):queuecommand("Finish") end,
			FinishCommand=function(s) s:finishtweening():visible(false) end,
		};
	};
--Jacket--
t[#t+1] = Def.ActorFrame {
	 InitCommand=function(s)
		s:Center():diffusealpha(1):zoom(1)
	end,
	OnCommand=function(s) s:sleep(0.5):decelerate(0.2):zoom(2):diffusealpha(0) end,
	Def.Quad{
		InitCommand=function(s) s:diffuse(Color.Black)
			s:setsize(620,620)	
		end,
	};
	Def.Sprite {
		InitCommand=function(self)
			if GAMESTATE:IsCourseMode() then
				local ent = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()):GetTrailEntries()
				self:Load(jk.GetSongGraphicPath(ent[1]:GetSong())):setsize(620,620)
			else
				self:Load(jk.GetSongGraphicPath(GAMESTATE:GetCurrentSong())):setsize(620,620)	
			end
		end;
	};
};

return t;
