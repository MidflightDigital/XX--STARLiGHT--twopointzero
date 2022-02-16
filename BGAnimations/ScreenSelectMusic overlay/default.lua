local Deco = Def.ActorFrame{};
if not GAMESTATE:IsCourseMode() then
	Deco[#Deco+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/"..ThemePrefs.Get("WheelType").."Deco"))();
end;

local jk = LoadModule"Jacket.lua"
local ProfilePrefs = LoadModule "ProfilePrefs.lua"

--Custom Music Preview breaks so much crap, let's just not. -Inori
local function play_sample_music(self)
    if GAMESTATE:IsCourseMode() then return end
    local song = GAMESTATE:GetCurrentSong()

    if song then
        local songpath = song:GetMusicPath()
        local sample_start = song:GetSampleStart()
        local sample_len = song:GetSampleLength()

        if songpath and sample_start and sample_len then
          SOUND:PlayMusicPart(songpath, sample_start,sample_len, 1, 1.5, true, true)
        else
            SOUND:PlayMusicPart("", 0, 0)
        end
    end
end

return Def.ActorFrame{
	OnCommand=function(s) SOUND:PlayOnce(THEME:GetPathS("","Music_In"))
		setenv("OPList",0)
	end,
	PlayerJoinedMessageCommand=function(self,param)
		SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectMusic"):StartTransitioningScreen("SM_GoToNextScreen")
  	end;
	Deco;
	loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_OptionsList/default.lua"))();
	loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/InputHandler.lua"))();
	Def.Sound{
		Name="MWChange",
		File=THEME:GetPathS("","MWChange/Default_MWC.ogg"),
		IsAction=true,
	};
	--[[Def.Actor{
		CurrentSongChangedMessageCommand=function(self)
			self:finishtweening():sleep(0.1):queuecommand("PlayMusicPreview")
		end;
		PlayMusicPreviewCommand=function(subself) play_sample_music() end,
	};]]
	CodeMessageCommand=function(s,p)
		if p.PlayerNumber == PLAYER_1 then
			if p.Name == "OpenOL" then
				SCREENMAN:GetTopScreen():OpenOptionsList(PLAYER_1)
			end
		end
		if p.PlayerNumber == PLAYER_2 then
			if p.Name == "OpenOL" then
				SCREENMAN:GetTopScreen():OpenOptionsList(PLAYER_2)
			end
		end
	end,
	Def.Sound{
		File=THEME:GetPathS("","_swoosh out"),
		OffCommand=function(s) s:sleep(1):queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
	OffCommand=function(s)
		ProfilePrefs.LoadFromProfilePrefs()
		s:sleep(1):queuecommand("Dim")
	end,
	DimCommand=function(s) SOUND:DimMusic(0,math.huge) end,
}
