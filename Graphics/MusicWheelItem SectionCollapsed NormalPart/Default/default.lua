local jk = LoadModule "Jacket.lua"
return Def.ActorFrame{
	SetMessageCommand=function(s,p)
		s:visible(false)

		s:GetChild("Jacket"):visible(false)
		s:GetChild("Glow"):visible(false)
		s:GetChild("TopText"):visible(false)
		s:GetChild("BottomText"):visible(false)
		s:GetChild("Genre"):visible(false)

		local group = p.Text
		local so = GAMESTATE:GetSortOrder()
		if p.Type == "SectionExpanded" or p.Type == "SectionCollapsed" then
			s:visible(true)
			s:GetChild("Jacket"):Load(jk.GetGroupGraphicPath(group,"Jacket",so)):scaletofit(-115,-115,115,115):visible(true)
			if so == "SortOrder_Group" then
				s:GetChild("Glow"):visible(true)
				s:GetChild("TopText"):settext(THEME:GetString("MusicWheel","GROUPTop")):visible(true)
				s:GetChild("BottomText"):settext(THEME:GetString("MusicWheel","GROUPBot")):visible(true)
			end
			if so == "SortOrder_Genre" then
				s:GetChild("Genre"):settext(group):visible(true)
			end
		end
	end,
	Def.Quad{
		InitCommand=function(s) s:diffuse(Alpha(Color.Black,0.4)):setsize(230,230) end,
	};
	Def.Sprite {
		Name="Jacket",
	};
	Def.Sprite{
		Name="Glow",
		Texture=THEME:GetPathG("","_jackets/glow.png"),
		InitCommand=function(s) s:visible(false):setsize(230,230) end,
	};
	Def.BitmapText{
		Name="TopText",
		Font="_avenirnext lt pro bold/10px",
		InitCommand=function(s) s:diffusealpha(0.9):y(-107):strokecolor(color("0,0,0,0.5")) end,
	};
	Def.BitmapText{
		Name="BottomText",
		Font="_avenirnext lt pro bold/10px",
		InitCommand=function(s) s:diffusealpha(0.9):y(107):strokecolor(color("0,0,0,0.5")) end,
	};
	Def.BitmapText{
		Name="Genre",
		Font="_avenirnext lt pro bold/46px",
		InitCommand=function(s) s:y(-20):diffusealpha(1):maxwidth(200):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
	};
};
