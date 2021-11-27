local st_rev = Enum.Reverse(StepsType)
local diff_rev = Enum.Reverse(Difficulty)

ClearLampColors = {
	[0]={1,1,1,0},
	color "#555452",
	color "#f70b9e",
	GameColor.Judgment["JudgmentLine_W4"],
	GameColor.Judgment["JudgmentLine_W3"],
	GameColor.Judgment["JudgmentLine_W2"],
	GameColor.Judgment["JudgmentLine_W1"]
};

local BestGetHighScoreList;
if Profile.GetHighScoreListIfExists then
	BestGetHighScoreList = Profile.GetHighScoreListIfExists;
else
	BestGetHighScoreList = Profile.GetHighScoreList;
end;


return {
    --returns -1 if a < b, 0 if a == b, or 1 if a > b according to the typical
    --StepMania sort order, a la strcmp or C++'s spaceship operator
    --this function is basically a direct translation of the C++ code path that
    --SongUtil.GetPlayableSteps uses so it *should* return identical results.
    CompareSteps=function(a, b)
        local st_a = st_rev[a:GetStepsType()]
        local st_b = st_rev[b:GetStepsType()]
        if st_a ~= st_b then
            return st_a < st_b and -1 or 1
        end

        local diff_a = diff_rev[a:GetDifficulty()]
        local diff_b = diff_rev[b:GetDifficulty()]
        if diff_a ~= diff_b then
            return diff_a < diff_b and -1 or 1
        end
        
        local meter_a = a:GetMeter()
        local meter_b = b:GetMeter()
        if meter_a ~= meter_b then
            return meter_a < meter_b and -1 or 1
        end

        --note: PLAYER_1 is also used in the C++ code
        local taps_a = a:GetRadarValues(PLAYER_1):GetValue 'RadarCategory_TapsAndHolds'
        local taps_b = b:GetRadarValues(PLAYER_1):GetValue 'RadarCategory_TapsAndHolds'
        if taps_a ~= taps_b then
            return taps_a < taps_b and -1 or 1
        end

        local desc_a = a:GetDescription() 
        local desc_b = b:GetDescription()
        if desc_a == desc_b then
            return 0
        else
            return desc_a < desc_b and -1 or 1
        end
    end,
    SameDiffSteps=function(song,pn)
        if song then
            local diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty()
            local st = GAMESTATE:GetCurrentStyle():GetStepsType()
            return song:GetOneSteps(st,diff)
        end
    end,
    ClearLamp=function(song,steps,pn)
        local best_lamp = 0; --No Play
	    if PROFILEMAN:IsPersistentProfile(pn) then
		    local prof = PROFILEMAN:GetProfile(pn);
		    local st = GAMESTATE:GetCurrentStyle():GetStepsType();
		    local list = BestGetHighScoreList(prof, song, steps);
		    if list then
		    	for score in ivalues(list:GetHighScores()) do
		    		local this_lamp = 0;
		    		if score:GetGrade() == 'Grade_Failed' then
		    			this_lamp = 1; --Failed
		    		else
		    			local missed_nontaps = (score:GetHoldNoteScore'HoldNoteScore_LetGo'
		    			+ score:GetHoldNoteScore'HoldNoteScore_MissedHold'
		    			+ score:GetTapNoteScore'TapNoteScore_HitMine')>0
		    			if missed_nontaps or score:GetTapNoteScore'TapNoteScore_Miss'>0 then
		    				this_lamp = 2; --Cleared
		    			elseif score:GetTapNoteScore'TapNoteScore_W5'>0
		    				or score:GetTapNoteScore'TapNoteScore_W4'>0
		    			then
		    				this_lamp = 3; --Good FC
		    			elseif score:GetTapNoteScore'TapNoteScore_W3'>0 then
			    			this_lamp = 4; --Great FC
			    		elseif score:GetTapNoteScore'TapNoteScore_W2'>0 then
			    			this_lamp = 5; --Perfect FC
			    		elseif score:GetTapNoteScore'TapNoteScore_W1'>0 then
			    			--no reason to keep searching, this is the best one
			    			return 6; --Marvelous FC
			    		else
			    			--this means the chart has no notes.
			    			--treat this as a normal clear.
			    			return 2; --Cleared
			    		end;
			    	end;
			    	if this_lamp > best_lamp then
			    		best_lamp = this_lamp;
			    	end;
			    end;
		    end;
	    end;
	    return best_lamp;
    end,
}