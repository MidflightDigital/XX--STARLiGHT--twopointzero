local DEBUG = false

if StarlightCache and StarlightCache.ScoreAndGrade and not DEBUG then
  return StarlightCache.ScoreAndGrade
end

local ScoreAndGrade = {}
StarlightCache.ScoreAndGrade = ScoreAndGrade

local GRADE_FAILED = 'Grade_Failed'

-- Should we maybe have this in SN2Scoring instead?
local defaultTierToSN2TierTable = {
  Grade_Tier01   = 'Grade_Tier02', -- AAA
  Grade_Tier02   = 'Grade_Tier04', -- AA
  Grade_Tier03   = 'Grade_Tier07', -- A
  Grade_Tier04   = 'Grade_Tier10', -- B 
  Grade_Tier05   = 'Grade_Tier13', -- C
  Grade_Tier06   = 'Grade_Tier16', -- D
  Grade_Tier07   = 'Grade_Tier17', -- D
  [GRADE_FAILED] = GRADE_FAILED, -- Failed
}
function ScoreAndGrade.DefaultTierToSN2Tier(tier)
  local output = defaultTierToSN2TierTable[tier]
  assert(output, 'Unknown tier:' .. tier)
  return output
end

function ScoreAndGrade.GetFullComboType(obj)
  if DEBUG then return 'TapNoteScore_W1' end -- For testing
  
  local tnsFunc, hnsFunc
  if lua.CheckType('PlayerStageStats', obj) then
    tnsFunc, hnsFunc = obj['GetTapNoteScores'], obj['GetHoldNoteScores']
  elseif lua.CheckType('HighScore', obj) then
    tnsFunc, hnsFunc = obj['GetTapNoteScore'], obj['GetHoldNoteScore']
  else
    error('First argument is not HighScore or PlayerStageStats')
  end
  assert(tnsFunc)
  assert(hnsFunc)
  
  if obj:GetScore() == 0                             -- If nothing was scored
  or hnsFunc(obj, 'HoldNoteScore_LetGo') > 0         -- or any hold note was let go too early 
  or tnsFunc(obj, 'TapNoteScore_CheckpointMiss') > 0 -- or any hold note checkpoint was missed
  or tnsFunc(obj, 'TapNoteScore_Miss') > 0           -- or any tap note was missed
  or tnsFunc(obj, 'TapNoteScore_W5') > 0 then        -- or any tap note was boos
    return nil
  end
  
  for _, tns in ipairs({
    'TapNoteScore_W4',
    'TapNoteScore_W3',
    'TapNoteScore_W2',
    'TapNoteScore_W1'
  }) do
    if tnsFunc(obj, tns) > 0 then
      return tns
    end
  end
  
  return nil
end

function ScoreAndGrade.GetScore(HSorPSS, steps, showEX)
  if DEBUG then return showEX and 300 or 1000000 end -- for testing
  if showEX then
    return SN2Scoring.ComputeEXScoreFromData(SN2Scoring.GetCurrentScoreData(HSorPSS))
  end
  
  if ThemePrefs.Get('ConvertScoresAndGrades') then
    return SN2Scoring.GetSN2ScoreFromHighScore(steps, HSorPSS)
  end
  
  return HSorPSS:GetScore()
end

