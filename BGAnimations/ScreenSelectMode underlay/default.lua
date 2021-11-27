return Def.ActorFrame{
  Def.Quad{
    InitCommand=function(s) s:diffuse(color("0,0,0,1")):FullScreen() end,
  };
  loadfile(THEME:GetPathB("","ScreenWithMenuElements background"))();
  Def.ActorFrame{
    InitCommand = function(s) s:xy(_screen.cx-540,_screen.cy+30) end,
    Def.ActorFrame{
      Def.Sprite{
        Texture=THEME:GetPathB("","ScreenLogo underlay/panels"),
        InitCommand=function(s) s:xy(10,338) end,
      };
      Def.Sprite{
        Texture=THEME:GetPathB("","ScreenLogo underlay/panels"),
        InitCommand=function(s) s:xy(10,338):blend(Blend.Add)
          :diffuseshift():effectcolor1(Alpha(Color.White,0.3)):effectcolor2(Alpha(Color.White,0)):effectperiod(5)
        end,
      };
    };
    Def.Sprite{ Texture=THEME:GetPathB("","ScreenLogo underlay/new dancer"), };
  };
  Def.ActorFrame{
    InitCommand=function(s) s:Center() end,
    Def.Sprite{
      Texture=THEME:GetPathB("","ScreenLogo underlay/XX.png"),
      InitCommand=function(s) s:xy(362,16) end,
    };
    Def.Sprite{
      Texture=THEME:GetPathB("","ScreenLogo underlay/starlight.png"),
      InitCommand=function(s) s:xy(22,84) end,
    };
    Def.Sprite{
      Texture=THEME:GetPathB("","ScreenLogo underlay/twopointzero.png"),
      InitCommand=function(s) s:xy(112,126) end,
    };
    Def.Sprite{
      InitCommand=function(s)
        s:xy(-64,-32)
        if MonthOfYear() == 4 and DayOfMonth() == 1 then
          s:Load(THEME:GetPathB("","ScreenLogo underlay/itg_main.png"))
        else
          s:Load(THEME:GetPathB("","ScreenLogo underlay/main.png"))
        end
      end,
    };
  };
  Def.Sprite{
    InitCommand=function(s) 
      if MonthOfYear() == 4 and DayOfMonth() == 1 then
        s:Load(THEME:GetPathB("","ScreenLogo underlay/itglogo.png"))
      else
        s:Load(THEME:GetPathB("","ScreenLogo underlay/xxlogo.png"))
      end
      s:xy(_screen.cx+104,_screen.cy+16):blend(Blend.Add):queuecommand("Anim")
    end,
    AnimCommand=function(s) s:diffusealpha(0):sleep(1):linear(0.75):diffusealpha(0.3):sleep(0.1):linear(0.4):diffusealpha(0):queuecommand("Anim") end,
  };
};
