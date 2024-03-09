local jk = LoadModule "Jacket.lua"
local t = Def.ActorFrame{};


t[#t+1] = Def.ActorFrame{
	Def.Sprite{
		SetMessageCommand=function(s,p)
			s:rotationz(-45)
			if jk.GetGroupGraphicPath(p.Text,"Banner",GAMESTATE:GetSortOrder()) ~= nil then
				s:LoadFromCached("Banner",jk.GetGroupGraphicPath(p.Text,"Banner",GAMESTATE:GetSortOrder()))
			else
				s:Load(jk.GetGroupGraphicPath(p.Text,"Banner",GAMESTATE:GetSortOrder()))
			end
			s:setsize(384,120)
		end,
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/36px",
		InitCommand=function(s) s:rotationz(-45):diffusealpha(1):maxwidth(200):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
		SetMessageCommand=function(self,params)
			local group = params.Text;
			local so = GAMESTATE:GetSortOrder();
			if group then
				if so == "SortOrder_Genre" then
					self:settext(group)
				else
					self:settext("")
				end;
			else
				self:settext()
			end;
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
		Def.Sprite {
			InitCommand=function(s) s:xy(factorsx[i],-416) end,
			SetMessageCommand=function(self,params)
				local index = params.DrawIndex
				if index then
					if index == indexes[i] then
						if jk.GetGroupGraphicPath(params.Text,"Jacket",GAMESTATE:GetSortOrder()) ~= nil then
							self:LoadFromCached("Jacket",jk.GetGroupGraphicPath(params.Text,"Jacket",GAMESTATE:GetSortOrder()))
						else
							self:Load(jk.GetGroupGraphicPath(params.Text,"Jacket",GAMESTATE:GetSortOrder()))
						end
						self:scaletoclipped(716,716)
                        self:cropbottom(0.35):croptop(0.26)
					end
				end
			end;
		};
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/bannerwheel bottom"),
			InitCommand=function(s) s:setsize(716,52):xy(factorsx[i],-330) end,
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/42px",
			InitCommand=function(s) s:xy(factorsx[i],-390):zoom(2)
				s:diffusealpha(1):maxwidth(200):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
			SetMessageCommand=function(self,params)
				local group = params.Text;
				local so = GAMESTATE:GetSortOrder();
				local index = params.DrawIndex
				if index then
					if index == indexes[i] then
						if group then
							if so == "SortOrder_Genre" then
								self:settext(group)
							else
								self:settext("")
							end;
						else
							self:settext("")
						end;
					else
						self:settext("")
					end
				end
			end;
		};
	};
end;

return t;
