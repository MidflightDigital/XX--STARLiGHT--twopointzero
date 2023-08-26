local function LoadMetric(name, isBoolean)
    local metricValue = THEME:GetMetric("SNDifficultyList", name)
    assert(metricValue, "SNDifficultyList: can't load metric "..name)
    --only numbers and booleans are supported right now
    if isBoolean then
        return (metricValue == "true") or (metricValue=="1")
    else
        local n = tonumber(metricValue)
        assert(n, "SNDifficultyList: metric "..name.." must be a number but is not")
        return n
    end
end

local function PlayerLabelName(pn)
	local name = string.upper(ToEnumShortString(pn))
	return '../../../Graphics/_shared/Diff/'..name
end

local difficultiesToDraw = {
    'Difficulty_Beginner',
    'Difficulty_Easy',
    'Difficulty_Medium',
    'Difficulty_Hard',
    'Difficulty_Challenge',
    'Difficulty_Edit'
}

local invDifficultiesToDraw = {}
for k, v in pairs(difficultiesToDraw) do
    invDifficultiesToDraw[v] = k
end

local startPos = -96
local itemSpacingY = 40
local labelPos = -284
local tickPos = -80
local glowFeet = true
local indX = -4
local plabelX = 374

local lastSong = nil
local lastSteps = {PlayerNumber_P1=nil, PlayerNumber_P2=nil}

local function DiffToYPos(diff)
    if invDifficultiesToDraw[diff] == nil then return nil end
    return startPos + ( itemSpacingY*( invDifficultiesToDraw[diff]-1 ) )
end

local function SetXFromPlayerNumber(that, pn)
    local XFudge = 16
    if pn == 'PlayerNumber_P1' then
        that:x(indX-plabelX)
    elseif pn == 'PlayerNumber_P2' then
        that:x(indX+plabelX+4)
    end
end

local ret = Def.ActorFrame{
    OffCommand=function(self) self:sleep(0.5):visible(false) end}

local hardXColor = DDRDiffList.HardXColor
local lightXColor = DDRDiffList.LightXColor
local darkXColor = DDRDiffList.DarkXColor

local function IndicatorUpdate(self, pn)
    if not GAMESTATE:IsPlayerEnabled(pn) then return end
    self:finishtweening()
    local currentlyVisible = self:GetVisible()
    local steps = GAMESTATE:GetCurrentSteps(pn)
    if steps and GAMESTATE:GetCurrentSong() then
        if currentlyVisible then
            self:linear(0.1)
        end
        local yPos = DiffToYPos(steps:GetDifficulty())
        if yPos then
            self:visible(true)
            self:y(yPos)
            return
        end
    end
    self:visible(false)
end

local function AddContentsToOutput(tbl)
    for _, e in pairs(tbl) do
        table.insert(ret, e)
    end
end

do
    local indicatorBackgrounds = {}
    local indicatorLabels = {}
    for _, pn in pairs(PlayerNumber) do
        --the initcommand here just prepares the things that are the same in both modes
        local indicatorBackground = Def.Sprite{
            Texture="cursorglow",
            Name='Background'..ToEnumShortString(pn),
            InitCommand=function(self) self:visible(false) end
        }
        DDRDiffList.MessageHandlers(indicatorBackground, function(self, songChange)
          if songChange then
              self:finishtweening():x(indX)
          end
            return IndicatorUpdate(self, pn)
        end)
        local indicatorLabel = Def.Sprite{
            Texture=PlayerLabelName(pn),
            Name='PlayerLabel',
            InitCommand=function(self) self:visible(false) end,
            PlayerJoinedMessageCommand=function(self,p)
                if p.Player==pn then self:Load(ResolveRelativePath(PlayerLabelName(pn),1)) end
            end
        }
        DDRDiffList.MessageHandlers(indicatorLabel, function(self, _, XMode) SetXFromPlayerNumber(self, pn, XMode)
            return IndicatorUpdate(self, pn) end)
        table.insert(indicatorLabels, indicatorLabel)
        table.insert(indicatorBackgrounds, indicatorBackground)
    end
    AddContentsToOutput(indicatorBackgrounds)
    AddContentsToOutput(indicatorLabels)
end

--here's where it gets hairy
for idx, diff in pairs(difficultiesToDraw) do

    --[[DIFFICULTY LABEL]]
    local label = Def.Sprite{
        Name = "Label",
        Texture = "SNDifficultyList labels 1x6.png",
        InitCommand = function(self) self:setstate(idx-1):SetAllStateDelays(math.huge):diffuse{0.5,0.5,0.5,1} end
    }
    DDRDiffList.MessageHandlers(label, function(self, songChange, XMode)
        if songChange then
          self:x(labelPos):zoom(1)
        end

        local song = GAMESTATE:GetCurrentSong()
        if song then
          self:diffuse{1,1,1,1}
        else
          self:diffuse{0.5,0.5,0.5,1}
        end
    end)
    --[[END DIFFICULTY LABEL]]

    --this has been moved into another file because it has to be reused.
    local meterDisplay = loadfile(THEME:GetPathG("_ScreenSelectMusic","MeterDisplay"))({Difficulty=diff,PositionX=tickPos})
    local element = Def.ActorFrame{
        Name = "Row"..diff,
        InitCommand = function(self) self:y( DiffToYPos(diff) ) end,
        label, meterDisplay
    }
    table.insert(ret, element)
end

return ret
