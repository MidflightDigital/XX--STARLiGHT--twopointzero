local invalidprefsBGM = {
	"leeium",
	"SN3"
};

local invalidprefsWheel = {
	"Default",
	"Solo"
};

local invalidprefsmenu = {
	"New",
	"Old",
};

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

local t = Def.ActorFrame{
	Def.Actor{
		OnCommand=function(s)
			if GAMESTATE:GetCoinMode() == 'CoinMode_Pay' then
				local coins = GAMESTATE:GetCoins()
				if coins >= 1 then
					GAMESTATE:InsertCoin(-coins)
				end
			end
			SOUND:DimMusic(0,math.huge)
			if has_value(invalidprefsmenu,ThemePrefs.Get("MenuBG")) then
				ThemePrefs.Set("MenuBG","Default")
			end
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
		end,
	};
};

local f = RageFileUtil.CreateRageFile()
if f:Open(mus_path, 1) then
	if GetMenuMusicPath("music") then
		if GetMenuMusicPath("music") ~= "/"..THEME:GetCurrentThemeDirectory().."Sounds/"..f:Read() then
			--I don't know why the FUCK I have to do this but it read+write just doesn't work I guess.
			f:Close()
			f:Open(mus_path, 2)
			f:Write(GetMenuMusicPath("music",true))
			f:Close()
		end
		f:destroy()
		THEME:ReloadMetrics()
	end
end

return t;
