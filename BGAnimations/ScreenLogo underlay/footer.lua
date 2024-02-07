
return Def.ActorFrame{
  Def.ActorFrame{
    Name="Top",
    InitCommand=function(s) s:xy(_screen.cx+160,SCREEN_TOP-140):diffusealpha(0):zoom(0.7):rotationz(180)  end,
    OnCommand = function(s)
      s:sleep(2.5):smooth(0.3):y(SCREEN_TOP+38):diffusealpha(1):zoom(1.4)
    end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):addy(-200) end,
    Def.Sprite{
      Texture=THEME:GetPathG("ScreenWithMenuElements","Footer/base.png"),
    };
    Def.Sprite{
      Texture=THEME:GetPathG("ScreenWithMenuElements","Footer/side glow.png"),
      InitCommand=function(s) s:y(0) end,
      OnCommand=function(s) 
        if screen ~= "ScreenSelectProfilePrefs" then
          s:cropleft(0.5):cropright(0.5):sleep(2.8):decelerate(0.4):cropleft(0):cropright(0):sleep(0.5):queuecommand("Anim")
        end
      end,
      AnimCommand=function(s) s:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.5")):effectperiod(2) end,
    };
    Def.ActorFrame{
      OnCommand=function(s) 
        if screen ~= "ScreenSelectProfilePrefs" then
          s:diffusealpha(0):sleep(2.8):decelerate(0.5):diffusealpha(1)
        end
      end,
      Def.Sprite{
        Texture=THEME:GetPathG("ScreenWithMenuElements","Footer/arrow.png"),
        InitCommand=function(s) s:xy(1,-36) end,
        OnCommand=function(s) 
          if screen ~= "ScreenSelectProfilePrefs" then
            s:addy(100):sleep(2.75):decelerate(0.4):addy(-100)
          end
        end
      };
    };
  };
  Def.ActorFrame{
    Name="Bottom",
    InitCommand=function(s) s:xy(_screen.cx-160,SCREEN_BOTTOM+140):diffusealpha(0):zoom(0.7)  end,
    OnCommand = function(s)
      s:sleep(2.5):smooth(0.3):y(SCREEN_BOTTOM-38):diffusealpha(1):zoom(1.4)
    end,
    StartPressedLogoMessageCommand=function(s) s:linear(0.1):addy(200) end,
    Def.Sprite{
      Texture=THEME:GetPathG("ScreenWithMenuElements","Footer/base.png"),
    };
    Def.Sprite{
      Texture=THEME:GetPathG("ScreenWithMenuElements","Footer/side glow.png"),
      InitCommand=function(s) s:y(0) end,
      OnCommand=function(s) 
        if screen ~= "ScreenSelectProfilePrefs" then
          s:cropleft(0.5):cropright(0.5):sleep(2.8):decelerate(0.4):cropleft(0):cropright(0):sleep(0.5):queuecommand("Anim")
        end
      end,
      AnimCommand=function(s) s:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.5")):effectperiod(2) end,
    };
    Def.ActorFrame{
      OnCommand=function(s) 
        if screen ~= "ScreenSelectProfilePrefs" then
          s:diffusealpha(0):sleep(2.8):decelerate(0.5):diffusealpha(1)
        end
      end,
      Def.Sprite{
        Texture=THEME:GetPathG("ScreenWithMenuElements","Footer/arrow.png"),
        InitCommand=function(s) s:xy(1,-36) end,
        OnCommand=function(s) 
          if screen ~= "ScreenSelectProfilePrefs" then
            s:addy(100):sleep(2.75):decelerate(0.4):addy(-100)
          end
        end
      };
    };
  }
}
