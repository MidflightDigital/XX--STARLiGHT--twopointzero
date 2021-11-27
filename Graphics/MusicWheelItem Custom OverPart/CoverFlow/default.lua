local set;
local t = Def.ActorFrame{}
local Crstext = THEME:GetString("MusicWheel","CustomItemCrsText");

t[#t+1] = Def.ActorFrame{
	Def.Sprite{
		SetMessageCommand=function(self,params)
			self:visible(true);
			if params.Label == Crstext then
				self:Load(THEME:GetPathG("","MusicWheelItem Custom OverPart/Default/COURSE.png"))
			end;
			self:setsize(372,372)
		end;
	},
}

return t
