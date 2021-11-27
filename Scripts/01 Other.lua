-- �R���{�ݒ�
function JudgmentTransformCommand( self, params )
	local x = 0
	local y = -76
	-- リバース時のY軸設定、センターが基本
	if params.bReverse then y = 67 end
	-- This makes no sense and wasn't even being used due to misspelling.
	-- if bCentered then y = y * 2 end
	self:x( x )
	self:y( y )
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function MemCardInsert()
    if GAMESTATE:GetCoins() >= GAMESTATE:GetCoinsNeededToJoin() then
        if MEMCARDMAN:GetCardState(PLAYER_1) == 'MemoryCardState_checking' then
            GAMESTATE:JoinInput(PLAYER_1)
            SCREENMAN:GetTopScreen():SetNextScreenName(Branch.StartGame()):StartTransitioningScreen("SM_GoToNextScreen")
        elseif MEMCARDMAN:GetCardState(PLAYER_2) == 'MemoryCardState_checking' then
            GAMESTATE:JoinInput(PLAYER_2)
            SCREENMAN:GetTopScreen():SetNextScreenName(Branch.StartGame()):StartTransitioningScreen("SM_GoToNextScreen")
        end
    end
end

function SetupCredits()
    if GAMESTATE:GetCurrentGame():GetName() == "dance" then
        --[[local song = SONGMAN:FindSong("STARLiGHT DRIVE")
        if song then
            GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
            GAMESTATE:SetCurrentSong(song)
            GAMESTATE:SetCurrentStyle('versus')
            GAMESTATE:SetCurrentSteps(PLAYER_1,song:GetAllSteps()[1])
            GAMESTATE:SetCurrentSteps(PLAYER_2,song:GetAllSteps()[1])
            GAMESTATE:ApplyStageModifiers(PLAYER_1,"FailOff")
            GAMESTATE:ApplyStageModifiers(PLAYER_2,"FailOff")
            return "ScreenGameplayCredits"
        else
            return "ScreenCreditsXX"
        end]]
    end
    return "ScreenCreditsXX"
end

function SetupHowToPlay(self)
    local st = GAMESTATE:GetCurrentStyle():GetStepsType()
    if PROFILEMAN:IsPersistentProfile(PLAYER_1) or PROFILEMAN:IsPersistentProfile(PLAYER_2) then
        setenv("HTP",false)
        return "ScreenSelectMusic"
    else
        if ThemePrefs.Get("ShowHTP") == true and st ~= 'StepsType_Dance_Double' then
            local song = SONGMAN:FindSong("Lesson by DJ")
            if song then
                setenv("HTP",true)
                GAMESTATE:SetCurrentSong(song);
                local steps = song:GetOneSteps(st, 0);
                GAMESTATE:SetCurrentPlayMode('PlayMode_Regular')
                GAMESTATE:SetCurrentSteps('PlayerNumber_P1',steps);
                GAMESTATE:SetCurrentSteps('PlayerNumber_P2',steps);
                local can, reason = GAMESTATE:CanSafelyEnterGameplay()
                if can then
                    GAMESTATE:SetTemporaryEventMode(true)
                    setenv("FixStage",1)
                    return "ScreenGameplayHowTo";
                else
                    return "ScreenSelectMusic";
                end
            else
                return "ScreenSelectMusic"
            end;
        else
            return "ScreenSelectMusic"
        end
    end
end;

function CustStageCheck()
    if not GAMESTATE:IsAnExtraStage() then
        if GAMESTATE:GetCurrentStage() == "Stage_Final" then
            return "Final"
        else
            return CustStage
        end
    elseif GAMESTATE:IsExtraStage() then
        return "Extra1"
    elseif GAMESTATE:IsExtraStage2() then
        return "Extra2"
    else
        return CustStage
    end
end

function ComboTransformCommand( self, params )
	local x = 0
	local y = 38
	if params.bReverse then y = -23 end

	--[[
	if params.bCentered then
		if params.bReverse then
			y = y - 30
		else
			y = y + 40
		end
	end
	--]]
	self:x( x )
	self:y( y )
end

--This comes in handy in a number of places
function GetOrCreateChild(tab, field, kind)
    kind = kind or 'table'
    local out
    if not tab[field] then
        if kind == 'table' then
            out = {}
        elseif kind == 'number' then
            out = 0
        elseif kind == 'boolean_df' or kind == 'boolean' then
            out = false
        elseif kind == 'boolean_dt' then
            out = true
        else
            error("GetOrCreateChild: I don't know a default value for type "..kind)
        end
        tab[field] = out
    else out = tab[field] end
    return out
end

function TextBannerAfterSet(self,param)
	local Title=self:GetChild("Title")
	local Subtitle=self:GetChild("Subtitle")
	local Artist=self:GetChild("Artist")

	if Subtitle:GetText() ~= "" then
		--strip off whitespace at the beginning of the subtitle text
		--and the end of the title text
		local SubtitleText = Subtitle:GetText()
		local TitleText = Title:GetText()
		Title:settext(JoinStringsWithSpace(TitleText, SubtitleText))
	end

	Title:maxwidth(460)
	Title:y(-14)

	Subtitle:visible(false)

	Artist:maxwidth(460)
	Artist:y(10)

end

function TextBannerGameplayAfterSet(self, param)
	TextBannerAfterSet(self)
	self:GetChild("Title"):maxwidth(350)
	self:GetChild("Artist"):maxwidth(350)
end

-- JoinStringsWithSpace(a, b)
-- Joins a pair of strings by a space, removing other whitespace around it.
function JoinStringsWithSpace(a, b)
	return a:gsub("%s*$","").." "..b:gsub("^%s*","")
end

--[[
StarlightCache
This is a weak table. What that means is that this table isn't counted when
the garbage collector decides whether a given object is still in use or not.
So you can put things in this table without worrying that they won't be freed
when Lua needs more memory, as long as they aren't being used anywhere else.
Note that under certain circumstances (ScreenSelectMusic especially) Lua does
garbage collections pretty frequently, so you shouldn't rely on objects
staying in here very long. The Env table is also a pretty good place to
put objects that you want to live for an entire game, as StepMania will delete
the Env table itself when the GameState is reset. (tertu has verified this.)
WARNING: Don't put a table that contains itself in here under Lua 5.1. Lua 5.2
and later allow it, but this theme has to run on 5.1 still.
--]]
StarlightCache = setmetatable({}, {__mode="v"})

local videoRenderers = split(",",PREFSMAN:GetPreference("VideoRenderers"))
if videoRenderers[1] == "d3d" then
	Warn("Direct3D mode detected. XX -STARLiGHT- does not support Direct3D mode. Use at your own risk.")
end

function GetProfileIDForPlayer(pn)
    if GAMESTATE:IsHumanPlayer(pn) then
        local profile = PROFILEMAN:GetProfile(pn)
        if not PROFILEMAN:IsPersistentProfile(pn) then
            return "!MACHINE"
        end
        if PROFILEMAN:ProfileWasLoadedFromMemoryCard(pn) then
            return (pn=='PlayerNumber_P1') and "!MC0" or "!MC1"
        end
        if GAMESTATE:Env() then
            local pidCache = GetOrCreateChild(GAMESTATE:Env(),"PlayerLocalIDs")
            if pidCache[pn] then
                return pidCache[pn]
            end
            --worst case scenario: we have to search all the local profiles to find it.
            for _, id in pairs(PROFILEMAN:GetLocalProfileIDs()) do
                if PROFILEMAN:GetLocalProfile(id) == profile then
                    pidCache[pn] = id
                    return id
                end
            end
            --apparently this just means we're using the machine profile if this all fails.
            pidCache[pn] = "!MACHINE"
            return "!MACHINE"
        end
    end
    return "!MACHINE"
end

--this gets the course song number or stage index, +1 as appropriate
function GameState:GetAppropriateStageNum()
	if self:IsCourseMode() then
		return self:GetCourseSongIndex() + 1
	else
		return self:GetCurrentStageIndex() + 1
	end
end

--Loads the file at path and runs it in the specified environment,
--or an empty one if no environment is provided. Catches any errors that occur.
--Returns false if the called function failed, true and anything else the function returned if it worked
function dofile_safer(path, env)
    env = env or {}
    if not FILEMAN:DoesFileExist(path) then
        --the file doesn't exist
        return false
    end
    local handle = RageFileUtil.CreateRageFile()
    handle:Open(path, 1)
    local code = loadstring(handle:Read(), path)
    handle:Close()
    handle:destroy()
    if not code then
        --an error occurred while compiling the file
        return false
    end
    setfenv(code, env)
    return pcall(code)
end

--stuff for doing update functions that i love so -tertu
function CalculateWaitFrames(targetDelta, delta)
    return math.max(1, math.floor((targetDelta/delta)+0.5))-1
end

--returns a function that returns true if the function should run this update
function GetUpdateTimer(targetDelta)
    local frameCounter = 0
    return function()
        if frameCounter == 0 then
            frameCounter = CalculateWaitFrames(targetDelta, DISPLAY:GetFPS())
            return true
        end
        frameCounter = frameCounter - 1
        return false
    end
end

--sesub(str, enum): returns str with every "%" replaced with the short form of enum
function sesub(str, enum)
    return str:gsub("%%", ToEnumShortString(enum))
end

--like pairs, but returns only values
function values(t)
	local key = nil
	return function()  
		local value;
		key, value = next(t, key);
		return value;
	end;
end;

function EnabledPlayers()
	return values(GAMESTATE:GetEnabledPlayers())
end

function HumanPlayers()
	return values(GAMESTATE:GetHumanPlayers())
end

--not really related but this seems like an OK place
function PlayerStageStats:FullComboType()
	if self:FullComboOfScore('TapNoteScore_W1') then
		return 'TapNoteScore_W1'
	elseif self:FullComboOfScore('TapNoteScore_W2') then
		return 'TapNoteScore_W2'
	elseif self:FullComboOfScore('TapNoteScore_W3') then
		return 'TapNoteScore_W3'
	elseif self:FullComboOfScore('TapNoteScore_W5') then
		return 'TapNoteScore_W4'
	else
		return nil
	end
end

function Course:IsA20DanCourse()
	return self:GetCourseType() == 'CourseType_Nonstop' and
		string.find(self:GetDescription(), "A20DanCourse")~=nil
end

--returns the ReadBPM for a given song. This is the value that mmods treat
--as the maximum song BPM.
function CalculateReadBPM(song)
    local read_bpm = 0
    local mMod_high_cap = THEME:GetMetric("Player", "MModHighCap")
    --an mmod high cap of 0 or less means there is none.
    if mMod_high_cap <= 0 then
        mMod_high_cap = math.huge
    end

    local disp_bpms = song:GetDisplayBpms()
    if disp_bpms[1] == -1 then --secret display BPM. we have to find out what the real BPM should be
        read_bpm = song:GetSongTiming():GetActualBPM()[2]
    else
        read_bpm = disp_bpms[2]
    end

    return math.min(read_bpm, mMod_high_cap)
end