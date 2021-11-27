local args = {...}
local pss = args[1]
local ringColor = FullComboEffectColor[pss:FullComboType()]

if ringColor then
	return Def.ActorFrame{
		Def.Sprite{
			Texture="ring",
			InitCommand=function(self) self:diffuse(ringColor):zoom(0) end;
			OnCommand=function(self) self:sleep(0.5):linear(0.2):zoom(0.5):spin():effectmagnitude(0,0,-170) end;
			OffCommand=function(self) self:linear(0.2):zoom(0) end
		},
		Def.Sprite{
			Texture="lines",
			InitCommand=function(self) self:diffuse(ringColor):zoom(0) end;
			OnCommand=function(self) self:sleep(0.5):linear(0.2):zoom(0.6):spin():effectmagnitude(0,0,170) end;
			OffCommand=function(self) self:linear(0.2):zoom(0) end
		}
	}
else
	return Def.Actor{}
end
