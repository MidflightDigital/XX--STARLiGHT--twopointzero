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

MyGrooveRadar = {}

function MyGrooveRadar.PackageArbitraryRadarData(tbl, style)
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
end

function MyGrooveRadar.GetRadarTable(ident)
    if not mgrData:is_loaded(ident) then
        mgrData:load(ident)
    end
    return mgrData:get_data(ident)
end

function MyGrooveRadar.GetRadarData(ident, style, category)
    local rData = MyGrooveRadar.GetRadarTable(ident)
    if rData[style] then
        if rData[style][category] <= 10 then
            return rData[style][category] or 0
        else
            return 10 or 0
        end
    end
    return 0
end

function MyGrooveRadar.SetRadarData(ident, style, category, value)
    local rData = MyGrooveRadar.GetRadarTable(ident)
    if rData[style] then
        rData[style][category] = value
        mgrData:set_dirty(ident)
    end
end

function MyGrooveRadar.SaveAllRadarData()
    return mgrData:save_all()
end

function MyGrooveRadar.GetRadarDataPackaged(ident, style)
    local out = {}
    for idx, category in pairs(categoryToActorMappings) do
        out[idx] = MyGrooveRadar.GetRadarData(ident, style, category)
    end
    return out
end

function MyGrooveRadar.ApplyBonuses(ident, stageStats, styleName)
    local actualRadar = stageStats:GetRadarActual()
    local possibleRadar = stageStats:GetRadarPossible()
    for savedCat, stepsCat in pairs(savedCategoryToSMCategory) do
        local earnedValue = actualRadar:GetValue(stepsCat)*possibleRadar:GetValue(stepsCat)
        local savedValue = MyGrooveRadar.GetRadarData(ident, styleName, savedCat)
        if savedValue < earnedValue then
            MyGrooveRadar.SetRadarData(ident, styleName, savedCat, savedValue + (earnedValue-savedValue)/10)
        end
    end
end