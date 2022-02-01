local t = Def.ActorFrame {
	SetMessageCommand=function(self,params)
		self:zoom(params.HasFocus and 1.5 or 1.2);
	end;

	Def.Sprite{ Texture='normal',
		InitCommand=function(s) s:y(-8):diffuse(color("0,0.5,1,1")) end
	};
	Def.Sprite{ Texture='normal',
		InitCommand=function(s) s:y(-8):diffuse(color("#00ccff")):blend(Blend.Add):diffusealpha(0.5):thump():effectclock('beat'):effectmagnitude(1,1.05,1):effectoffset(0.35) end,
		SetMessageCommand=function(self,params)
			if params.Index ~= nil then
				self:visible(params.HasFocus);
			end
		end;
	};
	Def.Sprite{ Texture='bright',
		InitCommand=function(s) s:y(-8):diffuseshift():effectcolor1(Color.White):effectcolor2(Alpha(Color.White,0.5)):effectclock('beatnooffset') end,
		SetMessageCommand=function(self,params)
			if params.Index ~= nil then
				self:visible(params.HasFocus);
			end
		end;
	};
	Def.BitmapText{
		Font='_avenirnext lt pro bold/25px',
		InitCommand=function(s) s:y(-8):maxwidth(320) end,
		SetCommand=function(self,params)
			self:settext(THEME:GetString("MusicWheel","CourseText"));
		end;
	};
};

return t
