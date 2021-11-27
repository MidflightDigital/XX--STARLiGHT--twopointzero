local group;
local JM = LoadModule "Jacket.lua"

local t = Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s)
			s:diffuse(Alpha(Color.Black,0.75)):setsize(372,372)
		end,
	};
	Def.Sprite {
		SetMessageCommand=function(self,p)
			self:Load(JM.GetGroupGraphicPath(p.Text,"Jacket",GAMESTATE:GetSortOrder()))
			self:setsize(372,372)
		end;
	};
	LoadActor(THEME:GetPathG("","_jackets/glow.png"))..{
		InitCommand=function(s) s:visible(false) end,
		SetMessageCommand=function(self,params)
			local pt_text = params.Text;
			local group = params.Text;
			local so = GAMESTATE:GetSortOrder()
			if group then
				if so == "SortOrder_Group" then
					self:visible(true)
				else
					self:visible(false)
				end
			end;
			self:setsize(372,372)
		end;
	};
	LoadFont("_avenirnext lt pro bold 20px")..{
		InitCommand=function(s) s:diffusealpha(0.9):y(-172):strokecolor(color("0,0,0,0.5")):zoom(0.8) end,
		SetMessageCommand=function(self,params)
			local group = params.Text;
			local so = GAMESTATE:GetSortOrder();
			if group then
				if so == "SortOrder_Group" then
					self:settext(THEME:GetString("MusicWheel","GROUPTop"))
				else
					self:settext("")
				end;
			else
				self:settext("")
			end;
		end;
	};
	LoadFont("_avenirnext lt pro bold 20px")..{
		InitCommand=function(s) s:diffusealpha(0.9):y(172):zoom(0.8) end,
		SetMessageCommand=function(self,params)
			local group = params.Text;
			local so = GAMESTATE:GetSortOrder();
			if group then
				if so == "SortOrder_Group" then
					self:settext(THEME:GetString("MusicWheel","GROUPBot"))
				else
					self:settext("")
				end;
			else
				self:settext("")
			end;
		end;
	};
	LoadFont("_avenirnext lt pro bold 46px")..{
		InitCommand=function(s) s:y(-20):zoom(1.2):diffusealpha(1):maxwidth(200):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
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
				self:settext("")
			end;
		end;
	};
};
return t;
