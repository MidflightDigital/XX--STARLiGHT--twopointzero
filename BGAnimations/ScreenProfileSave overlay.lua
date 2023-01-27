local x = Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:diffuse(Alpha(Color.Black,0)):FullScreen() end,
		BeginCommand=function(s)
			if SCREENMAN:GetTopScreen():GetPrevScreenName() == "ScreenEvaluationSummary" then
				s:diffusealpha(1)
			end
		end
	};
	Def.Sprite {
		InitCommand=function(s) s:Center():diffusealpha(0) end,
		OnCommand=function(s)
			if SCREENMAN:GetTopScreen():GetNextScreenName() == "ScreenSelectMusicExtra" then
				s:Load(THEME:GetPathB("ScreenEvaluationNormal","decorations/movie.mp4")):queuecommand('Play')
			end
		end,
		PlayCommand=function(s) s:play():diffusealpha(1):linear(0.5):diffusealpha(0) end,
	};
};

local MyGrooveRadar = LoadModule "MyGrooveRadar.lua"

local stype = GAMESTATE:GetCurrentStyle():GetStyleType()
local styleName = ((stype == 'StyleType_OnePlayerTwoSides') or (stype == 'StyleType_TwoPlayersSharedSides'))
		and 'double'
		or 'single'
for _, plr in pairs(GAMESTATE:GetEnabledPlayers()) do
	local profileID = GetProfileIDForPlayer(plr)
	if profileID ~= "!MACHINE" then
		local shortPn = ToEnumShortString(plr)
		local pPrefs = ProfilePrefs.Read(profileID)
		pPrefs.filter = getenv("ScreenFilter"..shortPn) or 0
		pPrefs.character = (GAMESTATE:Env())["SNCharacter"..shortPn] or ""
		MyGrooveRadar.ApplyBonuses(profileID, STATSMAN:GetCurStageStats():GetPlayerStageStats(plr), styleName)
		ProfilePrefs.Save(profileID)
	end
	--stepmania checks the last used HS name and if it's empty, it saves it as "EVNT" in event mode.
	--Except you know, there is no last used hs name or it's not handled properly.
	-- Inori
	PROFILEMAN:GetProfile(plr):SetLastUsedHighScoreName(PROFILEMAN:GetProfile(plr):GetDisplayName())
    GAMESTATE:StoreRankingName(plr,PROFILEMAN:GetProfile(plr):GetDisplayName())
end
MyGrooveRadar.SaveAllRadarData()

--local dim_vol = 1

x[#x+1] = Def.Actor {
	BeginCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToSave() then self:sleep(1) end
		self:queuecommand("Load")
	end;
	LoadCommand=function() SCREENMAN:GetTopScreen():Continue() end,
	--[[OffCommand=function(s)
		local screen = SCREENMAN:GetTopScreen()
		
		if string.match("ScreenSelectMusic", screen:GetNextScreenName()) then
			s:queuecommand('Play')
		end
	end,
	PlayCommand=function(s)
		if dim_vol ~= 0 then
			SOUND:DimMusic(1-(1-dim_vol), math.huge)
			dim_vol = round(dim_vol - 0.001,3)
			s:sleep(0.001):queuecommand('Play')
		end
	end]]
};

return x