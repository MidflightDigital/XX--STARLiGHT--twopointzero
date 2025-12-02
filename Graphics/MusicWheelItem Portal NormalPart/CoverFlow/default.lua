local getOn = 0;
local getOff = 0;
local jk = LoadModule"Jacket.lua"

return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s) s:diffuse(Alpha(Color.Black,0.4)):scaletofit(-186,-186,186,186) end,
	};
	Def.Sprite{
		Texture=THEME:GetPathG("","_jackets/portal.png"),
		InitCommand = function(self)
			self:scaletofit(-186,-186,186,186)
		end,
		SetMessageCommand=function(s,p)
			local song = GAMESTATE:GetCurrentSong()
			if p.Index ~= nil then
				if p.HasFocus then
					if song then
						s:LoadFromCached("Jacket",jk.GetSongGraphicPath(song,"Jacket"))
					end
				else
					s:Load(THEME:GetPathG("","_jackets/portal.png"))
				end
			end
			s:scaletofit(-186,-186,186,186)
		end
	},
	Def.Sprite{
		Name="Glow",
		Texture=THEME:GetPathG("","_jackets/over"),
		InitCommand=function(s)
			s:scaletofit(-186,-186,186,186)
		end
	},
	Def.BitmapText{
		Name="TopText",
		Font="_avenirnext lt pro bold/20px",
		InitCommand=function(s) s:y(-172):diffuse(color("#dafaff")):zoom(0.8) end,
		SetMessageCommand=function(s)
			s:settext(THEME:GetString("MusicWheel","PORTALTop"))
		end
	};
	Def.BitmapText{
		Name="BottomText",
		Font="_avenirnext lt pro bold/20px",
		InitCommand=function(s) s:y(172):diffuse(color("#dafaff")):zoom(0.8) end,
		SetMessageCommand=function(s)
			s:settext(THEME:GetString("MusicWheel","PORTALBot"))
		end
	};
}
