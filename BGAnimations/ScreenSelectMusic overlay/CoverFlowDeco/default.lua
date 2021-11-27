local wt = ThemePrefs.Get("WheelType")

local t = Def.ActorFrame{
    Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            mw:xy(_screen.cx,_screen.cy-156)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:fov(60):vanishpoint(_screen.cx,_screen.cy-156)
			mw:SetDrawByZPosition(true)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
		end
    }
};
local SongAttributes = LoadModule "SongAttributes.lua"

if not GAMESTATE:IsCourseMode() then
    if not GAMESTATE:IsAnExtraStage() then
        t[#t+1] = StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
            InitCommand=function(s)
                s:xy(_screen.cx,SCREEN_TOP+104)
            end,
        };
    end
    t[#t+1] = Def.ActorFrame{
        InitCommand=function(s) s:xy(_screen.cx,_screen.cy+76):diffusealpha(0) end,
        OnCommand=function(s) s:addy(40):sleep(0.4):decelerate(0.4):addy(-40):diffusealpha(1) end,
        OffCommand=function(s) s:sleep(0.1):accelerate(0.2):addy(40):diffusealpha(0) end,
        CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
        Def.Sprite{
            Texture=THEME:GetPathG("","_shared/titlebox"),
        };
        Def.BitmapText{
            Name="Title";
            Font="_avenirnext lt pro bold 20px";
            SetCommand=function(s)
                s:strokecolor(Alpha(Color.Black,0.5))
                if GAMESTATE:GetCurrentSong() then
                    s:settext(GAMESTATE:GetCurrentSong():GetDisplayFullTitle()):diffuse(SongAttributes.GetMenuColor(GAMESTATE:GetCurrentSong())):maxwidth(400)
                    s:y(-8)
                elseif SCREENMAN:GetTopScreen():GetChild("MusicWheel") then
                    s:y(0)
                    if SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetSelectedType('WheelItemDataType_Section') then
                        s:settext(SongAttributes.GetGroupName(SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetSelectedSection()));
                        s:diffuse(SongAttributes.GetGroupColor(SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetSelectedSection()));
                    end
                end
            end;
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold 20px";
            SetCommand=function(s)
                s:strokecolor(Alpha(Color.Black,0.5))
                local song = GAMESTATE:GetCurrentSong()
                if song then
                    local art=song:GetDisplayArtist()
                    s:settext(art):diffuse(SongAttributes.GetMenuColor(song)):maxwidth(400)
                    s:y(16)
                else
                    s:settext("")
                end
            end;
        };
    };
    for i=1,2 do
        Name="Arrows";
        t[#t+1] = Def.ActorFrame{
            InitCommand=function(s) s:xy(i==1 and _screen.cx-240 or _screen.cx+240,_screen.cy+16):zoomx(i==1 and 1 or -1) end,
            OnCommand=function(s)
                s:diffusealpha(0):addx(i==1 and -100 or 100)
                :sleep(0.6):decelerate(0.3):addx(i==1 and 100 or -100):diffusealpha(1)
                s:bounce():effectclock("beat"):effectperiod(1):effectmagnitude(i==2 and 10 or -10,0,0):effectoffset(0.2)
            end,
            OffCommand=function(s)
                s:finishtweening():accelerate(0.2):addx(i==1 and -100 or 100):diffusealpha(0)
            end,
            NextSongMessageCommand=function(s)
                if i==2 then s:stoptweening():x(_screen.cx+260):decelerate(0.5):x(_screen.cx+240) end
            end, 
            PreviousSongMessageCommand=function(s)
                if i==1 then s:stoptweening():x(_screen.cx-260):decelerate(0.5):x(_screen.cx-240) end
            end, 
            Def.Sprite{ Texture=THEME:GetPathG("","_shared/arrows/base");};
            Def.Sprite{
                Texture=THEME:GetPathG("","_shared/arrows/color");
                InitCommand=function(s) s:diffuse(color("#00f0ff")) end,
                NextSongMessageCommand=function(s)
                    if i==2 then
                        s:stoptweening():diffuse(color("#ff00ea")):sleep(0.5):diffuse(color("#00f0ff"))
                    end
                end, 
                PreviousSongMessageCommand=function(s)
                    if i==1 then
                        s:stoptweening():diffuse(color("#ff00ea")):sleep(0.5):diffuse(color("#00f0ff"))
                    end
                end, 
            };
        };
    end;
    t[#t+1] = LoadActor("Difficulty");
    for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
        if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
            t[#t+1] = LoadActor("../InfoPanel",pn)..{
			    InitCommand=function(s) s:visible(false):y(_screen.cy-200) end,
                CodeMessageCommand=function(s,p)
                    if p.PlayerNumber == pn then
			    	    if p.Name == "OpenPanes1" then
			    	    	s:visible(true)
			    	    end
			    	    if p.Name == "ClosePanes" then
			    	    	s:visible(false)
                        end
                    end
			    end,
            };
        end
        t[#t+1] = LoadActor(THEME:GetPathB("ScreenSelectMusic","overlay/_ShockArrow/default.lua"),pn)..{
            InitCommand=function(s)
                s:xy(pn==PLAYER_1 and _screen.cx-340 or _screen.cx+340,_screen.cy+80):zoom(0.5)
            end,
            SetCommand=function(s)
                local song = GAMESTATE:GetCurrentSong()
                if song then
                    local steps = GAMESTATE:GetCurrentSteps(pn)
                    if steps then
                        if steps:GetRadarValues(pn):GetValue('RadarCategory_Mines') >= 1 then
                            s:queuecommand("Anim")
                        else
                            s:queuecommand("Hide")
                        end
                    else
                        s:queuecommand("Hide")
                    end
                else
                    s:queuecommand("Hide")
                end
            end,
            CurrentSongChangedMessageCommand=function(s) s:stoptweening():queuecommand("Set") end,
            ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
            OffCommand=function(s) s:stoptweening():queuecommand("Hide") end,	
        }
    end
end;

local numwh = THEME:GetMetric("MusicWheelCoverFlow","NumWheelItems")+2
t[#t+1] = Def.Actor{
	OnCommand=function(s)
		if SCREENMAN:GetTopScreen() then
            local wheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetChild("MusicWheelItem")
			for i=1,numwh do
                local inv = numwh-math.floor(i-numwh/2+0.5)+1
                if i == 2 or i == 3 or i == 4 or i == 5 or i == 6 or i == 7 then
					wheel[i]:addx(-SCREEN_WIDTH):sleep(0.3):decelerate(0.4):addx(SCREEN_WIDTH)
				elseif i == 9 or i == 10 or i == 11 or i == 12 or i == 13 or i == 14 then
                    wheel[i]:addx(SCREEN_WIDTH):sleep(0.3):decelerate(0.4):addx(-SCREEN_WIDTH)
                else
                    wheel[i]:zoom(0):sleep(0.3):decelerate(0.4):zoom(1)
				end
            end
		end
    end,
};

t[#t+1] = Def.ActorFrame{
    SongUnchosenMessageCommand=function(s) 
		s:sleep(0.2):queuecommand("Remove")
	end,
    RemoveCommand=function(s) s:RemoveChild("TwoPartDiff") end,
	SongChosenMessageCommand=function(self)
		self:AddChildFromPath(THEME:GetPathB("ScreenSelectMusic","overlay/TwoPartDiff"));
	end;
}

return t;
