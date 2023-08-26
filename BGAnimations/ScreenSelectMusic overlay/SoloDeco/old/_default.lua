local SongAttributes = LoadModule "SongAttributes.lua"

local ex = ""
if GAMESTATE:IsAnExtraStage() then
  ex = "ex_"
end

local jk = LoadModule "Jacket.lua"

local Center = Def.ActorFrame{};
--Center Song Marker
if IsUsingWideScreen() then
for i=1,2 do
    Center[#Center+1] = Def.ActorFrame{
        Name="CenterMark",
        Def.Sprite{
            Texture=ex.."center",
            InitCommand=function(s) s:halign(0)
                if i==1 then
                    s:x(IsUsingWideScreen() and SCREEN_LEFT+87 or SCREEN_LEFT+120)
                else
                    s:x(IsUsingWideScreen() and SCREEN_RIGHT-87 or SCREEN_RIGHT-120)
                end
                s:y(_screen.cy-5.2):rotationz(i==2 and 180 or 0)
                :addx(i==1 and -740 or 740)
            end,
            OnCommand=function(s) s:decelerate(0.4)
                if IsUsingWideScreen() then
                    s:addx(i==1 and 740 or -740):cropleft(i==2 and 0.564 or 0)
                else
                    s:addx(i==1 and 644 or -644):cropleft(i==2 and 0.83 or 0)
                end
            end,
            OffCommand=function(s) s:sleep(0.2):decelerate(0.4):addx(i==1 and -740 or 740) end,
            CurrentSongChangedMessageCommand=function(s)
                s:finishtweening()
                if IsUsingWideScreen() then
                    s:addx(i==1 and -40 or 40):cropleft(i==2 and 0.625 or 0):sleep(0.3):decelerate(0.2):addx(i==1 and 40 or -40):cropleft(i==2 and 0.564 or 0)
                else
                    s:addx(i==1 and -40 or 40):cropleft(i==2 and 0.625 or 0):sleep(0.3):decelerate(0.2):addx(i==1 and 40 or -40):cropleft(i==2 and 0.564 or 0)
                end
            end,
        }
    }
end
end

local PS = Def.ActorFrame{};

for pn in EnabledPlayers() do
	PS[#PS+1] = Def.ActorFrame{
		InitCommand=function(s) s:xy(pn==PLAYER_1 and (IsUsingWideScreen() and _screen.cx-630 or _screen.cx-460) or (IsUsingWideScreen() and _screen.cx+630 or _screen.cx+460),_screen.cy+336):zoom(0) end,
		OnCommand=function(s) s:sleep(0.3):bounceend(0.25):zoom(0.75) end,
		OffCommand=function(s) s:sleep(0.5):bouncebegin(0.25):zoom(0) end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
		["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
		Def.Sprite{
			Texture="../DefaultDeco/RadarBase.png",
			InitCommand=function(s) s:y(10):blend(Blend.Add):zoom(1.35):diffuse(ColorMidTone(PlayerColor(pn))):diffusealpha(0.75) end,
		};
        create_ddr_groove_radar("radar",0,20,pn,350,Alpha(PlayerColor(pn),0.25));
        LoadActor(THEME:GetPathB("ScreenSelectMusic","overlay/_ShockArrow/default.lua"),pn)..{
            InitCommand=function(s)
                s:zoom(0.6):xy(pn==PLAYER_1 and -260 or 260,130)
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
            OffCommand=function(s) s:queuecommand("Hide") end,	
        };
		Def.BitmapText{
			Font="_avenirnext lt pro bold/42px",
			InitCommand=function(s) s:shadowlengthy(5):y(-180) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() then
					if GAMESTATE:GetCurrentSteps(pn) then
						s:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())))
						s:diffuse(CustomDifficultyToColor(ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())))
					end
				else
					s:settext("")
				end
			end,
		};
		Def.BitmapText{
			Font="ScreenSelectMusic difficulty",
			InitCommand=function(s) s:zoom(1):y(20):shadowlengthy(5) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() then
					s:settext(GAMESTATE:GetCurrentSteps(pn) and GAMESTATE:GetCurrentSteps(pn):GetMeter() or "")
				else
					s:settext("")
				end
			end,
		};
		Def.BitmapText{
			Font="CFBPMDisplay",
			InitCommand=function(s) s:y(150):diffuse(color("#dff0ff")):strokecolor(color("#00baff")) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() then
					if GAMESTATE:GetCurrentSteps(pn) then
						if GAMESTATE:GetCurrentSteps(pn):GetAuthorCredit() ~= "" then
							s:settext(GAMESTATE:GetCurrentSteps(pn):GetAuthorCredit())
						else
							s:settext("???")
						end
					else
						s:settext("")
					end
				else
					s:settext("")
				end
			end,
		};
	}

	for diff in ivalues(Difficulty) do
		PS[#PS+1] = Def.ActorFrame{
			InitCommand=function(s) s:y((Difficulty:Reverse()[diff]*46)+(_screen.cy+200)):x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6):addx(pn==PLAYER_1 and -100 or 100) end,
			OnCommand=function(s) s:sleep(0.3):decelerate(0.25):addx(pn==PLAYER_1 and 100 or -100) end,
			OffCommand=function(s) s:sleep(0.5):decelerate(0.25):addx(pn==PLAYER_1 and -100 or 100) end,
			CurrentSongChangedMessageCommand=function(s) s:finishtweening():queuecommand("Set") end,
			["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:finishtweening():queuecommand("Set") end,
			SetCommand=function(s)
				s:decelerate(0.2)
				local song = GAMESTATE:GetCurrentSong()
				if song then
					local st = GAMESTATE:GetCurrentStyle():GetStepsType()
					if song:GetOneSteps(st,diff) then
						if song:GetOneSteps(st,diff) == GAMESTATE:GetCurrentSteps(pn) then
							s:x(pn==PLAYER_1 and SCREEN_LEFT+20 or SCREEN_RIGHT-20)
						else
							s:x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
						end
					else
						s:x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
					end
				else
					s:x(pn==PLAYER_1 and SCREEN_LEFT+6 or SCREEN_RIGHT-6)
				end
			end,
			Def.Quad{
				InitCommand=function(s) s:setsize(5,36):diffuse(CustomDifficultyToColor(ToEnumShortString(diff))):x(pn==PLAYER_1 and 4 or -4) end,
			},
			Def.BitmapText{
				Font="_avenirnext lt pro bold/25px",
				InitCommand=function(s) s:x(pn==PLAYER_1 and 14 or -14):diffuse(Color.Black):strokecolor(color("#dedede")):halign(pn==PLAYER_1 and 0 or 1) end,
				SetCommand=function(s)
					local song = GAMESTATE:GetCurrentSong()
					if song then
						local st = GAMESTATE:GetCurrentStyle():GetStepsType()
						if song:GetOneSteps(st,diff) then
							s:settext(song:GetOneSteps(st,diff):GetMeter())
						else
							s:settext("")
						end
					else
						s:settext("")
					end
				end,
			};
		}
	end
	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
		PS[#PS+1] = LoadActor("../InfoPanel",pn)..{
			InitCommand=function(s) s:visible(false):y(_screen.cy+320):zoom(0.8):addx(pn==PLAYER_1 and 80 or -80) end,
		};
	end
