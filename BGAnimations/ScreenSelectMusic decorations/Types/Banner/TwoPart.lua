local player = ...
local t = Def.ActorFrame{
  InitCommand=function(s) s:y(_screen.cy+80):zoom(1.1) end,
  OnCommand=function(self)
    self:y(_screen.cy+654)
  end;
  StartSelectingStepsMessageCommand=function(self)
    self:stoptweening():decelerate(0.5):y(_screen.cy+80)
  end;
  SongUnchosenMessageCommand=function(self)
    self:stoptweening():decelerate(0.25):y(_screen.cy+684)
  end;
  OffCommand=function(s)
    s:stoptweening():decelerate(0.25):y(_screen.cy+684)
  end;
};

local SpacingY = 60;

local function DrawDifListItem(diff)
  local DifficultyListItem = Def.ActorFrame{
    InitCommand=function(s) s:xy(player==PLAYER_1 and _screen.cx-335 or _screen.cx+165,Difficulty:Reverse()[diff] * SpacingY) end,
    CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
    CurrentCourseChangedMessageCommand=function(s) s:playcommand("Set") end,
    ["CurrentSteps" .. ToEnumShortString(player) .. "ChangedMessageCommand"]=function(s) s:finishtweening():queuecommand("Set") end,
    ["CurrentTrail" .. ToEnumShortString(player) .. "ChangedMessageCommand"]=function(s) s:finishtweening():queuecommand("Set") end,
    SetCommand=function(self)
      local song=GAMESTATE:GetCurrentSong()
      local st=GAMESTATE:GetCurrentStyle():GetStepsType()
      if song then
        self:visible(song:HasStepsTypeAndDifficulty(st,diff))
      end;
    end;
    Def.Sprite{
      Name = "TicksDark",
      Texture = "_backticks",
      InitCommand=function(s) s:x(player == PLAYER_1 and 250 or -250):diffuse(ColorDarkTone(CustomDifficultyToColor(diff))) end;
    };
    Def.Sprite{
      Name = "TicksOver",
      Texture = "_ticks",
      SetCommand=function(self)
        self:diffuse(CustomDifficultyToColor(diff))
        local song = GAMESTATE:GetCurrentSong()
        local st=GAMESTATE:GetCurrentStyle():GetStepsType()
        if song then
          self:x(player==PLAYER_1 and 250 or -250)
          local steps = song:GetOneSteps(GAMESTATE:GetCurrentStyle():GetStepsType(), diff)
          if steps then
              local meter = steps:GetMeter()
              if meter > 10 then
                  self:diffuse(CustomDifficultyToColor(diff)):cropright(1-meter/10):glowshift():effectcolor1(CustomDifficultyToColor(diff)):effectcolor2(color "#FFFFFF")
              else
                  self:diffuse(CustomDifficultyToColor(diff)):stopeffect():cropright(1-meter/10)
              end
          else
              self:stopeffect():cropright(1)
          end;
        end;
      end;
    };
    Def.Sprite{
      Texture="DiffColor",
      Name="Background";
      InitCommand=function(self) self:diffuse(CustomDifficultyToColor(diff)) end,
    };
    Def.Sprite{
      Texture="DiffCenter",
      InitCommand=function(s) s:diffuse(Color.Black) end,
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px",
      Name="DiffLabel";
      Text=THEME:GetString("CustomDifficulty",ToEnumShortString(diff)),
      InitCommand=function(s) s:halign(player==PLAYER_1 and 0 or 1):diffuse(CustomDifficultyToColor(diff)):x(player == PLAYER_1 and -120 or 120) end,
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px",
      Name="Meter";
      InitCommand=function(s) s:draworder(99):x(player == PLAYER_1 and 100 or -100):diffuse(Color.White):strokecolor(Color.Black) end,
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
    Def.Sprite{
      Texture="DiffColor",
      Name="Gradient";
      InitCommand=function(s)
        s:diffuse(color("0,0,0,0")):diffusetopedge(color("1,1,1,1")):blend(Blend.Add):diffusealpha(0.5)
      end,
    };
  };
  return DifficultyListItem
end;

local difficulties = {"Beginner", "Easy", "Medium", "Hard", "Challenge", "Edit"}

for difficulty in ivalues(difficulties) do
        t[#t+1] = DrawDifListItem("Difficulty_" .. difficulty);
end

t[#t+1] = Def.ActorFrame{
  Def.Sprite{
    Texture="DiffColor",
    Name="Background";
    InitCommand=function(self)
      self:x(player==PLAYER_1 and _screen.cx-335 or _screen.cx+165):blend(Blend.Add)
    end;
    OffCommand=function(self)
      self:linear(0.25)
      self:diffusealpha(0)
    end;
    ["CurrentSteps" .. ToEnumShortString(player) .. "ChangedMessageCommand"]=function(self)
      self:diffusealpha(0)
      self:stoptweening()
      self:diffusealpha(1)
      self:queuecommand("Anim")
      local song=GAMESTATE:GetCurrentSong()
      if song then
        local steps = GAMESTATE:GetCurrentSteps(player)
        if steps then
          local diff = steps:GetDifficulty();
          local st=GAMESTATE:GetCurrentStyle():GetStepsType();
          self:y(Difficulty:Reverse()[diff] * SpacingY)
        end;
      end;
    end;
    AnimCommand=function(s) s:diffuseshift():effectclock("beat"):effectcolor1(color("1,1,1,0.4")):effectcolor2(color("1,1,1,0")) end,
  };
}

return t;
