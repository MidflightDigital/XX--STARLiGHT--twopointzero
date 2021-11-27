local pn = ({...})[1] --only argument to file
local GR = {
    {-1,-112, "Stream"}, --STREAM
    {-120,-43, "Voltage"}, --VOLTAGE
    {-108,72, "Air"}, --AIR
    {108,72, "Freeze"}, --FREEZE
    {120,-43, "Chaos"}, --CHAOS
};

local lab = Def.ActorFrame{};
local radars = Def.ActorFrame{}

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
    radars[#radars+1] = Def.ActorFrame{
        OnCommand=function(s) s:zoom(0):rotationz(-360):sleep(0.3):decelerate(0.4):zoom(1):rotationz(0) end,
        OffCommand=function(s) s:sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
        create_ddr_groove_radar("radar",0,0,pn,125,Alpha(PlayerColor(pn),0.25))
    }
end

for i,v in ipairs(GR) do
    lab[#lab+1] = Def.ActorFrame{
        OnCommand=function(s)
            s:xy(v[1],v[2])
            :diffusealpha(0):addx(-10):sleep(0.1+i/10):linear(0.1):diffusealpha(1):addx(10)
        end;
        OffCommand=function(s)
            s:sleep(i/10):linear(0.1):diffusealpha(0):addx(-10)
        end;
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler/RLabels"),
            OnCommand=function(s) s:animate(0):setstate(i-1) end,
        };
        Def.BitmapText{
            Font="_avenirnext lt pro bold 20px";
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
                if GAMESTATE:GetNumPlayersEnabled() == 2 then
                    s:x(pn==PLAYER_2 and 30 or -30)
                else
                    s:x(0)
                end
            end,
            CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
            ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
            ["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
        };
    };
end

return Def.ActorFrame{
    Def.ActorFrame{
        Name="Radar",
        InitCommand=function(s) s:zoom(0) end,
        OnCommand=function(s) s:zoom(0):rotationz(-360):sleep(0.4):decelerate(0.4):zoom(1):rotationz(0) end,
        OffCommand=function(s) s:sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler/GrooveRadar base"),
        };
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler/sweep"),
            InitCommand = function(s) s:zoom(1.275):spin():effectmagnitude(0,0,100) end,
        };
    };
    lab;
    radars;
}

