local t = Def.ActorFrame {}

for pn in ivalues(PlayerNumber) do
t[#t+1] = Def.ActorFrame {
	InitCommand=function(s) s:visible(false):x(pn==PLAYER_1 and 250 or -250) end,
	OptionsListOpenedMessageCommand=function(self,params)
		if params.Player == pn then
			self:visible(true)
		end
	end;
	OptionsListClosedMessageCommand=function(self,params)
		if params.Player == pn then
			self:visible(false)
		end
	end;
	Def.Quad{
		InitCommand=function(s) s:setsize(500,SCREEN_HEIGHT):diffuse(Color.Black):diffusetopedge(color("0.5,0.5,0.5,1"))
			:diffusealpha(0.7)
		end,
	};
}
end

return t