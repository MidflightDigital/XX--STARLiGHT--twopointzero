local padding    = WideScale(12, 28)
local row_height = 68
local row_width  = WideScale(582, 784) - (padding * 2)

return Def.Quad {
	InitCommand=function(self)
		self:horizalign(left):x(padding)
		self:setsize(row_width , row_height):diffuse(Alpha(Color.Black,0.5))
	end
}