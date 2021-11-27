return Def.ActorFrame {
	StorageDevicesChangedMessageCommand=function(self, params)
		MemCardInsert()
	end;
	Def.Sprite{
		Texture="movie.avi",
		InitCommand=function(s) s:zoomtoheight(1080):Center() end,
	};
	Def.Sound{
		Name="BGM";
		File=THEME:GetPathS("_ScreenMovie","music"),
		OnCommand=function(s)
			local AFS = ToEnumShortString(PREFSMAN:GetPreference("AttractSoundFrequency"))
			if AFS ~= "Never" then
				if AFS ~= "EveryTime" then
					if AFS == "2" then
						AttractFreq = AttractFreq+1
						if AttractFreq%2 == 0 then
							s:play()
						end
					elseif AFS == "3" then
						AttractFreq = AttractFreq+1
						if AttractFreq%3 == 0 then
							s:play()
						end
					elseif AFS == "4" then
						AttractFreq = AttractFreq+1
						if AttractFreq%4 == 0 then
							s:play()
						end
					elseif AFS == "5" then
						AttractFreq = AttractFreq+1
						if AttractFreq%5 == 0 then
							s:play()
						end
					else
						s:play()
						AttractFreq = AttractFreq+1
					end
				else
					s:play()
				end
			end
		end
	};
	Def.Quad{
		InitCommand=function(s) s:diffuse(color("0,0,0,1")):FullScreen() end,
		OnCommand=function(s) s:diffusealpha(0):sleep(61):linear(0.75):diffusealpha(1) end,
	};
};
