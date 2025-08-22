
local ScoreAndGrade = {}

local DEBUG = false

-- Should we maybe have this in SN2Scoring instead?
local defaultTierToSN2TierTable = {
  Grade_Tier01 = 'Grade_Tier02', -- AAA
  Grade_Tier02 = 'Grade_Tier04', -- AA
  Grade_Tier03 = 'Grade_Tier07', -- A
  Grade_Tier04 = 'Grade_Tier10', -- B 
  Grade_Tier05 = 'Grade_Tier13', -- C
  Grade_Tier06 = 'Grade_Tier16', -- D
  Grade_Tier07 = 'Grade_Tier17', -- D
}
function ScoreAndGrade.DefaultTierToSN2Tier(tier)
  local output = defaultTierToSN2TierTable[tier]
  assert(output, 'Unknown tier:' .. tier)
  return output
end

function ScoreAndGrade.GetFCType(obj)
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

function ScoreAndGrade.GetScore(hs, steps, showEX)
  if DEBUG then return showEX and 300 or 1000000 end -- for testing
  if showEX then
    return SN2Scoring.ComputeEXScoreFromData(SN2Scoring.GetCurrentScoreData(hs))
  end
  
  if ThemePrefs.Get('ConvertScoresAndGrades') then
    return SN2Scoring.GetSN2ScoreFromHighScore(steps, hs)
  end
  
  return hs:GetScore()
end

function ScoreAndGrade.GetGrade(hs, steps)
  if DEBUG then return 'Grade_Tier01' end -- for testing  
  if ThemePrefs.Get('ConvertScoresAndGrades') then
    local score = SN2Scoring.GetSN2ScoreFromHighScore(steps, hs)
    return SN2Grading.ScoreToGrade(score)
  end
  
  return ScoreAndGrade.DefaultTierToSN2Tier(hs:GetGrade())
end

function ScoreAndGrade.GetScoreActor(opt_in)
  local opts = {
    Font = '_avenirnext lt pro bold/20px',
    ShowEXScore = false,
  }
  if opts_in then
    for k, v in pairs(opts_in) do opts[k] = v end
  end
  
  local t = Def.BitmapText{
    Font=opts.Font,
    SetGradeCommand = function(s, params)
      local hs = params.Highscore
      local steps = params.Steps
    
      local score
      if hs then
        assert(steps)
        score = ScoreAndGrade.GetScore(hs, steps, opts.ShowEXScore)
      end
      
      s:settext(score and commify(score) or '0')
    end
  }
  
  return t
end

function ScoreAndGrade.GetScoreActorRolling(opts_in)
  local opts = {
    Font = '_avenirnext lt pro bold/46px',
    ShowEXScore = false,
    Load = 'RollingNumbers',
  }
  if opts_in then
    for k, v in pairs(opts_in) do opts[k] = v end
  end
  
  local t = Def.RollingNumbers{
    Font = opts.Font,
    SetGradeCommand = function(s, params)
      local hs = params.Highscore
      local steps = params.Steps
      
      local score
      if hs then
        assert(steps)
        score = ScoreAndGrade.GetScore(hs, steps, opts.ShowEXScore)
      end
      s:Load(opts.Load):targetnumber(score and score or 0)
    end
  }
  
  return t
end

