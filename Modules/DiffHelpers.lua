local DiffHelpers = {}
local DDRDiffList = {}

return {
    DiffToColor=function(diff, dark)
        local color = CustomDifficultyToColor(ToEnumShortString(diff))
        if dark then
            return ColorDarkTone(color)
        else
            return color
        end
    end,
    AnyPlayerSelected=function(diff)
        for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
            local curSteps = GetCurrentStepsPossiblyCPU(pn)
            if curSteps and curSteps:GetDifficulty()==diff then
                return true
            end
        end
        return false
    end;
    MessageHandlers=function(that, handler)
        local baseXMode = "X Style"
        local lastXMode = baseXMode
        local function check()
            local song = GAMESTATE:GetCurrentSong()
            if song then
                local mt = LoadModule"SongAttributes.lua".GetMeterType(song)
                if mt ~= '_MeterType_Default' then
                    local songXMode = mt ~= '_MeterType_DDR'
                    lastXMode = songXMode
                    return songXMode
                end
            end
            lastXMode = baseXMode
            return baseXMode
        end

        that.CurrentSongChangedMessageCommand = function(self, _) handler(self, true, check()) end
        for _, pn in pairs(PlayerNumber) do
            pn = ToEnumShortString(pn)
            that["CurrentSteps"..pn.."ChangedMessageCommand"] = function(self, _) handler(self, false, lastXMode) end
        end
    end
}