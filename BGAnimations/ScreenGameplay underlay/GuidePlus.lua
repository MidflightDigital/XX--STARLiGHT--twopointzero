local pn = ...

local main_beat_color = {1,1,1,0.9}
local sub_beat_color = {1,1,1,0.2}
local guide_display = LoadModule "GuideDisplay.lua"(pn)



--This is the amount we are zooming the player by
local player_scale = THEME:GetMetric("Common","ScreenHeight")/480
local arrow_spacing = THEME:GetMetric("ArrowEffects", "ArrowSpacing")
local scaled_arrow_spacing = arrow_spacing * player_scale
local half_width_px = GAMESTATE:GetCurrentStyle(pn):GetWidth(pn) / 2 * player_scale
local half_height_px = 1.5 * player_scale

local start_offset_beats = 3
local end_offset_beats = 9

local actor;

local t = Def.ActorFrame{}
t[#t+1] = Def.ActorMultiVertex{
    Name="DrawLines",
    --Note: applying a blank white texture makes the AMV look a lot better for some reason.
    Texture=THEME:GetPathG('',"_white"),
    InitCommand=function(s)
        actor = s
        s:SetDrawState{Mode='DrawMode_Quads',First=1,Num=-1}
    end,
}

--This is used in an attempt to reduce the amount of garbage this produces.
--The Y coords will just get overwritten in Update.
local line_template = {
    {{-half_width_px, -half_height_px, 0}, main_beat_color, {0,0}},
    {{-half_width_px, half_height_px, 0}, main_beat_color, {0,1}},
    {{half_width_px, half_height_px, 0}, main_beat_color, {1,1}},
    {{half_width_px, -half_height_px, 0}, main_beat_color, {1,0}}
}

local function Update()
    --Wait for the DrawLines to be initialized.
    if actor == nil then return end

    local vertex_def1, vertex_def2, vertex_def3, vertex_def4 =
        line_template[1], line_template[2], line_template[3], line_template[4]
    local coords1, coords2, coords3, coords4 =
        vertex_def1[1], vertex_def2[1], vertex_def3[1], vertex_def4[1]
    local line_data = guide_display:GetPositions(start_offset_beats, end_offset_beats, scaled_arrow_spacing)
    local line_count = #line_data
    local vertex_start = 1

    for i=1,line_count do
        local beat, y = line_data[i][1], line_data[i][2]

        local line_color = beat%4 == 0 and main_beat_color or sub_beat_color
        vertex_def1[2] = line_color;
        vertex_def2[2] = line_color;
        vertex_def3[2] = line_color;
        vertex_def4[2] = line_color;

        local top = y - half_height_px
        coords1[2] = top; coords4[2] = top
        local bottom = y + half_height_px
        coords2[2] = bottom; coords3[2] = bottom

        actor:SetVertices(vertex_start, line_template)

        vertex_start = vertex_start + 4
    end

    local vertex_count = #line_data * 4
    actor:SetNumVertices(vertex_count)
end

t.DoneLoadingNextSongMessageCommand=function()
    guide_display:SetSongAndSteps(GAMESTATE:GetCurrentSong(), GAMESTATE:GetCurrentSteps(pn))
end

t.OnCommand = function(s)
    s:SetUpdateFunction(Update)
end

t.OffCommand = function(s)
    s:SetUpdateFunction(nil):visible(false)
end

return t