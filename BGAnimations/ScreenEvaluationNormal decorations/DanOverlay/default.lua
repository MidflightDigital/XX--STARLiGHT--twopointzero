local t = Def.ActorFrame{
    InitCommand=function(s) s:Center() end,
    OnCommand=function(s) s:hibernate(2.5):sleep(3.6):smooth(0.2):zoom(3):diffusealpha(0) end,
};

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(GAMESTATE:GetMasterPlayerNumber())

t[#t+1] = Def.ActorFrame{
    Def.Sprite{
        Texture="guy.png";
        InitCommand=function(s) s:diffusealpha(0) end,
        OnCommand=function(s) s:sleep(1):smooth(0.2):x(-600):diffusealpha(1) end,
    };
    Def.Sprite{
        Texture="girl.png";
        InitCommand=function(s) s:diffusealpha(0) end,
        OnCommand=function(s) s:sleep(1):smooth(0.2):x(480):diffusealpha(1) end,
    };
    Def.Sprite{
        Texture="lensflare",
        InitCommand=function(s) s:zoom(0) end,
        OnCommand=function(s) s:sleep(1):zoomx(3):zoomy(0):sleep(0.4):linear(0.1):zoomx(1):zoomy(1) end,
    },
    Def.Sprite{
        InitCommand=function(s)
            s:zoom(0)
            if pss:GetFailed() then
                s:Load(THEME:GetPathB("ScreenEvaluationNormal","decorations/DanOverlay/failed.png"))
            else
                s:Load(THEME:GetPathB("ScreenEvaluationNormal","decorations/DanOverlay/cleared.png"))
            end
        end,
        OnCommand=function(s) s:sleep(1):zoomx(3):zoomy(0):sleep(0.1):linear(0.1):zoomx(1):zoomy(1) end,
    },
};
for i=1,2 do
    t[#t+1] = Def.ActorFrame{
        InitCommand=function(s) s:x(i==1 and -660 or 660):zoomx(i==1 and 1 or -1) end,
        Def.Sprite{
            Texture="hex1";
            InitCommand=function(s) s:diffusealpha(0) end,
            OnCommand=function(s) s:sleep(1):smooth(0.2):diffusealpha(1) end,
        };
        Def.Sprite{
            Texture="hex2";
            OnCommand=function(s) s:diffusealpha(0):sleep(1.3):smooth(0.3):xy(50,50):diffusealpha(0.9) end,
        };
    }
end

return Def.ActorFrame{
    Def.Sprite{
        InitCommand=function(s)
            s:basezoom(0.8):zoomx(3):zoomy(0):xy(_screen.cx,_screen.cy-310)
            if pss:GetFailed() then
                s:Load(THEME:GetPathB("ScreenEvaluationNormal","decorations/DanOverlay/small failed.png"))
            else
                s:Load(THEME:GetPathB("ScreenEvaluationNormal","decorations/DanOverlay/small cleared.png"))
            end
        end,
        OnCommand=function(s) s:sleep(6.7):smooth(0.2):zoomx(1):zoomy(1) end,
        OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
    },
    Def.Quad{
        InitCommand=function(s) s:diffuse(Alpha(Color.Black,0)):FullScreen() end,
        OnCommand=function(s) s:sleep(2.8):smooth(0.2):diffusealpha(0.5):sleep(3.7):smooth(0.4):diffusealpha(0) end,
    };
    t;
    Def.Sound{
        Condition=pss:GetFailed() == true,
        File=THEME:GetPathB("ScreenEvaluationNormal","decorations/DanOverlay/s_failed.ogg"),
        OnCommand=function(s)
            s:sleep(2.8):queuecommand("Play")
        end,
        PlayCommand=function(s) s:play() end,
    },
    Def.Sound{
        Condition=pss:GetFailed() ~= true,
        File=THEME:GetPathB("ScreenEvaluationNormal","decorations/DanOverlay/s_cleared.ogg"),
        OnCommand=function(s)
            s:sleep(2.8):queuecommand("Play")
        end,
        PlayCommand=function(s) s:play() end,
    }
};