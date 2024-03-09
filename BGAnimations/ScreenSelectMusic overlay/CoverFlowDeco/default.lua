local wt = ThemePrefs.Get("WheelType")
local SongAttributes = LoadModule "SongAttributes.lua"
local jk = LoadModule"Jacket.lua"

local t = Def.ActorFrame{};

local SongInfo = Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx,_screen.cy+76):diffusealpha(0) end,
    OnCommand=function(s) s:addy(40):sleep(0.4):decelerate(0.4):addy(-40):diffusealpha(1) end,
    OffCommand=function(s) s:sleep(0.1):accelerate(0.2):addy(40):diffusealpha(0) end,
    CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
    ChangedLanguageDisplayMessageCommand = function(s) s:playcommand("Set") end,
    SetCommand=function(s)
        local song = GAMESTATE:GetCurrentSong()
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        local so = GAMESTATE:GetSortOrder()
        if not mw then return end
        local title = s:GetChild("Title")
        local artist = s:GetChild("Artist")
        local banner = s:GetChild("Banner")

        title:finishtweening():diffusealpha(0):x(-20):decelerate(0.25):x(0):diffusealpha(1)
        artist:finishtweening():diffusealpha(0):x(20):decelerate(0.25):x(0):diffusealpha(1)
        banner:finishtweening()

        if song then
            title:visible(true):settext(song:GetDisplayFullTitle()):diffuse(SongAttributes.GetMenuColor(song)):y(-6):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
            artist:visible(true):settext(song:GetDisplayArtist()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
            banner:Load(jk.GetSongGraphicPath(song,"Banner"))
        elseif mw:GetSelectedType('WheelItemDataType_Section') then
            if mw:GetSelectedSection() == "" then
              banner:Load(THEME:GetPathG("","_banners/Random"))
            end
            if mw:GetSelectedSection() ~= "" then
              title:visible(true):settext(SongAttributes.GetGroupName(mw:GetSelectedSection())):y(6):diffuse(SongAttributes.GetGroupColor(mw:GetSelectedSection())):strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(mw:GetSelectedSection())))
              artist:settext(""):visible(false)
              banner:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Banner",so))
            else
              title:settext(""):visible(false)
              artist:settext(""):visible(false)
              banner:Load(THEME:GetPathG("","Common fallback banner"));
            end
        end
        banner:scaletofit(-205,-75,205,75):y(20)
    end,
    Def.Sprite{
        Texture=THEME:GetPathG("","_shared/mask_titlebox"),
        InitCommand=function(s) s:MaskSource() end,
    };
    Def.Sprite{
        Name="Banner",
        InitCommand=function(s) s:MaskDest():ztestmode('ZTestMode_WriteOnFail'):blend(Blend.Add):diffusealpha(0.5) end,
    };
    Def.Sprite{
        Texture=THEME:GetPathG("","_shared/titlebox"),
    };
    Def.BitmapText{
        Name="Title";
        Font="_avenirnext lt pro bold/20px";
        InitCommand=function(s) s:maxwidth(400) end,
    };
    Def.BitmapText{
        Name="Artist",
        Font="_avenirnext lt pro bold/20px";
        InitCommand=function(s) s:y(20):maxwidth(400) end,
    };
};

local Arrows = Def.ActorFrame{};
for i=1,2 do
    Arrows[#Arrows+1] = Def.ActorFrame{
		Name="Arrow";
		InitCommand=function(s) s:xy(i==1 and _screen.cx-240 or _screen.cx+240,_screen.cy-156):rotationy(i==1 and 0 or 180):zoom(0.9) end,
		OnCommand=function(s)
			s:diffusealpha(0):addx(i==1 and -100 or 100)
			:sleep(0.6):decelerate(0.3):addx(i==1 and 100 or -100):diffusealpha(1)
		end,
        CurrentSongChangedMessageCommand=function(s)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
                    s:bounce():effectmagnitude(i==2 and -10 or 10,0,0):effectperiod(0.5):effectclock("music")
                else
                    s:bounce():effectmagnitude(i==2 and -10 or 10,0,0):effectoffset(0.2):effectclock("beatnooffset")
                end
            else
                s:bounce():effectmagnitude(i==2 and -10 or 10,0,0):effectperiod(1):effectclock("music")
            end
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
		quadButton(1)..{
			InitCommand=function(s) s:setsize(60,60):visible(false) end,
			TopPressedCommand=function(s)
				SOUND:PlayOnce(THEME:GetPathS("",""..ThemePrefs.Get("WheelType").."_MusicWheel change"))
				local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
				if i==2 then
					s:queuecommand("NextSong")
					mw:Move(1)
					mw:Move(0)
				else
					mw:Move(-1)
					mw:Move(0)
				end
			end,
		};
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

if not GAMESTATE:IsCourseMode() then
    if not GAMESTATE:IsAnExtraStage() then
        t[#t+1] = StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
            InitCommand=function(s)
                s:xy(_screen.cx,SCREEN_TOP+104)
            end,
        };
    end
    t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/CoverFlowDeco/Difficulty"))();
    for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
        if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
            t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/InfoPanel"))(pn)..{
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
        t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_ShockArrow/default.lua"))(pn)..{
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

return Def.ActorFrame{
    SongUnchosenMessageCommand=function(s) 
		s:sleep(0.2):queuecommand("Remove")
	end,
    RemoveCommand=function(s) s:RemoveChild("TwoPartDiff") end,
	SongChosenMessageCommand=function(self)
		--self:AddChildFromPath(THEME:GetPathB("ScreenSelectMusic","overlay/TwoPartDiff"));
	end;
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
        OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
		end
    },
    SongInfo;
    Arrows;
    t;
    LoadActor("../TwoPartDiff")
}
