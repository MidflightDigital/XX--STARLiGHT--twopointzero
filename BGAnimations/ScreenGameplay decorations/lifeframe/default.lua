local pn = ...

local stream = Def.Sprite{
	OnCommand=function(s)
		if GAMESTATE:IsDemonstration() then
			s:setsize(680,51) 
		else
			s:scaletoclipped(656,42):x(pn==PLAYER_1 and -10 or -4)
		end
		s:MaskDest():ztestmode("ZTestMode_WriteOnFail"):customtexturerect(0,0,1,1)
		:texcoordvelocity(pn=="PlayerNumber_P2" and 0.5 or -0.5,0)
	end;
};

local function base_x()
	if pn == PLAYER_1 then
	  if IsUsingWideScreen() then
		return _screen.cx-526
	  else
		return _screen.cx-420
	  end
	elseif pn == PLAYER_2 then
	  if IsUsingWideScreen() then
		return _screen.cx+540
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
		s:xy(base_x(),GAMESTATE:IsDemonstration() and SCREEN_TOP+40 or SCREEN_TOP+69):zoom(IsUsingWideScreen() and 1 or 0.8)
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
	Def.Sprite{
		Name="LifeFrame"..pn,
		InitCommand=function(s) s:x(pn==PLAYER_1 and -10 or -4):rotationy(pn==PLAYER_2 and 180 or 0):visible(not GAMESTATE:IsDemonstration()) end,
		BeginCommand=function(self)
			if GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current'):LifeSetting() == 'LifeType_Battery' then
			  self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/4live.png"))  
			else
				if GAMESTATE:IsCourseMode() then
					local course = GAMESTATE:GetCurrentCourse()
					--[[if course:IsA20DanCourse() then
						self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/class.png"))
					else]]
						self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/normal.png"))
					--end
				else
					self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/normal.png"))
				end
			end;
		end;
	}
}