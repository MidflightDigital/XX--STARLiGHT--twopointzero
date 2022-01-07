local t = LoadFallbackB();

local screenName = Var "LoadingScreen";

local bars = Def.ActorFrame{}

for i=1,7 do
	bars[#bars+1] = Def.Quad{
		InitCommand=function(s) s:y(80*i):diffuse(Alpha(Color.White,0.2)):setsize(1276,34) end,
	};
end

t[#t+1] = Def.ActorFrame{
	OnCommand=function(s) s:draworder(-10):addy(SCREEN_HEIGHT):sleep(0.2):decelerate(0.2):addy(-SCREEN_HEIGHT) end,
	OffCommand=function(s) s:accelerate(0.2):addy(-SCREEN_HEIGHT) end,
	Def.ActorFrame{
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_CENTER_Y-90) end,
		Def.ActorFrame{
			InitCommand=function(s) s:diffusealpha(0.5) end,
			Def.Quad{
				InitCommand=function(s) s:setsize(1280,596):diffuse(Alpha(Color.White,0.25)) end,
			},
			Def.Quad{
				InitCommand=function(s) s:setsize(1276,592):diffuse(Color.Black) end,
			},
			Def.Quad{
				InitCommand=function(s) s:setsize(1276,592):diffuse(Color.Black) end,
			},
		},
		Def.Sprite{
			Texture="DialogTop",
			InitCommand=function(s) s:y(-320) end,
		};
		bars..{
			InitCommand=function(s) s:y(-342) end,
		}
	};
	Def.BitmapText{
		Font="Common normal",
		InitCommand=function(s)
			s:xy(SCREEN_RIGHT,SCREEN_TOP+80):halign(1):settext(VersionDate().."\n"..ProductVersion()):diffusealpha(0.5)
		end,
	};
	Def.Sprite{
		Texture="explain.png",
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM-180) end,
	};
};

return t