function ScoreAndGrade.GetGrade(HSorPSS, steps)
  if DEBUG then return 'Grade_Tier01' end -- for testing
  
  -- This is the most optimal way to check if HSorPSS is from a failed stage.
  -- If the stage is not failed then PSS:GetGrade() will do some calculations to calculate the grade which we might
  -- not really need, but there's PSS:GetFailed() which is just a getter function, so we can use that; See:
  -- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/PlayerStageStats.cpp#L183
  -- Sadly, there is no such thing as HS:GetFailed(), but HS:GetGrade() is also just a getter function and returns the
  -- result of a previously ran PSS:GetGrade(), so we can use that without needing to do any grade calculations; See:
  -- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/StageStats.cpp#L138
  local grade
  local isFailed
  if lua.CheckType('HighScore', HSorPSS) then
    grade = HSorPSS:GetGrade()
    isFailed = grade == GRADE_FAILED
  elseif lua.CheckType('PlayerStageStats', HSorPSS) then
    isFailed = HSorPSS:GetFailed()
    if isFailed then
      -- We can safely presume this, PSS:GetGrade() would return the same in this case anyway
      grade = GRADE_FAILED
    end
  else
    error('First argument is not HighScore or PlayerStageStats')
  end
  
  if not isFailed and ThemePrefs.Get('ConvertScoresAndGrades') then
    local score = SN2Scoring.GetSN2ScoreFromHighScore(steps, HSorPSS)
    return SN2Grading.ScoreToGrade(score)
  end
  
  if not grade then
    -- If HSorPSS is a PSS and not from a failed stage, and we don't do any score and grade conversion,
    -- then lets just do the calculations within PSS:GetGrade() because now we actually need it.
    grade = HSorPSS:GetGrade()
  end
  
  return ScoreAndGrade.DefaultTierToSN2Tier(grade)
end

function ScoreAndGrade.CreateScoreActor(opts)
  local properties = {
    Font = '_avenirnext lt pro bold/20px',
    ShowEXScore = false,
  }
  if opts then
    for k, v in pairs(opts) do properties[k] = v end
  end
  
  local SetScoreCommand = properties.SetScoreCommand
  properties.SetScoreCommand = function(self, params)
    local score
    if params then
      local stats = params.Stats
      local steps = params.Steps
    
      if stats then
        assert(steps)
        score = ScoreAndGrade.GetScore(stats, steps, properties.ShowEXScore)
      end
    end
    
    self:settext(score and commify(score) or '0')
    
    if SetScoreCommand then
      SetScoreCommand(self, params)
    end
  end
  
  return Def.BitmapText(properties)
end

function ScoreAndGrade.CreateScoreRollingActor(opts)
  local properties = {
    Font = '_avenirnext lt pro bold/46px',
    Load = 'RollingNumbers',
    ShowEXScore = false,
  }
  if opts then
    for k, v in pairs(opts) do properties[k] = v end
  end
  
  local InitCommand = properties.InitCommand
  properties.InitCommand = function(self)
    self:Load(properties.Load)
    if InitCommand then
      InitCommand(self)
    end
  end
  
  local SetScoreCommand = properties.SetScoreCommand
  properties.SetScoreCommand = function(self, params)
    local score
    if params then
      local stats = params.Stats
      local steps = params.Steps
      
      if stats then
        assert(steps)
        score = ScoreAndGrade.GetScore(stats, steps, properties.ShowEXScore)
      end
    end
    self:targetnumber(score and score or 0)
    
    if SetScoreCommand then
      SetScoreCommand(self, params)
    end
  end
  
  return Def.RollingNumbers(properties)
end

