local Crstext = THEME:GetString("MusicWheel","CustomItemCrsText");
local SongAttributes = LoadModule "SongAttributes.lua"
local jk = LoadModule"Jacket.lua"

local song = GAMESTATE:GetCurrentSong()

local AnimPlayed = true

local Jacket = Def.ActorFrame{
  Def.Sprite{
    SetCommand=function(s)
      local song = GAMESTATE:GetCurrentSong()
      if song then
        s:Load(jk.GetSongGraphicPath(song)):scaletofit(-120,-120,120,120)
      end
		end;
  };
  Def.BitmapText{
    Font="_avenirnext lt pro bold/46px",
    InitCommand=function(s) s:y(-20):diffusealpha(1):maxwidth(200):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
    SetMessageCommand=function(self,params)
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      if mw and mw:GetSelectedType() == "WheelItemDataType_Section" then
        if GAMESTATE:GetSortOrder() == "SortOrder_Genre" then
          self:settext(mw:GetSelectedSection())
        else
          self:settext("")
        end;
      else
        self:settext("")
      end
    end,
  };
  Def.Sprite{
		Name="SongLength",
		Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
		InitCommand=function(s) s:animate(0):zoom(0.75):xy(80,80) end,
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
	};
}

local songinfo = Def.ActorFrame{
  Def.BitmapText{
    Font="_avenirnext lt pro bold/36px",
    Name="Title",
    InitCommand=function(s) s:halign(0):maxwidth(540):y(-34):diffuse(Color.Black) end,
    SetCommand=function(s)
      local song = GAMESTATE:GetCurrentSong()
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      if not mw then return end
      if song then
        if song:GetDisplaySubTitle() == "" then
          s:settext(song:GetDisplayMainTitle())
        else
          s:settext(song:GetDisplayFullTitle())
        end
      elseif mw:GetSelectedType('WheelItemDataType_Section') then
        local group = mw:GetSelectedSection()
        if group then
          s:settext(GAMESTATE:GetSortOrder('SortOrder_Group') and SongAttributes.GetGroupName(group) or "")
        end
      else
        s:settext("")
      end
    end
  };
  Def.BitmapText{
    Font="_avenirnext lt pro bold/36px",
    Name="Artist",
    InitCommand=function(s) s:halign(0):maxwidth(500):zoomx(0.78):zoomy(0.65) end,
    SetCommand=function(s)
      local song = GAMESTATE:GetCurrentSong()
      if song then
        s:settext(song:GetDisplayArtist())
      else
        s:settext("")
      end
    end
  }
}

return Def.ActorFrame{
  CurrentSongChangedMessageCommand=function(s)
    if GAMESTATE:GetCurrentSong() then
      s:finishtweening():queuecommand("Show"):playcommand("Set")
    else
      s:queuecommand("Hide")
    end
  end,
  ShowCommand=function(s)
    if AnimPlayed == false then 
      s:finishtweening():diffusealpha(0):linear(0.05):diffusealpha(0.75)
      :linear(0.1):diffusealpha(0.25):linear(0.1):diffusealpha(1)
      s:queuecommand("UpdateShow")
    end
  end,
  UpdateShowCommand=function(s) AnimPlayed = true end,
  HideCommand=function(s)
    if AnimPlayed == true then
      s:finishtweening():diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(0.5)
      :sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(0.25):sleep(0.05)
      :linear(0.05):diffusealpha(0)
      s:queuecommand("UpdateHide")
    end
  end,
  UpdateHideCommand=function(s) AnimPlayed = false end,
  Def.Sprite{
    Texture="SongInfo";
    InitCommand=function(s)
      s:xy(8,9)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","overlay/ADeco/extra_SongInfo"))
      end
    end,
  };
  Def.Sprite{
    Texture="SongInfo";
    InitCommand=function(s)
      s:xy(8,9):MaskSource(true)
      if GAMESTATE:IsAnExtraStage() then
        s:Load(THEME:GetPathB("ScreenSelectMusic","overlay/ADeco/extra_SongInfo"))
      end
    end,
  };
  Def.Sprite{
		Texture="grad.png",
		InitCommand=function(s) s:setsize(102,306):diffusealpha(0.5):blend(Blend.Add):MaskDest():ztestmode("ZTestMode_WriteOnFail") end,
		OnCommand=function(s) s:queuecommand("Anim") end,
		AnimCommand=function(s) s:x(-540):sleep(4):smooth(1.5):x(480):queuecommand("Anim") end,
	};
  Jacket..{
    InitCommand=function(s) s:x(301) end,
  };
  songinfo..{
    InitCommand=function(s) s:x(-420) end,
  };
  loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_CDTITLE.lua"))(0,50)..{
    InitCommand=function(s)
      s:visible(ThemePrefs.Get("CDTITLE")):draworder(-1):diffusealpha(0)
    end,
    OnCommand=function(s) s:sleep(0.4):decelerate(0.4):diffusealpha(1) end,
    OffCommand=function(s) s:sleep(0.2):decelerate(0.2):diffusealpha(0) end,
  };
}
