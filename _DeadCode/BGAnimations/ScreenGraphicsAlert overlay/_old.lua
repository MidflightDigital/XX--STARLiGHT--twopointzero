local TextBox=Def.BitmapText{
    Font="_avenirnext lt pro bold/42px",
    InitCommand=function(s) s:wrapwidthpixels(SCREEN_WIDTH/1.5):strokecolor(Color.Black) end,
};

local curIndex = 1

local function input(event,param)
    if not event.button then return false end
    if event.type ~= "InputEventType_Release" then
        if event.GameButton == "Start" then
            if curIndex >= 6 then
                SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
                SOUND:DimMusic(0,math.huge)
            else
                curIndex = curIndex+1
                SOUND:PlayOnce(THEME:GetPathS("","Profile_Move"))
                MESSAGEMAN:Broadcast("Show")
            end
        end
    end

    return false
end

return Def.ActorFrame{
    OnCommand=function(s) s:queuecommand("Capture") end,
	CaptureCommand=function(s) 
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		SOUND:PlayOnce(THEME:GetPathS("ScreenSelectPlayMode","in"))
    end,
    Def.Quad{
        InitCommand=function(s) s:diffuse(Alpha(Color.Black,0.5)):FullScreen() end,
    };
    Def.Sprite{
        Texture="1.png",
        InitCommand=function(s) s:xy(SCREEN_RIGHT-300,SCREEN_BOTTOM):valign(1):zoom(0.4):addy(2048) end,
        OnCommand=function(s) s:sleep(0.2):decelerate(0.3):addy(-2048):linear(0.1):addy(20) end,
        ShowMessageCommand=function(s) s:finishtweening():decelerate(0.1):rotationy(-90) end,
    };
    TextBox..{
        Text="Hey, I noticed that the graphic settings are a bit less colorful than DDR -XX- STARLiGHT is used to.",
        InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT+120,_screen.cy):cropright(1) end,
        OnCommand=function(s) s:sleep(0.6):linear(1):cropright(0) end,
        ShowMessageCommand=function(s) s:finishtweening():diffusealpha(0) end,
    };
    --2
    Def.Sprite{
        Texture="2.png",
        InitCommand=function(s) s:xy(SCREEN_RIGHT-300,SCREEN_BOTTOM):valign(1):zoom(0.4):rotationy(90):diffusealpha(0) end,
        ShowMessageCommand=function(s) 
            if curIndex == 2 then
                s:sleep(0.1):diffusealpha(1):decelerate(0.1):rotationy(0)
            else
                s:finishtweening():decelerate(0.1):rotationy(-90)
            end
        end
    };
    TextBox..{
        Text="The problem is that your bit depth isn't set to 32.",
        InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT+120,_screen.cy):cropright(1) end,
        ShowMessageCommand=function(s) 
            if curIndex == 2 then
                s:sleep(0.6):diffusealpha(1):linear(1):cropright(0)
            else
                s:finishtweening():decelerate(0.1):diffusealpha(0)
            end
        end,
    };
    --3
    Def.Sprite{
        Texture="3.png",
        InitCommand=function(s) s:xy(SCREEN_RIGHT-300,SCREEN_BOTTOM):valign(1):zoom(0.4):rotationy(90):diffusealpha(0) end,
        ShowMessageCommand=function(s) 
            if curIndex == 3 then
                s:sleep(0.1):diffusealpha(1):decelerate(0.1):rotationy(0)
            else
                s:finishtweening():decelerate(0.1):diffusealpha(0)
            end
        end
    };
    Def.Sprite{
        Texture="Gradient.png",
        InitCommand=function(s) s:xy(SCREEN_LEFT+240,_screen.cy-100):halign(0):setsize(854,480):diffusealpha(0) end,
        ShowMessageCommand=function(s) 
            if curIndex == 3 then
                s:sleep(0.1):decelerate(0.1):diffusealpha(1)
                SOUND:PlayOnce(THEME:GetPathS("MemoryCardManager","error"))
            else
                s:finishtweening():decelerate(0.1):diffusealpha(0)
            end
        end
    };
    TextBox..{
        Text="Bit depth determines how many different colors can be shown on your screen, so a lot of subtle colors will be flattened and have weird stripes.",
        InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT+120,_screen.cy+300):cropright(1) end,
        ShowMessageCommand=function(s) 
            if curIndex == 3 then
                s:sleep(0.6):diffusealpha(1):linear(1):cropright(0)
            else
                s:finishtweening():diffusealpha(0)
            end
        end,
    };
    --4
    Def.Sprite{
        Texture="4.png",
        InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM):valign(1):zoom(0.4):diffusealpha(0) end,
        ShowMessageCommand=function(s) 
            if curIndex == 4 then
                s:sleep(0.1):decelerate(0.1):diffusealpha(1)
            elseif curIndex == 5 then
                s:decelerate(0.1):rotationy(-90)
            else
                s:finishtweening():decelerate(0.1):diffusealpha(0)
            end
        end
    };
    TextBox..{
        Text="And every computer and phone already runs at the full 32 bits, by the way!",
        InitCommand=function(s) s:halign(0.5):xy(SCREEN_CENTER_X,_screen.cy+300):cropright(1) end,
        ShowMessageCommand=function(s) 
            if curIndex == 4 then
                s:sleep(0.6):diffusealpha(1):linear(1):cropright(0)
            else
                s:finishtweening():diffusealpha(0)
            end
        end,
    };
    --5
    Def.Sprite{
        Texture="5.png",
        InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM):valign(1):zoom(0.4):diffusealpha(0) end,
        ShowMessageCommand=function(s) 
            if curIndex == 5 then
                s:sleep(0.1):decelerate(0.1):diffusealpha(1)
            elseif curIndex == 6 then
                s:decelerate(0.1):rotationy(-90)
            else
                s:finishtweening():decelerate(0.1):diffusealpha(0)
            end
        end
    };
    TextBox..{
        Text="Your computer should be able to handle this unless you're running this on a potato.",
        InitCommand=function(s) s:halign(0.5):xy(SCREEN_CENTER_X,_screen.cy+300):cropright(1) end,
        ShowMessageCommand=function(s) 
            if curIndex == 5 then
                s:sleep(0.6):diffusealpha(1):linear(1):cropright(0)
            else
                s:finishtweening():diffusealpha(0)
            end
        end,
    };
    --6
    Def.Sprite{
        Texture="6.png",
        InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM):valign(1):zoom(0.4):diffusealpha(0) end,
        ShowMessageCommand=function(s) 
            if curIndex == 6 then
                s:sleep(0.1):decelerate(0.1):diffusealpha(1)
            elseif curIndex == 7 then
                s:decelerate(0.1):rotationy(-90)
            else
                s:finishtweening():decelerate(0.1):diffusealpha(0)
            end
        end;
    };
    TextBox..{
        Text="You can change the bit depth from the settings menu. Remember, set it to 32 bits!",
        InitCommand=function(s) s:halign(0.5):xy(SCREEN_CENTER_X,_screen.cy+300):cropright(1) end,
        ShowMessageCommand=function(s) 
            if curIndex == 6 then
                s:sleep(0.6):diffusealpha(1):linear(1):cropright(0)
            else
                s:finishtweening():diffusealpha(0)
            end
        end,
        OffCommand=function(s) s:diffusealpha(0) end,
    };
};