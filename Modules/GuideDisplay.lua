--GuideDisplay
--This handles figuring out what beat bars should be displayed.
--It doesn't actually handle drawing them at all, that's the responsibility
--of a different piece of code.

if StarlightCache and StarlightCache.GuideDisplay then
    return StarlightCache.GuideDisplay
end



--[[About visual units (vus)
A visual unit is the amount of space that 1 beat takes up on screen at 1x, or
that 1 second takes up at C60. You can convert pixels to visual units by
dividing them by the arrow spacing and vice versa.
]]

local GuideDisplay = {}

--Returns whether the mod is in beats per visual unit (not cmod) or not (cmod)
--and its value in base form, which ends up being a visual unit multiplier
local function ModTypeAndValue(gf)
    local po = gf.ps:GetCurrentPlayerOptions()
    local cmod = po:CMod()
    if cmod then
        return false, cmod/60
    else
        local mmod = po:MMod()
        if mmod then
            return true, mmod/gf.read_bpm
        else
            return true, po:XMod()
        end
    end
end

local function sort_by_first_entry(tbl)
    return table.sort(tbl, function(a, b) return a[1] < b[1] end)
end

function GuideDisplay:SetSongAndSteps(song, steps)
    local timing = steps:GetTimingData()
    local last_beat = song:GetLastBeat()
    self.last_beat = last_beat
    self.last_second = song:GetLastSecond()
    self.read_bpm = CalculateReadBPM(song)

    --I don't know how fast GetElapsedTimeFromBeat is, but my guess is calling
    --it over and over again from Lua isn't a great idea, so cache it.
    local beat_times = {}
    self.beat_times = beat_times
    --The way this works is that Lua checks the table for a value with the
    --given key. If it can find one, that is the result. If it can't, it
    --calls the __index function, which uses rawset to add it to the table
    --for future lookups.
    local bt_metatable = {
        __index = function(me, key)
            local value = timing:GetElapsedTimeFromBeat(key)
            rawset(me, key, value)
            return value
        end
    }
    setmetatable(beat_times, bt_metatable)

    local has_speeds = timing:HasSpeedChanges()
    self.has_speeds = has_speeds
    
    if has_speeds then

        local raw_speeds = timing:GetSpeeds(true)
        --Speed segments have a bunch of implicitly defined properties, so let's
        --precalculate some of them so there's less work for GetCurrentSpeed to
        --do later.
        local speed_descriptions = {}
        self.speeds = speed_descriptions
        local speed_count = #raw_speeds

        --Keep track of the previous_speed, as that is needed for each entry.
        --The whole point of this exercise is to allow GetCurrentSpeed to 
        --determine the current speed by looking at one table entry.
        local previous_speed = 1

        --As far as I can tell, it is possible for a speed segment to end earlier
        --than it is supposed to end. Also, as far as I can tell, this means that
        --you have to calculate what the speed is when it actually ends.
        --This does that.
        local function EarlyCutoff(end_speed, start_point, end_point, next_start)
            --This computes how far the segment will be through its nominal
            --speed transition when it ends, then multiplies that by the amount
            --of speed the segment gains and adds that to the starting speed.
            return previous_speed+
            (end_speed - previous_speed)
            *(next_start - start_point)/(end_point - start_point)
        end


        for speed_idx=1,speed_count do
            local raw_entry = raw_speeds[speed_idx]
            --This will be the result. It will use named keys instead to make
            --the code below easier to understand.
            local baked_entry = {}

            local start_beats = raw_entry[1]
            baked_entry.start_beats = start_beats

            --This is a true/false value stored as a number.
            local is_time_mode = raw_entry[4] == 1
            baked_entry.time_mode = is_time_mode

            --Broadly, this code is the same whether this is a time or beats
            --based segment, with the exception of these three variables.
            local start_point, end_point, next_start
            if is_time_mode then
                start_point = beat_times[start_beats]
                baked_entry.start_time = start_point
                end_point = start_point + raw_entry[3]
            else
                start_point = start_beats
                baked_entry.start_beats = start_beats
                end_point = start_beats + raw_entry[3]
            end

            local next_idx = speed_idx+1
            if next_idx <= speed_count then
                next_start = raw_speeds[next_idx][1]
                if is_time_mode then
                    next_start = beat_times[next_start]
                end
            end

            baked_entry.start_speed = previous_speed
            local end_speed = raw_entry[3]

            if next_start < end_point then
                --this speed was cutoff early, calculate what the real ending speed is
                end_speed = EarlyCutoff(end_speed, start_point,
                end_point, next_start)
            end

            baked_entry.delta = end_speed - previous_speed

            self.speeds[speed_idx] = baked_entry
        end
        self.speed_start = 1
    end

    local last_beat = math.floor(last_beat)

    --Thanks to scroll changes, this is a pain
    local beat_vus = {}
        
    local scroll_descriptions = {}
    self.scrolls = scroll_descriptions
    local raw_scrolls = timing:GetScrolls(true)
    
    --If any scrolls are equal to or less than 0, there are special considerations
    --(basically, there needs to be a little extra data stored and an extra step at runtime)
    local has_negative_or_zero_scrolls = false
    for _, scroll in pairs(raw_scrolls) do
        if scroll[2] <= 0 then
            has_negative_or_zero_scrolls = true
            break
        end
    end
    self.has_negative_or_zero_scrolls = has_negative_or_zero_scrolls
    
    local current_beat = 0
    local accumulated_vus = 0
    --these are updated in the loop
    local previous_scroll_value = nil 
    local previous_start_beats = nil
    local num_scrolls = #raw_scrolls
        
    --Scroll segments are not necessarily beat aligned. Because of that, unlike the rest of this code,
    --we have to work in the scroll segment space.
    for scroll_idx = 1, num_scrolls do
        local raw_scroll = raw_scrolls[scroll_idx]
        local start_beats, scroll_value = raw_scroll[1], raw_scroll[2]

        --accumulate the vus from the last scroll segment
        if scroll_idx > 1 then
            accumulated_vus = accumulated_vus + (start_beats-previous_start_beats) * previous_scroll_value
        end
            
        --The end beat of the scroll segment is the start beat of the next one, unless there isn't a next one.
        local end_beats = last_beat
        if scroll_idx + 1 <= num_scrolls then
            end_beats = raw_scrolls[scroll_idx+1][1]
        end

        --prepare this for calculating number of vus during gameplay
        local scroll_description = {start_beats=start_beats, end_beats=end_beats, value=scroll_value, start_vus=accumulated_vus}
        --hack to make the finding functions we have work for these too
        scroll_description[1] = start_beats
        scroll_descriptions[scroll_idx] = scroll_description
        

        --calculate the VU position of each beat that occurs during this scroll segment.
        while current_beat < end_beats do
            beat_vus[#beat_vus+1] = {accumulated_vus+(current_beat-start_beats)*scroll_value, current_beat}
            current_beat = current_beat + 1
        end

        previous_scroll_value = scroll_value
        previous_start_beats = start_beats
    end

    sort_by_first_entry(beat_vus)
    self.beat_vus = beat_vus

    local time_vus = {}
    self.time_vus = time_vus
    --This is pretty complicated, but thankfully there is a function that takes
    --care of all of the hard work so this code ends up pretty simple.
    for beat=0,last_beat do
        time_vus[#time_vus+1] = beat_times[beat]
    end
    --no sort needed, because these are always going to increase
end

--You'd think there would be a way to get the current speed, but nope.
local function GetCurrentSpeed(self, current_beats, current_time)
    if not self.has_speeds then
        return 1
    end

    --save the current speed so there's no need to waste time with passed speeds.
    local speed_idx = self.speed_start
    local speed = self.speeds
    local current_speed = speed[speed_idx]

    while current_speed.start_beats < current_beats do
        if speed_idx == #speed then break end

        speed_idx = speed_idx + 1
        current_speed = speed[speed_idx]
    end

    self.speed_start = speed_idx

    local result = current_speed.start_speed
    local duration = current_speed.duration
    if duration > 0 then
        if current_speed.time_mode then
            result = result + (current_speed.delta*(current_time-current_speed.start_time))
        else
            result = result + (current_speed.delta*(current_beats-current_speed.start_beats))
        end
    else
        result = current_speed.start_speed + current_speed.delta
    end

    return result
end

--XXX this function is kind of inefficient, the guess is mainly there to make it less inefficient
local function find_nearest_index(list, target, guess, prefer_forward)
    guess = guess or 1
    local list_len = #list

    --doesn't handle nan because it should never get nan
    local function sign(num)
        if num < 0 then
            return -1
        elseif num > 0 then
            return 1
        else
            return 0
        end
    end
 
    local current_idx = guess
    local last_idx
    local last_difference
    local current_difference = list[current_idx][1] - target
    
    --did we overshoot? back it up
    while current_difference > 0 and current_idx > 1 do
        current_idx = current_idx - 1
        current_difference = list[current_idx][1]
    end

    if (current_difference >= 0 and current_idx == 1) or (current_idx == list_len and current_difference <= 0) then
        return current_idx
    end

    repeat
        if current_difference == 0 then
            return current_idx
        end
        last_idx = current_idx
        current_idx = current_idx + 1
        last_difference = current_difference
        current_difference = list[current_idx][1] - target
    until sign(current_difference) ~= sign(last_difference) or current_idx == list_len

    return prefer_forward and last_idx or current_idx
end

local function find_start_and_end_positions(current_vus, vusBack, vusForward, vu_scale, vu_array, start_guess)
    local first_vu = current_vus-vusBack
    local start_position = find_nearest_index(vu_array, first_vu, 1, false)
    local last_vu = current_vus+vusForward
    local end_position = find_nearest_index(vu_array, last_vu, 1, true)

    return start_position, end_position
end

--vusBack is the number of visual units back the guide display should go
--vusForward is the number of visual units forward the guide display should go
function GuideDisplay:GetPositions(vusBack, vusForward, finalScale)
    finalScale = finalScale or 1
    --The scale is the amount of visual units one base unit (i.e. a beat or second) takes up on screen.
    --For amods, mmods, and xmods, this is the effective xmod.
    --For cmods, this is the cmod divided by 60 (the cmod at which 1 VU = 1 second)
    --This provides the effects of speed modifiers and lets us skip rendering things within
    --range that wouldn't actually be visible.
    local isBeats, vu_scale = ModTypeAndValue(self)
    local pos = self.ps:GetSongPosition()
    local current_time = pos:GetMusicSeconds()
    
    local out = {}
    if isBeats then

        local beat_vus = self.beat_vus
        local current_vus, first_vu, last_vu
        local absolute_last_beat = self.last_beat
        local has_negative_or_zero_scrolls = self.has_negative_or_zero_scrolls
	
        --Xmod/Mmod/Amod time.
        --Scroll segments make this a bit more complicated than it would
        --otherwise be, as they essentially are a VU multiplier.
        --If there are no scroll segments, we can cheat.
        local current_beats = pos:GetSongBeat()
        vu_scale = vu_scale * GetCurrentSpeed(self, current_beats, current_time)
        local current_scroll_index = 1
        local scrolls = self.scrolls
        if scrolls then
            --This is the usual case.
            local only_one_scroll = #scrolls == 1
            
            if only_one_scroll then
                current_vus = scrolls[1].value * current_beats
            else
                current_scroll_index = find_nearest_index(scrolls, current_beats, 1, false)
                local current_scroll = scrolls[current_scroll_index]

                current_vus = (current_scroll.start_vus
                    + (current_beats-current_scroll.start_beats)*current_scroll.value)
            end
        else
            current_vus = 0
        end

        local start_position, end_position =
        find_start_and_end_positions(current_vus, vusBack, vusForward, vu_scale, beat_vus, self.beat_vu_guess)
        self.beat_vu_guess = start_position

        local final_vu_scale = vu_scale * finalScale

        for idx=start_position, end_position do
            local line_obj = beat_vus[idx]
            out[#out+1] = {line_obj[2], (line_obj[1] - current_vus) * final_vu_scale}
        end
        --debugging code, enable if you're trying to debug charts with scroll problems
        --print(("guidedisplay: scroll: %d vus: %f start: %f end: %f"):format(current_scroll_index, current_vus, start_position, end_position))

        if has_negative_or_zero_scrolls then
            --It's entirely possible that these won't be in the proper beat order, which they need to be.
            --So we need to sort them again.
            sort_by_first_entry(out)
        end

    else

        --Cmod time.
        --Thankfully, the engine makes this relatively simple by exposing
        --GetBeatFromElapsedTime, which is all we need.
        local time_vus = self.time_vus

        local current_vus = current_time*vu_scale
        local start_position, end_position
        find_start_and_end_positions(current_vus, vusBack, vusForward, vu_scale, time_vus, self.time_vu_guess)
        self.time_vu_guess = start_position
        vu_scale = vu_scale * finalScale

        for idx=start_position, end_position do
            local line_obj = time_vus[idx]
            out[#out+1] = {line_obj[2], (line_obj[1]- current_vus) * vu_scale}
        end

    end

    return out
end

local mt_gd = {__index=GuideDisplay}

setmetatable(GuideDisplay, {__call=function(_, pn)
    local out = {}
    setmetatable(out, mt_gd)
    out.ps = GAMESTATE:GetPlayerState(pn)
    
    return out
end})

if StarlightCache then
    StarlightCache.GuideDisplay = GuideDisplay
end
return GuideDisplay
