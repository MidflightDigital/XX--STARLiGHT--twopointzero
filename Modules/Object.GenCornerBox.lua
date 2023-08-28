return function( Options )
	return Def.ActorFrame{
		InitCommand=function(self)
			self:SetHeight( Options.Height )
			:SetWidth( Options.Width )

			self:GetChildAt(1):y( -Options.Height*.5 ):valign(1):halign(1):x( -Options.Width*.5 )
			self:GetChildAt(2):y( -Options.Height*.5 ):valign(1):zoomtowidth( Options.Width )
			self:GetChildAt(3):y( -Options.Height*.5 ):valign(1):halign(1):rotationy(180):x( Options.Width*.5 )

			self:GetChildAt(4):zoomtoheight( Options.Height ):halign(1):x( -Options.Width*.5 )
			self:GetChildAt(5):zoomto( Options.Width, Options.Height ):diffuse(color("#464646"))
			self:GetChildAt(6):zoomtoheight( Options.Height ):rotationy(180):halign(1):x( Options.Width*.5 )

			self:GetChildAt(7):y( Options.Height*.5 ):rotationx(180):valign(1):halign(1):x( -Options.Width*.5 )
			self:GetChildAt(8):y( Options.Height*.5 ):rotationx(180):valign(1):zoomtowidth( Options.Width )
			self:GetChildAt(9):y( Options.Height*.5 ):rotationx(180):valign(1):halign(1):rotationy(180):x( Options.Width*.5 )
		end,
		-- Top Left
		Def.Sprite{ Texture=THEME:GetPathG("_tex/"..( Options.Corners[1] and "Diagonal" or "Box" ),"Corner") },
		-- Top Middle
		Def.Sprite{ Texture=THEME:GetPathG("_tex/Box","Fill") },
		-- Top Right
		Def.Sprite{ Texture=THEME:GetPathG("_tex/"..( Options.Corners[2] and "Diagonal" or "Box" ),"Corner") },

		-- Middle Left
		Def.Sprite{ Texture=THEME:GetPathG("_tex/Box","Side") },
		-- Middle Middle
		Def.Quad{},
		-- Middle Right
		Def.Sprite{ Texture=THEME:GetPathG("_tex/Box","Side") },

		-- Bottom Left
		Def.Sprite{ Texture=THEME:GetPathG("_tex/"..( Options.Corners[3] and "Diagonal" or "Box" ),"Corner") },
		-- Bottom Middle
		Def.Sprite{ Texture=THEME:GetPathG("_tex/Box","Fill") },
		-- Bottom Right
		Def.Sprite{ Texture=THEME:GetPathG("_tex/"..( Options.Corners[4] and "Diagonal" or "Box" ),"Corner") },
	}
end
