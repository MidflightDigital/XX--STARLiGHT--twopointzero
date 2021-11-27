local t = Def.ActorFrame{}

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
    t[#t+1] = LoadActor("frame.lua",pn)..{
        InitCommand=function(s)
            if IsUsingWideScreen() then
                s:x(pn==PLAYER_1 and _screen.cx-480 or _screen.cx+480)
            else
                s:x(pn == PLAYER_1 and _screen.cx-400 or _screen.cx+400)
            end
            s:y(_screen.cy-2)
        end,
        
    };
end

return Def.ActorFrame{
    StartMessageCommand=function(s)
        SOUND:PlayOnce(THEME:GetPathS("Common","start"))
    end,
    DirectionMessageCommand=function(s)
        SOUND:PlayOnce(THEME:GetPathS("","Profile_Move"))
    end,
    CancelMessageCommand=function(s)
        SOUND:PlayOnce(THEME:GetPathS("Common","cancel"))
    end,
    ContinueMessageCommand=function(s,p)
        if GAMESTATE:GetNumPlayersEnabled() == 2 then
            if getenv("keysetP1") == 1 and getenv("keysetP2") == 1 then
                SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
            end
        else
            SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
        end
    end,
    Def.Sprite{
        Texture=THEME:GetPathG("","ScreenSelectProfile/Cab outline");
        InitCommand=function(s) s:Center() end,
        OffCommand=function(s) s:diffusealpha(0):sleep(0.1):diffusealpha(0.5):sleep(0.1):diffusealpha(0):sleep(0.12):diffusealpha(1):linear(0.2):diffusealpha(0) end,
    };
    t;
}