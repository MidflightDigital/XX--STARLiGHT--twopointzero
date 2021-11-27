-- Hack to clear the z-buffer AFTER the mask destination, since clearzbuffer will
-- clear it BEFORE the current object is rendered.
ClearZ = Def.Quad {
	InitCommand = function(s) s:stretchto(-2,-2,-1,-1):clearzbuffer(true) end,
}
