local function input(event,param)
    if not event.button then return false end
    if event.type ~= "InputEventType_Release" then
        if event.GameButton == "Start" then
            SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
            SOUND:DimMusic(0,math.huge)
        end
    end

    return false
end

local paneimage = "pane.png"

--nice
if math.random(1,100) == 69 then
    paneimage = "pane s.png"
end

return Def.ActorFrame{
    InitCommand=function(s) s:Center() end,
    OnCommand=function(s) s:queuecommand("Capture") end,
	CaptureCommand=function(s) 
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		SOUND:PlayOnce(THEME:GetPathS("ScreenSelectPlayMode","in"))
    end,
    Def.Sprite{
        Texture=paneimage,
        InitCommand=function(s) s:croptop(0.5):cropbottom(0.5) end,
        OnCommand=function(s) s:sleep(0.2):linear(0.2):croptop(0):cropbottom(0) end,
        OffCommand=function(s) s:linear(0.2):croptop(0.5):cropbottom(0.5) end,
    };
    Def.Sprite{
        Texture="top",
        InitCommand=function(s) s:valign(1) end,
        OnCommand=function(s) s:sleep(0.2):linear(0.2):y(-266) end,
        OffCommand=function(s) s:linear(0.2):y(0) end,
    };
    Def.Sprite{
        Texture="top",
        InitCommand=function(s) s:valign(1):rotationz(180) end,
        OnCommand=function(s) s:sleep(0.2):linear(0.2):y(266) end,
        OffCommand=function(s) s:linear(0.2):y(0) end,
    };
};