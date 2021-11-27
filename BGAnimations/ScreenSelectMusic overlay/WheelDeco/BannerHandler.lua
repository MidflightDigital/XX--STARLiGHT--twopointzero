local ex = ""
if GAMESTATE:IsAnExtraStage() then
  ex = "ex_"
end
local jk = LoadModule "Jacket.lua"

return Def.ActorFrame{
--Jacket
  Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx-256,_screen.cy-254):visible(IsUsingWideScreen()) end,
    OnCommand=function(s) s:addy(-800):sleep(0.4):decelerate(0.5):addy(800) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.5):addy(-800) end,
    CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
    LoadActor(ex.."Jacket Backer");
    Def.Banner{
      InitCommand=function(s) s:xy(-2,-4) end,
      SetCommand=function(self,params)
        self:finishtweening()
        local song = GAMESTATE:GetCurrentSong();
        local so = GAMESTATE:GetSortOrder();
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        if not mw then return end
        if song then
          self:Load(jk.GetSongGraphicPath(song,"Jacket"))
        elseif mw:GetSelectedType('WheelItemDataType_Section')  then
          if mw:GetSelectedSection() == "" then
            self:Load(THEME:GetPathG("","_jackets/Random"))
          else
            self:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Jacket",so))
          end
        else
          self:Load( THEME:GetPathG("","MusicWheelItem fallback") );
        end;
        self:zoomto(240,240);
          end;
    };
    Def.Sprite{
      InitCommand=function(s) s:xy(-2,-4) end,
      SetCommand=function(self)
        local song = GAMESTATE:GetCurrentSong();
        local so = GAMESTATE:GetSortOrder();
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        if not song and mw then
          if mw:GetSelectedType() == 'WheelItemDataType_Custom' then
            self:Load(THEME:GetPathG("","_jackets/COURSE"))
            self:visible(true)
          else
            self:visible(false)
          end;
        else
          self:visible(false)
        end;
        self:zoomto(240,240);
      end;
    };
    LoadFont("_avenirnext lt pro bold 46px")..{
        InitCommand=function(s) s:y(-20):diffusealpha(1):maxwidth(200):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
        SetMessageCommand=function(self,params)
          local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
          local so = GAMESTATE:GetSortOrder();
          if mw and  mw:GetSelectedType() == "WheelItemDataType_Section" then
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
  
  --Banner
  Def.ActorFrame{
    InitCommand=function(s) s:xy(SCREEN_LEFT+286,_screen.cy-254) end,
    OnCommand=function(s) s:addx(-800):sleep(0.3):decelerate(0.3):addx(800) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.3):addx(-800) end,
    CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
    LoadActor(ex.."BannerFrame");
    Def.Banner{
      InitCommand=function(s) s:xy(-24,-20) end,
      SetCommand=function(self,params)
        self:finishtweening()
        local song = GAMESTATE:GetCurrentSong();
        local so = GAMESTATE:GetSortOrder();
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        if not mw then return end
        if song then
          self:Load(jk.GetSongGraphicPath(song,"Banner"))
        elseif mw:GetSelectedType('WheelItemDataType_Section') then
          if mw:GetSelectedSection() == "" then
            self:Load(THEME:GetPathG("","_banners/Random"))
          else
            self:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Banner",so))
          end
        else
          self:visible(false)
        end;
        self:scaletoclipped(478,150);
      end;
    };
    Def.Sprite{
      InitCommand=function(s) s:xy(-24,-20) end,
      SetCommand=function(self)
        local song = GAMESTATE:GetCurrentSong();
        local so = GAMESTATE:GetSortOrder();
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        if not song and mw then
          if mw:GetSelectedType() == 'WheelItemDataType_Custom' then
            self:Load(THEME:GetPathG("","_banners/COURSE")):setsize(478,150)
            self:visible(true)
          else
            self:visible(false)
          end;
        else
          self:visible(false)
        end;
      end;
    };
    Def.Sprite{
      OnCommand=function(self)
        local style = GAMESTATE:GetCurrentStyle():GetStyleType()
        if style == 'StyleType_OnePlayerOneSide' then
          self:Load(THEME:GetPathB("","ScreenEvaluationSummary decorations/1Pad"))
        else
          self:Load(THEME:GetPathB("","ScreenEvaluationSummary decorations/2Pad"))
        end;
          self:xy(-210,85):zoom(0.6)
      end;
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold 46px";
		  InitCommand=function(s) s:xy(-20,-20):diffusealpha(1):maxwidth(460):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
      SetMessageCommand=function(self,params)
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        local so = GAMESTATE:GetSortOrder();
        if mw and mw:GetSelectedType() == "WheelItemDataType_Section" then
			    if so == "SortOrder_Genre" then
            self:settext(mw:GetSelectedSection())
            self:visible(true)
			    else
            self:visible(false)
			    end;
		    else
          self:visible(false)
        end
      end,
	  };
    loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_CDTITLE.lua"))(180,-70)..{
      InitCommand=function(s)
        s:visible(ThemePrefs.Get("CDTITLE")):draworder(1)
      end,
    }
  };
};
