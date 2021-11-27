local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("","_jackets/smallrandom.png")) .. {
	InitCommand = function(self)
			self:setsize(230,230)
	end,
}

return t
