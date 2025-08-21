local pn = ...
local Radar = LoadModule('DDR Groove Radar.lua')
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local ver = ""
if ThemePrefs.Get("SV") == "onepointzero" then
  ver = "1_"
end

local function XPOS(self,offset)
    self:x(pn==PLAYER_1 and (SCREEN_LEFT+240)+offset or (SCREEN_RIGHT-240)+offset)
end

local yspacing = 32
local keyset={}

for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
    if not keyset[pn] then
        keyset[pn] = false
    end
end

local function PlayerPanel()
    local t = Def.ActorFrame{};
t[#t+1] = Def.ActorFrame{
    
    SetCommand=function(s)
        local c = s:GetChildren();
        local song = GAMESTATE:GetCurrentSong() or GAMESTATE:GetCurrentCourse()
        if song then
            local steps = GAMESTATE:GetCurrentSteps(pn) or GAMESTATE:GetCurrentTrail(pn)
            if steps then
                c.Bar_underlay:visible(true)
                c.Text_name:settext(PROFILEMAN:GetProfile(pn):GetDisplayName())

                local profile
                if PROFILEMAN:IsPersistentProfile(pn) then
                    profile = PROFILEMAN:GetProfile(pn)
                else
                    profile = PROFILEMAN:GetMachineProfile()
                end

                local scores = profile:GetHighScoreList(song, steps):GetHighScores()
                assert(scores)
                local score = scores[1]
                
                s:playcommand('SetGrade', { Highscore = score, Steps = steps })
                
                local topscore = 0
                if score then
                    if ThemePrefs.Get("ConvertScoresAndGrades") and false then
                        topscore = SN2Scoring.GetSN2ScoreFromHighScore(steps, score)
                    else
                        topscore = score:GetScore()
                    end
                    RStats = score -- Is this a global? Or just missing a local declaration?
                end
                
                if topscore ~= 0 then
                    local misses = RStats:GetTapNoteScore("TapNoteScore_Miss")+RStats:GetTapNoteScore("TapNoteScore_CheckpointMiss")
                    local boos = RStats:GetTapNoteScore("TapNoteScore_W5")
                    local goods = RStats:GetTapNoteScore("TapNoteScore_W4")
                    local greats = RStats:GetTapNoteScore("TapNoteScore_W3")
                    local perfects = RStats:GetTapNoteScore("TapNoteScore_W2")
                    local marvelous = RStats:GetTapNoteScore("TapNoteScore_W1")
                    for i=1, #scores do
                        -- XXX: What are we trying to do here??
                        if scores[i] then
                            topscore = scores[i];
                            assert(topscore)
                            c.Text_judgmenttitles:diffusealpha(1)
                            c.Text_judgments:settext(topscore:GetTapNoteScore("TapNoteScore_W1").."\n"
                            ..topscore:GetTapNoteScore("TapNoteScore_W2").."\n"
                            ..topscore:GetTapNoteScore("TapNoteScore_W3").."\n"
                            ..topscore:GetTapNoteScore("TapNoteScore_W4").."\n"
                            ..topscore:GetHoldNoteScore("HoldNoteScore_Held").."\n"
                            ..topscore:GetTapNoteScore("TapNoteScore_W5")+topscore:GetTapNoteScore("TapNoteScore_Miss")):diffusealpha(1)
                        else
                            c.Text_judgments:settext("0\n0\n0\n0\n0\n0")
                        end;
                    end;
                else
                    c.Text_score:settext("")
                    c.Text_judgments:settext("0\n0\n0\n0\n0\n0")
                end
            end
        else
            c.Text_score:settext("")
            c.Text_judgments:settext("0\n0\n0\n0\n0\n0")
        end
    end,
    Def.Sprite{
        Name="Bar_underlay",
        Texture="playerbacker",
        InitCommand=function(s) s:y(-20) end,
    };
    Def.BitmapText{
        Font="Common normal",
        Text="";
        Name="Text_name",
        InitCommand=function(s) s:y(-34):maxwidth(300/0.8):zoom(0.8) end,
    };
    ScoreAndGrade.GetScoreActorRolling{
        Font = '_avenirnext lt pro bold/25px',
        Load = 'RollingNumbersSongData',
    }..{
        Name='Text_score',
        InitCommand=function(s) s:xy(0,-6):zoom(0.9) end,
    },
    LoadActor(THEME:GetPathG("","myMusicWheel/default.lua"),pn,1,"Player","Current",diff)..{
        InitCommand=function(s) s:xy(40,-6) end,
    },
    Def.BitmapText{
        Font="Common normal",
        Name="Text_judgmenttitles",
        InitCommand=function(s) s:zoom(0.9):halign(0):addx(-140):addy(80) end,
        OnCommand=function(s) s:settext("Marvelous\nPerfect\nGreat\nGood\nOK\nMiss") end,
    };
    Def.BitmapText{
        Font="Common normal",
        Name="Text_judgments";
        InitCommand=function(s) s:zoom(0.9):halign(1):addx(120):addy(80) end,
    };
}
return t
end

