local x = Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):Center():diffuse(color("0,0,0,1")) end,
	};
};

x[#x+1] = Def.Actor {
		BeginCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToSave() then self:sleep(0.1); end;
		self:queuecommand("Load");
	end;
	LoadCommand=function() SCREENMAN:GetTopScreen():Continue(); end;
};
return x;