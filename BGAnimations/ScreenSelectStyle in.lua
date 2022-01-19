local t = Def.ActorFrame{};

t[#t+1] = Def.ActorFrame{
	OnCommand=function(s)
		SOUND:DimMusic(1,math.huge)
	end,
	Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0)) end,
		OnCommand=function(s)
			if getenv("FixStage") == 1 then
				s:diffusealpha(1):linear(0.2):diffusealpha(0):sleep(0.55)
			else
				s:diffusealpha(0):sleep(0.75)
			end
		end,
	};
	Def.Sound{
		File=THEME:GetPathS("","ScreenSelectStyle in.ogg"),
		OnCommand=function(s) s:sleep(0.2):queuecommand("Play") end,
		PlayCommand=function(s) s:play() end,
	};
};

return t;
