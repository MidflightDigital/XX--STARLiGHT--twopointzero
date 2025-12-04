local screenName = Var('LoadingScreen')
local wheelType = ThemePrefs.Get('WheelType')

local ButtonSongLeft = THEME:GetMetric(screenName, 'PreviousSongButton') -- Usually MenuLeft
local ButtonSongRight = THEME:GetMetric(screenName, 'NextSongButton') -- Usually MenuRight
local ButtonSongUp = 'MenuUp'
local ButtonSongDown = 'MenuDown'

-- These will be defined later during InitCommands below
local MusicWheel
local VerticalScrollHandler

-- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/WheelBase.h#L15
local numWheelItems = math.ceil(THEME:GetMetric('MusicWheel' .. wheelType, 'NumWheelItems')+2)
local centerIndex = math.floor(numWheelItems / 2)
local function GetRelativeMusicWheelItemType(relativeIndex)
  local MusicWheelItem = MusicWheel:GetWheelItem(centerIndex + relativeIndex)
  return ToEnumShortString(WheelItemDataType[MusicWheelItem:GetType()+1])
end

-- Similar usage as WheelBase::ChangeMusic(int iDist), but works on the vertical axis of MusicWheelA's grid layout
local NUM_SONGS_PER_ROW = wheelType == 'A' and 3 or 1
local function MusicWheel_ChangeMusicY(deltaY)
  deltaY = deltaY >= 0 and math.floor(deltaY + 0.5) or math.ceil(deltaY - 0.5) -- Round deltaY to nearest integer
  if deltaY == 0 then
    MusicWheel:Move(0)
    return 0, 0
  end

  local numRows = math.abs(deltaY) 
  local sign = deltaY / numRows
  local moves = 0
  for row = 1, numRows, 1 do
    if GetRelativeMusicWheelItemType(moves) ~= 'Song' then
      moves = moves + sign
    else  
      moves = moves + sign
      for i = moves, moves + (NUM_SONGS_PER_ROW - 2) * sign, sign do
        if GetRelativeMusicWheelItemType(i) ~= 'Song' then
          break
        end
        moves = i + sign
      end
    end
  end
  
  MusicWheel:Move(moves)
  MusicWheel:Move(0)
  return deltaY, moves
end

-- Similar usage as WheelBase::Move(int n), but works to scroll on the vertical axis of MusicWheelA's grid layout
local function MusicWheel_MoveY(deltaY)
  if not MusicWheel then
    error('MusicWheel_MoveY(): Cannot be called before the MusicWheel has been retrieved!')
  end
  if VerticalScrollHandler then
    VerticalScrollHandler:MoveY(deltaY)
  else
    MusicWheel:Move(deltaY) -- fallback just for good measure
  end
end

local PRESS_FIRST   = 'FirstPress'
local PRESS_REPEAT  = 'Repeat'
local PRESS_RELEASE = 'Release'

local pressedButtonsPerPlayer = {}
local function UpdatePressedButtons(event)
  local player = event.PlayerNumber
  if not player then return end
  local button = event.GameButton
  if not button or button == '' then return end
  local pressedButtons = pressedButtonsPerPlayer[player]
  if not pressedButtons then
    pressedButtons = {}
    pressedButtonsPerPlayer[player] = pressedButtons
  end
  local pressType = ToEnumShortString(event.type)
  if pressType == PRESS_FIRST or pressType == PRESS_REPEAT then
    pressedButtons[button] = true
  elseif pressType == PRESS_RELEASE then
    pressedButtons[button] = false
  end
end
local function IsButtonPressed(player, button)
  local pressedButtons = pressedButtonsPerPlayer[player]
  if not pressedButtons then return false end
  return not not pressedButtons[button]
end
local function ResetPressedButtonsState()
  for player in pairs(pressedButtonsPerPlayer) do
    pressedButtonsPerPlayer[player] = nil
  end
end