local difficulties = {"Difficulty_Beginner", "Difficulty_Easy", "Difficulty_Medium", "Difficulty_Hard", "Difficulty_Challenge", "Difficulty_Edit"}


local function DifficultyPanel()
    local t = Def.ActorFrame{};
    for diff in ivalues(difficulties) do
        t[#t+1] = Def.ActorFrame{
            InitCommand=function(s) s:y((Difficulty:Reverse()[diff] * yspacing)) end,
            SetCommand=function(s)
                local c = s:GetChildren()
                local song = GAMESTATE:GetCurrentSong() or GAMESTATE:GetCurrentCourse()
                local bHasStepsTypeAndDifficulty = false;
                local curDiff;
                local steps;
                if song then
                    local st = GAMESTATE:GetCurrentStyle():GetStepsType()
                    if not GAMESTATE:IsCourseMode() then
                        bHasStepsTypeAndDifficulty = song:HasStepsTypeAndDifficulty(st, diff)
                        steps = song:GetOneSteps(st,diff)
                    else
                        steps = GAMESTATE:GetCurrentTrail(pn)
                    end
                    if steps then
                        if not GAMESTATE:IsCourseMode() then
                            local meter = steps:GetMeter()
                            c.Text_meter:settext(IsMeterDec(meter))
                            c.Text_meter:visible(true)
                        end
                        c.Text_difficulty:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff))):visible(true)
                        c.Text_difficulty:diffuse(CustomDifficultyToColor(diff))
                        local cursteps = GAMESTATE:GetCurrentSteps(pn) or GAMESTATE:GetCurrentTrail(player)
                        if cursteps then
                            curDiff = cursteps:GetDifficulty(pn)
                            if ToEnumShortString(curDiff) == ToEnumShortString(diff) then
                                c.Bar_underlay:diffuse(CustomDifficultyToColor(diff))
                            else
                                c.Bar_underlay:diffuse(Color.White)
                            end
                        end
                        scorelist = PROFILEMAN:GetProfile(pn):GetHighScoreList(song,steps)
                        assert(scorelist)
                        local scores = scorelist:GetHighScores()
                        assert(scores)
                        local topscore=0
                        local temp=#scores
                        if scores[1] then
                            if ThemePrefs.Get("ConvertScoresAndGrades") then
                                topscore = SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[1])
                            else
                                topscore = scores[1]:GetScore()
                            end
                            RStats = scores[1];
                        end
                        assert(topscore)
                        if topscore ~= 0 then
                            c.Text_score:settext(commify(topscore))
                        else
                            c.Text_score:settext("")
                        end
                    else
                        c.Bar_underlay:diffuse(Alpha(Color.White,0.2))
                        c.Text_meter:settext("")  
                        c.Text_difficulty:settext("")
                        c.Text_score:settext("")
                    end
                else
                    c.Bar_underlay:diffuse(Alpha(Color.White,0.2))
                    c.Text_meter:settext("")
                    c.Text_difficulty:settext("")
                    c.Text_score:settext("")
                end
            end;
            Def.ActorFrame{
                Name="Bar_underlay";
                Def.Quad{
                    InitCommand=function(s) s:setsize(312,26):faderight(0.75):diffusealpha(0.5) end,
                };
                Def.Quad{
                    InitCommand=function(s) s:y(-12):setsize(312,2):faderight(0.5):diffusealpha(0.5) end,
                };
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/25px",
                Name="Text_meter";
                InitCommand=function(s) s:x(-6):strokecolor(Alpha(Color.Black,0.5)) end,
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/20px",
                Name="Text_difficulty",
                InitCommand=function(s) s:x(-150):halign(0):strokecolor(Alpha(Color.Black,0.5)) end,
            };
            Def.BitmapText{
                Name="Text_score",
                Font="_avenirnext lt pro bold/20px",
                InitCommand=function(s) s:x(120):halign(1):diffuse(Color.White):strokecolor(Color.Black) end,
            };
            LoadActor(THEME:GetPathG("","myMusicWheel/default.lua"),pn,1,"Player","One",diff)..{
                InitCommand=function(s) s:x(146) end,
            }
        };
    end
    return t
end

