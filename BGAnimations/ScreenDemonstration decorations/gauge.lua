local pn = ...

local stream = Def.Sprite{
	OnCommand=function(s)
		s:setsize(524,40):x(pn==PLAYER_1 and -10 or -4)
		s:MaskDest():ztestmode("ZTestMode_WriteOnFail"):customtexturerect(0,0,1,1)
		:texcoordvelocity(pn=="PlayerNumber_P2" and 0.5 or -0.5,0)
	end;
};

local function base_x()
	if pn == PLAYER_1 then
	  if IsUsingWideScreen() then
		return _screen.cx-524
	  else
		return _screen.cx-420
	  end
	elseif pn == PLAYER_2 then
	  if IsUsingWideScreen() then
		return _screen.cx+538
	  else
		return _screen.cx+420
	  end
	else
	  error("Pass a valid player number, dingus.",2)
	end
end
return Def.ActorFrame{
    Name="LifeFrame",
	InitCommand=function(s)
		s:xy(base_x(),SCREEN_TOP+38):zoom(IsUsingWideScreen() and 1 or 0.8)
	end,
	--Separating each stream type to prevent lag issues. -Sunny
	stream..{
		Name="normal",
		BeginCommand=function(s) s:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/stream/normal (stretch).png")) end,
		HealthStateChangedMessageCommand=function(self, param)
			if param.PlayerNumber == pn then
				if param.HealthState == "HealthState_Danger" then
						self:visible(false)
				elseif param.HealthState == "HealthState_Hot" then
						self:visible(false)
				else
						self:visible(true)
				end;
			end;
		end;
	};
	stream..{
		Name="hot",
		BeginCommand=function(s) s:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/stream/hot (stretch).png")):visible(false) end,
		HealthStateChangedMessageCommand=function(self, param)
			if param.PlayerNumber == pn then
				if param.HealthState == "HealthState_Danger" then
						self:visible(false)
				elseif param.HealthState == "HealthState_Hot" then
						self:visible(true)
				else
						self:visible(false)
				end;
			end;
		end;
	};
	stream..{
		Name="danger",
		BeginCommand=function(s) s:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/stream/danger (stretch).png")):visible(false) end,
		HealthStateChangedMessageCommand=function(self, param)
			if param.PlayerNumber == pn then
				if param.HealthState == "HealthState_Danger" then
						self:visible(true)
				elseif param.HealthState == "HealthState_Hot" then
						self:visible(false)
				else
						self:visible(false)
				end;
			end;
		end;
	};
}