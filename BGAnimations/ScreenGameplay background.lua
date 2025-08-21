local background = Def.ActorFrame{
    Name="YOU_WISH_YOU_WERE_PLAYING_BEATMANIA_RIGHT_NOW",
    UpdateDiscordInfoCommand=function(s)
        local player = GAMESTATE:GetMasterPlayerNumber()
        if GAMESTATE:GetCurrentSong() and IsLuaVersionAtLeast(5, 3) then
            local title = PREFSMAN:GetPreference("ShowNativeLanguage") and GAMESTATE:GetCurrentSong():GetDisplayMainTitle() or GAMESTATE:GetCurrentSong():GetTranslitFullTitle()
            local songname = title .. " - " .. GAMESTATE:GetCurrentSong():GetGroupName()
            local state = (GAMESTATE:IsDemonstration() or GAMESTATE:IsHumanPlayer(player)) and "Watching Song" or "Playing Song"
            GAMESTATE:UpdateDiscordProfile(GAMESTATE:GetPlayerDisplayName(player))
            local stats = STATSMAN:GetCurStageStats()
            if not stats then
                return
            end
            local courselength = function()
                if GAMESTATE:IsCourseMode() then
                    if GAMESTATE:GetPlayMode() ~= "PlayMode_Endless" then
                        return GAMESTATE:GetCurrentCourse():GetDisplayFullTitle().. " (Song ".. stats:GetPlayerStageStats( player ):GetSongsPassed()+1 .. " of ".. GAMESTATE:GetCurrentCourse():GetEstimatedNumStages() ..")" or ""
                    end
                    return GAMESTATE:GetCurrentCourse():GetDisplayFullTitle().. " (Song ".. stats:GetPlayerStageStats( player ):GetSongsPassed()+1 .. ")" or ""
                end
            end
            GAMESTATE:UpdateDiscordSongPlaying(GAMESTATE:IsCourseMode() and courselength() or state,songname,(GAMESTATE:GetCurrentSong():GetLastSecond() - GAMESTATE:GetCurMusicSeconds())/GAMESTATE:GetSongOptionsObject('ModsLevel_Song'):MusicRate())
        end
    end,
    CurrentSongChangedMessageCommand=function(s) s:playcommand("UpdateDiscordInfo") end,
    OnCommand=function(self)
        self:playcommand("UpdateDiscordInfo")
    end,
}


local bgScripts = dofile(THEME:GetCurrentThemeDirectory().."BGAnimations/BGScripts/default.lua")
if bgScripts.worked then
    return Def.ActorFrame{
        background,
        bgScripts.bg,
    }
else
    return Def.ActorFrame{
        background
    }
end