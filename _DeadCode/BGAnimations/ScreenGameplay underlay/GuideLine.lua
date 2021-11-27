local pn = ...

--This currently doesn't work for versus mode. Don't enable it unless you're going to debug it.

local thickness = 3;
local mainAlpha = 0.9;
local subAlpha = 0.2;

local t = Def.ActorFrame{};

--[ja]�����ƂɃ��C����`��
for i = 0,800,1 do

	t[#t+1] = Def.Quad{
		
		InitCommand = function(self)
			self:diffusecolor(color("1,1,1,1"));
			if (i%4==0) then
				self:diffusealpha(mainAlpha);
			else
				self:diffusealpha(subAlpha);
			end;
			local style= GAMESTATE:GetCurrentStyle(pn)
			local width= style:GetWidth(pn)
			self:zoomto(width,thickness);
			self:y((SCREEN_TOP-190)+(i*UnitBySpeedMod(GetCurrentSpeedMod(GAMESTATE:GetCurrentSong()));
		end;
	};
end;

local function GLScroll(self)
	local song = GAMESTATE:GetCurrentSong();
	if song then

		local start = song:GetFirstBeat();
		local last = song:GetLastBeat();
		local cur = GAMESTATE:GetSongBeat();
		
		self:y(cur*(0-UnitBySpeedMod(GetCurrentSpeedMod(song))));

		--[ja]�X�N���[���t�B���^�ɑ�����
		if (GAMESTATE:GetSongBeat() >= last) then
			self:visible(false);
		elseif (GAMESTATE:GetSongBeat() >= start-16) then
			self:visible(true);
		else
			--self:visible(true);
			self:visible(false);
		end;
		
	end;
end;



t.InitCommand=function(s) s:SetUpdateFunction(GLScroll) end,


function UnitBySpeedMod(sm)

	local spacing = THEME:GetMetric("ArrowEffects", "ArrowSpacing")
	if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
		return -spacing * sm;
	else
		return spacing * sm;
	end;

end;

local ps = GAMESTATE:GetPlayerState(pn)
function GetCurrentSpeedMod(song)

	local po = ps:GetCurrentPlayerOptions()
	local mmod = po:MMod()
	if mmod then
		return mmod/CalculateReadBPM(song)
	end
	return po:XMod() or 1

end;

return t;