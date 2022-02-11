--[[
01 MyGrooveRadar.lua
]]
--Load the setting we need for this.
local mgrData = create_setting('MyGrooveRadar','MyGrooveRadar.lua',{
    single={chaos=0,air=0,freeze=0,voltage=0,stream=0},
    double={chaos=0,air=0,freeze=0,voltage=0,stream=0}
}, 2, {})

local categoryToActorMappings = {'stream','voltage','air','freeze','chaos'}
local savedCategoryToSMCategory = {
    stream='RadarCategory_Stream',
    voltage='RadarCategory_Voltage',
    air='RadarCategory_Air',
    freeze='RadarCategory_Freeze',
    chaos='RadarCategory_Chaos'
}

local function GetRadarTable(ident)
    if not mgrData:is_loaded(ident) then
        mgrData:load(ident)
    end
    return mgrData:get_data(ident)
end

local function GetRadarData(ident, style, category)
    local rData = GetRadarTable(ident)
    if rData[style] then
        if rData[style][category] <= 10 then
            return rData[style][category] or 0
        else
            return 10 or 0
        end
    end
    return 0
end

local function SetRadarData(ident, style, category, value)
    local rData = GetRadarTable(ident)
    if rData[style] then
        rData[style][category] = value
        mgrData:set_dirty(ident)
    end
end

return {
    PackageArbitraryRadarData=function(tbl, style)
        if tbl then
            local out = {}
            local myVals = tbl[style]
            if myVals then
                for idx, category in ipairs(categoryToActorMappings) do
                    out[idx] = myVals[category] or 0
                end
                return out
            end
        end
        --if we did not do this it would crash!
        return {0,0,0,0,0}
    end,
    GetRadarTable=function(ident)
        return GetRadarTable(ident)
    end,
    GetRadarData=function(ident, style, category)
        return GetRadarData(ident, style, category)
    end,
    SetRadarData=function(ident, style, category, value)
        return SetRadarData(ident, style, category, value)
    end,
    SaveAllRadarData=function()
        return mgrData:save_all()
    end,
    GetRadarDataPackaged=function(ident, style)
        local out = {}
        for idx, category in pairs(categoryToActorMappings) do
            out[idx] = GetRadarData(ident, style, category)
        end
        return out
    end,
    ApplyBonuses=function(ident, stageStats, styleName)
        local actualRadar = stageStats:GetRadarActual()
        local possibleRadar = stageStats:GetRadarPossible()
        for savedCat, stepsCat in pairs(savedCategoryToSMCategory) do
            local earnedValue = actualRadar:GetValue(stepsCat)*possibleRadar:GetValue(stepsCat)
            local savedValue = GetRadarData(ident, styleName, savedCat)
            if savedValue < earnedValue then
                SetRadarData(ident, styleName, savedCat, savedValue + (earnedValue-savedValue)/10)
            end
        end
    end
}