local t = Def.ActorFrame{};

for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = Def.ActorFrame{
		loadfile(THEME:GetPathB("ScreenGameplay","overlay/FullCombo"))(pn)..{
			InitCommand=function(s)
				if PREFSMAN:GetPreference("Center1Player") and GAMESTATE:GetNumPlayersEnabled() == 1 then
					s:x(_screen.cx)
				else
					s:x(ScreenGameplay_X(pn))
				end
			end,
		};
		Def.Sprite{
			Condition=GAMESTATE:GetNumPlayersEnabled() == 2 and GAMESTATE:PlayerIsUsingModifier(pn,'battery'),
			Texture="GO"..ToEnumShortString(pn);
			InitCommand=function(s) s:visible(false) end,
			BobCommand=function(s) s:bob():effectmagnitude(0,10,0):effectperiod(1) end,
			HealthStateChangedMessageCommand= function(self, param)
				if param.PlayerNumber == pn then
					if param.HealthState == 'HealthState_Dead' then 
						if GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current'):FailSetting() == 'FailType_Immediate' then
							--can't use px due to the placement switching we have going on.
							if PREFSMAN:GetPreference("Center1Player") and GAMESTATE:GetNumPlayersEnabled() == 1 then
								self:x(_screen.cx)
							else
								self:x(ScreenGameplay_X(pn))
							end
							self:y(_screen.cy)
						else
							--Move the GameOver graphic onto the life bar so it doesn't block the notefield
							--Since it now displays over the lifebar, we force it to always use ScreenGameplay_X so it displays over the lifebar no matter what.
							self:xy(ScreenGameplay_X(pn),SCREEN_TOP+60):zoom(0.75)
						end
						self:visible(true):rotationz(360):linear(0.2):rotationz(0):queuecommand("Bob")
					end
				end
			end,
			NextCourseSongDelayMessageCommand=function(s)
				s:sleep(BeginOutDelay()):linear(0.2):diffusealpha(0)
			end,
			OffCommand=function(s)
				s:sleep(BeginOutDelay()):linear(0.2):diffusealpha(0)
			end,
		};
	};
	t[#t+1] = Def.Sound{
		File="FullCombo/Combo_Splash",
		Name="ComboSplash"..ToEnumShortString(pn),
		SupportPan=true,
	};
end;

return t;

