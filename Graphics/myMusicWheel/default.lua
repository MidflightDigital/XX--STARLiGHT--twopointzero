--[[
    Unified Small Grade Display
    pn: What do you think.
    index: Index of the score you want to pull.
    thing: Machine or Player Profile
    stype: OneSteps or CurrentSteps
    diff: Difficulty
]]

local args = {...}
local pn = args[1]
local index = args[2]
local thing = args[3]
local stype = args[4]
local diff = args[5]

return Def.ActorFrame{
    SetCommand=function(s)
        local fc = s:GetChild("FC")

        s:GetChild("Grade"):visible(false)
        fc:visible(false)

        local song = GAMESTATE:GetCurrentSong()
        if song then
            local steps
            local st = GAMESTATE:GetCurrentStyle():GetStepsType()
            if stype == "Current" then
                steps = GAMESTATE:GetCurrentSteps(pn)
            elseif stype == "One" then
                steps = song:GetOneSteps(st,diff)
            end
            local topscore = 0
            local topgrade
            local profile
            if steps then
                if thing == "Machine" then
                    profile = PROFILEMAN:GetMachineProfile()
                else
                    profile = PROFILEMAN:GetProfile(pn)
                end
                scorelist = profile:GetHighScoreList(song,steps)
                local scores = scorelist:GetHighScores()
                if scores[index] then
                    if ThemePrefs.Get("ConvertScoresAndGrades") then
                        topscore = SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[index])
                        topgrade = SN2Grading.ScoreToGrade(topscore,steps)
                    else
                        topscore = scores[index]:GetScore()
                        topgrade = scores[index]:GetGrade()
                    end
                    local RStats = scores[index]
                end

                if topscore ~= 0 then
                    local misses = RStats:GetTapNoteScore("TapNoteScore_Miss")+RStats:GetTapNoteScore("TapNoteScore_CheckpointMiss")
                    local boos = RStats:GetTapNoteScore("TapNoteScore_W5")
                    local goods = RStats:GetTapNoteScore("TapNoteScore_W4")
                    local greats = RStats:GetTapNoteScore("TapNoteScore_W3")
                    local perfects = RStats:GetTapNoteScore("TapNoteScore_W2")
                    local marvelous = RStats:GetTapNoteScore("TapNoteScore_W1")
                    s:GetChild("Grade"):visible(true):Load(THEME:GetPathG("myMusicWheel/GradeDisplayEval",ToEnumShortString(topgrade)))
                    if (misses+boos) == 0 and scores[index]:GetScore() > 0 and (marvelous+perfects)>0 then
                        fc:visible(true)
                        if (greats+perfects) == 0 then
                          fc:GetChild("FCStarColor"):diffuse(GameColor.Judgment["JudgmentLine_W1"])
                          :glowblink():effectperiod(0.20)
                        elseif greats == 0 then
                            fc:GetChild("FCStarColor"):diffuse(GameColor.Judgment["JudgmentLine_W2"])
                          :glowshift()
                        elseif (misses+boos+goods) == 0 then
                            fc:GetChild("FCStarColor"):diffuse(GameColor.Judgment["JudgmentLine_W3"])
                          :stopeffect()
                        elseif (misses+boos) == 0 then
                            fc:GetChild("FCStarColor"):diffuse(GameColor.Judgment["JudgmentLine_W4"])
                            :stopeffect()
                        end;
                    end
                end
            end
        end
    end,
    Def.Sprite{
        Name="Grade",
    },
    Def.ActorFrame{
        Name="FC",
        InitCommand=function(s) s:zoom(0.4):xy(14,5) end,
        Def.Sprite{
            Name="FCStar",
            Texture="star.png",
        },
        Def.Sprite{
            Name="FCStarColor",
            Texture="colorstar.png",
        }
    },
}