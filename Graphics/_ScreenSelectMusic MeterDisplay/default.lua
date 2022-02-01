local args = ({...})[1]
local tickPos = args.PositionX
local diff = args.Difficulty

local trackPN = args.TrackPN
local FindSteps = function(song) return song:GetOneSteps(GAMESTATE:GetCurrentStyle():GetStepsType(), diff) end
if trackPN then
    FindSteps = function()
        local steps = GAMESTATE:GetCurrentStepsPossiblyCPU(trackPN)
        if steps and steps:GetDifficulty() == diff then
            return steps
        end
        return nil
    end
end

local diffColor
local hardXColor = DDRDiffList.HardXColor
local lightXColor = DDRDiffList.LightXColor
local darkXColor = DDRDiffList.DarkXColor

--[[TICKS UNDERLAY]]
local ticksUnder = Def.Sprite{
    Name="TicksUnder",
    Texture="ticks",
    InitCommand = function(self) self:halign(0):diffuse(DiffHelpers.DiffToColor(diff,true)) end,
}
DDRDiffList.MessageHandlers(ticksUnder, function(self, _, XMode)
    self:x(tickPos-64)

    local diffColor = DiffHelpers.DiffToColor(diff, true)
    local song = GAMESTATE:GetCurrentSong()
    if song then
        local steps = FindSteps(song)
        if steps then
            local meter = steps:GetMeter()
            self:diffuse(diffColor):cropleft(math.min(1,meter/20))
        else
            self:diffuse(diffColor):cropleft(0)
        end
    else
        self:diffuse(diffColor):cropleft(0)
    end
end)
--[[END TICKS UNDERLAY]]

--[[TICKS OVERLAY]]
local ticksOver = Def.Sprite{
    Name = "TicksOver",
    Texture = "ticks",
    InitCommand = function(self) self:diffuse(DiffHelpers.DiffToColor(diff)):halign(0):cropright(1) end,
}
DDRDiffList.MessageHandlers(ticksOver, function(self, songChanged)
    self:x(tickPos-64)
    local diffColor = DiffHelpers.DiffToColor(diff)
    local song = GAMESTATE:GetCurrentSong()
    if song then
        if songChanged then self:stopeffect() end
        local steps = FindSteps(song)
        if steps then
            local meter = steps:GetMeter()
            self:diffuse(diffColor):stopeffect():cropright(1-meter/20)
        else
            self:stopeffect():cropright(1)
        end
    else
        self:stopeffect():cropright(1)
    end
end)
--[[END TICKS OVERLAY]]

--[[METER NUMBER]]
local meter = Def.BitmapText{
    Font="_avenirnext lt pro bold/25px";
    InitCommand=function(self) self:x(tickPos-100):zoom(1.1):diffuse{0.5,0.5,0.5,1} end
}
DDRDiffList.MessageHandlers(meter, function(self, _, XMode)
    self:visible(true)
    local song = GAMESTATE:GetCurrentSong()
    if song then
        local steps = FindSteps(song)
        if steps then
            local meter = steps:GetMeter()
            self:settext(tostring(meter))
            self:diffuse{1,1,1,1}:strokecolor(Color.Black)
        else
            self:settext ""
        end
    else
        self:settext ""
    end
end)

return Def.ActorFrame{ticksUnder,ticksOver,meter}
