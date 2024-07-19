local pn = ...
local yspacing = 46
local DiffList = Def.ActorFrame{};

local function DrawDiffListItem(diff)
  local DifficultyListItem = Def.ActorFrame{
    InitCommand=function(s)
      s:y(Difficulty:Reverse()[diff] * yspacing)
    end,
    SetCommand=function(self)
      local st=GAMESTATE:GetCurrentStyle():GetStepsType()
      local song=GAMESTATE:GetCurrentSong()
      if song then
          local steps = song:GetOneSteps( st, diff )
          if steps then
            local meter = song:GetOneSteps(st,diff):GetMeter()

            if song:GetOneSteps(st,diff) == GAMESTATE:GetCurrentSteps(pn) then
							self:decelerate(0.2):x(pn==PLAYER_1 and SCREEN_LEFT+20 or SCREEN_RIGHT-20)
						else
							self:decelerate(0.2):x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
						end

            self:GetChild("Background"):diffuse(CustomDifficultyToColor(ToEnumShortString(diff))):visible(true)
            self:GetChild("Meter"):settext(IsMeterDec(meter)):visible(true)
          else
            self:decelerate(0.2):x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
            self:GetChild("Background"):visible(false)
            self:GetChild("Meter"):settext(""):visible(false)
          end
      else
        self:decelerate(0.2):x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
        self:GetChild("Background"):visible(false)
        self:GetChild("Meter"):settext(""):visible(false)
      end;
    end;

    Def.Quad{
      Name="Background";
      InitCommand=function(s) s:setsize(5,36):diffusealpha(0.8):x(pn==PLAYER_1 and 4 or -4):visible(false) end,
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px",
      Name="Meter";
      InitCommand=function(s) s:x(pn==PLAYER_1 and 14 or -14):diffuse(Color.Black):strokecolor(color("#dedede")):halign(pn==PLAYER_1 and 0 or 1) end,
    };
  };
  return DifficultyListItem
end

local difficulties = {"Difficulty_Beginner", "Difficulty_Easy", "Difficulty_Medium", "Difficulty_Hard", "Difficulty_Challenge", "Difficulty_Edit"}

for diff in ivalues(difficulties) do
  DiffList[#DiffList+1] = DrawDiffListItem(diff)
end

return Def.ActorFrame{
  CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
	["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:finishtweening():queuecommand("Set") end,
  DiffList;
}