function ScoreAndGrade.CreateGradeActor(opts)
  local properties = {
    Big = false,
    HideFC = false,
    AlternativeFC = false,  -- Only effective if Big == false
  }
  if opts then
    for k, v in pairs(opts) do properties[k] = v end
  end
  
  properties[#properties+1] = Def.Sprite{
    Name='Grade',
  }
  
  if not properties.HideFC then
    if properties.Big then 
      properties[#properties+1] = Def.ActorFrame{
        Name='FullCombo',
        InitCommand=function(self)
          self:visible(false)
          self:xy(190, 30)
        end,
        Def.ActorFrame{
          Name='Star1',
          InitCommand=function(self)
            self:spin():effectmagnitude(0,0,-170)
          end,
          Def.Sprite{
            Texture=THEME:GetPathB('ScreenEvaluationNormal','decorations/grade/star.png'),
          },
          Def.Sprite{
            Name='ColorStar',
            Texture=THEME:GetPathB('ScreenEvaluationNormal','decorations/grade/colorstar.png'),
          }
        };
        Def.ActorFrame{
          Name='Star2',
          InitCommand=function(self)
            self:spin():effectmagnitude(0,0,80):diffusealpha(0.5)
          end,
          Def.Sprite{
            Texture=THEME:GetPathB('ScreenEvaluationNormal','decorations/grade/star.png'),
          },
          Def.Sprite{
            Name='ColorStar',
            Texture=THEME:GetPathB('ScreenEvaluationNormal','decorations/grade/colorstar.png'),
          }
        }
      }
    elseif properties.AlternativeFC then
      properties[#properties+1] = Def.Sprite{
        Name='FullCombo',
        Texture=THEME:GetPathG('Player', 'Badge FullCombo'),
        InitCommand=function(self)
          self:visible(false)
          self:xy(18,4):zoom(0.5):shadowlength(1)
        end,
      }
    else
      properties[#properties+1] = Def.ActorFrame{
        Name='FullCombo',
        InitCommand=function(self)
          self:visible(false)
          self:xy(14,5):zoom(0.4)
        end,
        Def.Sprite{
          Name='Star',
          Texture=THEME:GetPathG('','myMusicWheel/star.png'),
        },
        Def.Sprite{
          Name='ColorStar',
          Texture=THEME:GetPathG('','myMusicWheel/colorstar.png'),
        }
      }
    end
  end
  
  local SetScoreCommand = properties.SetScoreCommand
  properties.SetScoreCommand = function(self, params)
    local grade
    local stats
    if params then
      stats = params.Stats
      local steps = params.Steps
      
      if stats then
        assert(steps)
        grade = ScoreAndGrade.GetGrade(stats, steps)
      end
    end
    
    self:visible(not not grade)
    
    if grade then
      local Grade = self:GetChild('Grade')
      
      if properties.Big then
        Grade:Load(THEME:GetPathB('ScreenEvaluationNormal decorations/grade/GradeDisplayEval', ToEnumShortString(grade)))
      else
        Grade:Load(THEME:GetPathG('myMusicWheel/GradeDisplayEval', ToEnumShortString(grade)))
      end
      
      if not properties.HideFC then
        local FullCombo = self:GetChild('FullCombo')
        local fullComboType = ScoreAndGrade.GetFullComboType(stats)
        FullCombo:visible(not not fullComboType)
        
        if fullComboType then
          if properties.Big then
            local ringColor = FullComboEffectColor[fullComboType]
            if ringColor then  
              FullCombo:GetChild('Star1'):GetChild('ColorStar'):diffuse(ringColor)
              FullCombo:GetChild('Star2'):GetChild('ColorStar'):diffuse(ringColor)
            else
              assert(false, 'Unknown Full Combo type: ' .. fullComboType)
            end
          else
            local FCRing
            if properties.AlternativeFC then
              FCRing = FullCombo
            else
              FCRing = FullCombo:GetChild('ColorStar')
            end
            if     fullComboType == 'TapNoteScore_W1' then FCRing:diffuse(GameColor.Judgment['JudgmentLine_W1']):glowblink():effectperiod(0.2)
            elseif fullComboType == 'TapNoteScore_W2' then FCRing:diffuse(GameColor.Judgment['JudgmentLine_W2']):glowshift()
            elseif fullComboType == 'TapNoteScore_W3' then FCRing:diffuse(GameColor.Judgment['JudgmentLine_W3']):stopeffect()
            elseif fullComboType == 'TapNoteScore_W4' then FCRing:diffuse(GameColor.Judgment['JudgmentLine_W4']):stopeffect()
            else
              assert(false, 'Unknown Full Combo type: ' .. fullComboType)
            end
          end
        end
      end
    end
    
    if SetScoreCommand then
      SetScoreCommand(self, params)
    end
  end
    
  return Def.ActorFrame(properties)
end

return ScoreAndGrade