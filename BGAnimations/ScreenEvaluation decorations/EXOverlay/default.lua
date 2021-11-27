local t = Def.ActorFrame{
    InitCommand=function(s) s:Center():diffusealpha(0) end,
    OnCommand=function(s) s:sleep(1):linear(0.1):diffusealpha(1):sleep(3):linear(0.1):diffusealpha(0):addy(20) end,
};

t[#t+1] = Def.ActorFrame{
    Def.Sprite{
        Texture="guy.png";
        InitCommand=function(s) s:diffusealpha(0) end,
        OnCommand=function(s) s:sleep(0.2):smooth(0.2):x(-600):diffusealpha(1) end,
    };
    Def.Sprite{
        Texture="girl.png";
        InitCommand=function(s) s:diffusealpha(0) end,
        OnCommand=function(s) s:sleep(0.2):smooth(0.2):x(480):diffusealpha(1) end,
    };
    Def.Sprite{
        Texture="lensflare",
        OnCommand=function(s) s:zoomx(3):zoomy(0):sleep(0.4):linear(0.1):zoomx(1):zoomy(1) end,
    },
    Def.Sprite{
        Texture="exclusive",
        OnCommand=function(s) s:zoomx(3):zoomy(0):sleep(0.1):linear(0.1):zoomx(1):zoomy(1) end,
    },
    Def.Sound{
        File=THEME:GetPathS("","_siren"),
        OnCommand=function(self)
            --if GAMESTATE:HasEarnedExtraStage() then
                self:play()
            --end;
        end;
    };
};
for i=1,2 do
    t[#t+1] = Def.ActorFrame{
        InitCommand=function(s) s:x(i==1 and -660 or 660):zoomx(i==1 and 1 or -1) end,
        Def.Sprite{
            Texture="hex1";
        };
        Def.Sprite{
            Texture="hex2";
            OnCommand=function(s) s:diffusealpha(0):sleep(0.3):smooth(0.3):xy(50,50):diffusealpha(0.9) end,
        };
    }
end

return t