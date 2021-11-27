local posy = 0		--vertical position addition
local fadl = 0.75	--fade left
local fadr = 0.75	--fade right
local zomx = 160 	--zoom x
local zomy = 12		--zoom y
local skwx = -0.25	--skewx

return Def.ActorFrame {
	Def.Sprite{
		Texture="_underline",
		InitCommand=function(s)
			s:y(10):diffuseshift():effectcolor1(Color.White):effectcolor2(Alpha(Color.White,0.5))
		end,
	};
};