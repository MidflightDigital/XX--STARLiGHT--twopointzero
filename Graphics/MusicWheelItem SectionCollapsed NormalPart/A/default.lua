local SongAttributes = LoadModule "SongAttributes.lua"

return Def.ActorFrame {
	SetMessageCommand=function(self,params)
		self:zoom(params.HasFocus and 1.5 or 1.2);
	end;

	Def.Sprite{ Texture='normal',
		InitCommand=function(s) s:y(-8) end,
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
			self:stoptweening();
			if params.Text == '' then
				self:settext("RANDOM");
			elseif GAMESTATE:GetSortOrder() == 'SortOrder_Group' then
				self:settext(string.gsub(params.Text,"^%d%d? ?%- ?", ""));
			elseif GAMESTATE:GetSortOrder() == 'SortOrder_TopGrades' then
				self:settext(string.gsub(params.Text,"AAAA","AAA+"))
			else
				self:settext(SongAttributes.GetGroupName(params.Text));
			end
		end;
	};
	Def.ActorFrame{
        InitCommand=function(s) s:y(-8) end,
        SetMessageCommand=function(self,params)
			if params.Index ~= nil then
				self:visible(params.HasFocus);
			end
		end;
        Def.Sprite{ Texture=THEME:GetPathG("","_shared/arrows/arrowb"),
            InitCommand=function(s) s:x(-300):bounce():effectmagnitude(-6,0,0):effectclock('beatnooffset'):effectoffset(0.35) end,
        },
        Def.Sprite{ Texture=THEME:GetPathG("","_shared/arrows/arrowb"),
            InitCommand=function(s) s:zoomx(-1):x(300):bounce():effectmagnitude(6,0,0):effectclock('beatnooffset'):effectoffset(0.35) end,
        },
    }
};
