--DO NOT TRY TO LOAD THIS ACTOR DIRECTLY!!
--IT WILL NOT WORK!!

local t = Def.ActorFrame{};

local function setVisibility(self)
    local song = GAMESTATE:GetCurrentSong();
    local shouldShowBGScripts = false
    if song then
        shouldShowBGScripts = not (#song:GetBGChanges() > 0)
        if shouldShowBGScripts then
            local opts = GAMESTATE:GetSongOptionsObject('ModsLevel_Current')
            shouldShowBGScripts = not opts:StaticBackground()
        end
    end
    local bg = SCREENMAN:GetTopScreen():GetChild("SongBackground")
    if bg then
        bg:visible(not shouldShowBGScripts);
    end
    self:visible(shouldShowBGScripts);
end

t.OnCommand = setVisibility
t.CurrentSongChangedMessageCommand = setVisibility

local charName = ResolveCharacterName(GAMESTATE:GetMasterPlayerNumber())

local loadWorked = false
local potentialVideo = Characters.GetDancerVideo(charName)

if potentialVideo then
    loadWorked = true
	t[#t+1] = Def.ActorFrame{
        Def.Sprite{
            Texture=potentialVideo,
		    InitCommand=function(s) s:draworder(1):Center():zoomto(SCREEN_WIDTH+38,SCREEN_HEIGHT+38) end,
        };
	};

end
	
return {bg=t, worked=loadWorked};
