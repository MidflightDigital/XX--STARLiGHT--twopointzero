local args = {...}
local pss = args[1]
local ringColor = FullComboEffectColor[pss:FullComboType()]

if ringColor then
	return Def.ActorFrame{
		FOV=120,
		InitCommand=function(self) self:zoom(0):bob():effectmagnitude(0,0,20) end;
		OnCommand=function(self) self:sleep(0.5):linear(0.2):zoom(0.8) end;
		OffCommand=function(self) self:linear(0.2):zoom(0) end,
		Def.ActorFrame{
			InitCommand=function(s) s:spin():effectmagnitude(0,0,-170) end,
			Def.Sprite{
				Texture="star.png",
			},
			Def.Sprite{
				Texture="colorstar",
				InitCommand=function(self) self:diffuse(ringColor) end;
			}
		};
		Def.ActorFrame{
			InitCommand=function(s) s:spin():effectmagnitude(0,0,80):diffusealpha(0.5) end,
			Def.Sprite{
				Texture="star.png",
			},
			Def.Sprite{
				Texture="colorstar",
				InitCommand=function(self) self:diffuse(ringColor) end;
			}
		};
	}
else
	return Def.Actor{}
end
