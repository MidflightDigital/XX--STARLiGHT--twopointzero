local readBPM = nil

return Def.Actor{
    DoneLoadingNextSongMessageCommand=function()
        readBPM = CalculateReadBPM(GAMESTATE:GetCurrentSong())
    end,
    CodeMessageCommand=function(_,p)
        local increasing_speed

        local code_name = p.Name
        if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") and not SCREENMAN:GetTopScreen():IsPaused() then
            if code_name == "SpeedUp" then
                increasing_speed = true
            elseif code_name == "SpeedDown" then
                increasing_speed = false
            else
                return
            end
        else
            if code_name == "SpeedUp2" then
                increasing_speed = true
            elseif code_name == "SpeedDown2" then
                increasing_speed = false
            else
                return
            end
        end

        local playerState = GAMESTATE:GetPlayerState(p.PlayerNumber)
        local playerOptions = playerState:GetPlayerOptions("ModsLevel_Preferred")

        local cur_cmod = playerOptions:CMod()
        local cur_xmod = playerOptions:XMod()
        local cur_mmod = playerOptions:MMod()

        --[[
        There are a couple different reasons we may want to disable a player.
        Given that each mod type supported in 5.1 needs special consideration,
        an added type, like 5.3's A mods, would likely need special consideration
        as well, so changing it without knowing what that would be is likely
        a bad idea.
        If the read BPM is 0, trying to calculate an X mod for the mmod would
        return infinity, and that has to be done, so don't try.
        --]]

        if not (cur_xmod or cur_mmod or cur_cmod) or (cur_mmod and readBPM == 0) then
            return
        end

        --Now the player must be using an X, M, or C mod, so assumptions can
        --be made based on that.
        local new_speedmod
        if cur_mmod then
            new_speedmod = cur_mmod
        elseif cur_cmod then
            new_speedmod = cur_cmod
        else
            new_speedmod = cur_xmod
        end

        local speedmod_increment, top_cap
        if cur_mmod or cur_cmod then
            speedmod_increment = 50
            bottom_cap = 100
            top_cap = 800
        else
            speedmod_increment = 0.25
            bottom_cap = 0.25
            top_cap = 8
        end


        --round the value to a multiple of speedmod_increment
        new_speedmod = math.floor(new_speedmod / speedmod_increment + 0.5) * speedmod_increment

        if not increasing_speed then
            if new_speedmod ~= bottom_cap then
                speedmod_increment = -speedmod_increment
            else
                speedmod_increment = 0
            end
        end

        new_speedmod = math.max(speedmod_increment, new_speedmod + speedmod_increment)
        new_speedmod = math.min(new_speedmod, top_cap)

        if cur_mmod then
            --For some reason mmods can't be changed properly during gameplay.
            --Set the mmod, but set an equivalent xmod as well.
            playerOptions:MMod(new_speedmod)
            playerOptions:XMod(new_speedmod/readBPM)
        elseif cur_cmod then
            playerOptions:CMod(new_speedmod)
        else
            playerOptions:XMod(new_speedmod)
        end

        playerState:ApplyPreferredOptionsToOtherLevels()
    end,
  }