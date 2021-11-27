--Lifted from default, appears to have been written by Kyzentun
local filter_color= color("0,0,0,0")
local this_pn
local screen = Var"LoadingScreen"

local ShowGuidelines = true
local Guide = Def.ActorFrame{}

--Guidelines currently aren't working properly on versus mode. Please don't enable it yet.
--[[for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	Guide[#Guide+1] = LoadActor("GuideLine",pn);
end]]

local args= {
	--the screen filter
	Def.Quad{
		InitCommand= function(self)
			self:hibernate(math.huge):diffuse(filter_color)
			:fadeleft(1/32)
			:faderight(1/32)
		end,
		PlayerStateSetCommand= function(self, param)
			local pn= param.PlayerNumber
			local style= GAMESTATE:GetCurrentStyle(pn)
			local alf= getenv("ScreenFilter"..ToEnumShortString(pn)) or 0
			local width= style:GetWidth(pn)+14
			self:setsize(width, _screen.h*4096)
			if screen == "ScreenDemonstration" then
				self:diffusealpha(0.5)
			else
				self:diffusealpha(alf/100)
			end
			self:hibernate(0)
		end,

	};
	Def.Quad{
		InitCommand=function(self) self
			:diffuse(color("#ff1b00"))
			:diffusealpha(0)
			:hibernate(math.huge)
		end,
		PlayerStateSetCommand= function(self, param)
			local pn= param.PlayerNumber
			this_pn= pn
			local style= GAMESTATE:GetCurrentStyle(pn)
			local width= style:GetWidth(pn)
			self:setsize(width, _screen.h*4096):hibernate(0)
		end,
		HealthStateChangedMessageCommand= function(self, param)
			if this_pn and param.PlayerNumber == this_pn then
				self:linear(0.1)
				:diffusealpha((param.HealthState == 'HealthState_Danger') and 0.5 or 0)
			end
		end,
	},
	--Left
	LoadActor("rope")..{
		InitCommand=function(self) self
			:diffusealpha(0)
			:customtexturerect(0,0,1,2)
			:hibernate(math.huge)
			:zoomx(0.4):zoomy(1)
			:diffuseshift()
			:effectcolor1(color("1,1,1,1"))
			:effectcolor2(color("1,1,1,0.5"))
			:effectperiod(0.5)
		end,
		PlayerStateSetCommand= function(self, param)
			local pn= param.PlayerNumber
			local style= GAMESTATE:GetCurrentStyle(pn)
			local width= style:GetWidth(pn)
			self:x((-width/2)-10):hibernate(0)
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:texcoordvelocity(0,-0.5)
			elseif not GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:texcoordvelocity(0,0.5)
			end;
		end,
		HealthStateChangedMessageCommand= function(self, param)
			if this_pn and param.PlayerNumber == this_pn then
				self:linear(0.1)
				:diffusealpha((param.HealthState == 'HealthState_Danger') and 1 or 0)
			end
		end,
	},
	LoadActor("text")..{
		InitCommand=function(self) self
			:diffusealpha(0)
			:hibernate(math.huge)
			:zoom(0.5)
		end,
		PlayerStateSetCommand= function(self, param)
			local pn= param.PlayerNumber
			local style= GAMESTATE:GetCurrentStyle(pn)
			local width= style:GetWidth(pn)
			self:x((-width/2)-10):hibernate(0)
		end,
		HealthStateChangedMessageCommand= function(self, param)
			if this_pn and param.PlayerNumber == this_pn then
				self:linear(0.1)
				:diffusealpha((param.HealthState == 'HealthState_Danger') and 1 or 0)
			end
		end,
	},
	LoadActor("text")..{
		InitCommand=function(self) self
			:diffusealpha(0)
			:hibernate(math.huge)
			:zoom(0.5)
			:blend('BlendMode_Add')
			:heartbeat():effectmagnitude(1.5,1,0):effectperiod(0.5)
		end,
		PlayerStateSetCommand= function(self, param)
			local pn= param.PlayerNumber
			local style= GAMESTATE:GetCurrentStyle(pn)
			local width= style:GetWidth(pn)
			self:x((-width/2)-10):hibernate(0)
		end,
		HealthStateChangedMessageCommand= function(self, param)
			if this_pn and param.PlayerNumber == this_pn then
				self:linear(0.1)
				:diffusealpha((param.HealthState == 'HealthState_Danger') and 0.5 or 0)
			end
		end
	},
	--Right
	LoadActor("rope")..{
		InitCommand=function(self) self
			:diffusealpha(0)
			:customtexturerect(0,0,1,2)
			:hibernate(math.huge)
			:zoomx(0.4):zoomy(1)
			:diffuseshift()
			:effectcolor1(color("1,1,1,1"))
			:effectcolor2(color("1,1,1,0.5"))
			:effectperiod(0.5)
		end,
		PlayerStateSetCommand= function(self, param)
			local pn= param.PlayerNumber
			local style= GAMESTATE:GetCurrentStyle(pn)
			local width= style:GetWidth(pn)
			self:x((width/2)+10):hibernate(0)
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:texcoordvelocity(0,-0.5)
			elseif not GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:texcoordvelocity(0,0.5)
			end;
		end,
		HealthStateChangedMessageCommand= function(self, param)
			if this_pn and param.PlayerNumber == this_pn then
				self:linear(0.1)
				:diffusealpha((param.HealthState == 'HealthState_Danger') and 1 or 0)
			end
		end,
	},
	LoadActor("text")..{
		InitCommand=function(self) self
			:diffusealpha(0)
			:hibernate(math.huge)
			:zoom(0.5)
			:rotationz(180)
		end,
		PlayerStateSetCommand= function(self, param)
			local pn= param.PlayerNumber
			local style= GAMESTATE:GetCurrentStyle(pn)
			local width= style:GetWidth(pn)
			self:x((width/2)+10):hibernate(0)
		end,
		HealthStateChangedMessageCommand= function(self, param)
			if this_pn and param.PlayerNumber == this_pn then
				self:linear(0.1)
				:diffusealpha((param.HealthState == 'HealthState_Danger') and 1 or 0)
			end
		end,
	},
	LoadActor("text")..{
		InitCommand=function(self) self
			:diffusealpha(0)
			:hibernate(math.huge)
			:rotationz(180)
			:zoom(0.5)
			:blend('BlendMode_Add')
			:heartbeat():effectmagnitude(1.5,1,0):effectperiod(0.5)
		end,
		PlayerStateSetCommand= function(self, param)
			local pn= param.PlayerNumber
			local style= GAMESTATE:GetCurrentStyle(pn)
			local width= style:GetWidth(pn)
			self:x((width/2)+10):hibernate(0)
		end,
		HealthStateChangedMessageCommand= function(self, param)
			if this_pn and param.PlayerNumber == this_pn then
				self:linear(0.1)
				:diffusealpha((param.HealthState == 'HealthState_Danger') and 0.5 or 0)
			end
		end
	},
	Guide;
}

local function FilterUpdate(self)
	local song = GAMESTATE:GetCurrentSong();
	if song then


		local start = song:GetFirstBeat();
		local last = song:GetLastBeat();
		
		if (GAMESTATE:GetSongBeat() >= last) then
			self:visible(false);
		elseif (GAMESTATE:GetSongBeat() >= start-16) then
			self:visible(true);
		else
			self:visible(false);
		end;


	end;
end;

args.InitCommand=function(s) s:SetUpdateFunction(FilterUpdate) end

return Def.ActorFrame(args)
