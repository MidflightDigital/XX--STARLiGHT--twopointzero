local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local t = Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy+310) end,
    OnCommand=function(s) s:addy(SCREEN_HEIGHT/2):sleep(0.2):decelerate(0.2):addy(-SCREEN_HEIGHT/2) end,
    OffCommand=function(s) s:sleep(0.4):accelerate(0.2):addy(SCREEN_HEIGHT/2) end,
};

local ver = ""
if ThemePrefs.Get("SV") == "onepointzero" then
  ver = "1_"
end

local heardBefore = 0

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
    t[#t+1] = Def.ActorFrame{
        InitCommand=function(s) s:x(pn==PLAYER_2 and 390 or -390,-76) end,
        OnCommand=function(s) s:addy(76):sleep(0.36):decelerate(0.2):addy(-76):queuecommand("Sheard") end,
        SheardCommand=function(s)
          heardBefore = 1
          s:queuecommand("Set")
        end,
        OffCommand=function(s) s:accelerate(0.2):addy(76) end,
        CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
        ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
        SetCommand=function(s)
          if heardBefore == 1 then
            s:finishtweening()
            local song = GAMESTATE:GetCurrentSong();
            local steps=GAMESTATE:GetCurrentSteps(pn);
            if song and steps then
              local sart = steps:GetAuthorCredit()
              if sart ~= "" then
                s:decelerate(0.2):y(-146)
              else
                s:accelerate(0.2):y(-76)
              end
            else
              s:accelerate(0.2):y(-76)
            end
          end
        end,
        Def.Sprite{
            Texture="insert.png";
            InitCommand=function(s) s:zoomx(pn==PLAYER_2 and -1 or 1)
              if GAMESTATE:IsAnExtraStage() then
                s:Load(THEME:GetPathB("ScreenSelectMusic","decorations/Types/CoverFlow/Difficulty/ex_insert.png"))
              end    
            end,
        };
        Def.BitmapText{
            Font="CFBPMDisplay";
            InitCommand=function(s)
                s:settext("Step Credits:"):zoom(0.5)
                if GAMESTATE:IsAnExtraStage() then
                  s:diffuse(color("#ffffff")):strokecolor(color("#8400ff"))
                else
                  s:diffuse(color("#dff0ff")):strokecolor(color("#00baff"))
                end
                s:xy(pn==PLAYER_2 and 90 or -90,-36)
            end,
        };
        Def.BitmapText{
            Font="CFBPMDisplay";
            InitCommand=function(s)
                s:zoom(0.8):visible(false)
                if GAMESTATE:IsAnExtraStage() then
                  s:diffuse(color("#ffffff")):strokecolor(color("#8400ff"))
                else
                  s:diffuse(color("#dff0ff")):strokecolor(color("#00baff"))
                end
            end,
            SetCommand=function(s)
                s:maxwidth(280)
                local song = GAMESTATE:GetCurrentSong();
                local steps=GAMESTATE:GetCurrentSteps(pn);
                if song and steps then
                    local sart = steps:GetAuthorCredit()
                    if sart ~= "" then
                        s:settext(sart):visible(true)
                    else
                        s:settext("")
                    end
                else
                    s:settext("")
                end
            end,
        };
    }
end

