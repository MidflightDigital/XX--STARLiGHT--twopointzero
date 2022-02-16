local Crstext = THEME:GetString("MusicWheel","CustomItemCrsText");
local SongAttributes = LoadModule "SongAttributes.lua"
local jk = LoadModule"Jacket.lua"

local Jacket = Def.ActorFrame{
  InitCommand=function(s) s:y(-40) end,
  quadButton(1)..{
    InitCommand=function(s) s:setsize(378,378):visible(false) end,
    TopPressedCommand=function(s)
      if GAMESTATE:GetCurrentSong() then
        SOUND:PlayOnce(THEME:GetPathS("Common","start"))
        SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_MenuTimer")
      end
    end,
  };
  Def.Sprite{ Texture=THEME:GetPathG("","_shared/_jacket back"),};
	Def.ActorProxy{
    SetCommand=function(self)
      if centerSongObjectProxy then
        self:SetTarget(centerSongObjectProxy)
      end
      self:zoom(1.64)
      self:visible(GAMESTATE:GetCurrentSong() ~= nil)
		end;
  };
  Def.Sprite{
    Name="GroupJacket",
    SetCommand=function(self,params)
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      if not mw then return end
      if not GAMESTATE:GetCurrentSong() then
        if mw:GetSelectedType('WheelItemDataType_Section') then
          if mw:GetSelectedSection() == "" then
            self:Load(THEME:GetPathG("","_jackets/Random"))
          else
            self:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Jacket",GAMESTATE:GetSortOrder()))
          end
        else
          self:Load( THEME:GetPathG("","MusicWheelItem fallback") );
        end
        self:diffusealpha(1)
      else
        self:diffusealpha(0)
      end
      self:scaletofit(-189,-189,189,189)
    end;
  },
  Def.Sprite{
    SetCommand=function(self,params)
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      if not GAMESTATE:GetCurrentSong() and mw then
        if mw:GetSelectedType() == 'WheelItemDataType_Custom' then
          self:Load(THEME:GetPathG("","_jackets/COURSE"))
          self:visible(true)
        else
          self:visible(false)
        end
      else
        self:visible(false)
      end
      self:zoomto(378,378);
    end;
  },
  loadfile(THEME:GetPathG("","_jackets/GenreBanner.lua"))(BNR)..{
    InitCommand=function(s) s:zoom(0.735) end,
  },
  --[[Def.Sprite{
    Texture=THEME:GetPathG("","_shared/jacket glow"),
    InitCommand=function(s) s:blend(Blend.Add):setsize(378,378) end,
    SetCommand=function(s)
      s:finishtweening():diffusealpha(1):decelerate(0.3):diffusealpha(0)
    end
  }]]
}

local SongInfo = Def.ActorFrame{
  InitCommand=function(s) s:y(208) end,
  SetCommand=function(s)
    local song = GAMESTATE:GetCurrentSong()
    local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
    local so = GAMESTATE:GetSortOrder()
    if not mw then return end
    local title = s:GetChild("TextBanner"):GetChild("Title")
    local artist = s:GetChild("TextBanner"):GetChild("Artist")
    local banner = s:GetChild("Banner")

    title:finishtweening():diffusealpha(0):x(-20):decelerate(0.25):x(0):diffusealpha(1)
    artist:finishtweening():diffusealpha(0):x(20):decelerate(0.25):x(0):diffusealpha(1)
    banner:finishtweening()

    if song then
      banner:Load(jk.GetSongGraphicPath(song,"Banner"))
      title:visible(true):settext(song:GetDisplayFullTitle()):diffuse(SongAttributes.GetMenuColor(song)):y(-6):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
      artist:visible(true):settext(song:GetDisplayArtist()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
    elseif mw:GetSelectedType('WheelItemDataType_Section') then
      if mw:GetSelectedSection() == "" then
        banner:Load(THEME:GetPathG("","_banners/Random"))
      end
      if mw:GetSelectedSection() ~= "" then
        title:visible(true):settext(SongAttributes.GetGroupName(mw:GetSelectedSection())):y(6):diffuse(SongAttributes.GetGroupColor(mw:GetSelectedSection())):strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(mw:GetSelectedSection())))
        artist:settext(""):visible(false)
        banner:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Banner",so))
      else
        title:settext(""):visible(false)
        artist:settext(""):visible(false)
        banner:Load(THEME:GetPathG("","Common fallback banner"));
      end
    end
    banner:scaletofit(-205,-75,205,75):y(20)
  end,
  Def.Sprite{
    Texture=THEME:GetPathG("","_shared/mask_titlebox"),
    InitCommand=function(s) s:MaskSource() end,
  };
  Def.Sprite{
    Name="Banner",
    InitCommand=function(s) s:MaskDest():ztestmode('ZTestMode_WriteOnFail'):blend(Blend.Add):diffusealpha(0.5) end,
  };
  Def.Sprite{
    Texture=THEME:GetPathG("","_shared/titlebox"),
  };
  Def.ActorFrame{
    Name="TextBanner",
    Def.BitmapText{
      Name="Title",
      Font="_avenirnext lt pro bold/20px",
      InitCommand=function(s) s:maxwidth(400) end,
    };
    Def.BitmapText{
      Name="Artist",
      Font="_avenirnext lt pro bold/20px",
      InitCommand=function(s) s:y(20):maxwidth(400) end,
    };
  },
--[[Def.Sprite{
    Texture=THEME:GetPathG("","_shared/midglow_titlebox"),
    InitCommand=function(s) s:blend(Blend.Add) end,
    SetCommand=function(s)
      s:finishtweening():diffusealpha(1):decelerate(0.3):diffusealpha(0)
    end
  }]]
}

return Def.ActorFrame{
  CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
  ChangedLanguageDisplayMessageCommand = function(s) s:stoptweening():queuecommand("Set") end,
  Jacket;
  SongInfo;
};
