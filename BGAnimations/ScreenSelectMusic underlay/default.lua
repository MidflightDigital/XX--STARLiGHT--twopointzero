local t = Def.ActorFrame{};

if not GAMESTATE:IsCourseMode() then
if ThemePrefs.Get("WheelType") == "Wheel" then
  t[#t+1] = Def.ActorFrame{
    LoadActor("MusicWheelWheelUnder.png")..{
      InitCommand=function(s) s:halign(1):xy(SCREEN_RIGHT,_screen.cy):diffusealpha(0.5)
        if GAMESTATE:IsAnExtraStage() then
          s:diffuse(color("#f900fe"))
        end
      end,
      OnCommand=function(s) s:addx(1100):sleep(0.5):decelerate(0.2):addx(-1100) end,
      OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(1100) end,
    };
    Def.Quad{
      InitCommand=function(s) s:setsize(834,66):xy(_screen.cx+370,_screen.cy+22):diffuse(color("0,0,0,0.5")) end,
      OnCommand=function(s) s:addx(1100):sleep(0.5):decelerate(0.2):addx(-1100) end,
      OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(1100) end,
    }
  };
end;

if ThemePrefs.Get("WheelType") == "A" then
  t[#t+1] = Def.ActorFrame{
    Def.Sprite{
      Texture="ADeco",
      InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT,_screen.cy):blend(Blend.Add):diffusealpha(1) end,
      OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
      OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
    };
    Def.Sprite{
      Texture="ADeco",
      InitCommand=function(s) s:zoomx(-1):halign(0):xy(SCREEN_RIGHT,_screen.cy):blend(Blend.Add):diffusealpha(1) end,
      OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
      OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
    };
  };
end;

if ThemePrefs.Get("WheelType") == "Jukebox" then
  t[#t+1] = Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy-140):rotationx(-55):zoomx(1.4):diffusealpha(0) end,
    OnCommand=function(s) s:linear(0.5):diffusealpha(1) end,
    OffCommand=function(s) s:stoptweening():linear(0.5):diffusealpha(0) end,
    Def.Sprite{
      Texture="inner",
      InitCommand=function(s) s:spin():effectmagnitude(0,0,25) 
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/ex_inner"))
        end
      end,
    };
    Def.Sprite{
      Texture="outer",
      InitCommand=function(s) s:spin():effectmagnitude(0,0,-25)
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/ex_outer"))
        end
      end,
    };
  }
end;

if ThemePrefs.Get("WheelType") == "Banner" then
t[#t+1] = Def.ActorFrame{
  loadfile(THEME:GetPathB("ScreenSelectMusic","underlay/Header"))();
  Def.Sprite{
    Texture=THEME:GetPathG("ScreenWithmenuElements","Header/old.png"),
    InitCommand=function(s) 
      s:xy(_screen.cx,SCREEN_TOP+130):zoom(0.94)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathG("ScreenWithmenuElements","Header/extra_old.png"))
      end
    end,
    OnCommand=function(s)s :addx(-SCREEN_WIDTH):linear(0.2):addx(SCREEN_WIDTH) end,
    OffCommand=function(s)s :linear(0.2):addx(SCREEN_WIDTH) end,
  };
  StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
    InitCommand=function(s) s:zoom(1.25):xy(_screen.cx,SCREEN_TOP+130) end,
  };
  Def.Sprite{
    Texture="wheelunder",
    InitCommand=function(s) 
      s:xy(_screen.cx,_screen.cy-210)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/extra_wheelunder"))
      end
    end,
    OnCommand=function(s) s:zoomtoheight(310):zoomtowidth(0):linear(0.2):zoomtowidth(SCREEN_WIDTH) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.3):zoomtowidth(0) end,
  };
};
end;

if ThemePrefs.Get("WheelType") == "Default" then
t[#t+1] = Def.ActorFrame{
  Def.Sprite{
    Texture="wheelunder",
    InitCommand=function(s) 
      s:xy(_screen.cx,_screen.cy+246)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","underlay/extra_wheelunder"))
      end
    end,
    OnCommand=function(s) s:zoomtowidth(0):linear(0.2):zoomtowidth(SCREEN_WIDTH) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.3):zoomtowidth(0) end,
    StartSelectingStepsMessageCommand=function(s) s:queuecommand("Off") end,
  	SongUnchosenMessageCommand=function(s) s:queuecommand("On") end,
  };
};
end;

if ThemePrefs.Get("WheelType") == "Solo" then
  loadfile(THEME:GetPathB("","ScreenSelectMusic underlay/Solo/default.lua"))();
end;

if ThemePrefs.Get("WheelType") == "Preview" then
  t[#t+1] = Def.Sprite{
		Texture="wheelunder",
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-67.5):zoomto(SCREEN_WIDTH,412):draworder(-1) end,
    OnCommand=function(s) s:zoomtowidth(0):linear(0.2):zoomtowidth(SCREEN_WIDTH) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.3):zoomtowidth(0) end,
    StartSelectingStepsMessageCommand=function(s) s:queuecommand("Off") end,
  	SongUnchosenMessageCommand=function(s) s:queuecommand("On") end,
	};
end;

end;
return t;