local function HandleInput_MusicWheelA(event)
  if not PREFSMAN:GetPreference('OnlyDedicatedMenuButtons') then return end
  local player = event.PlayerNumber
  if not player or not GAMESTATE:IsPlayerEnabled(player) then return end
  local button = event.GameButton
  local pressType = ToEnumShortString(event.type)
  
  local useVerticalScrollHandler = (button == ButtonSongUp or button == ButtonSongDown)
  if not (useVerticalScrollHandler or button == ButtonSongLeft or button == ButtonSongRight) then return end

  local isUpPressed = false
  local isDownPressed = false
  local isLeftPressed = false
  local isRightPressed = false
  for _, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
    isUpPressed = isUpPressed or IsButtonPressed(pn, ButtonSongUp)
    isDownPressed = isDownPressed or IsButtonPressed(pn, ButtonSongDown)
    isLeftPressed = isLeftPressed or IsButtonPressed(pn, ButtonSongLeft)
    isRightPressed = isRightPressed or IsButtonPressed(pn, ButtonSongRight)
  end
  
  if (isUpPressed or isDownPressed) and (isLeftPressed or isRightPressed) and pressType == PRESS_FIRST then
    -- Resolve conflicting scroll handlers; Only use the last one pressed and stop the other
    if useVerticalScrollHandler then
      MusicWheel:Move(0)
    else
      MusicWheel_MoveY(0)
    end
  end
  if not useVerticalScrollHandler then return end
  
  -- Mimics Stepmania's behavior for controlling the MusicWheel scrolling. See:
  -- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/ScreenSelectMusic.cpp#L645
  if (isUpPressed and not isDownPressed) then
    if pressType == PRESS_FIRST then
      MusicWheel_MoveY(-1)
    end
  elseif (isDownPressed and not isUpPressed) then
    if pressType == PRESS_FIRST then
      MusicWheel_MoveY( 1)
    end
  else
    MusicWheel_MoveY(0) -- Stop if both up and down is pressed or if neither are pressed
    
    if isUpPressed and isDownPressed and pressType == PRESS_FIRST then
      if button == ButtonSongUp then
        MusicWheel_ChangeMusicY(-1)
      elseif button == ButtonSongDown then
        MusicWheel_ChangeMusicY( 1)
      end
    end
  end
end

local function InputHandler(event)
  UpdatePressedButtons(event)
  local pressType = ToEnumShortString(event.type)
  
  if pressType ~= PRESS_RELEASE then
    local deviceButton = ToEnumShortString(event.DeviceInput.button):lower()
    if deviceButton == 'left mouse button' -- Stepmania 5.1
    or deviceButton == 'left (01)'         -- Outfox 
    then
      MESSAGEMAN:Broadcast('MouseLeftClick')
    end
  end
  if getenv('OPList') == 1 then return end
  
  if wheelType == 'A' then
    HandleInput_MusicWheelA(event)
  end
end

setenv("DList",0)

local t = Def.ActorFrame{
  BeginCommand=function()
    MusicWheel = SCREENMAN:GetTopScreen():GetChild('MusicWheel')
  end,
  OnCommand=function(self)
    SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
    SCREENMAN:GetTopScreen():AddInputCallback(DDRInput(self))
  end;
  OffCommand=function(self) 
    SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
    SCREENMAN:GetTopScreen():RemoveInputCallback(DDRInput(self))
    ResetPressedButtonsState()
  end,
  ResetInputStateMessageCommand=function()
    -- We need to reset the state like this because there's no way to detect SM_LoseFocus or SM_GainFocus in Lua...
    ResetPressedButtonsState()
  end,
  SongChosenMessageCommand=function(self) setenv("DList",1) self:playcommand("Off") end;
  SongUnchosenMessageCommand=function(self)
    setenv("DList",0)
    self:sleep(0.5):queuecommand("On");
  end;
  MouseLeftClickMessageCommand = function(self)
    if ThemePrefs.Get("Touch") == true then
      self:queuecommand("PlayTopPressedActor")
    end
  end;
  --[[StartReleaseCommand=function(s)
    local song = GAMESTATE:GetCurrentSong()
    local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
    if song and getenv("OPList") == 0 then
      if not ShowTwoPart() and getenv("SortList") == 0 then
        SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_MenuTimer")
      else
      end
    end
  end,]]
  StartRepeatCommand=function(s)
    local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
    local song = GAMESTATE:GetCurrentSong()
    if song then
      if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
        if ShowTwoPart() and getenv("OPStop") == 0 then
          SCREENMAN:GetTopScreen():OpenOptionsList(PLAYER_1)
        else
          SCREENMAN:GetTopScreen():OpenOptionsList(PLAYER_1)
        end
      end
      if GAMESTATE:IsPlayerEnabled(PLAYER_2) then 
        if ShowTwoPart() and getenv("OPStop") == 0 then
          SCREENMAN:GetTopScreen():OpenOptionsList(PLAYER_2)
        else
          SCREENMAN:GetTopScreen():OpenOptionsList(PLAYER_2)
        end
      end
    end
  end,
  PlayTopPressedActorCommand = function(self)
    playTopPressedActor()
    resetPressedActors()
  end;
  loadfile(THEME:GetPathB("","_cursor"))();
}

