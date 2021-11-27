-- From ProductivityHelpers on SMTheming Wiki
function Actor:Tile(w, h)
	self:zoomto(w, h)
	self:customtexturerect(0, 0, w / self:GetWidth(), h / self:GetHeight())
end

function Actor:TileX(w)
	self:zoomtowidth(w)
	self:customtexturerect(0, 0, w / self:GetWidth(), 1)
end

function Actor:TileY(h)
	self:zoomtoheight(h)
	self:customtexturerect(0, 0, 1, h / self:GetHeight())
end

