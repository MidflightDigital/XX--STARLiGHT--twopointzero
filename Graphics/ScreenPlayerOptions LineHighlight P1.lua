-- left/right padding from screen edges
local padding = WideScale(12, 28)

-- OptionRow height and width
local row_height = 68
local row_width  = WideScale(582, 784) - (padding * 2)

return Def.Quad{
	InitCommand=function(s) s:setsize(row_width,row_height):diffuse(color("#797a82")):diffusealpha(0.8) end,
};
