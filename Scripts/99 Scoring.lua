--[[Scoring.lua
This includes a couple modules that all have to do with scoring and grading.
SN2Grading partially depends on SN2Scoring.
All information used is from http://aaronin.jp/ddrssystem.html. The
information used for A was written by Aaron C.
Note that a bunch of functions Starlight doesn't use have been removed.
]]

--SN2Scoring
--Implements the scoring system used by DDR A. Yes, I know about the name.

--Shared functions/data

SN2Scoring = {}
local maxNoteValues =
{
    TapNoteScore_W1 = 1,
    TapNoteScore_W2 = 1,
    TapNoteScore_W3 = 1,
    TapNoteScore_W4 = 1,
    TapNoteScore_W5 = 1,
    TapNoteScore_Miss = 1
}

local maxHoldValues =
{
    HoldNoteScore_Held = 1,
    HoldNoteScore_LetGo = 1,
    HoldNoteScore_MissedHold = 1
}

--Given a thing which has functions hnsFuncName and tnsFuncName that take one
--argument and return the number of TNSes or HNSes there are in that thing,
--pack that information into something useful.
--This is a pretty bad function description, so just see how it's used.
local function GetScoreDataFromThing(thing)
    local tnsFuncName, hnsFuncName
    if     lua.CheckType('HighScore',        thing) then tnsFuncName, hnsFuncName = 'GetTapNoteScore',  'GetHoldNoteScore'
    elseif lua.CheckType('PlayerStageStats', thing) then tnsFuncName, hnsFuncName = 'GetTapNoteScores', 'GetHoldNoteScores'
    else
        error('First argument is not HighScore or PlayerStageStats')
    end
    
    local output = {}
    --how class function lookup works internally in Lua
    local hnsFunc = thing[hnsFuncName]
    local tnsFunc = thing[tnsFuncName]
    local total = 0
    local value = 0
    for tns, _ in pairs(maxNoteValues) do
        value = tnsFunc(thing, tns)
        output[tns] = value
        total = total + value
    end
    for hns, _ in pairs(maxHoldValues) do
        value = hnsFunc(thing, hns)
        output[hns] = value
        total = total + value
    end
    output.Total = total
    return output
end

function SN2Scoring.GetCurrentScoreData(HSorPSS, judgment)    
    local scoreData = GetScoreDataFromThing(HSorPSS)
    --workaround for the fact that the current TNS or HNS won't have been
    --added to the PSS yet.
    if judgment and scoreData[judgment] then
        scoreData[judgment] = scoreData[judgment] + 1
        scoreData.Total = scoreData.Total + 1
    end
    return scoreData
end

--The multiplier tables have to be filled in completely.
--However, the deduction ones do not.
local normalScoringRules =
{
    multipliers =
    {
        TapNoteScore_W1 = 1,
        TapNoteScore_W2 = 1,
        TapNoteScore_W3 = 0.6,
        TapNoteScore_W4 = 0.2,
        TapNoteScore_W5 = 0.2
    },
    deductions =
    {
        TapNoteScore_W2 = 10,
        TapNoteScore_W3 = 10,
        TapNoteScore_W4 = 10,
        TapNoteScore_W5 = 10
    }
}

--data format for this function:
--a table with a count of total holds, rolls, and taps called "Total"
--all earned TapNoteScores in the class W1-W5 and Miss under their native names
--all earned HoldNoteScores
function SN2Scoring.ComputeNormalScoreFromData(data, max)
    local objectCount = data.Total
    local maxScore = 1000000
    local maxFraction = 0
    local totalDeductions = 0
    local tnsMultipliers, hnsMultipliers, deductions
    if max then
        tnsMultipliers = maxNoteValues
        hnsMultipliers = maxHoldValues
        deductions = {}
    else
        tnsMultipliers = normalScoringRules.multipliers
        hnsMultipliers = {HoldNoteScore_Held = 1}
        deductions = normalScoringRules.deductions
    end
    local scoreCount
    for tns, multiplier in pairs(tnsMultipliers) do
        scoreCount = data[tns]
        maxFraction = maxFraction + scoreCount * multiplier
        totalDeductions = totalDeductions + scoreCount * (deductions[tns] or 0)
    end
    for hns, multiplier in pairs(hnsMultipliers) do
        scoreCount = data[hns]
        maxFraction = maxFraction + scoreCount * multiplier
    end
    return math.floor(((maxFraction/objectCount) * maxScore - totalDeductions)/10 + 0.5)*10
end

local exScoringTapValues =
{
    TapNoteScore_W1 = 3,
    TapNoteScore_W2 = 2,
    TapNoteScore_W3 = 1
}

