local SongAttributes = LoadModule "SongAttributes.lua"

return Def.ActorFrame{
  Def.Sprite{
	Texture="Backing",
    SetMessageCommand=function(self, param)
		if param.Type == "SectionCollapsed" or param.Type == "SectionExpanded" then
			local group = param.Text;
      		self:diffuse(SongAttributes.GetGroupColor(group));
		end
    end;
  };
  Def.BitmapText{
	  Font="_avenirnext lt pro bold/25px";
	  InitCommand=function(s) s:halign(0):x(-420):maxwidth(250/0.8):wrapwidthpixels(2^24):zoom(2) end,
	  SetMessageCommand=function(self, param)
		if param.Type == "SectionCollapsed" or param.Type == "SectionExpanded" then
			local group = param.Text;
			self:diffuse(SongAttributes.GetGroupColor(group));
			self:settext(SongAttributes.GetGroupName(group));
		end
	end;
	};
};
