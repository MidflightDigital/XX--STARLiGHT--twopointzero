
return Def.ActorFrame{
	Def.ActorFrame{
		InitCommand=function(s) s:y(-120) end,
		Def.Sprite{
			Texture=THEME:GetPathG("","_jackets/smallrandom.png"),
			Name="SongCD";
			InitCommand=function(self) self:setsize(120,120) end;
		};
	};
	Def.ActorFrame{
		InitCommand=function(s) s:rotationx(75) end,
		Def.Sprite{
			Texture=THEME:GetPathG("","_jackets/smallrandom.png"),
			Name="-3 Banner";
			InitCommand=function(s) s:xy(-538,-458) end,
   			SetMessageCommand=function(self,params)
  				local group = params.Text;
				local index = params.DrawIndex
				if index then
					if index == 18 then
          				self:setsize(186,186):visible(true)
					else
						self:visible(false)
					end;
				end;
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_jackets/smallrandom.png"),
			Name="-2 Banner";
			InitCommand=function(s) s:xy(-350,-460) end,
    		SetMessageCommand=function(self,params)
  				local group = params.Text;
				local index = params.DrawIndex
				if index then
					if index == 19 then
          				self:setsize(184,184):visible(true)
					else
						self:visible(false)
					end;
				end;
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_jackets/smallrandom.png"),
			Name="-1 Banner";
			InitCommand=function(s) s:xy(-175,-461) end,
    		SetMessageCommand=function(self,params)
  				local group = params.Text;
				local index = params.DrawIndex
				if index then
					if index == 20 then
          				self:setsize(182,182):visible(true)
					else
						self:visible(false)
					end;
				end;
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_jackets/smallrandom.png"),
			Name="CenterBanner";
			InitCommand=function(s) s:xy(1,-460) end,
    		SetMessageCommand=function(self,params)
  				local group = params.Text;
				local index = params.DrawIndex
				if index then
					if index == 21 then
         				self:setsize(186,186):visible(true)
					else
						self:visible(false)
					end;
				end;
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_jackets/smallrandom.png"),
			Name="+1 Banner";
			InitCommand=function(s) s:xy(175,-461) end,
    		SetMessageCommand=function(self,params)
  				local group = params.Text;
				local index = params.DrawIndex
				if index then
					if index == 22 then
         			self:setsize(186,186):visible(true)
					else
						self:visible(false)
					end;
				end;
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_jackets/smallrandom.png"),
			Name="+2 Banner";
			InitCommand=function(s) s:xy(350,-460) end,
    		SetMessageCommand=function(self,params)
  				local group = params.Text;
				local index = params.DrawIndex
				if index then
					if index == 23 then
          				self:setsize(182,182):visible(true)
					else
						self:visible(false)
					end;
				end;
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_jackets/smallrandom.png"),
			Name="+3 Banner";
			InitCommand=function(s) s:xy(538,-458) end,
    		SetMessageCommand=function(self,params)
  				local group = params.Text;
				local index = params.DrawIndex
				if index then
					if index == 24 then
          				self:setsize(186,186):visible(true)
					else
						self:visible(false)
					end;
				end;
			end;
		};
	};
};