if wheelType == 'A' then  
  -- Stepmania's MusicWheel:Move(n) only continously scrolls when n==1 or n==-1. See:
  -- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/WheelBase.cpp#L220
  -- If we try to do MusicWheel:Move(3) to scroll in the vertical grid axis of MusicWheelA then the music wheel will  
  -- only move 3 songs forward once and then stop, without any continous scrolling afterwards. To achieve the same 
  -- continous scrolling behavior in the vertical grid axis then we to make our own scroll handler and mimic Stepmania's
  -- continous scrolling behavior for vertical scrolling only. 
  
  -- Mimics WheelBase::Update(float fDeltaTime), but uses MusicWheel_ChangeMusicY() to move vertically instead. See:
  -- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/WheelBase.cpp#L149
  local function VerticalScrollHandler_Update(self, deltaTime)
    local moving = self.moving
    if moving ~= 0 then
      self.timeBeforeMovingBegins = math.max(self.timeBeforeMovingBegins - deltaTime, 0)
    end
    
    if moving ~= 0 and self.timeBeforeMovingBegins == 0 then
      local spinSpeed = moving * self.spinSpeed * deltaTime
      if self.currentItemType == 'Song' then
        -- Lets scroll a bit slower when scrolling over songs. To get the same vertical speed as if we were scrolling
        -- using native the left and right movements then we need to divide by 3 instead (value of NUM_SONGS_PER_ROW).
        spinSpeed = spinSpeed / 1.5
      end
      local offset = math.min(math.max(self.positionOffsetFromSelection - spinSpeed, -1), 1)
      
      if (moving > 0 and offset <= 0)
      or (moving < 0 and offset >= 0) then
        local iDeltaY = MusicWheel_ChangeMusicY(moving)
        offset = offset + iDeltaY
        self.currentItemType = GetRelativeMusicWheelItemType(0)
      end
      self.positionOffsetFromSelection = offset
    else
      self.positionOffsetFromSelection = 0
    end
  end
  
  -- Mimics WheelBase::Move(int n), but uses MusicWheel_ChangeMusicY() to move vertically instead. See
  -- https://github.com/stepmania/stepmania/blob/d55acb1ba26f1c5b5e3048d6d6c0bd116625216f/src/WheelBase.cpp#L358
  local function VerticalScrollHandler_MoveY(self, n)
    if n == self.moving then return end
    
    self.timeBeforeMovingBegins = 1/4
    self.moving = n
    if n ~= 0 then
      MusicWheel_ChangeMusicY(n)
    end
    self.currentItemType = GetRelativeMusicWheelItemType(0)
  end
  
  t[#t+1] = Def.ActorFrame{
    Name='VerticalScrollHandler',
    InitCommand=function(self)
      VerticalScrollHandler = self -- This exposes our functionality
      
      self.spinSpeed = PREFSMAN:GetPreference('MusicWheelSwitchSpeed')
      self.timeBeforeMovingBegins = 0
      self.moving = 0
      self.positionOffsetFromSelection = 0
      self.currentItemType = nil
      self:SetUpdateFunction(VerticalScrollHandler_Update)
      
      self.MoveY = VerticalScrollHandler_MoveY
    end,
  }
end

return t

--[[
local function WheelMove(mov)
  local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel");
	mw:Move(mov)
end

local t = Def.ActorFrame{
  OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(DDRInput(self))
  OffCommand=function(self)
    SCREENMAN:GetTopScreen():RemoveInputCallback(DDRInput(self))
  end;
  SongChosenMessageCommand=function(self) self:queuecommand("Off") end;
  SongUnchosenMessageCommand=function(self)
    self:sleep(0.5):queuecommand("On");
  end;
  StartReleaseCommand=function(self)
	  local mw = SCREENMAN:GetTopScreen("ScreenSelectMusic"):GetChild("MusicWheel");
    local song = GAMESTATE:GetCurrentSong() 
    if ThemePrefs.Get("WheelType") == "Jukebox" or ThemePrefs.Get("WheelType") == "Wheel" then
		  if song then
        SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_MenuTimer")
      end
    else
		end;
  end;
  StartRepeatCommand=function(self)
    local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
    local song = GAMESTATE:GetCurrentSong()
    if song then
      if ThemePrefs.Get("WheelType") == "Jukebox" or ThemePrefs.Get("WheelType") == "Wheel" then
        SCREENMAN:AddNewScreenToTop("ScreenPlayerOptionsPopup","SM_MenuTimer")
      else
        SCREENMAN:AddNewScreenToTop("ScreenPlayerOptionsPopup")
      end
    else
    end;
  end;
  SongUnchosenMessageCommand=function(self)
    self:sleep(0.5):queuecommand("On");
  end;
};]]
