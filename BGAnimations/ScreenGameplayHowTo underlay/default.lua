local t = Def.ActorFrame{};

t[#t+1] = Def.ActorFrame{
    Def.Actor{
        OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(DDRInput(self)) end,
        StartReleaseCommand=function(s)
            SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_DoNextScreen")
            s:sleep(3):queuecommand("Pause")
        end,
        PauseCommand=function(s) SCREENMAN:GetTopScreen():PauseGame(true) end,
    }
};

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
    t[#t+1] = Def.Quad{
        InitCommand=function(s)
            local style= GAMESTATE:GetCurrentStyle(pn)
            local width = style:GetWidth(pn)+14
            s:setsize(width*2.25,SCREEN_HEIGHT):xy(ScreenGameplay_X(pn),_screen.cy)
            :diffuse(Alpha(Color.Black,0)):fadeleft(1/32):faderight(1/32)
        end,
        OnCommand=function(s) s:sleep(6):linear(0.4):diffusealpha(0.5) end,
    };
end

return t;