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
			local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
  			local width=style:GetWidth(pn)*(NumColumns/1.7)
			self:zoomto(width,thickness);
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:y((SCREEN_TOP+190)+(i*UnitBySpeedMod(GetCurrentSpeedMod())));
			else
				self:y((SCREEN_TOP-190)+(i*UnitBySpeedMod(GetCurrentSpeedMod())));
			end
		end;
	};
end;

local function GLScroll(self)
	local song = GAMESTATE:GetCurrentSong();
	if song then

		local start = song:GetFirstBeat();
		local last = song:GetLastBeat();
		local cur = GAMESTATE:GetSongBeat();
		
		self:y(cur*(0-UnitBySpeedMod(GetCurrentSpeedMod())));

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



t.InitCommand=function(s) s:SetUpdateFunction(GLScroll) end


function UnitBySpeedMod(sm)

	if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
		return -96 * sm;
	else
		return 96 * sm;
	end;

end;

function GetCurrentSpeedMod()

	local hispeed = 1;

	if GAMESTATE:PlayerIsUsingModifier(pn,'0.25x') then
		hispeed=0.25;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'0.5x') then
		hispeed=0.5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'0.75x') then
		hispeed=0.75;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'1x') then
		hispeed=1;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'1.25x') then
		hispeed=1.25;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'1.5x') then
		hispeed=1.5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'1.75x') then
		hispeed=1.75;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'2x') then
		hispeed=2;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'2.25x') then
		hispeed=2.25;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'2.5x') then
		hispeed=2.5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'2.75x') then
		hispeed=2.75;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'3x') then
		hispeed=3;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'3.25x') then
		hispeed=3.25;   
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'3.5x') then
		hispeed=3.5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'3.75x') then
		hispeed=3.75;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'4x') then
		hispeed=4;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'4.25x') then
		hispeed=4.25;   
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'4.5x') then
		hispeed=4.5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'4.75x') then
		hispeed=4.75;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'5x') then
		hispeed=5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'5.25x') then
		hispeed=5.25;   
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'5.5x') then
		hispeed=5.5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'5.75x') then
		hispeed=5.75;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'6x') then
		hispeed=6;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'6.25x') then
		hispeed=6.25;   
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'6.5x') then
		hispeed=6.5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'6.75x') then
		hispeed=6.75;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'7x') then
		hispeed=7;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'7.25x') then
		hispeed=7.25;   
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'7.5x') then
		hispeed=7.5;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'7.75x') then
		hispeed=7.75;
	elseif GAMESTATE:PlayerIsUsingModifier(pn,'8x') then
		hms=8;
	end;



	return hispeed;

end;

return t;