end

return Def.ActorFrame{
    Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            mw:xy(SCREEN_RIGHT-500,_screen.cy):zoom(1.3)
            SCREENMAN:GetTopScreen():GetChild("Header"):visible(false)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:fov(60):vanishpoint(_screen.cx,_screen.cy)
			mw:SetDrawByZPosition(true)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:sleep(1):diffusealpha(0)
		end
    };
    OnCommand=function(s)
        local numwh = THEME:GetMetric("MusicWheel","NumWheelItems")+4
		if SCREENMAN:GetTopScreen() then
			local wheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetChild("MusicWheelItem")
			for i=1,numwh do
				local inv = numwh-math.round( (i-numwh/2) )+1
				wheel[i]:rotationx(180):diffusealpha(0)
				:sleep( (i < numwh/2) and i/20 or inv/20 )
				:bounceend(0.25):rotationx(0):diffusealpha(1)
			end
		end
    end;
    OffCommand=function(s)
        local numwh = THEME:GetMetric("MusicWheel","NumWheelItems")+4
		if SCREENMAN:GetTopScreen() then
			local wheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetChild("MusicWheelItem")
			for i=1,numwh do
				local inv = numwh-math.round( (i-numwh/2) )+1
				wheel[i]:sleep( (i < numwh/2) and i/20 or inv/20 )
				:bouncebegin(0.25):rotationx(360):diffusealpha(0)
			end
		end
    end;
    Def.Quad{
        InitCommand=function(s) s:xy(SCREEN_RIGHT-500,_screen.cy):zoom(1.3):setsize(473,100):skewx(-0.5):diffusealpha(0):blend(Blend.Add)
            :fadeleft(0.5)
        end,
        OnCommand=function(s)
            local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            if not mw then return end
            local GC = SongAttributes.GetGroupColor(mw:GetSelectedSection())
            s:sleep(0.4):decelerate(0.5):diffusealpha(1)
            :diffuseshift():effectcolor1(Alpha(GC,0)):effectcolor2(Alpha(GC,0.5))
            :effectperiod(2)
        end,
        OffCommand=function(s) s:stopeffect():finishtweening():linear(0.1):diffusealpha(0) end,
        CurrentSongChangedMessageCommand=function(s) s:finishtweening():stopeffect():diffusealpha(0):sleep(0.3):queuecommand("On") end,
    };
    Def.ActorFrame{
        InitCommand=function(s) s:diffusealpha(0) end,
        OnCommand=function(s) s:sleep(0.2):diffusealpha(0.5):sleep(0.1):diffusealpha(0):sleep(0.12):diffusealpha(0.2):linear(0.2):diffusealpha(1) end,
        OffCommand=function(s) s:diffusealpha(0):sleep(0.1):diffusealpha(0.5):sleep(0.1):diffusealpha(0):sleep(0.12):diffusealpha(1):linear(0.2):diffusealpha(0) end,
        Def.Sprite{
            Name="Header",
            Texture="SELECT MUSIC.png",
            InitCommand=function(s) s:align(0,0):xy(SCREEN_LEFT+16,SCREEN_TOP+16):zoom(IsUsingWideScreen() and 1 or 0.8) end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold/46px",
            Name="Stage";
            InitCommand=function(s) s:align(0,0):xy(SCREEN_LEFT+30,SCREEN_TOP+100):diffusecolor(color("#e6ffff")) end,
            Text=THEME:GetString("Stage",ToEnumShortString(GAMESTATE:GetCurrentStage())).." STAGE",
        };
    };
    --[[Def.ActorFrame{
        InitCommand=function(s) s:xy(SCREEN_RIGHT,_screen.cy-16):addx(680) end,
        OnCommand=function(s) s:sleep(0.5):decelerate(0.4):addx(-680) end,
        OffCommand=function(s) s:sleep(0.2):decelerate(0.2):addx(460) end,
        CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
        Def.Sprite{
            Texture=ex.."info",
            InitCommand=function(s) s:halign(1) end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold/25px",
            InitCommand=function(s) s:halign(0):xy(-350,-26):maxwidth(300):zoom(1.1) end,
            SetCommand=function(s)
                local song = GAMESTATE:GetCurrentSong()
                local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
                local so = GAMESTATE:GetSortOrder()
                local text = ""
                if not mw then return end
                if song then
                    text = song:GetDisplayMainTitle()
                elseif mw:GetSelectedType('WheelItemDataType_Section') then
                    local group = mw:GetSelectedSection()
                    if group then
                        if so == "SortOrder_Group" then
                            text = SongAttributes.GetGroupName(group)
                        end
                    end
                end
                s:settext(text)
            end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold/25px",
            InitCommand=function(s) s:halign(0):xy(-350,6):maxwidth(300):zoom(1.1) end,
            SetCommand=function(s)
                local song = GAMESTATE:GetCurrentSong()
                if song then
                    s:settext(song:GetDisplayArtist())
                else
                    s:settext("")
                end
            end,
        };
        LoadActor("../DefaultDeco/BPM.lua",0)..{
            InitCommand=function(s) s:xy(-350,40):zoom(1.1) end,
        }
    };]]
    Def.ActorFrame{
        Name="Jacket",
        InitCommand=function(s) s:xy(SCREEN_LEFT+222,_screen.cy-110):addx(-440) end,
        OnCommand=function(s) s:sleep(0.4):decelerate(0.2):addx(440) end,
        OffCommand=function(s) s:decelerate(0.2):addx(-440) end,
        CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
        Def.Sprite{
            Texture=ex.."jacket",
        };
        Def.ActorFrame{
            Def.Sprite{
                SetCommand=function(s)
                    local song = GAMESTATE:GetCurrentSong()
                    local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
                    if not mw then return end
                    if song then
                        s:Load(jk.GetSongGraphicPath(song,"Jacket"))
                    elseif mw:GetSelectedType('WheelItemDataType_Section') then
                        if mw:GetSelectedSection() == "" then
                            s:Load(THEME:GetPathG("","_jackets/Random"))
                        else
                            s:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Jacket",GAMESTATE:GetSortOrder()))
                        end
                    else
                        s:Load( THEME:GetPathG("","MusicWheelItem fallback") );
                    end;
                    s:zoomto(374,374);
                end;
            };
            Def.Sprite{
                SetCommand=function(s)
                    local song = GAMESTATE:GetCurrentSong()
                    local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
                    if not song and mw then
                        if mw:GetSelectedType() == 'WheelItemDataType_Custom' then
                            s:Load(THEME:GetPathG("","_jackets/COURSE"))
                            s:visible(true)
                        else
                            s:visible(false)
                        end;
                    else
                        s:visible(false)
                    end;
                    s:zoomto(378,378);
                end;
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/46px",
                InitCommand=function(s) s:y(-20):zoom(1.5):diffusealpha(1):maxwidth(200):diffusebottomedge(color("#d8d8d8")):diffusetopedge(color("#8c8c8c")):strokecolor(Color.Black) end,
                SetMessageCommand=function(self,params)
                  local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
                  local so = GAMESTATE:GetSortOrder();
                  if mw and  mw:GetSelectedType() == "WheelItemDataType_Section" then
                    local group = mw:GetSelectedSection()
                    if so == "SortOrder_Genre" then
                      self:settext(group)
                    else
                      self:settext("")
                    end;
                  else
                    self:settext("")
                  end
                end,
              };
        };
    };
    PS;
}