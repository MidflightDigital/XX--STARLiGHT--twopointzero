local tt={};
--Get parameter
tt[1],tt[2],tt[3],tt[4],tt[5],tt[6],tt[7] = ...
local player = tt[6]
local style = tt[7]

local MyGrooveRadar = LoadModule "MyGrooveRadar.lua"

local function radarSet(self)


	self:SetFromValues(player,tt);
	self:visible(true);

	if GAMESTATE:IsHumanPlayer(player) then
		self:visible(true);
		if MEMCARDMAN:GetCardState(player) == 'MemoryCardState_none' then
			self:visible(true);
			local ind = SCREENMAN:GetTopScreen():GetProfileIndex(player);
			if ind > 0 then --We can display this.

				tt = MyGrooveRadar.GetRadarDataPackaged(PROFILEMAN:GetLocalProfileIDFromIndex(ind-1),style)
				self:SetFromValues(player,tt);
			else
				--[[if SCREENMAN:GetTopScreen():SetProfileIndex(player, 1) then
					self:visible(false);
					self:queuecommand('UpdateInternal2');
				else]]
					self:visible(false);
				--end;
			end
		else
		--------------------using card
		self:visible(true);
		end
	else
		self:visible(false);
	end

end



local t = Def.ActorFrame {

	Name="Radar",
	InitCommand=function(s) s:Center() end,

	Def.GrooveRadar {
		OnCommand=function(s) s:zoom(0):sleep(0.5):sleep(0.583):decelerate(0.150):zoom(0.25) end,
		OffCommand=function(s) s:sleep(0.00):decelerate(0.167):zoom(0) end,
		StorageDevicesChangedMessageCommand=function(self, params)
			self:queuecommand('UpdateInternal2');
		end;
		CodeMessageCommand = function(self, params)

			if params.Name == 'Up' or params.Name == 'Up2' or params.Name == 'DownLeft' then
				self:queuecommand('UpdateInternal2');
			end;
			if params.Name == 'Down' or params.Name == 'Down2' or params.Name == 'DownRight' then
				self:queuecommand('UpdateInternal2');
			end;

		end;
		PlayerJoinedMessageCommand=function(self, params)
			self:queuecommand('UpdateInternal2');
		end;
		PlayerUnjoinedMessageCommand=function(self, params)
			self:queuecommand('UpdateInternal2');
		end;

		OnCommand=function(self, params)
			self:zoom(0):sleep(0.5):sleep(0.583):decelerate(0.150):zoom(0.25)
			self:queuecommand('UpdateInternal2');
		end;

		UpdateInternal2Command=function(self)
			radarSet(self);
		end;


	},


}

return t
