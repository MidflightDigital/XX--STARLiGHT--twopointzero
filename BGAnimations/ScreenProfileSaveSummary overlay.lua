local dim_vol = 1

local x = Def.ActorFrame {
	Def.Quad {
		InitCommand=function(s)
			s:FullScreen():diffuse(Color.Black):diffusealpha(0)
		end,
		BeginCommand=function(s)
			if SCREENMAN:GetTopScreen():HaveProfileToSave() then s:sleep(0.5) end
			s:linear(0.297):diffusealpha(1)
		end
	}
};

x[#x+1] = Def.Actor {
	BeginCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToSave() then self:sleep(0.5) end
		self:queuecommand("Load")
	end,
	LoadCommand=function(s)
		SCREENMAN:GetTopScreen():Continue()
		
		s:queuecommand('Play')
	end,
	PlayCommand=function(s)
		if dim_vol ~= 0 then
			SOUND:DimMusic(1-(1-dim_vol), math.huge)
			dim_vol = round(dim_vol - 0.001,3)
			s:sleep(0.001):queuecommand('Play')
		end
	end
};

return x