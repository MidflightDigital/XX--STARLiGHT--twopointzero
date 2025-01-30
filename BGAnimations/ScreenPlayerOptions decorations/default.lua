SOUND:DimMusic(1,math.huge)
local num_players = GAMESTATE:GetHumanPlayers()

function setting(self,screen,pn)
	local index = screen:GetCurrentRowIndex(pn);
	local row = screen:GetOptionRow(index);
	local name = row:GetName();
	local choice = row:GetChoiceInRowWithFocus(pn);
	if name ~= "Exit" then
		if THEME:GetMetric( "ScreenOptionsMaster",name.."Explanation" ) ~= false then
			self:settext(THEME:GetString("OptionItemExplanations",name..tostring(choice)));
		else self:settext("");
		end;
	end;
end;

local song_bpms= {}
local bpm_text= "??? - ???"
local function format_bpm(bpm)
	return ("%.0f"):format(bpm)
end

local t = Def.ActorFrame{
	Def.Quad{
		Condition=Var"LoadingScreen" == "ScreenPlayerOptionsPopup",
		InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0)):draworder(-11) end,
		OnCommand=function(s) s:smooth(0.3):diffusealpha(0.5) end,
		OffCommand=function(s) 
			s:smooth(0.3):diffusealpha(0)
		end,
	},
}

local bars = Def.ActorFrame{}

for i=1,7 do
	bars[#bars+1] = Def.Quad{
		InitCommand=function(s) s:y(80*i):diffuse(Alpha(Color.White,0.2)):setsize(1276,34) end,
	};
end

t[#t+1] = Def.ActorFrame{
	OnCommand=function(s) s:draworder(-10):addy(SCREEN_HEIGHT):sleep(0.2):decelerate(0.2):addy(-SCREEN_HEIGHT) end,
	OffCommand=function(s) 
		ProfilePrefs.SaveAll()
		s:accelerate(0.2):addy(-SCREEN_HEIGHT)
	end,
	Def.ActorFrame{
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_CENTER_Y-90) end,
		Def.ActorFrame{
			InitCommand=function(s) s:diffusealpha(0.5) end,
			Def.Quad{
				InitCommand=function(s) s:setsize(1280,596):diffuse(Alpha(Color.White,0.25)) end,
			},
			Def.Quad{
				InitCommand=function(s) s:setsize(1276,592):diffuse(Color.Black) end,
			},
			Def.Quad{
				InitCommand=function(s) s:setsize(1276,592):diffuse(Color.Black) end,
			},
		},
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenOptionsService","decorations/DialogTop"),
			InitCommand=function(s) s:y(-320) end,
		};
		bars..{
			InitCommand=function(s) s:y(-342) end,
		}
	};
};

