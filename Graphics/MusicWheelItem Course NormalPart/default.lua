local lights = Def.ActorFrame{}

for i=1,2 do
	lights[#lights+1] = Def.ActorFrame{
		Def.Sprite{
			Texture="light.png",
			InitCommand=function(s) s:x(i==1 and -290 or 290):rotationz(i==2 and 180 or 0):blend(Blend.Add):diffusealpha(0.6) end,
		};
	};
end

return Def.ActorFrame{
	Def.Sprite{
		Texture="coursebox",
	};
	Def.Sprite{
		Texture=THEME:GetPathG("","Common fallback banner");
		InitCommand=function(s) s:scaletoclipped(512,160) end,
	};
	Def.Banner {
		Name="SongBanner";
		InitCommand=function(s) s:scaletoclipped(512,160) end,
		SetMessageCommand=function(self,params)
			if params.Type == "Course" then
				self:LoadFromCourse(params.Course);
			end
		end;
	};
	lights;
};
