function Branch.FirstScreen()
	return "ScreenMDSplash"
end

CustomBranch = {
    InitialScreen = function()
        return "ScreenTitle"
    end,
    WarningOrAlert = function()
        if _VERSION ~= "Lua 5.3" and tonumber(VersionDate()) < 20190328 then
            return "ScreenOldSM"
        else
            if SN3Debug then
                return "ScreenDevBuild"
            else
                return "ScreenPotatoPC"
            end
        end
    end,
    AfterOLDSM = function()
        if PREFSMAN:GetPreference('DisplayColorDepth') == 16 or PREFSMAN:GetPreference('TextureColorDepth') == 16 then
            return "ScreenGraphicsAlert"
        else
            if SN3Debug then
                return "ScreenDevBuild"
            else
                return "ScreenPotatoPC"
            end
        end
    end,
    AttractStart = function()
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
    end,
    StartGame = function()
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
    end,
}