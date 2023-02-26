local pn = ...

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
	Def.Sprite{
		Texture="stream/normal",
		OnCommand=function(s)
			if GAMESTATE:IsCourseMode() then
				local course = GAMESTATE:GetCurrentCourse()
				if course:IsA20DanCourse() then
					s:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/stream/dan (stretch).png"))
				end
			end
			if GAMESTATE:IsDemonstration() then
				s:setsize(680,51) 
			else
				s:scaletoclipped(656,42):x(pn==PLAYER_1 and -10 or -4)
			end
			s:MaskDest():ztestmode("ZTestMode_WriteOnFail"):customtexturerect(0,0,1,1)
			:texcoordvelocity(pn=="PlayerNumber_P2" and 0.5 or -0.5,0)
		end;
		HealthStateChangedMessageCommand=function(self, param)
			if param.PlayerNumber == pn then
				if param.HealthState == "HealthState_Danger" then
					if GAMESTATE:IsCourseMode() then
						local course = GAMESTATE:GetCurrentCourse()
						if course:IsA20DanCourse() then
							self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/stream/dan (stretch).png"))
						end
					else
						self:Load(THEME:GetPathB("","ScreenGameplay decorations/lifeframe/stream/danger (stretch).png"))
					end
				elseif param.HealthState == "HealthState_Hot" then
					if GAMESTATE:IsCourseMode() then
						local course = GAMESTATE:GetCurrentCourse()
						if course:IsA20DanCourse() then
							self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/stream/dan (stretch).png"))
						end
					else
						self:Load(THEME:GetPathB("","ScreenGameplay decorations/lifeframe/stream/hot (stretch).png"))
					end
				else
					if GAMESTATE:IsCourseMode() then
						local course = GAMESTATE:GetCurrentCourse()
						if course:IsA20DanCourse() then
							self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/stream/dan (stretch).png"))
						end
					else
						self:Load(THEME:GetPathB("","ScreenGameplay decorations/lifeframe/stream/normal (stretch).png"))
					end
				end;
		  		self:scaletoclipped(656,42)
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
					if course:IsA20DanCourse() then
						self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/class.png"))
					else
						self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/normal.png"))
					end
				else
					self:Load(THEME:GetPathB("ScreenGameplay","decorations/lifeframe/normal.png"))
				end
			end;
		end;
	}
}