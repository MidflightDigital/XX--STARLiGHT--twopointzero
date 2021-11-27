local pn = ...
local yspacing = 32
local DiffList = Def.ActorFrame{};

local function DrawDiffListItem(diff)
  local DifficultyListItem = Def.ActorFrame{
    InitCommand=function(s)
      s:y(Difficulty:Reverse()[diff] * yspacing)
    end,
    SetCommand=function(self)
      local st=GAMESTATE:GetCurrentStyle():GetStepsType()
      local song=GAMESTATE:GetCurrentCourse()
      if song then
        --lol
        if diff == "Difficulty_Easy" or
        diff == "Difficulty_Medium" or
        diff == "Difficulty_Hard" then
          self:diffusealpha(1)
        else
          self:diffusealpha(0.5)
        end
      else
        self:diffusealpha(0.5)
      end;
    end;
    Def.Quad{
      Name="Background";
      InitCommand=function(s) s:setsize(336,28):diffusealpha(0.8):draworder(0) end,
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold 20px",
      Name="DiffLabel";
      InitCommand=function(self)
        self:halign(pn=='pnNumber_P2' and 1 or 0):draworder(99):diffuse(CustomDifficultyToColor(diff)):strokecolor(Color.Black)
        self:x(pn=="pnNumber_P2" and 164 or -164)
        self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff)))
      end;
    };
    --TODO: Figure out how to match the current trail with all trails to get the meter for each difficulty.
    --[[
    Def.BitmapText{
      Font="_avenirnext lt pro bold 25px",
      Name="Meter";
      InitCommand=function(s) s:draworder(99):strokecolor(Color.Black):x(pn==pn_2 and 20 or -20) end,
      SetCommand=function(self)
        self:settext("")
        local st=GAMESTATE:GetCurrentStyle():GetStepsType()
        local curTrail = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber())
        local meters = {}
        for i=1,#curTrail:GetTrailEntries() do
            local ce = curTrail:GetTrailEntry(i-1):GetSteps():GetMeter()
            table.insert(meters,ce)
        end
        self:settext(math.max(unpack(meters)))
      end;
    };]]
  };
  return DifficultyListItem
end

local difficulties = {"Difficulty_Beginner", "Difficulty_Easy", "Difficulty_Medium", "Difficulty_Hard", "Difficulty_Challenge", "Difficulty_Edit"}


for diff in ivalues(difficulties) do
  DiffList[#DiffList+1] = DrawDiffListItem(diff)
end


return Def.ActorFrame{
  InitCommand=function(s) s:addx(pn==PLAYER_1 and -500 or 500) end,
  OnCommand=function(s) s:addx(pn==PLAYER_1 and -500 or 500):decelerate(0.25):addx(pn==PLAYER_1 and 500 or -500) end,
  OffCommand=function(self)
    self:sleep(0.15):linear(0.25):addx(pn==PLAYER_1 and -500 or 500)
  end;
  ["CurrentTrail" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s)
    s:finishtweening():queuecommand("Set")
    end,
  Def.Sprite{
    Texture=THEME:GetPathB("ScreenSelectMusic","overlay/_Difficulty/extra_DiffFrame.png"),
    InitCommand=function(s) 
      s:xy(pn==PLAYER_1 and -8 or 8,80):rotationy(pn==PLAYER_1 and 0 or 180)
    end,
  };
  Def.Sprite{
    Texture=THEME:GetPathB("ScreenSelectMusic","overlay/_Difficulty/cursorglow.png"),
    ["CurrentTrail" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s)
      local song=GAMESTATE:GetCurrentCourse()
      if song then
        local steps = GAMESTATE:GetCurrentTrail(pn)
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