for _,pn in ipairs(GAMESTATE:GetHumanPlayers()) do
	local function p(text)
		return text:gsub("%%", ToEnumShortString(pn));
	end
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s) s:xy(pn == PLAYER_1 and _screen.cx-320 or _screen.cx+320,SCREEN_BOTTOM-100) end,
		OnCommand=function(s) s:diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):linear(0.05):diffusealpha(1) end,
		OffCommand=function(s) s:diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05) end,
		Def.Sprite{
			Texture="exp.png",
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/25px",
	    	InitCommand=function(s) s:y(-6):maxwidth(400):zoom(1.3) end,
			BeginCommand=function(s) s:queuecommand("Set") end,
	    	SetCommand=function(self)
	      		local screen = SCREENMAN:GetTopScreen();
	      		if screen then
	        		setting(self,screen,pn);
	      		end;
	    	end;
	    	[p"MenuLeft%MessageCommand"]=function(s) s:playcommand("Set") end,
			[p"MenuRight%MessageCommand"]=function(s) s:playcommand("Set") end,
	    	ChangeRowMessageCommand=function(s,param)
        	    if param.PlayerNumber == pn then s:playcommand "Set"; end;
        	end;
	  	};
	};
	t[#t+1] = Def.BitmapText{
		File="_avenirnext lt pro bold/25px",
		Name="Speed Mod";
		InitCommand=function(s) s:xy(pn == PLAYER_1 and _screen.cx-630 or _screen.cx+630,_screen.cy-400):draworder(-9)
			:uppercase(true):halign(pn == PLAYER_1 and 0 or 1):strokecolor(color("0,0,0,0.25")):diffusealpha(0)
		end,
		OnCommand=function(s) s:sleep(0.4):decelerate(0.2):diffusealpha(1) end,
		OffCommand=function(s) s:accelerate(0.2):diffusealpha(0) end,
		ArbitrarySpeedModsSavedMessageCommand=function(s,p)
			if p.Player == pn then
				s:playcommand("Adjust")
			end
		end,
		AdjustCommand=function(self)
			local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
			local speed= nil
			local mode= nil
			if poptions:MaxScrollBPM() > 0 then
				mode= "M"
				speed= math.round(poptions:MaxScrollBPM())
			elseif poptions:TimeSpacing() > 0 then
				mode= "C"
				speed= math.round(poptions:ScrollBPM())
			elseif poptions:AverageScrollBPM() > 0 then
				mode= "A"
				speed= math.round(poptions:AverageScrollBPM())
			elseif poptions:XMod() > 0 then
				mode= "x"
				speed= math.round(poptions:ScrollSpeed() * 100)
			else
				mode= "what"
				speed= 69
			end
			-- Courses don't have GetDisplayBpms.
			if GAMESTATE:GetCurrentSong() then
				song_bpms= GAMESTATE:GetCurrentSong():GetDisplayBpms()
				song_bpms[1]= math.round(song_bpms[1])
				song_bpms[2]= math.round(song_bpms[2])
				if song_bpms[1] == song_bpms[2] then
					bpm_text= format_bpm(song_bpms[1])
				else
					bpm_text= format_bpm(song_bpms[1]) .. " - " .. format_bpm(song_bpms[2])
				end
			end
			local text= ""
			local no_change= true
			if mode == "x" then
				if not song_bpms[1] then
					text= "??? - ???"
				elseif song_bpms[1] == song_bpms[2] then
					text= "x"..(speed/100).." ("..format_bpm(song_bpms[1] * speed*.01)..")"
				else
					text= "x"..(speed/100).." ("..format_bpm(song_bpms[1] * speed*.01) .. " - " ..
						format_bpm(song_bpms[2] * speed*.01)..")"
				end
				no_change= speed == 100
			elseif mode == "C" then
				text= mode .. speed
				no_change= speed == song_bpms[2] and song_bpms[1] == song_bpms[2]
			elseif mode == "M" then
				no_change= speed == song_bpms[2]
				if song_bpms[1] == song_bpms[2] then
					text= mode .. speed
				else
					local factor= song_bpms[1] / song_bpms[2]
					text= format_bpm(speed * factor) .. " - " .. speed
				end
			elseif mode == "A" then 
				no_change= speed == song_bpms[2]
				if song_bpms[1] == song_bpms[2] then
					text= mode .. speed
				else
					local factor= math.average({song_bpms[1], song_bpms[2]})
					text= speed .. " - " .. format_bpm(factor)
				end
			else
				text = "??? What speed mod are you using? Like. Actually."
			end
			if GAMESTATE:IsCourseMode() then
				if mode == "x" then
					text = "x"..(speed/100)
				else
					text = mode .. speed
				end
				self:settext("Current Velocity: "..text)
			else
				self:settext("Current Velocity: "..text):zoom(1)
			end
		end;
	}
end

t[#t+1] = LoadFallbackB()

--Totally didn't pull this from Outfox default lol -Inori
-- Load all noteskins for the previewer.
local icol = 2
if GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() < 2 then
	icol = 1
end
local column = GAMESTATE:GetCurrentStyle():GetColumnInfo( GAMESTATE:GetMasterPlayerNumber(), icol )
for _,v in pairs(NOTESKIN:GetNoteSkinNames()) do
	local noteskinset = NOTESKIN:LoadActorForNoteSkin( column["Name"] , "Tap Note", v )

	if noteskinset then
		t[#t+1] = noteskinset..{
			Name="NS"..string.lower(v), InitCommand=function(s) s:visible(false) end,
			OnCommand=function(s) s:diffusealpha(0):sleep(0.2):linear(0.2):diffusealpha(1) end,
			OffCommand=function(s) s:linear(0.2):diffusealpha(0) end
		}
	else
		lua.ReportScriptError(string.format("The noteskin %s failed to load.", v))
		t[#t+1] = Def.Actor{ Name="NS"..string.lower(v) }
	end
end


return t