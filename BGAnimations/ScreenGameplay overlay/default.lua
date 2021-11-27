local t = Def.ActorFrame{};

for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = Def.ActorFrame{
		loadfile(THEME:GetPathB("ScreenGameplay","overlay/FullCombo"))(pn)..{
			InitCommand=function(s) s:x(ScreenGameplay_X(pn)) end,
		};
		Def.Sprite{
			Texture="GO"..ToEnumShortString(pn);
			InitCommand=function(s) s:visible(false):xy(ScreenGameplay_X(pn),_screen.cy) end,
			BobCommand=function(s) s:bob():effectmagnitude(0,10,0):effectperiod(1) end,
			HealthStateChangedMessageCommand= function(self, param)
				if param.PlayerNumber == pn then
				if param.HealthState == 'HealthState_Dead' then
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

