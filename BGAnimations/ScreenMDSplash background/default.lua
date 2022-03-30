local mus_path = THEME:GetCurrentThemeDirectory().."/Sounds/ScreenSelectMusic music (loop).redir"
--update the select music redir here...
local function UpdateSSM()
  if ThemePrefs.Get("MenuMusic") ~= CurrentMenuMusic then
    if not CurrentMenuMusic and FILEMAN:DoesFileExist(mus_path) then
      CurrentMenuMusic = ThemePrefs.Get("MenuMusic")
    else
      local f = RageFileUtil.CreateRageFile()
      local worked = f:Open(mus_path, 10)
      if worked then
        f:Write(GetMenuMusicPath("music",true))
        f:Close()
      elseif SN3Debug then
        SCREENMAN:SystemMessage("Couldn't open select music redir")
      end
      f:destroy()
	  CurrentMenuMusic = ThemePrefs.Get("MenuMusic")
      THEME:ReloadMetrics()
    end
  end
end

local mw_path = THEME:GetCurrentThemeDirectory().."/Sounds/MusicWheel change.redir"
local function UpdateMWC()
  if ThemePrefs.Get("WheelType") ~= CurrentWT then
    if not CurrentWT and FILEMAN:DoesFileExist(mw_path) then
      CurrentWT = ThemePrefs.Get("WheelType")
    else
      local f = RageFileUtil.CreateRageFile()
      local worked = f:Open(mw_path, 10)
      if worked then
        if ThemePrefs.Get("WheelType") == "A" then
          f:Write("_silent")
        elseif ThemePrefs.Get("WheelType") == "Jukebox" then
          f:Write("MWChange/Jukebox_MWC.ogg")
        elseif ThemePrefs.Get("WheelType") == "Banner" then
          f:Write("MWChange/Banner_MWC.ogg")
        else
          f:Write("MWChange/Default_MWC.ogg")
        end
        f:Close()
      elseif SN3Debug then
        SCREENMAN:SystemMessage("Couldn't open MusicWheel change redir")
      end
      f:destroy()
	  CurrentWT = ThemePrefs.Get("WheelType")
      THEME:ReloadMetrics()
    end
  end
end

return Def.ActorFrame{
    OnCommand=function(self)
        if not FILEMAN:DoesFileExist("Save/ThemePrefs.ini") then
          Trace("ThemePrefs doesn't exist; creating file")
          ThemePrefs.ForceSave()
        end
        if SN3Debug then
          SCREENMAN:SystemMessage("Saving ThemePrefs.")
        end
        ThemePrefs.Save()
        UpdateMWC()
        UpdateSSM()
        SOUND:DimMusic(0,math.huge)
      end;
      Def.Quad{
        InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0)) end,
        StartTransitioningCommand=function(s) s:sleep(0.2):linear(0.4):diffusealpha(1) end,
      };
    Def.Sprite{
        Texture=THEME:GetPathB("","ScreenMDSplash background/MIDFLIGHT DIGITAL 2021.mp4"),
        InitCommand=function(s) s:Center():setsize(1920,1080) end,
    };
};