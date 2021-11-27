
setenv("FixStage",0)

return Def.ActorFrame{
  StorageDevicesChangedMessageCommand=function(self, params)
		MemCardInsert()
	end;
  Def.Quad{
    InitCommand=function(s) s:diffuse(color("0,0,0,1")):FullScreen() end,
  };
  LoadActor("../ScreenWithMenuElements background");
  Def.ActorFrame{
    InitCommand = function(s) s:xy(_screen.cx-540,_screen.cy+30) end,
    OnCommand=function(s) s:diffusealpha(0):linear(0.3):diffusealpha(1) end,
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
    InitCommand=function(s) s:Center():zoom(2):diffusealpha(0) end,
    OnCommand=function(s) s:linear(0.3):diffusealpha(1):zoom(1) end,
    LoadActor(THEME:GetPathB("","ScreenLogo underlay/XX.png")) .. {
      InitCommand=function(s) s:xy(362,16) end,
    };
    LoadActor(THEME:GetPathB("","ScreenLogo underlay/starlight.png")) .. {
      InitCommand=function(s) s:xy(22,84) end,
    };
    LoadActor(THEME:GetPathB("","ScreenLogo underlay/twopointzero.png")) .. {
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
      s:xy(_screen.cx+104,_screen.cy+16):diffusealpha(0):blend(Blend.Add):sleep(0.3):queuecommand("Anim")
    end,
    AnimCommand=function(s) s:diffusealpha(0):sleep(1):linear(0.75):diffusealpha(0.3):sleep(0.1):linear(0.4):diffusealpha(0):queuecommand("Anim") end,
  };
  Def.Sprite{
    InitCommand=function(s)
      if MonthOfYear() == 4 and DayOfMonth() == 1 then
        s:Load(THEME:GetPathB("","ScreenLogo underlay/itglogo.png"))
      else
        s:Load(THEME:GetPathB("","ScreenLogo underlay/xxlogo.png"))
      end
      s:xy(_screen.cx+104,_screen.cy+16):blend(Blend.Add):diffusealpha(0)
    end,
    OnCommand=function(s) s:sleep(0.3):diffusealpha(1):linear(1):diffusealpha(0):zoom(1.5) end,
  };
  LoadActor(THEME:GetPathB("","ScreenTitleJoin underlay/_press start"))..{
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy+340):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#B4FF01")) end,
    OffCommand=function(s) s:linear(0.1):diffusealpha(0) end,
  };
}

