local pn = ({...})[1] --only argument to file
local GR = {
    {-1,-122, "Stream"}, --STREAM
    {-120,-43, "Voltage"}, --VOLTAGE
    {-108,72, "Air"}, --AIR
    {108,72, "Freeze"}, --FREEZE
    {120,-43, "Chaos"}, --CHAOS
};

local t = Def.ActorFrame{};

t[#t+1] = Def.ActorFrame{
    OnCommand=function(s) s:zoom(0):rotationz(-360):decelerate(0.4):zoom(1):rotationz(0) end,
    OffCommand=function(s) s:sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
    create_ddr_groove_radar("radar",0,0,pn,125,Alpha(PlayerColor(pn),0.25));
};

for i,v in ipairs(GR) do
    t[#t+1] = Def.ActorFrame{
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
            InitCommand=function(s)
                if GAMESTATE:GetNumPlayersEnabled() == 2 and ThemePrefs.Get("WheelType") == "CoverFlow" then
                    s:x(pn==PLAYER_1 and -20 or 20):diffuse(PlayerColor(pn))
                end
            end,
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
            CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
            ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
            ["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:queuecommand("Set") end,
        };
    };
end

return t;
