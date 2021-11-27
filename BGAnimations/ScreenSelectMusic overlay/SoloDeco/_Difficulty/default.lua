local pn = ...
local xspacing = 80
local DiffList = Def.ActorFrame{};

local function DrawDiffListItem(diff)
  local DifficultyListItem = Def.ActorFrame{
    InitCommand=function(s)
      s:x(Difficulty:Reverse()[diff] * xspacing)
    end,
    Def.BitmapText{
      Font="_avenir next demi bold 20px",
      Name="DiffLabel";
      InitCommand=function(self)
        self:y(-15):zoomx(0.6):zoomy(0.7)
        self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff)))
      end;
      SetCommand=function(self)
        local st=GAMESTATE:GetCurrentStyle():GetStepsType()
        local song=GAMESTATE:GetCurrentSong()
        self:diffuse(color("#333333"))
        if song then
          if song:HasStepsTypeAndDifficulty( st, diff ) then
            if GAMESTATE:GetCurrentSteps(pn):GetDifficulty() == diff then
              self:diffuse(PlayerColor(pn))
            else
              self:diffuse(color("#333333"))
            end
          end
        end;
      end;
      CurrentSongChangedMessageCommand=function(s)
        s:queuecommand("Set")
      end
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold 36px",
      Name="Meter";
      InitCommand=function(s) s:y(15) end,
      SetCommand=function(self)
        self:settext("")
        local st=GAMESTATE:GetCurrentStyle():GetStepsType()
        local song=GAMESTATE:GetCurrentSong()
        if song then
          if song:HasStepsTypeAndDifficulty( st, diff ) then
            local steps = song:GetOneSteps( st, diff )
            self:settext( steps:GetMeter() )
            if GAMESTATE:GetCurrentSteps(pn):GetDifficulty() == diff then
              self:diffuse(PlayerColor(pn))
            else
              self:diffuse(Color.White)
            end
          end
        end;
      end;
      CurrentSongChangedMessageCommand=function(s)
        s:visible(GAMESTATE:GetCurrentSong() ~= nil)
      end
    };
  };
  return DifficultyListItem
end

local difficulties = {"Difficulty_Beginner", "Difficulty_Easy", "Difficulty_Medium", "Difficulty_Hard", "Difficulty_Challenge", "Difficulty_Edit"}


for diff in ivalues(difficulties) do
  DiffList[#DiffList+1] = DrawDiffListItem(diff)
end

return Def.ActorFrame{
  ["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:finishtweening():queuecommand("Set") end,
  DiffList..{
    InitCommand=function(s) s:x(-190) end,
  };
  Def.Sprite{
    Texture="diffglow",
    InitCommand=function(s) s:diffuse(PlayerColor(pn)):y(30):diffusealpha(0.7) end,
    ["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s)
      local song=GAMESTATE:GetCurrentSong()
      if song then
        local steps = GAMESTATE:GetCurrentSteps(pn)
        if steps then
          local diff = steps:GetDifficulty();
          local st=GAMESTATE:GetCurrentStyle():GetStepsType();
          s:x(-190+Difficulty:Reverse()[diff] * xspacing)
        end;
      end;
    end,
    CurrentSongChangedMessageCommand=function(s)
      s:visible(GAMESTATE:GetCurrentSong() ~= nil)
    end
  };
}