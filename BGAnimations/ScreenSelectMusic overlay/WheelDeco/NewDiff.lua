local yspacing = 40
local DiffList = Def.ActorFrame{};

local function DrawDiffListItem(diff)
  local DifficultyListItem = Def.ActorFrame{
    InitCommand=function(s)
      s:y(Difficulty:Reverse()[diff] * yspacing)
    end,
    CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
    SetCommand=function(self)
      local st=GAMESTATE:GetCurrentStyle():GetStepsType()
      local song=GAMESTATE:GetCurrentSong()
      if song then
        if song:HasStepsTypeAndDifficulty( st, diff ) then
          local steps = song:GetOneSteps( st, diff )
          self:diffusealpha(1)
        else
          self:diffusealpha(0.5)
        end
      else
        self:diffusealpha(0.5)
      end;
    end;
    Def.BitmapText{
      Font="_avenirnext lt pro bold 20px",
      Name="DiffLabel";
      InitCommand=function(self)
        self:halign(0):draworder(99):diffuse(CustomDifficultyToColor(diff)):strokecolor(Color.Black):zoom(1.2)
        self:x(-210)
        self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff)))
      end;
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold 25px",
      Name="Meter";
      InitCommand=function(s) s:draworder(99):strokecolor(Color.Black):x(-30) end,
      SetCommand=function(self)
        self:settext("")
        local st=GAMESTATE:GetCurrentStyle():GetStepsType()
        local song=GAMESTATE:GetCurrentSong()
        if song then
          if song:HasStepsTypeAndDifficulty( st, diff ) then
            local steps = song:GetOneSteps( st, diff )
            self:settext( steps:GetMeter() )
          end
        end;
      end;
    };
    Def.Sprite{
        Texture="ticks",
        InitCommand=function(s) s:halign(0):diffuse(CustomDifficultyToColor(diff)) end,
    };
    Def.Sprite{
        Texture="ticks",
        InitCommand=function(s) s:halign(0) end,
        SetCommand=function(s)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                local steps = song:GetOneSteps(GAMESTATE:GetCurrentStyle():GetStepsType(),diff)
                if steps then
                    local meter = steps:GetMeter()
                    s:diffuse(CustomDifficultyToDarkColor(diff)):cropleft(math.min(1,meter/20))
                else
                    s:cropleft(1)
                end
            else
                s:cropleft(1)
            end
        end
    };
  };
  return DifficultyListItem
end

local difficulties = {"Difficulty_Beginner", "Difficulty_Easy", "Difficulty_Medium", "Difficulty_Hard", "Difficulty_Challenge", "Difficulty_Edit"}


for diff in ivalues(difficulties) do
  DiffList[#DiffList+1] = DrawDiffListItem(diff)
end

local ind = Def.ActorFrame{};

for pn in EnabledPlayers() do
    ind[#ind+1] = Def.ActorFrame{
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
        CurrentSongChangedMessageCommand=function(s)
            s:visible(GAMESTATE:GetCurrentSong() ~= nil)
        end,
        Def.Sprite{ Texture="cursorglow 1x2",
            InitCommand=function(s) s:setstate(pn==PLAYER_1 and 0 or 1):animate(false) end,
            --blahblahblah But Inori, why don't you use the fancy function you used right above?
            --This way both actors get updated correctly.
            CurrentStepsP1ChangedMessageCommand=function(s) s:queuecommand("Set") end,
            CurrentStepsP2ChangedMessageCommand=function(s) s:queuecommand("Set") end,
            SetCommand=function(s)
                local p1diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
                local p2diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
                if p1diff == p2diff and GAMESTATE:GetNumPlayersEnabled() == 2 then
                    s:cropleft(pn==PLAYER_2 and 0.5 or 0):cropright(pn==PLAYER_1 and 0.5 or 0)
                else
                    s:cropleft(0):cropright(0)
                end
            end
        };
        Def.Sprite{
            Texture=THEME:GetPathG("","_shared/Diff/"..ToEnumShortString(pn)),
            InitCommand=function(s) s:x(pn == PLAYER_1 and -380 or 380) end,
        };
    }
end

return Def.ActorFrame{
    InitCommand=function(s) s:y(-90) end,
    ind;
    DiffList..{
        InitCommand=function(s) s:x(-140) end,
    };
}