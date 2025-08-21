local t = Def.ActorFrame{};
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local xPosPlayer = {
    P1 = SCREEN_LEFT+280,
    P2 = SCREEN_RIGHT-280
}

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do

t[#t+1] = Def.ActorFrame{
  InitCommand=function(s)
    local short = ToEnumShortString(pn)
    s:x(xPosPlayer[short]):y(_screen.cy+180)
    local c = s:GetChildren()
    
    local song = GAMESTATE:GetCurrentSong()
    local steps = GAMESTATE:GetCurrentSteps(pn)
    local score
    if song and steps then
      local profile
      if PROFILEMAN:IsPersistentProfile(pn) then
        profile = PROFILEMAN:GetProfile(pn)
      else
        profile = PROFILEMAN:GetMachineProfile()
      end

      local scores = profile:GetHighScoreList(song, steps):GetHighScores()
      score = scores[1]
    end
    
    s:playcommand('SetGrade', { Highscore = score, Steps = steps })
  end;
  OnCommand=function(self)
    if pn == PLAYER_1 then
      self:addx(-800):sleep(1.2):decelerate(0.2):addx(800)
    else
      self:addx(800):sleep(1.2):decelerate(0.2):addx(-800)
    end;
    --[[local profileID = GetProfileIDForPlayer(pn)
    local pPrefs = ProfilePrefs.Read(profileID)
    if pPrefs.guidelines == true then
      pPrefs.guidelines = false
    else
      pPrefs.guidelines = false
    end]]
  end;
  Def.Sprite{
    Texture="score",
    InitCommand=function(s) s:zoomx(pn=='PlayerNumber_P2' and -1 or 1) end,
  };
  Def.Sprite{
    Texture="BEST SCORE.png",
    InitCommand=function(s)
      s:xy(pn==PLAYER_1 and -200 or 200,-60)
    end
  };
  ScoreAndGrade.GetScoreActorRolling{
    Font='ScoreDisplayNormal Text',
  }..{
    Name='Score',
    InitCommand=function(self)
      self:xy(pn=='PlayerNumber_P2' and 46 or -46,-32):strokecolor(Color.Black)
    end;
  },
  Def.BitmapText{
    Font="_avenirnext lt pro bold/42px";
    InitCommand=function(self)
      self:y(14)
      self:playcommand("Set")
      self:zoomy(0.75);
    end;
    SetCommand=function(s)
      s:maxwidth(434);
      s:settext(PROFILEMAN:GetProfile(pn):GetDisplayName())
    end;
  };
  Def.BitmapText{
    Font="CFBPMDisplay";
    InitCommand=function(self)
      self:y(60):diffuse(color("#d5feff"))
      self:playcommand("Set")
      self:zoomy(0.75);
    end;
    SetCommand=function(s)
      s:maxwidth(390);
      local song = GAMESTATE:GetCurrentSong()
      if song then
        local steps = GAMESTATE:GetCurrentSteps(pn)
        local sart = steps:GetAuthorCredit()
        if sart ~= "" then
          s:settext("stepchart by "..steps:GetAuthorCredit())
        else
          s:settext("")
        end
      end
    end;
  };
  Def.BitmapText{
    Font="_avenirnext lt pro bold/20px";
    Name="Difficulty Label";
    InitCommand=function(self)
      self:x(pn=='PlayerNumber_P2' and 200 or -200):y(-80):zoom(0.75)
      self:playcommand("Set")
    end;
    SetCommand=function(s)
      local diff;
      if GAMESTATE:IsCourseMode() then
        diff = GAMESTATE:GetCurrentTrail(pn):GetDifficulty();
      else
        diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty();
      end;
      s:maxwidth(270);
      s:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff))):uppercase(true):diffuse(CustomDifficultyToColor(diff))
    end;
  };
  ScoreAndGrade.GetGradeActor{}..{
    Name='Grade',
    InitCommand=function(s) s:xy(pn=='PlayerNumber_P2' and -200 or 200,-32):zoom(1.4) end
  },
}
end;

return t;
