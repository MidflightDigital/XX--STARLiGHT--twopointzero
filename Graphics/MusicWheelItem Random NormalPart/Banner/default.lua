local t = Def.ActorFrame{};


t[#t+1] = Def.ActorFrame{
	LoadActor(THEME:GetPathG("","_banners/random.png")) .. {
	Name="SongCD";
	InitCommand=function(self)
    	self:setsize(384,120):rotationz(-45)
	end;
	};
};

local factorsx = {-518, 0, 518};
local indexes = {7, 8, 9};

for i = 1,3 do
	t[#t+1] = Def.ActorFrame{
		SetMessageCommand=function(self,params)
			local index = params.DrawIndex
			if index then
				if index == indexes[i] then
					self:visible(true)
				else
					self:visible(false)
				end;
			end;
		end;
		Def.Sprite{
            Texture=THEME:GetPathG("","_jackets/random.png");
			InitCommand=function(s) s:xy(factorsx[i],-416) end,
			SetMessageCommand=function(self,params)
				local group = params.Text
				local index = params.DrawIndex
				if group then
					if index then
						if index == indexes[i] then
                            self:scaletoclipped(716,716)
                            self:cropbottom(0.35):croptop(0.26)
						end;
					end;
				end;
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/bannerwheel bottom"),
			InitCommand=function(s) s:setsize(716,52):xy(factorsx[i],-330) end,
		};
	};

end;

return t;
