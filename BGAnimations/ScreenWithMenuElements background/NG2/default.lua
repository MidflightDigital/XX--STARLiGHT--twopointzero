return Def.ActorFrame {
    Def.Quad {
        InitCommand=function(s) s:FullScreen() end,
        OnCommand=function(self)
            self:diffusetopedge(color("#303030")):diffusebottomedge(color("#808080"));
        end;
    };
    Def.Quad {
        InitCommand=function(s) s:CenterX():y(_screen.cy+SCREEN_HEIGHT/3):setsize(SCREEN_WIDTH,SCREEN_HEIGHT/2):fadetop(0.25) end,
        OnCommand=function(s) s:diffusetopedge(color("#f0f0f0")):diffusebottomedge(color("#cccccc")):diffusealpha(0.5) end,
    };
    LoadActor("light")..{
        InitCommand=function(s) s:FullScreen():diffusealpha(0.25) end, 
    };
    Def.ActorFrame{
        InitCommand=function(s) s:spin():effectmagnitude(0,0,-2) end,
        LoadActor("Node-BG.png")..{
            InitCommand=function(s) s:setsize(1920*2,1080*2):xy(_screen.cx-200,_screen.cy+40):diffusealpha(0.2):pulse():effectperiod(50) end,
        };
    };
    Def.ActorFrame{
        InitCommand=function(s) s:spin():effectmagnitude(0,0,6) end,
        LoadActor("Node-BG.png")..{
            InitCommand=function(s) s:setsize(1920*2,1080*2):xy(_screen.cx+500,_screen.cy-180):diffusealpha(0.2):pulse():effectperiod(100) end,
        };
    };
    LoadActor("Node-BG.png")..{
        InitCommand=function(s) s:setsize(1920*2,1080*2):rotationz(120):Center():diffusealpha(0.2):spin():effectmagnitude(0,0,-2) end,
    };
};