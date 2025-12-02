return Def.ActorFrame{
  Def.Sprite{
    Texture=THEME:GetPathG("","MusicWheelItem SectionCollapsed NormalPart/Wheel/Backing"),
    InitCommand=function(s) s:diffuse(color("0.7,0,0.5,1")) end,
  };
  Def.BitmapText{
		Font="_avenirnext lt pro bold/25px";
		InitCommand=function(s) s:halign(0):x(-420):maxwidth(250/0.8):wrapwidthpixels(2^24):zoom(2) end,
		SetMessageCommand=function(self,params)
			if params.Index ~= nil then
				if params.HasFocus then
					if GAMESTATE:GetCurrentSong() then
						self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle())
					end
				else
					self:settext(THEME:GetString("MusicWheel","Portal"));
				end
			end
      self:diffuse(color("0.7,0,0.5,1"))
		end;
	};
};
