local yield = coroutine.yield

return {
	{
		Name = "LifeTracker";
    	Requires = {};
    	IgnoreMines = false;
    	IgnoreCheckpoints = false;
		CourseBehavior = 'PerCourse';
    	Code = function()
    		local varTable = {Worst=math.huge, Best=-math.huge}
    		local params = yield(varTable)
    		while not params.Finalize do
    			local life = params.PSS:GetCurrentLife()
    			varTable.Worst = math.min(life, varTable.Worst)
    			varTable.Best = math.max(life, varTable.Best)
    			params = yield(varTable)
    		end
    	end;
    };
	{
		Name = "AScoring";
		Requires = {'LifeTracker'};
		IgnoreMines = false;
		IgnoreCheckpoints = true;
		CourseBehavior = 'PerCourse';
		Code = function(pn, song, steps, course, trail)
			local function rvMaxRawScore(rv)
				return 5*(rv:GetValue'RadarCategory_TapsAndHolds'
				+rv:GetValue'RadarCategory_Holds'+rv:GetValue'RadarCategory_Rolls'
				+rv:GetValue'RadarCategory_Mines')
    		end
			local maxRawScore = 0
    		if trail then
				local rv = trail:GetRadarValues()
				--for certain courses StepMania just doesn't fill in the RadarValues.
    			if rv:GetValue'RadarCategory_TapsAndHolds' ~= -1 then
    				maxRawScore = rvMaxRawScore(rv)
    			else
    				for entry in values(trail:GetTrailEntries()) do
    					maxRawScore = rvMaxRawScore(entry:GetSteps():GetRadarValues(pn))
    					+ maxRawScore
    				end
    			end
    		else
				maxRawScore = rvMaxRawScore(steps:GetRadarValues(pn))
    		end
			local varTable = {Score=0, MaxScore=0}
			local cur_maxRawScore = 0; local rawScore = 0; local deductions = 0;
    		local failOn = 
    		GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions():FailSetting() ~= 'FailType_Off'

			while true do
				local params, data = yield(varTable)
				if params.Finalize then return varTable end
				cur_maxRawScore = cur_maxRawScore + 5
				varTable.MaxScore = math.floor(cur_maxRawScore/maxRawScore*100000+0.5)*10
				local tns = params.TNS
				if params.PSS:GetFailed() or (failOn and data.LifeTracker.Worst <= 0) then
					--do nothing for this note besides increase max score
				elseif params.HNS then
					if params.HNS == 'Held' then
						rawScore = rawScore + 5
					end
				elseif tns then
					if tns == 'W1' or tns == "AvoidMine" then
						rawScore = rawScore + 5
    					elseif tns ~= 'Miss' and tns ~= "HitMine" then
    						deductions = deductions + 1
						if tns == 'W2' then
							rawScore = rawScore + 5
						elseif tns == 'W3' then
							rawScore = rawScore + 3
    						else
    							rawScore = rawScore + 1
    						end
    					end
				end
				varTable.Score = math.floor(rawScore/maxRawScore*100000-deductions+0.5)*10
			end
		end
	},
	{
		Name = "DDRComboState";
		IgnoreMines = true;
		IgnoreCheckpoints = true;
		CourseBehavior = 'PerCourse';
		Code = function()
			local varTable = {Current='TapNoteScore_Miss'}
			local r = Enum.Reverse(TapNoteScore)
			local minimum = r[THEME:GetMetric("Gameplay", "MinScoreToMaintainCombo")]
			local curValue = r.TapNoteScore_Miss
			while true do
				local params = yield(varTable)
				if params.Finalize then return varTable end
				if not params.HNS then
					local tns = params.Original.TapNoteScore
					local value = r[tns]
					if (curValue < minimum and value >= minimum) or value < curValue then
						varTable.Current = tns
						curValue = value
					end
				end
			end
		end
	},
	{
        --NB: Most of the stats modules don't depend on anything outside of StatsEngine, but this one does.
		Name = "XXComboState";
    	IgnoreMines = false;
		IgnoreCheckpoints = true;
    	Requires = {"DDRComboState"};
    	CourseBehavior = "PerCourse";
    	Code = function()
    		local r = Enum.Reverse(TapNoteScore)
			local minimum = r[THEME:GetMetric("Gameplay", "MinScoreToMaintainCombo")]
    		local colorMode = ThemePrefs.Get "ComboColorMode"
    		local lenientColoring = colorMode == "arcade" or colorMode == "waiei"
    		local waiei = colorMode == "waiei"
    		colorMode = nil
    		local varTable = {Label="LabelNormal", Number="NumberNormal"}
    		while true do
    			local params, data = yield(varTable)
				if params.Finalize then return varTable end
				
				--if there have only been mines since the song started,
				--DDRComboState won't have loaded yet. Handle that.
				local ddrCombo = data.DDRComboState
				local curBase
				if ddrCombo then
					curBase = ddrCombo.Current
				else
					curBase = 'TapNoteScore_Miss'
				end

    			curBase = (curBase == 'TapNoteScore_W5') and 'TapNoteScore_W4' or curBase
    			local short = ToEnumShortString(curBase)
    			if params.PSS:FullComboOfScore(minimum) then
    				varTable.Label = "Label"..short
    				varTable.Number = "Number"..short
    			elseif r[curBase] >= minimum and lenientColoring then
    				varTable.Number = "Number"..short
    				if waiei then
    					varTable.Label = "LabelNormal"
    				else
    					varTable.Label = "Label"..short
    				end
    			else
    				--there were no taps this combo
    				varTable.Label = "LabelNormal"
    				varTable.Number = "NumberNormal"
    			end
    		end
    	end
    },
	{
		Name = "FastSlowRecord";
		IgnoreMines = true;
		IgnoreCheckpoints = true;
		CourseBehavior = 'PerCourse'; 
		Code = function()
			local varTable = {Fast=0,Slow=0,Just=0}
			local tnsToIgnore = {Miss=true}
			local tns
			local showW1 = GAMESTATE:ShowW1()
			while true do
				local params = yield(varTable)
				tns = params.TNS
				if params.Finalize then return varTable end
				if not (params.HNS or tnsToIgnore[tns]) then
					local offset = params.Offset
					if ((not showW1) and tns == 'W2') or tns == 'W1' then
						varTable.Just = varTable.Just + 1
					elseif offset > 0 then
						varTable.Slow = varTable.Slow + 1
					elseif offset < 0 then
						varTable.Fast = varTable.Fast + 1
					else
						--this should never happen
						Warn(string.format("FastSlowRecord hit fallback case, marking Just. offset=%f, tns=%s", offset, tns)) 
						varTable.Just = varTable.Just + 1
					end 
				end 
			end
		end
	},
	{
		Name = "EXScore";
    	Requires = {'LifeTracker'};
    	IgnoreMines = false;
    	IgnoreCheckpoints = true;
    	CourseBehavior = 'PerCourse';
    	Code = function(pn)
    		local varTable = {Score=0,MaxScore=0}
    		local values = {W1=3, W2=2, W3=1, AvoidMine=3}
			local failOn =
    		GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions():FailSetting() ~= 'FailType_Off'
    		while true do
    			local params, data = yield(varTable)
    			if params.Finalize then return varTable end
    			varTable.MaxScore = varTable.MaxScore + 3
				if params.PSS:GetFailed() or (failOn and data.LifeTracker.Worst <= 0) then
				--do nothing
    			elseif not params.HNS then
					local points = values[params.TNS] or 0
    				varTable.Score = varTable.Score + points
    			elseif params.HNS == 'Held' then
    				varTable.Score = varTable.Score + 3
    			end
    		end
    	end
	}
}
