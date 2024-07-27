local pn = ...;
local t = Def.ActorFrame {};

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local Calories = pss:GetCaloriesBurned();

local CaloriesToday;
if PROFILEMAN:IsPersistentProfile(pn) then
	CaloriesToday = PROFILEMAN:GetProfile(pn):GetCaloriesBurnedToday();
else
	CaloriesToday = STATSMAN:GetAccumPlayedStageStats():GetPlayerStageStats(pn)
		:GetCaloriesBurned()
end

--See Food.lua for details
local FoodInfo = LoadModule "Food.lua".GetFoodAndPercentage(CaloriesToday)

t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:y(-90) end,
	Def.Quad{
		InitCommand=function(s) s:setsize(556,34)
			:diffuse(color("#222222")):diffusetopedge(Color.Black)
		end,
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/36px",
		InitCommand=function(s) s:zoom(0.7):halign(1):x(14) end,
		OnCommand=function(self)
			self:settext(THEME:GetString("ScreenEvaluation","SongCal"));
		end;
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/36px",
		InitCommand=function(s) s:halign(1):x(274):zoom(0.8) end,
		OnCommand=function(self)
			local CaloriesMod = string.format("%04.2f",Calories)
			self:settext(CaloriesMod.." kcal")	
		end;
	};
}
t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:y(-52) end,
	Def.BitmapText{
		Font="_avenirnext lt pro bold/36px",
		InitCommand=function(s) s:zoom(0.7):halign(1):x(14) end,
		OnCommand=function(self)
			self:settext(THEME:GetString("ScreenEvaluation","TodayCal"));
		end;
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/36px",
		InitCommand=function(s) s:halign(1):x(274):zoom(0.8) end,
		OnCommand=function(self)
			local CaloriesMod = string.format("%04.2f",CaloriesToday)
			self:settext(CaloriesMod.." kcal")	
		end;
	};
}


--kcal
t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:xy(190,130) end,
	Def.Sprite{
		Texture="empty",
	};
	Def.Sprite{
		Texture="Fill",
		InitCommand=function(s) s:halign(0):x(-80) end,
		OnCommand=function(s)
			s:zoomx(FoodInfo[3])
		end,
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/46px";
		InitCommand=function(s) s:y(-54):zoom(1.1) end,
		OnCommand=function(s)
			s:settext(string.format("%0.0f%%",FoodInfo[3]*100))
		end,
	}
}

--Reference
t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:xy(190,10) end,
	Def.Sprite{
		Texture="reference",
		InitCommand=function(s) s:y(-20) end,
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/20px",
		Text=THEME:GetString("ScreenEvaluation","FoodEquiv"),
		InitCommand=function(s) s:y(-20):zoom(0.6):maxwidth(240) end,
	},
	Def.BitmapText{
		Font="_avenirnext lt pro bold/20px",
		InitCommand=function(s) s:xy(75,16):zoom(1.1):halign(1):wrapwidthpixels(300) end,
		OnCommand=function(s)
			s:settext(FoodInfo[2]..string.format(" %dkcal",FoodInfo[1][2]))
		end,
	}
};
--pictures
t[#t+1] = Def.Sprite{
		InitCommand=function(s) s:zoom(1):xy(-75,75) end,
		OnCommand=function(self)
			self:Load(
				THEME:GetPathB("ScreenEvaluationNormal",
				string.format("decorations/kcalP1/%s.png",
				FoodInfo[1][1])
			));
		end;
		};

return t;
