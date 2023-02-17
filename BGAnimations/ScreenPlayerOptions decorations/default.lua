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

local t = Def.ActorFrame{
	Def.Quad{
		Condition=Var"LoadingScreen" == "ScreenPlayerOptionsPopup",
		InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0)) end,
		OnCommand=function(s) s:smooth(0.3):diffusealpha(0.5) end,
		OffCommand=function(s) s:smooth(0.3):diffusealpha(0) end,
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
	OffCommand=function(s) s:accelerate(0.2):addy(-SCREEN_HEIGHT) end,
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
	    	MenuLeftP1MessageCommand=function(s) 
				if pn == PLAYER_1 then
					s:playcommand("Set")
				end
			end,
			MenuRightP1MessageCommand=function(s) 
				if pn == PLAYER_1 then
					s:playcommand("Set")
				end
			end,
			MenuLeftP2MessageCommand=function(s) 
				if pn == PLAYER_2 then
					s:playcommand("Set")
				end
			end,
			MenuRightP2MessageCommand=function(s) 
				if pn == PLAYER_2 then
					s:playcommand("Set")
				end
			end,
	    	ChangeRowMessageCommand=function(s,param)
        	    if param.PlayerNumber == pn then s:playcommand "Set"; end;
        	end;
	  	};
	};
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