local function RivalsPanel(rival)
    local t = Def.ActorFrame{};
    local rivals = {1,2,3,4,5}
    for rival in ivalues(rivals) do
        t[#t+1] = Def.ActorFrame{
            InitCommand=function(s) s:y((rivals[rival]*yspacing)-yspacing) end,
            SetCommand=function(s)
                local c = s:GetChildren();
                local song = GAMESTATE:GetCurrentSong()
                if song then
                    local steps = GAMESTATE:GetCurrentSteps(pn)
                    if steps then
                        c.Bar_underlay:visible(true)
                        if rival == 1 then
                            c.Bar_place:diffuse(color("#3cbbf6"))
                        elseif rival == 2 then
                            c.Bar_place:diffuse(color("#d6d7d4"))
                        elseif rival == 3 then
                            c.Bar_place:diffuse(color("#f6cc40"))
                        else
                            c.Bar_place:diffuse(color("#f22133"))
                        end
                    end
                    local profile = PROFILEMAN:GetMachineProfile();
                    scorelist = PROFILEMAN:GetMachineProfile():GetHighScoreList(song,steps)
                    local scores = scorelist:GetHighScores()
                    local topscore = 0
                    if scores[rival] then
                        if ThemePrefs.Get("ConvertScoresAndGrades") then
                            topscore = SN2Scoring.GetSN2ScoreFromHighScore(steps, scores[rival])
                        else
                            topscore = scores[rival]:GetScore()
                        end
                    end
                    RStats = scores[1];
                    if topscore ~= 0 then
                        c.Bar_underlay:diffuse(Color.White)
                        c.Text_score:settext(commify(topscore))
                        if scores[rival]:GetName() ~= nil then
                            if scores[rival]:GetName() == "" then
                                c.Text_name:settext("NO NAME")
                            else
                                c.Text_name:settext(scores[rival]:GetName())
                            end
                        else
                            c.Text_name:settext("STEP")
                        end
                    else
                        c.Bar_underlay:diffuse(Alpha(Color.White,0.2))
                        c.Text_score:settext("")
                        c.Text_name:settext("")
                    end
                else
                    c.Bar_underlay:diffuse(Alpha(Color.White,0.2))
                    c.Text_score:settext("")
                    c.Text_name:settext("")
                end
            end,
            Def.ActorFrame{
                Name="Bar_underlay";
                Def.Quad{
                    InitCommand=function(s) s:setsize(312,26):faderight(0.75):diffusealpha(0.5) end,
                };
                Def.Quad{
                    InitCommand=function(s) s:y(-12):setsize(312,2):faderight(0.5):diffusealpha(0.5) end,
                };
            };
            Def.Quad{
                Name="Bar_place",
                InitCommand=function(s) s:x(-140):setsize(20,20) end,
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/25px",
                Name="Text_place";
                Text=rival;
                InitCommand=function(s) s:x(-140):strokecolor(Alpha(Color.Black,0.5)):zoom(0.7) end,
            };
            Def.BitmapText{
                Name="Text_name",
                Font="_avenirnext lt pro bold/20px",
                InitCommand=function(s) s:x(-120):halign(0):diffuse(Color.White):strokecolor(Color.Black) end,
            };
            Def.BitmapText{
                Name="Text_score",
                Font="_avenirnext lt pro bold/20px",
                InitCommand=function(s) s:x(120):halign(1):diffuse(Color.White):strokecolor(Color.Black) end,
            };
            LoadActor(THEME:GetPathG("","myMusicWheel/default.lua"),pn,rival,"Machine","Current",diff)..{
                InitCommand=function(s) s:x(146) end,
            }
        }
    end
    return t
end

local function RadarPanel()
    local GR = {
        {-1,-122, "Stream"}, --STREAM
        {-120,-43, "Voltage"}, --VOLTAGE
        {-108,72, "Air"}, --AIR
        {108,72, "Freeze"}, --FREEZE
        {120,-43, "Chaos"}, --CHAOS
    };
    local t = Def.ActorFrame{};
    t[#t+1] = Def.ActorFrame{
        Def.ActorFrame{
            Name="Radar",
            Def.Sprite{
                Texture=THEME:GetPathG("","_shared/Radar/"..ver.."GrooveRadar base.png"),
            };
            Def.Sprite{
                Texture=THEME:GetPathG("","_shared/Radar/sweep.png"),
                InitCommand = function(s) s:zoom(1.35):spin():effectmagnitude(0,0,100) end,
            };
            Radar.create_ddr_groove_radar("radar",0,0,pn,125,Alpha(PlayerColor(pn),0.25));
        };
    };
    for i,v in ipairs(GR) do
        t[#t+1] = Def.ActorFrame{
            InitCommand=function(s)
                s:xy(v[1],v[2])
            end;
            Def.Sprite{
                Texture=THEME:GetPathG("","_shared/Radar/"..ver.."RLabels"),
                OnCommand=function(s) s:animate(0):setstate(i-1) end,
            };
            Def.BitmapText{
                Font="_avenirnext lt pro bold/20px";
                SetCommand=function(s)
                    local song = GAMESTATE:GetCurrentSong();
                    if song then
                        local steps = GAMESTATE:GetCurrentSteps(pn)
                        local value = lookup_ddr_radar_values(song, steps, pn)[i]
                        s:settext(math.floor(value*100+0.5))
                    else
                        s:settext("")
                    end
                    s:strokecolor(color("#1f1f1f")):y(28)
                end,
            };
        };
    end
    return t
