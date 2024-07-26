local Crstext = THEME:GetString("MusicWheel","CustomItemCrsText");
local SongAttributes = LoadModule "SongAttributes.lua"
local jk = ...

return Def.ActorFrame{
 	InitCommand=function(s) s:xy(_screen.cx,_screen.cy-190):diffusealpha(1) end,
  OnCommand=function(s) s:zoomy(0):sleep(0.2):bounceend(0.175):zoomy(1) end,
  OffCommand=function(s) s:bouncebegin(0.175):zoomy(0) end,
  CurrentSongChangedMessageCommand=function(s,p)
      s:finishtweening()
      local song = GAMESTATE:GetCurrentSong();
      local so = GAMESTATE:GetSortOrder();
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      
      local title = s:GetChild("Info"):GetChild("Title")
      local banner = s:GetChild("Banner")
      if not mw then return end
      if song then
        banner:Load(jk.GetSongGraphicPath(song,"Banner"))
        title:settext(song:GetDisplayFullTitle())
      elseif mw:GetSelectedType('WheelItemDataType_Section') then
        if mw:GetSelectedSection() ~= "" then
          banner:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Banner",GAMESTATE:GetSortOrder()))
          title:settext(SongAttributes.GetGroupName(mw:GetSelectedSection()))
        else
          if mw:GetSelectedType() == 'WheelItemDataType_Random' then
            banner:Load(THEME:GetPathG("","_banners/Random"))
            title:settext("RANDOM")
          elseif mw:GetSelectedType() == 'WheelItemDataType_Roulette' then
            banner:Load(THEME:GetPathG("","_banners/Random"))
            title:settext("ROULETTE")
          elseif mw:GetSelectedType('WheelItemDataType_Custom') then
            banner:Load(THEME:GetPathG("","_banners/COURSE"))
            title:settext("COURSE")
          end
        end
      else
        banner:Load(THEME:GetPathG("","Common fallback banner"));
      end;
      banner:scaletofit(-239,-75,239,75):y(20)
  end,
  Def.Sprite{
    Texture="BannerFrame",
    InitCommand=function(s) s:y(40)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","overlay/JukeboxDeco/ex_BannerFrame"))
      end
    end
  };
	Def.Sprite{
    Name="Banner",
  };
  Def.ActorFrame{
    Name="Info",
    InitCommand=function(s) s:y(120) end,
    Def.Quad{
      InitCommand=function(s) s:setsize(478,30):diffuserightedge(color("1,1,1,0")):diffuseleftedge(color("1,1,1,0")) end,
    },
    Def.BitmapText{
      Name="Title",
      Font="_avenirnext lt pro bold/20px",
      InitCommand=function(s) s:maxwidth(400) end,
    },
    Def.BitmapText{
      Name="Genre",
      Font="_avenirnext lt pro bold/46px",
      InitCommand=function(s) s:diffusealpha(1):maxwidth(200):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
      SetMessageCommand=function(self,params)
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        local so = GAMESTATE:GetSortOrder();
        if not mw then return end
        if mw:GetSelectedType() == "WheelItemDataType_Section" then
          local group = mw:GetSelectedSection()
          if so == "SortOrder_Genre" then
            self:settext(group)
          else
            self:settext("")
          end;
        else
          self:settext("")
        end
      end,
    };
  };
  loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/DefaultDeco/BPM.lua"))(1)..{
    InitCommand=function(s) s:xy(234,-80) end,
  };
  loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_CDTITLE.lua"))(320,0)..{
    InitCommand=function(s)
      s:visible(ThemePrefs.Get("CDTITLE"))
    end,
  }
};