function SN2Scoring.ComputeEXScoreFromData(data,max)
    local finalMultiplier = max and 3 or 1
    local tnsValues, hnsValues
    if max then
        tnsValues = maxNoteValues
        hnsValues = maxHoldValues
    else
        tnsValues = exScoringTapValues
        hnsValues = {HoldNoteScore_Held = 3}
    end
    local scoreCount
    local totalScore = 0
    for tns, value in pairs(tnsValues) do
        scoreCount = data[tns]
        totalScore = totalScore + scoreCount * value
    end
    for hns, value in pairs(hnsValues) do
        scoreCount = data[hns]
        totalScore = totalScore + scoreCount * value
    end
    return totalScore * finalMultiplier
end

function SN2Scoring.GetSN2ScoreFromHighScore(steps, HSorPSS)
    local scoreData = GetScoreDataFromThing(HSorPSS)
    local radar = steps:GetRadarValues(pn)
    scoreData.Total = radar:GetValue('RadarCategory_TapsAndHolds')+
        radar:GetValue('RadarCategory_Holds')+radar:GetValue('RadarCategory_Rolls')
    return SN2Scoring.ComputeNormalScoreFromData(scoreData)
end


--SN2Grading
--Implements the grading system used by DDR A. As above.

SN2Grading = {}
local grade_table = {
    Grade_Tier01 = 1000000, --AAA+
    Grade_Tier02 = 990000, --AAA
    Grade_Tier03 = 950000, --AA+
    Grade_Tier04 = 900000, --AA
    Grade_Tier05 = 890000, --AA-
    Grade_Tier06 = 850000, --A+
    Grade_Tier07 = 800000, --A
    Grade_Tier08 = 790000, --A-
    Grade_Tier09 = 750000, --B+
    Grade_Tier10 = 700000, --B
    Grade_Tier11 = 690000, --B-
    Grade_Tier12 = 650000, --C+
    Grade_Tier13 = 600000, --C
    Grade_Tier14 = 590000, --C-
    Grade_Tier15 = 550000, --D+
    Grade_Tier16 = 500000, --D
    Grade_Tier17 = 0, --D
}

function SN2Grading.ScoreToGrade(score)
    local output = nil
    local best = 0
    for grade, min_score in pairs(grade_table) do
        if score >= min_score and min_score >= best then
            output = grade
            best = min_score
        end
    end
    return output
end

--returns score too because what the hell
function SN2Grading.GetSN2GradeFromHighScore(steps, highScore)
    local score = SN2Scoring.GetSN2ScoreFromHighScore(steps, highScore)
    return SN2Grading.ScoreToGrade(score), score
end

function GetTotalItems(radars)
	local total = radars:GetValue('RadarCategory_TapsAndHolds')
	total = total + radars:GetValue('RadarCategory_Mines') 
	total = total + radars:GetValue('RadarCategory_Holds') 
	total = total + radars:GetValue('RadarCategory_Rolls')
	return math.max(1,total)
end

function GetResultScore(rv, pss)
	local totalItems = GetTotalItems(rv)
	local stepScore = round(1000000/totalItems,3)
	local score = 0
	local s = {}
	
	s[#s+1] = pss:GetTapNoteScores('TapNoteScore_W1')*stepScore
	s[#s+1] = pss:GetTapNoteScores('TapNoteScore_W2')*(stepScore-10)
	s[#s+1] = pss:GetTapNoteScores('TapNoteScore_W3')*((stepScore*0.6)-10)
	s[#s+1] = pss:GetTapNoteScores('TapNoteScore_W4')*((stepScore*0.2)-10)
	s[#s+1] = pss:GetHoldNoteScores('HoldNoteScore_Held')*stepScore
	s[#s+1] = pss:GetTapNoteScores('TapNoteScore_AvoidMine')*stepScore
	
	for i,v in ipairs(s) do
		score = score + v
	end
	
	return round(score,-1)
end

-- (c) 2015-2020 tertu marybig, Inorizushi
-- All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, and/or sell copies of the Software, and to permit persons to
-- whom the Software is furnished to do so, provided that the above
-- copyright notice(s) and this permission notice appear in all copies of
-- the Software and that both the above copyright notice(s) and this
-- permission notice appear in supporting documentation.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
-- OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF
-- THIRD PARTY RIGHTS. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR HOLDERS
-- INCLUDED IN THIS NOTICE BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL INDIRECT
-- OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
-- OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
-- OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
-- PERFORMANCE OF THIS SOFTWARE.
