local SongAttributes = LoadModule "SongAttributes.lua"
local jk = LoadModule"Jacket.lua"

local AnimPlayed = true

return Def.ActorFrame{
  CurrentSongChangedMessageCommand=function(s)
    if GAMESTATE:GetCurrentSong() then
      s:stoptweening():queuecommand("Show"):playcommand("Set")
    else
      s:queuecommand("Hide")
    end
  end,
  ShowCommand=function(s)
    if AnimPlayed == false then 
      s:stoptweening():diffusealpha(0):linear(0.05):diffusealpha(0.75)
      :linear(0.1):diffusealpha(0.25):linear(0.1):diffusealpha(1)
      s:queuecommand("UpdateShow")
    end
  end,
  UpdateShowCommand=function(s) AnimPlayed = true end,
  HideCommand=function(s)
    if AnimPlayed == true then
      s:stoptweening():diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(0.5)
      :sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(0.25):sleep(0.05)
      :linear(0.05):diffusealpha(0)
      s:queuecommand("UpdateHide")
    end
  end,
  UpdateHideCommand=function(s) AnimPlayed = false end,
  ChangedLanguageDisplayMessageCommand = function(s) s:finishtweening():queuecommand("Set") end,
  SetCommand=function(s,p)
      local song = GAMESTATE:GetCurrentSong()
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      local Jacket = s:GetChild("Jacket Area"):GetChild("Jacket")
      local Title = s:GetChild("Info"):GetChild("Title")
      local Artist = s:GetChild("Info"):GetChild("Artist")
      if not mw then return end
      if song then
          Jacket:Load(jk.GetSongGraphicPath(song,"Jacket"))
          Title:visible(true):settext(song:GetDisplayFullTitle())
          Artist:visible(true):settext(song:GetDisplayArtist() ~= "Unknown artist" and song:GetDisplayArtist() or '')
      end
      Jacket:scaletofit(-120,-120,120,120)
  end,
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
		InitCommand=function(s) s:setsize(102,306):diffusealpha(0.5):blend(Blend.Add):x(-540):MaskDest():ztestmode("ZTestMode_WriteOnFail"):queuecommand("Anim") end,
		AnimCommand=function(s) s:x(-540):sleep(4):smooth(1.5):x(480):queuecommand("Anim") end,
	};
  Def.Quad{
    InitCommand=function(s) s:x(301):setsize(240,240):diffuse(Color.Black) end,
  };
  Def.ActorFrame{
    Name="Jacket Area",
    InitCommand=function(s) s:x(301) end,
    Def.Sprite{
      Name="Jacket",
    };
  },
  Def.ActorFrame{
    Name="Info",
    InitCommand=function(s) s:x(-420) end,
    Def.BitmapText{
      Name="Title",
      Font="_avenirnext lt pro bold/36px",
      InitCommand=function(s) s:maxwidth(540):halign(0):y(-34):diffuse(Color.Black) end,
    };
    Def.BitmapText{
      Name="Artist",
      Font="_avenirnext lt pro bold/36px",
      InitCommand=function(s) s:maxwidth(500):halign(0):zoomx(0.78):zoomy(0.65) end,
    };
  },
  loadfile(THEME:GetPathB("ScreenSelectMusic","decorations/_CDTITLE.lua"))(0,50)..{
    InitCommand=function(s)
      s:visible(ThemePrefs.Get("CDTITLE")):draworder(-1):diffusealpha(0)
    end,
    OnCommand=function(s) s:sleep(0.4):decelerate(0.4):diffusealpha(1) end,
    OffCommand=function(s) s:sleep(0.2):decelerate(0.2):diffusealpha(0) end,
  };
}