--[[local function obf(st)
    return base64decode(st)
end

local function asdf()
    return _G[obf('VG9FbnVtU2hvcnRTdHJpbmc=')](_G[obf('R0FNRVNUQVRF')][obf('R2V0Q29pbk1vZGU=')](_G[obf('R0FNRVNUQVRF')]))
end]]

function Branch.FirstScreen()
	return "ScreenMDSplash"
end

function Branch.WarningOrAlert()
	if _VERSION ~= "Lua 5.3" and tonumber(VersionDate()) < 20190328 then
		return "ScreenOldSM"
	else
		if SN3Debug then
			return "ScreenDevBuild"
		else
			return "ScreenPotatoPC"
		end
	end
end

function Branch.AfterOLDSM()
	if PREFSMAN:GetPreference('DisplayColorDepth') == 16 or PREFSMAN:GetPreference('TextureColorDepth') == 16 then
		return "ScreenGraphicsAlert"
	else
		if SN3Debug then
			return "ScreenDevBuild"
		else
			return "ScreenPotatoPC"
		end
	end
end

function Branch.AttractStart()
	local mode = GAMESTATE:GetCoinMode()
	local screen = Var"LoadingScreen"
	if mode == "CoinMode_Home" then
		-- Only really matters if you hit Start from ScreenInit
		return "ScreenTitleMenu"
	elseif mode == "CoinMode_Free" then
		-- Start in Free Play mode goes directly into game
		return "ScreenLogo"
	else
	-- Inserting a credit in Pay mode goes to logo screen
		return "ScreenLogo"
	end
end

Branch.StartGame = function()
	-- XXX: we don't theme this screen
	if SONGMAN:GetNumSongs() == 0 and SONGMAN:GetNumAdditionalSongs() == 0 then
		return "ScreenHowToInstallSongs"
	end
	if PROFILEMAN:GetNumLocalProfiles() >= 1 then
		return "ScreenSelectProfile"
	else
		if PREFSMAN:GetPreference("MemoryCards") then
			return "ScreenSelectProfile"
		else
			return "ScreenDDRNameEntry"
		end
	end
end

function SelectMusicOrCourse()
	if IsNetSMOnline() then
		return "ScreenNetSelectMusic"
	elseif GAMESTATE:IsCourseMode() then
		return "ScreenSelectCourse"
	else
		if GAMESTATE:IsAnExtraStage() then
			return "ScreenSelectMusicExtra"
		else
			return "ScreenSelectMusic"
		end
	end
end

Branch.BackOutOfPlayerOptions = function()
	return SelectMusicOrCourse()
end;

function Branch.TitleMenu()
	local coinMode = GAMESTATE:GetCoinMode()
	if coinMode == 'CoinMode_Home' then
		return "ScreenSelectMode"
	else
		return "ScreenWarning"
	end
end;

function AfterSelectStyle()
	if IsNetConnected() then
		ReportStyle()
		GAMESTATE:ApplyGameCommand("playmode,regular")
	end
	if IsNetSMOnline() then
		return SMOnlineScreen()
	end
	if IsNetConnected() then
		return "ScreenNetRoom"
	end
	return "ScreenProfileLoad"

	--return CHARMAN:GetAllCharacters() ~= nil and "ScreenSelectCharacter" or "ScreenGameInformation"
end

function AfterCaution()
	if GAMESTATE:IsCourseMode() then
		return "ScreenSelectCourse"
	else
		return "ScreenSelectMusic"
	end
end

Branch.AfterGameplay = function()
	if GAMESTATE:IsCourseMode() then
		if GAMESTATE:GetPlayMode() == 'PlayMode_Nonstop' then
			return "ScreenEvaluationNonstop"
		else	-- oni and endless are shared
			return "ScreenEvaluationOni"
		end
	elseif GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
		return "ScreenEvaluationRave"
	else
		return "ScreenEvaluationNormal"
	end
end

Branch.AfterEvaluation = function()
	--normal
	if GAMESTATE:GetSmallestNumStagesLeftForAnyHumanPlayer() >= 1 then
		return "ScreenProfileSave"
	elseif GAMESTATE:GetCurrentStage() == "Stage_Extra1" then
		if STATSMAN:GetCurStageStats():AllFailed() then
			if GAMESTATE:IsCourseMode() then
				return "ScreenProfileSaveSummary"
			else
				return "ScreenEvaluationSummary"
			end;
		else
			return "ScreenProfileSave"
		end;
	elseif STATSMAN:GetCurStageStats():AllFailed() then
		return "ScreenEvaluationSummary"
	elseif GAMESTATE:IsCourseMode() then
		return "ScreenProfileSaveSummary"
	else
		return "ScreenEvaluationSummary"
	end
end

Branch.AfterSummary = "ScreenProfileSaveSummary"

Branch.AfterSaveSummary = function()
	if PROFILEMAN:GetNumLocalProfiles() >= 1 then
		return "ScreenDataSaveSummary"
	else
		return "ScreenGameOver"
	end
end

Branch.AfterDataSaveSummary = function()
	if GAMESTATE:AnyPlayerHasRankingFeats() then
		return "ScreenDataSaveSummaryEnd"
	else
		return "ScreenDataSaveSummaryEnd"
	end
end
