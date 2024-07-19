local Deco = Def.ActorFrame{};
if not GAMESTATE:IsCourseMode() then
	Deco[#Deco+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/"..ThemePrefs.Get("WheelType").."Deco"))();
end;

local jk = LoadModule"Jacket.lua"

--[[--Custom Music Preview breaks so much crap, let's just not. -Inori
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
end]]

return Def.ActorFrame{
	--[[Def.Actor{
		CurrentSongChangedMessageCommand=function(self)
			self:finishtweening():sleep(0.1):queuecommand("PlayMusicPreview")
		end;
		PlayMusicPreviewCommand=function(subself) play_sample_music() end,
	};]]
}
