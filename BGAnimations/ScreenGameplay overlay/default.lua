local t = Def.ActorFrame{};

for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = Def.ActorFrame{
		loadfile(THEME:GetPathB("ScreenGameplay","overlay/FullCombo"))(pn)..{
			InitCommand=function(s) s:x(ScreenGameplay_X(pn)) end,
		};
		Def.Sprite{
			Texture="GO"..ToEnumShortString(pn);
			InitCommand=function(s) s:visible(false):x(ScreenGameplay_X(pn)) end,
			BobCommand=function(s) s:bob():effectmagnitude(0,10,0):effectperiod(1) end,
			HealthStateChangedMessageCommand= function(self, param)
				if param.PlayerNumber == pn then
					if param.HealthState == 'HealthState_Dead' then 
						if GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current'):FailSetting() == 'FailType_Immediate' then
							self:y(_screen.cy)
						else
							--Move the GameOver graphic onto the life bar so it doesn't block the notefield
							self:y(SCREEN_TOP+60):zoom(0.75)
						end
						self:visible(true):rotationz(360):linear(0.2):rotationz(0):queuecommand("Bob")
					end
				end
			end
		};
	};
	t[#t+1] = Def.Sound{
		File="FullCombo/Combo_Splash",
		Name="ComboSplash"..ToEnumShortString(pn),
		SupportPan=true,
	};
end;

return t;

