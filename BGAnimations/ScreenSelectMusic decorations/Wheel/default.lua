local ex = ""
if GAMESTATE:IsAnExtraStage() then
  ex = "ex_"
end

local t = Def.ActorFrame{}

local RecordPane = Def.ActorFrame{
    InitCommand = function(s) s:xy(SCREEN_LEFT+470,SCREEN_BOTTOM-150) end,
      OnCommand=function(s) s:addy(600):sleep(0.4):decelerate(0.3):addy(-600) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addy(600) end,
    Def.Sprite{
      Texture=ex.."RadarBack",
    };
    Def.Sprite{
      Texture="eq",
      InitCommand = function(s) s:diffuse(color("0.25,0.25,0.25,0.5")) end,
    };
    loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/WheelDeco/BPM.lua"))();
    Def.ActorFrame{
      Def.Quad {
          InitCommand = function(s) s:zoomto(916,204):y(-10) end,
          OnCommand = function(s) s:bounce():effectclock("beat")
          :effectperiod(2):effectmagnitude(0,254,0):MaskSource(true)
        end,
      };
      Def.Sprite{
        Texture="eq",
          InitCommand = function(s) s:MaskDest():ztestmode("ZTestMode_WriteOnFail") end,
      };
    };
}

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
    t[#t+1] = Def.ActorFrame{
      loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Wheel/RadarHandler.lua"))(pn)..{
        InitCommand = function(s) s:xy(SCREEN_LEFT+172,SCREEN_BOTTOM-130):zoom(0.65) end,
      };
      loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/Wheel/Pane.lua"))()..{
        InitCommand = function(s) s:xy(SCREEN_LEFT+480,SCREEN_BOTTOM-145) end,
          OnCommand=function(s) s:addy(600):sleep(0.4):decelerate(0.3):addy(-600) end,
          OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addy(600) end,
        CurrentSongChangedMessageCommand=function(self)
          local song = GAMESTATE:GetCurrentSong()
            if song then
                self:zoom(1);
            else
                self:zoom(1);
            end;
          end;
      };
    };
    t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_ShockArrow/default.lua"))(pn)..{
          InitCommand=function(s)
              s:xy(pn==PLAYER_1 and SCREEN_LEFT+80 or SCREEN_LEFT+263,SCREEN_BOTTOM-200):zoom(0.25)
          end,
          SetCommand=function(s)
              local song = GAMESTATE:GetCurrentSong()
              if song then
                  local steps = GAMESTATE:GetCurrentSteps(pn)
                  if steps then
                      if steps:GetRadarValues(pn):GetValue('RadarCategory_Mines') >= 1 then
                          s:queuecommand("Anim")
                      else
                          s:queuecommand("Hide")
                      end
                  else
                      s:queuecommand("Hide")
                  end
              else
                  s:queuecommand("Hide")
              end
          end,
          CurrentSongChangedMessageCommand=function(s) s:stoptweening():queuecommand("Set") end,
          ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
          OffCommand=function(s) s:queuecommand("Hide") end,	
    }
end

return Def.ActorFrame{
    Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
            local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            mw:xy(_screen.cx+360,_screen.cy+20):draworder(-1)
        end,
        OnCommand=function(s)
            local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            mw:rotationy(30)
                :addx(1100):sleep(0.412):linear(0.196):addx(-1100)
            mw:SetDrawByZPosition(true)
        end,
        OffCommand=function(s)
            local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
        end
    };
    LoadActor("BannerHandler.lua"),
    StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
        InitCommand=function(s) s:xy(SCREEN_LEFT+340,_screen.cy-160):zoom(1) end,
    };
    RecordPane;
    t;
    Def.Sprite{
        Texture=ex.."Header",
        InitCommand=function(s) s:align(0,0):xy(SCREEN_LEFT,SCREEN_TOP+16) end,
        OnCommand=function(s) s:addx(-1000):sleep(0.1):decelerate(0.3):addx(1000) end,
        OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(-1000) end,
    };
    Def.ActorFrame{
        Name="HLFrame",
        InitCommand=function(s) s:xy(SCREEN_CENTER_X+436,_screen.cy+24) end,
        OnCommand=function(s) s:addx(1100):sleep(0.5):decelerate(0.2):addx(-1100) end,
        OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(1100) end,
        Def.Sprite{Texture=ex.."frame.png",};
        Def.Sprite{
          Texture=ex.."frame deco.png",
          InitCommand=function(s) s:diffuseshift():effectcolor1(Color.White):effectcolor2(Alpha(Color.White,0.75)):effectperiod(1) end,
        };
    };
    Def.ActorFrame{
        Name="DiffStuff",
        InitCommand=function(self) self:xy(IsUsingWideScreen() and SCREEN_LEFT+408 or SCREEN_LEFT+330,SCREEN_CENTER_Y+80) end,
        OnCommand=function(s) s:zoom(IsUsingWideScreen() and 1 or 0.8):addx(-800):sleep(0.3):decelerate(0.3):addx(800) end,
        OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(-800) end,
        Def.Sprite{
          Texture="DiffBacker",
        };
        Def.Sprite{
          Texture=ex.."DiffFrame",
          InitCommand=function(self) self:x(4)
          end
        };
        loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/WheelDeco/NewDiff.lua"))()..{
          InitCommand=function(self) self:x(4) end,
        };
    };
    Def.Sprite{
		Name="SongLength",
		Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
		InitCommand=function(s) s:animate(0):zoom(0.7):xy(SCREEN_LEFT+100,_screen.cy-104):zoomy(0) end,
		OnCommand=function(s) s:zoomy(0):sleep(0.3):bounceend(0.175):zoomy(0.7) end,
  		OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
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
    LoadActor("../TwoPartDiff"),
}