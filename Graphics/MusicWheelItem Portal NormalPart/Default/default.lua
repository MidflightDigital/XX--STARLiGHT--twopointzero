local getOn = 0;
local getOff = 0;
local jk = LoadModule"Jacket.lua"

return Def.ActorFrame{
	SetCommand=function(self,params)
		local song = params.Text
		local index = params.DrawIndex
		if song then
			if getOn == 0 then
				if index then
					if index == 4 then
						self:finishtweening():zoom(0):sleep(0.3):decelerate(0.4):zoom(1)
					elseif index < 4 then
						self:finishtweening():addx(-SCREEN_WIDTH):sleep(0.3):decelerate(0.4):addx(SCREEN_WIDTH)
					elseif index > 4 then
						self:finishtweening():addx(SCREEN_WIDTH):sleep(0.3):decelerate(0.4):addx(-SCREEN_WIDTH)
					end;
				end;
			end;
		end;
		self:queuecommand("SetOn");
	end;
	SetOnCommand=function(self)
		getOn = 1;
	end;
	Def.Quad{
		InitCommand=function(s) s:diffuse(Alpha(Color.Black,0.4)):setsize(230,230) end,
	};
	Def.Sprite{
		Texture=THEME:GetPathG("","_jackets/portal.png"),
		InitCommand = function(self)
			self:setsize(230,230)
		end,
	},
	Def.Sprite{
		Name="Glow",
		Texture=THEME:GetPathG("","_jackets/over"),
		InitCommand=function(s)
			s:setsize(230,230)
		end
	},
	Def.BitmapText{
		Name="TopText",
		Font="_avenirnext lt pro bold/10px",
		InitCommand=function(s) s:y(-107):diffuse(color("#dafaff")) end,
		SetMessageCommand=function(s)
			s:settext(THEME:GetString("MusicWheel","PORTALTop"))
		end
	};
	Def.BitmapText{
		Name="BottomText",
		Font="_avenirnext lt pro bold/10px",
		InitCommand=function(s) s:y(107):diffuse(color("#dafaff")) end,
		SetMessageCommand=function(s)
			s:settext(THEME:GetString("MusicWheel","PORTALBot"))
		end
	};
}