end

local function PlayerInfo(pn)
    local t = Def.ActorFrame{};
    t[#t+1] = PlayerPanel()..{
        InitCommand=function(s) s:valign(1):y(-20) end
    };
    return t
end

local function Scroller(pn)
    local t = Def.ActorFrame{};
    t[#t+1] = Def.ActorScroller{
        Name="ScrollerMain",
        NumItemsToDraw=1,
        SecondsPerItem=0.1,
        OnCommand=function(s)
            s:SetDestinationItem(0):SetFastCatchup(true)
            :SetMask(320,20):fov(60):zwrite(true):draworder(8):z(8)
        end,
        TransformFunction=function(s,o,i,n)
            s:x(math.floor(o*(10))):diffusealpha(1-math.abs(o))
        end,
        CodeMessageCommand=function(s,p)
            local DI = s:GetCurrentItem();
            if p.PlayerNumber == pn and keyset[pn] then
                if p.Name=="PaneLeft" then
                    if DI>0 then
                        s:SetDestinationItem(DI-1)
                        SOUND:PlayOnce(THEME:GetPathS("","MusicWheel expand"))
                    end
                end
                if p.Name=="PaneRight" then
                    if DI<2 then
                        s:SetDestinationItem(DI+1)
                        SOUND:PlayOnce(THEME:GetPathS("","MusicWheel expand"))
                    end
                end
            end
        end,
        Def.ActorFrame{
            Name="ScrollerItem1";
            DifficultyPanel()..{ InitCommand=function(s) s:y(-260) end,};
            Def.BitmapText{
                Font="_stagetext",
                Text="DIFFICULTY INFORMATION",
                Name="Header",
                InitCommand=function(s) s:zoom(0.7):y(-290):DiffuseAndStroke(color("#dff0ff"),color("0,0.7,1,0.5")) end,
            };
        };
        Def.ActorFrame{
            Name="ScrollerItem2";
            RadarPanel()..{
                InitCommand=function(s) s:y(-165):zoom(0.8) end,
            },
            Def.BitmapText{
                Font="_stagetext",
                Text="RADAR INFORMATION",
                Name="Header",
                InitCommand=function(s) s:zoom(0.7):y(-290):DiffuseAndStroke(color("#dff0ff"),color("0,0.7,1,0.5")) end,
            };
        };
        -- scores
	    Def.ActorFrame{
		    Name="ScrollerItem3";
		    RivalsPanel()..{
		        InitCommand=function(s) s:y(-260) end,
            };
            Def.BitmapText{
                Font="_stagetext",
                Text="RIVAL INFORMATION",
                Name="Header",
                InitCommand=function(s) s:zoom(0.7):y(-290):DiffuseAndStroke(color("#dff0ff"),color("0,0.7,1,0.5")) end,
            };
	    };
    };
    return t
end

local t = Def.ActorFrame{
    InitCommand=function(s,p) XPOS(s,0) s:visible(false)
    end,
    BeginCommand=function(s) s:playcommand("Set") end,
    OffCommand=function(s) s:sleep(0.5):decelerate(0.3):addx(pn==PLAYER_1 and -500 or 500) end,
    CurrentSongChangedMessageCommand=function(s,p) s:queuecommand("Set") end,
    CodeMessageCommand=function(s,p)
        
        if p.PlayerNumber == pn then
            if p.Name == "OpenPanes1" or p.Name == "OpenPanesEFUp" then
                if keyset[pn] == false then
                    keyset[pn] = true
                else
                    keyset[pn] = false
                end
                s:visible(keyset[pn])
                SOUND:PlayOnce(THEME:GetPathS("MusicWheel","expand"))
            end
        end
    end,
    ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s,p) s:queuecommand("Set") end,
    ["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s,p) s:queuecommand("Set") end,
    Def.Sprite{
        Texture="backer.png",
    };
    PlayerInfo(pn)..{
        InitCommand=function(s) s:addy(90) end,
    };
    Scroller(pn)..{
        InitCommand=function(s) s:addy(90) end,
    };
    Def.BitmapText{
        Font="_stagetext",
        Text="[PRESS ARROW PANELS TO CHANGE WINDOWS]",
        InitCommand=function(s) s:zoom(0.5):y(240):DiffuseAndStroke(color("#dff0ff"),color("0,0.7,1,0.5")) end,
    };
};



return t;
