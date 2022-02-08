local x = Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:diffuse(Alpha(Color.Black,0)):FullScreen() end,
		BeginCommand=function(s)
			if SCREENMAN:GetTopScreen():GetPrevScreenName() == "ScreenEvaluationSummary" then
				s:diffusealpha(1)
			elseif GAMESTATE:IsAnExtraStage() and SCREENMAN:GetTopScreen():GetNextScreenName() == "ScreenSelectMusicExtra" then
				s:diffusealpha(1)
			end
		end
	};
	Def.Sprite{
		Texture=THEME:GetPathB("","EX.png"),
		InitCommand=function(s) s:Center():visible(false) end,
		BeginCommand=function(s)
			if GAMESTATE:IsAnExtraStage() and SCREENMAN:GetTopScreen():GetNextScreenName() == "ScreenSelectMusicExtra" then
				s:visible(true)
			end
		end
	};
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenEvaluation","decorations/movie.mp4"),
		InitCommand=function(s) s:Center():visible(false):pause() end,
		BeginCommand=function(s)
			if GAMESTATE:IsAnExtraStage() and SCREENMAN:GetTopScreen():GetNextScreenName() == "ScreenSelectMusicExtra" then
				s:visible(true):play()
			end
		end
	};
};

local ProfilePrefs = LoadModule "ProfilePrefs.lua"
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
ProfilePrefs.SaveAll()

x[#x+1] = Def.Actor {
	BeginCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToSave() then self:sleep(1); end;
		self:queuecommand("Load");
	end;
	LoadCommand=function() SCREENMAN:GetTopScreen():Continue(); end;
};


return x;
