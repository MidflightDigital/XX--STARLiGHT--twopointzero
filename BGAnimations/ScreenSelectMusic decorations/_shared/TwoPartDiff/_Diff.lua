local pn = ...
local yspacing = 32
local DiffList = Def.ActorFrame{};
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local function DrawDiffListItem(diff)
  local DifficultyListItem = Def.ActorFrame{
    InitCommand=function(s)
      s:y(Difficulty:Reverse()[diff] * yspacing)
    end,
    SetCommand=function(s)      
      local c = s:GetChildren()
      
      local song = GAMESTATE:GetCurrentSong()
      local stepType = GAMESTATE:GetCurrentStyle():GetStepsType()
      local steps = song:GetOneSteps(stepType, diff)
      if not (song and steps) then
        s:diffusealpha(0.5)
        c.Score:visible(false)
        c.GradeFrame:visible(false)
        return
      end
      s:diffusealpha(1)
      
      local profile
      if PROFILEMAN:IsPersistentProfile(pn) then
        profile = PROFILEMAN:GetProfile(pn)
      else
        profile = PROFILEMAN:GetMachineProfile()
      end;
      local scores = profile:GetHighScoreList(song, steps):GetHighScores()
      local score = scores[1]
      if not score then
        c.Score:visible(false)
        c.GradeFrame:visible(false)
        return
      end
      
      s:playcommand('SetGrade', { Highscore = score, Steps = steps })
    end;

    Def.Quad{
      Name="Background";
      InitCommand=function(s) s:setsize(336,28):diffusealpha(0.8):draworder(0) end,
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/20px",
      Name="DiffLabel";
      InitCommand=function(self)
        self:halign(pn=='pnNumber_P2' and 1 or 0):draworder(99):diffuse(CustomDifficultyToColor(diff)):strokecolor(Color.Black)
        self:x(pn=="pnNumber_P2" and 164 or -164)
        self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff)))
      end;
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px",
      Name="Meter";
      InitCommand=function(s) s:draworder(99):strokecolor(Color.Black):x(pn==pn_2 and 20 or -20) end,
      SetCommand=function(self)
        self:settext("")
        local st=GAMESTATE:GetCurrentStyle():GetStepsType()
        local song=GAMESTATE:GetCurrentSong()
        if song then
          if song:HasStepsTypeAndDifficulty( st, diff ) then
            local steps = song:GetOneSteps( st, diff )
            local meter = steps:GetMeter()
            self:settext(IsMeterDec(meter))
          end
        end;
      end;
    };
    
    ScoreAndGrade.GetScoreActor{}..{
      Name='Score',
      InitCommand=function(s) s:draworder(5):x(pn==pn_2 and -69 or 69):strokecolor(Color.Black) end,
    },
    ScoreAndGrade.GetGradeActor{
      AlternativeFC = true,
    }..{
      Name='GradeFrame',
      InitCommand=function(s) s:x(pn==pn_2 and -148 or 140) end,
    }
    
  };
  return DifficultyListItem
end

local difficulties = {"Difficulty_Beginner", "Difficulty_Easy", "Difficulty_Medium", "Difficulty_Hard", "Difficulty_Challenge", "Difficulty_Edit"}


for diff in ivalues(difficulties) do
  DiffList[#DiffList+1] = DrawDiffListItem(diff)
end

return Def.ActorFrame{
  Def.Sprite{
    Texture=THEME:GetPathB("ScreenSelectMusic","decorations/_shared/_Difficulty/cursorglow"),
    StartSelectingStepsMessageCommand=function(s)
      local song=GAMESTATE:GetCurrentSong()
      if song then
        local steps = GAMESTATE:GetCurrentSteps(pn)
        if steps then
          local diff = steps:GetDifficulty();
          local st=GAMESTATE:GetCurrentStyle():GetStepsType();
          s:y(Difficulty:Reverse()[diff] * yspacing)
        end;
      end;
    end,
    ["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s)
      local song=GAMESTATE:GetCurrentSong()
      if song then
        local steps = GAMESTATE:GetCurrentSteps(pn)
        if steps then
          local diff = steps:GetDifficulty();
          local st=GAMESTATE:GetCurrentStyle():GetStepsType();
          s:y(Difficulty:Reverse()[diff] * yspacing)
        end;
      end;
    end,
  };
  DiffList;
}