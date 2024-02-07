
setenv("FixStage",0)

return Def.ActorFrame{
  StorageDevicesChangedMessageCommand=function(self, params)
		MemCardInsert()
	end;
  loadfile(THEME:GetPathB("","_Dancer/default.lua"))()..{
    InitCommand = function(s) s:xy(_screen.cx-540,_screen.cy+30) end,
    OnCommand=function(s) s:diffusealpha(0):linear(0.3):diffusealpha(1) end,
  };
  loadfile(THEME:GetPathB("","_Logo/default.lua"))()..{
    InitCommand=function(s) s:Center():zoom(2):diffusealpha(0) end,
    OnCommand=function(s) s:decelerate(0.5):diffusealpha(1):zoom(1) end,
  };
  Def.Sprite{
    InitCommand=function(s)
      if MonthOfYear() == 3 and DayOfMonth() == 1 then
        s:Load(THEME:GetPathB("","_Logo/owologo.png"))
      else
        s:Load(THEME:GetPathB("","_Logo/xxlogo.png"))
      end
      s:xy(_screen.cx+102,_screen.cy+16):blend(Blend.Add):diffusealpha(0)
    end,
    OnCommand=function(s) s:sleep(0.45):diffusealpha(1):linear(1):diffusealpha(0):zoom(1.5):sleep(0):zoom(1):queuecommand("Anim") end,
    AnimCommand=function(s) s:diffusealpha(0):sleep(1):linear(0.75):diffusealpha(0.3):sleep(0.1):linear(0.4):diffusealpha(0):queuecommand("Anim") end,
    OffCommand=function(s) s:stoptweening() end,
  };
  Def.Sprite{
    Texture=THEME:GetPathB("","ScreenTitleJoin underlay/_press start"),
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy+340):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#B4FF01")) end,
    OffCommand=function(s) s:stoptweening():linear(0.1):diffusealpha(0) end,
  };
  Def.Quad{
    InitCommand=function(s) s:diffuse(color("0,0,0,1")):FullScreen() end,
    OnCommand=function(s) s:linear(0.2):diffusealpha(0) end,
  };
}

