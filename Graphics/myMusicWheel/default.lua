--[[
  Unified Small Grade Display
  pn: Player number for grade display
  index: Index of the score you want to pull
  profileType: use Machine or Player Profile
  stepType: "Current" for current step, or "One" to select a specific difficulty
  diff: Difficulty if stepType == "One"
--]]

-- This file is mostly deprecated after the adoptation of the ScoreAndGrade module directly 
-- into code that wants to display a grade. If you prefer to still use this file then you can, 
-- as it's now a just a wrapper around the ScoreAndGrade.CreateGradeActor() function.
  
local args = {...}
local pn = args[1]
local index = args[2]
local profileType = args[3]
local stepType = args[4]
local diff = args[5]
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

return ScoreAndGrade.CreateGradeActor{
  Name='Grade',
  SetCommand=function(self)
    local SongOrCourse, StepsOrTrail
    if GAMESTATE:IsCourseMode() then
      SongOrCourse = GAMESTATE:GetCurrentCourse()
      StepsOrTrail = GAMESTATE:GetCurrentTrail(pn)
    else
      SongOrCourse = GAMESTATE:GetCurrentSong()
      if stepType == 'Current' then
        StepsOrTrail = GAMESTATE:GetCurrentSteps(pn)
      elseif stepType == 'One' and SongOrCourse then
        local stepType = GAMESTATE:GetCurrentStyle():GetStepsType()
        StepsOrTrail = SongOrCourse:GetOneSteps(stepType, diff)
      end
    end
    
    if not (SongOrCourse and StepsOrTrail) then
      self:visible(false)
      return
    end
    
    local profile
    if profileType == 'Machine' then
      profile = PROFILEMAN:GetMachineProfile()
    else
      if PROFILEMAN:IsPersistentProfile(pn) then
        profile = PROFILEMAN:GetProfile(pn)
      else
        profile = PROFILEMAN:GetMachineProfile()
      end
    end
    
    local scores = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()
    local score = scores[index]
    
    if not score then
      self:visible(false)
      return
    end
    self:visible(true)
    
    self:playcommand('SetScore', { Stats = score, Steps = StepsOrTrail })
  end
}