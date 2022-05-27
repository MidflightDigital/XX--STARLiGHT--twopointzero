local num_players = GAMESTATE:GetHumanPlayers()

local t = Def.ActorFrame{}

t[#t+1] = Def.ActorFrame{
    OnCommand=function(s) s:accelerate(0.3):diffusealpha(1) end,
	OffCommand=function(s) s:accelerate(0.3):diffusealpha(0) end,
	Def.ActorFrame{
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-18) end,
		Def.Quad{
			InitCommand=function(s) s:setsize(SCREEN_WIDTH-WideScale(12,40),780):diffuse(Alpha(Color.White,0.5)) end,
		},
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenOptionsService","decorations/DialogTop"),
            InitCommand=function(s) s:y(-414) end,
        }
    },
}

t[#t+1] = Def.Sprite{
    Texture="base",
    InitCommand=function(s) s:FullScreen():visible(false) end,
};

t[#t+1] = Def.Actor{
    OptionRowChangedMessageCommand=function(self,params)
        local CurrentRowIndex = {"P1","P2"}

        params.Title:stopeffect()

        -- get the index of PLAYER_1's current row
	    if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	    	CurrentRowIndex.P1 = SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_1)
	    end

	    -- get the index of PLAYER_2's current row
	    if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	    	CurrentRowIndex.P2 = SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_2)
	    end

	    local optionRow = params.Title:GetParent():GetParent()

        -- color the active optionrow's title appropriately
	    if optionRow:HasFocus(PLAYER_1) then
	    	params.Title:diffuse(PlayerColor(PLAYER_1))
	    end

	    if optionRow:HasFocus(PLAYER_2) then
	    	params.Title:diffuse(PlayerColor(PLAYER_2))
	    end

        if CurrentRowIndex.P1 and CurrentRowIndex.P2 then
	    	if CurrentRowIndex.P1 == CurrentRowIndex.P2 then
	    		params.Title:diffuseshift()
	    		params.Title:effectcolor1(PlayerColor(PLAYER_1))
	    		params.Title:effectcolor2(PlayerColor(PLAYER_2))
	    	end
	    end

    end
}

local icol = 2
if GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() < 2 then
    icol = 1
end
local column = GAMESTATE:GetCurrentStyle():GetColumnInfo( GAMESTATE:GetMasterPlayerNumber(), icol )
for _,v in pairs(NOTESKIN:GetNoteSkinNames()) do
    local noteskinset = NOTESKIN:LoadActorForNoteSkin( column["Name"] , "Tap Note", v )

    if noteskinset then
        t[#t+1] = noteskinset..{
            Name="NS"..string.lower(v), InitCommand=function(s) s:visible(false) end,
			OnCommand=function(s) s:diffusealpha(0):sleep(0.2):linear(0.2):diffusealpha(1) end,
			OffCommand=function(s) s:linear(0.2):diffusealpha(0) end
        }
    else
        lua.ReportScriptError(string.format("The noteskin %s failed to load.", v))
        t[#t+1] = Def.Actor{ Name="NS"..string.lower(v) }
    end
end

for i=1,#num_players do
end

t[#t+1] = LoadFallbackB()


return t