t[#t+1] = Def.ActorFrame{
  Def.ActorFrame{
    InitCommand=function(s) s:y(-150) end,
    OnCommand=function(s) s:addy(60):sleep(0.6):decelerate(0.2):addy(-60) end,
    OffCommand=function(s) s:accelerate(0.2):addy(70) end,
     Def.Sprite{
      Texture="bpm.png";
      InitCommand=function(s)
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathB("ScreenSelectMusic","decorations/Types/CoverFlow/Difficulty/ex_bpm.png"))
        end
      end,
    };
    loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Types/CoverFlow/Difficulty/BPM.lua"))()
  };
  Def.Sprite{
    Texture="TABLE.png";
    InitCommand=function(s)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","decorations/Types/CoverFlow/Difficulty/ex_TABLE.png"))
      end
    end,
  };
  Def.Sprite{Texture="eqbase.png";};
  Def.Quad{
    InitCommand=function(s) s:zoomto(1104,224):MaskSource(true) end,
    CurrentSongChangedMessageCommand = function(s)
      s:finishtweening()
      local song = GAMESTATE:GetCurrentSong()
      if song then
        if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
           s:bounce():effectmagnitude(0,224,0):effectperiod(0.5):effectclock("music")
        else
          s:bounce():effectmagnitude(0,224,0):effectclock("beatnooffset")
        end
      else
        s:bounce():effectmagnitude(0,224,0):effectperiod(1):effectclock("music")
      end
    end,
    OffCommand=function(s) s:finishtweening() end,
  };
  Def.Sprite{
    Texture="eq.png";
    InitCommand=function(s)
      s:MaskDest():ztestmode('ZTestMode_WriteOnFail')
    end,
  };
  Def.ActorFrame{
    InitCommand=function(s) s:xy(-360,10):zoom(0.8) end,
    OnCommand=function(s) s:zoom(0):rotationz(-360):decelerate(0.4):zoom(0.8):rotationz(0) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
    Def.Sprite{
      Texture=THEME:GetPathG("","_shared/Radar/"..ver.."GrooveRadar base.png"),
    };
    Def.Sprite{
      Texture=THEME:GetPathG("","_shared/Radar/sweep.png"),
       InitCommand = function(s) s:zoom(1.275):spin():effectmagnitude(0,0,100) end,
    };
  };
}

local yspacing = 34;

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
  t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Types/CoverFlow/Difficulty/RadarHandler"))(pn)..{
    InitCommand=function(s) s:xy(-360,10):zoom(0.8) end,
  }
  t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:diffuse(PlayerColor(pn)):x(180)
    end;
    ["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(self)
        local song=GAMESTATE:GetCurrentSong()
        if song then
          local steps = GAMESTATE:GetCurrentSteps(pn)
          if steps then
            local diff = steps:GetDifficulty();
            local st=GAMESTATE:GetCurrentStyle():GetStepsType();
            self:y((Difficulty:Reverse()[diff] * yspacing)-86)
          end;
        end;
    end;
    Def.Sprite{
      Texture="glow",
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
    }
  };
end

local function DrawDifListItem(diff, pn)
    local Item = Def.ActorFrame{
        InitCommand=function(s)
            s:xy(180,(Difficulty:Reverse()[diff] * yspacing)-86)
        end,
        CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
        SetCommand=function(self)
            local st=GAMESTATE:GetCurrentStyle():GetStepsType()
            local song=GAMESTATE:GetCurrentSong()
            if song then
              self:diffusealpha(1)
            else
              self:diffusealpha(0.5)
            end
          end;
        Def.Quad{
            Name="Background";
            InitCommand=function(s) s:setsize(640,28):diffusealpha(0.8) end,
        };
        Def.ActorFrame{
          SetCommand=function(self)
            local st=GAMESTATE:GetCurrentStyle():GetStepsType()
            local song=GAMESTATE:GetCurrentSong()
            if song then
              if song:HasStepsTypeAndDifficulty( st, diff ) then
                local steps = song:GetOneSteps( st, diff )
                self:diffuse(Alpha(Color.White,1))
              else
                self:diffuse(Alpha(Color.Black,0.25))
              end
            else
              self:diffuse(Alpha(Color.Black,0.25))
            end;
          end;
          Def.BitmapText{
            Name="DiffLabel";
            Font="_avenirnext lt pro bold/20px";
            InitCommand=function(s)
                s:diffuse(CustomDifficultyToColor(diff)):strokecolor(Color.Black):x(-20)
                s:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff)))
            end,
        };
        Def.BitmapText{
            Name="DiffLabel";
            Font="_avenirnext lt pro bold/25px";
            InitCommand=function(s)
                s:x(65):strokecolor(Color.Black)
            end,
            SetCommand=function(self)
                self:settext("")
                local st=GAMESTATE:GetCurrentStyle():GetStepsType()
                local song=GAMESTATE:GetCurrentSong()
                if song then
                  if song:HasStepsTypeAndDifficulty( st, diff ) then
                    local steps = song:GetOneSteps( st, diff )
                    local meter = steps:GetMeter()
                    self:settext(IsMeterDec(meter))
                  else
                    self:settext("00")
                  end
                end;
              end;
        };
        }
    }
    for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
      Item[#Item+1] = Def.ActorFrame{
				CurrentSongChangedMessageCommand=function(s) s:queuecommand('Set') end,
				CurrentCourseChangedMessageCommand=function(s) s:queuecommand('Set') end,
				['CurrentSteps'..ToEnumShortString(pn)..'ChangedMessageCommand']=function(s) s:queuecommand('Set') end,
				['CurrentTrail'..ToEnumShortString(pn)..'ChangedMessageCommand']=function(s) s:queuecommand('Set') end,
				SetCommand=function(self)
					local c = self:GetChildren()
				
					local song = GAMESTATE:GetCurrentSong()
					local stepType = GAMESTATE:GetCurrentStyle():GetStepsType()
					local steps
					if song then
						steps = song:GetOneSteps(stepType, diff)
					end
					if not (song and steps) then
						c.Score:visible(false)
						c.Grade:visible(false)
						return
					end
						
					local profile
					if PROFILEMAN:IsPersistentProfile(pn) then
						profile = PROFILEMAN:GetProfile(pn)
					else
						profile = PROFILEMAN:GetMachineProfile()
					end
					local scores = profile:GetHighScoreList(song, steps):GetHighScores()
					local score = scores[1]
					
					if not score then
						c.Score:visible(false)
						c.Grade:visible(false)
						return
					end
					c.Score:visible(true)
					c.Grade:visible(true)
					
					self:playcommand('SetScore', { Stats = score, Steps = steps })
				end,
				ScoreAndGrade.CreateScoreActor{
					Name='Score',
          Font='_avenirnext lt pro bold/20px',
					InitCommand=function(self)
						self:x(pn==PLAYER_2 and 260 or -260):strokecolor(Color.Black)
					end,
				},
				ScoreAndGrade.CreateGradeActor{
					Name='Grade',
					AlternativeFC=true,
					InitCommand=function(self)
						self:x(pn==PLAYER_2 and 176 or -186)
					end,
					OffCommand=function(self)
						self:decelerate(0.05):diffusealpha(0)
					end,
				},
			}
    end
    return Item