function ScoreAndGrade.GetGradeActor(opts_in)
  local opts = {
    Big = false,
    AlternativeFC = false,  -- Only effective if Big = false
    ActorConcat = nil,      -- Used to apply special OnCommand/OffCommand
  }
  if opts_in then
    for k, v in pairs(opts_in) do opts[k] = v end
  end
  local ActorConcat = opts.ActorConcat or {}
  
  local FullCombo
  if opts.Big then 
    FullCombo = Def.ActorFrame{
      InitCommand=function(s) s:xy(170, 50):visible(false) end,
      Def.ActorFrame{
        Name='StarFrame',
        FOV=120,
        InitCommand=function(s) s:zoom(0):bob():effectmagnitude(0,0,20) end,
        OnCommand=function(s) s:sleep(0.5):linear(0.2):zoom(0.8) end,
        OffCommand=function(s) s:linear(0.2):zoom(0) end,
        Def.ActorFrame{
          Name='Star1',
          InitCommand=function(s) s:spin():effectmagnitude(0,0,-170) end,
          Def.Sprite{
            Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/grade/star.png"),
          },
          Def.Sprite{
            Name='ColorStar',
            Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/grade/colorstar.png"),
          }
        };
        Def.ActorFrame{
          Name='Star2',
          InitCommand=function(s) s:spin():effectmagnitude(0,0,80):diffusealpha(0.5) end,
          Def.Sprite{
            Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/grade/star.png"),
          },
          Def.Sprite{
            Name='ColorStar',
            Texture=THEME:GetPathB("ScreenEvaluationNormal","decorations/grade/colorstar.png"),
          }
        }
      }
		}
  else
    FullCombo = Def.Sprite{
      InitCommand=function(s)
        s:visible(false)
        if opts.AlternativeFC then 
          s:xy(18,4):Load(THEME:GetPathG("Player","Badge FullCombo")):zoom(0.5):shadowlength(1)
        else
          s:xy(14,5):Load(THEME:GetPathG('','myMusicWheel/star.png')):zoom(0.4)
        end
      end,
    }
  end
    
  local t = Def.ActorFrame{
    SetGradeCommand = function(s, params)
      local hs = params.Highscore
      local steps = params.Steps
      
      local grade
      if hs then
        assert(steps)
        grade = ScoreAndGrade.GetGrade(hs, steps)
      end
      
      if not grade then
        s:visible(false)
        return
      end
      s:visible(true)
      local Grade = s:GetChild('Grade')
      local FullCombo = s:GetChild('FullCombo')
      
      if opts.Big then
        Grade:Load(THEME:GetPathB('ScreenEvaluationNormal decorations/grade/GradeDisplayEval', ToEnumShortString(grade)))
      else
        Grade:Load(THEME:GetPathG('myMusicWheel/GradeDisplayEval', ToEnumShortString(grade)))
      end
      
      local fullComboType = ScoreAndGrade.GetFCType(hs)
      if not fullComboType then
        FullCombo:visible(false)
        return
      end
      FullCombo:visible(true)
      
      if opts.Big then
        local ringColor = FullComboEffectColor[fullComboType]
        if not ringColor then
          assert(false, 'Unknown Full Combo type: ' .. fullComboType)
          return
        end
        
        local StarFrame = FullCombo:GetChild('StarFrame')
        StarFrame:GetChild('Star1'):GetChild('ColorStar'):diffuse(ringColor)
        StarFrame:GetChild('Star2'):GetChild('ColorStar'):diffuse(ringColor)
      else
        if     fullComboType == 'TapNoteScore_W1' then FullCombo:diffuse(GameColor.Judgment['JudgmentLine_W1']):glowblink():effectperiod(0.20)
        elseif fullComboType == 'TapNoteScore_W2' then FullCombo:diffuse(GameColor.Judgment['JudgmentLine_W2']):glowshift()
        elseif fullComboType == 'TapNoteScore_W3' then FullCombo:diffuse(GameColor.Judgment['JudgmentLine_W3']):stopeffect()
        elseif fullComboType == 'TapNoteScore_W4' then FullCombo:diffuse(GameColor.Judgment['JudgmentLine_W4']):stopeffect()
        else
          assert(false, 'Unknown Full Combo type: ' .. fullComboType)
        end
      end
    end,
    (Def.Sprite{
      Name='Grade',
    })..(ActorConcat['Grade'] or {}),
    (FullCombo..{
      Name='FullCombo',
    })..(ActorConcat['FullCombo'] or {})
  }
  
  return t
end

return ScoreAndGrade