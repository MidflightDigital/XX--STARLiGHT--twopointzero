local x = Def.ActorFrame{
	Def.Quad{
		BeginCommand=function(s)
			s:diffuse(Color.Black)
			s:FullScreen()
		end
	}
};

x[#x+1] = Def.Actor {
	BeginCommand=function(self)
		self:queuecommand("Load");
	end;
	LoadCommand=function() SCREENMAN:GetTopScreen():Continue(); end;
};


return x;