end;

local difficulties = {"Beginner", "Easy", "Medium", "Hard", "Challenge", "Edit"}

for difficulty in ivalues(difficulties) do
  t[#t+1] = DrawDifListItem("Difficulty_" .. difficulty);
end

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
t[#t+1] = Def.ActorFrame{
    Def.Sprite{
        Texture=THEME:GetPathG("","_shared/Diff/"..ToEnumShortString(pn));
      InitCommand=function(self)
        self:diffusealpha(0):x(pn==PLAYER_2 and 180+120 or 180-120)
        self:bounce():effectmagnitude(pn==PLAYER_2 and 4 or -4,0,0):effectclock("beatnooffset")
      end;
      OffCommand=function(s) s:stoptweening() end,
      ["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(self)
        self:diffusealpha(0)
        self:finishtweening()
        self:diffusealpha(1)
        local song=GAMESTATE:GetCurrentSong()
        if song then
          local steps = GAMESTATE:GetCurrentSteps(pn)
          if steps then
            local diff = steps:GetDifficulty();
            local st=GAMESTATE:GetCurrentStyle():GetStepsType();
            self:y((Difficulty:Reverse()[diff] * yspacing)-86)
          end;
        end;
      end;
    };
  };
end

t[#t+1] = Def.Sprite{
  Name="SongLength",
  Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
  InitCommand=function(s) s:animate(0):zoom(0.5):xy(-480,-80) end,
  SetCommand=function(s,p)
    local song = GAMESTATE:GetCurrentSong()
    if song then
      if song:IsLong() then
        s:setstate(0)
        s:visible(true)
      elseif song:IsMarathon() then
        s:setstate(1)
        s:visible(true)
      else
        s:visible(false)
      end
    else
      s:visible(false)
    end
  end,
  CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
};

t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_shared/_CDTITLE.lua"))(-250,-80)..{
  InitCommand=function(s)
    s:visible(ThemePrefs.Get("CDTITLE")):draworder(1):diffusealpha(0)
  end,
  OnCommand=function(s) s:sleep(0.4):decelerate(0.4):diffusealpha(1) end,
  OffCommand=function(s) s:sleep(0.2):decelerate(0.2):diffusealpha(0) end,
};

return t;
