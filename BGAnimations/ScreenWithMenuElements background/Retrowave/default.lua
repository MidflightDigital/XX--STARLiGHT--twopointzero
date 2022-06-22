local screen = Var 'LoadingScreen'

return Def.ActorFrame {
    InitCommand=function(s) s:fov(90):Center() end,
    OffCommand=function(s) s:finishtweening() end,
	
    Def.Sprite{
        Texture=THEME:GetPathB("ScreenWithMenuElements","background/Default/background.mp4"),
        InitCommand=function(s) s:setsize(SCREEN_WIDTH*2,SCREEN_HEIGHT):y(-300):diffuse(color("#cd22aa")):diffusetopedge(color("#bba500")) end,
		CurrentSongChangedMessageCommand=function(s)
			if screen == 'ScreenGameplay' then
				s:position(0)
				s:rate(1)
				s:sleep(0.5):queuecommand('PauseMovie')
			end
		end,
		CourseBreakTimeMessageCommand=function(s)
			s:rate(1)
		end,
		PauseMovieCommand=function(s) s:rate(0) end,
		NextCourseSongMessageCommand=function(s) s:rate(1) end,
		OffCommand=function(s)
			if screen == 'ScreenGameplay' then
				local delay = THEME:GetMetric('ScreenGameplay', 'OutTransitionSeconds')
				s:sleep(delay+BeginOutDelay())
				s:rate(1)
			end
		end,
    },
    Def.Quad{
        InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_WIDTH/2):y(100):valign(1):MaskSource() end,
    },
    Def.Quad{
        InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):valign(0):ztestmode('ZTestMode_WriteOnFail'):MaskDest()
            :diffuse(color("#0b0c31")):diffusebottomedge(color("#761959")) end,
    },
    Def.ActorFrame{
        InitCommand=function(s) s:queuecommand("Anim") end,
        AnimCommand=function(s) s:sleep(8):diffusealpha(0.7):xy(2,-2):sleep(0.05):diffusealpha(0.9):xy(0,0):sleep(0.05):diffusealpha(0.4):xy(-2,2):sleep(0.05):diffusealpha(1):xy(0,0):sleep(5)
            :sleep(0.05):diffusealpha(0.7):xy(2,2):sleep(0.05):diffusealpha(0.3):xy(-2,-2):sleep(0.05):diffusealpha(1):xy(0,0):queuecommand("Anim") end,
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN2/line"),
            InitCommand=function(s)
                s:ztestmode('ZTestMode_WriteOnFail'):MaskDest()
                :zoomto(SCREEN_WIDTH*1.5,SCREEN_HEIGHT*1.5):rotationx(-82):customtexturerect(0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96)
                :texcoordvelocity(0.7,0):effectperiod(4):blend(Blend.Add):diffuse(color("0.5,0.2,0.7,1"))
            end,
        },
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenWithMenuElements","background/SN2/line"),
            InitCommand=function(s)
                s:ztestmode('ZTestMode_WriteOnFail'):MaskDest()
                :zoomto(SCREEN_WIDTH*1.5,SCREEN_HEIGHT*1.5):rotationx(-82):customtexturerect(0,0,SCREEN_WIDTH*1.5/48,SCREEN_HEIGHT*1.5/96):xy(1,-1)
                :texcoordvelocity(0.7,0):effectperiod(4):blend(Blend.Add):diffusealpha(0.1)
            end,
        },
    },
    Def.ActorFrame{
        InitCommand=function(s)
            s:pulse():effectmagnitude(1,0.98,0.98):effectclock('beat'):effectoffset(0.2):effecttiming(0.6*2,0.2*2,0.2*2,0)
        end,
        Def.Sprite{
            Texture="circle",
            InitCommand=function(s) s:xy(1,-202):bob():effectmagnitude(0,20,0):effectperiod(50):blend(Blend.Add) end,
        },
        Def.Sprite{
            Texture="circle",
            InitCommand=function(s) s:y(-200):bob():effectmagnitude(0,20,0):effectperiod(50) end,
        },
    },
    Def.Sprite{
        Texture="mountains",
        InitCommand=function(s) s:valign(1):y(100) end,
    },
    Def.Sprite{
        Texture="midline",
        InitCommand=function(s) s:y(100):blend(Blend.Add):diffuse(color("#d626b7")):diffusealpha(1) end,
    },
    Def.Sprite{
        Texture="line1",
        InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):y(100):rotationx(-82):blend(Blend.Add):diffuse(color("#d626b7")):diffusealpha(0.5):cropright(1):queuecommand("Anim") end,
        AnimCommand=function(s) s:cropright(1):cropleft(0):sleep(5):decelerate(0.5):cropright(0):decelerate(0.5):cropleft(1):queuecommand("Anim") end,
    },
    Def.Sprite{
        Texture="line1",
        InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):y(110):rotationx(-82):blend(Blend.Add):diffusealpha(0.8):cropright(1):queuecommand("Anim") end,
        AnimCommand=function(s) s:cropright(1):cropleft(0):sleep(5):decelerate(0.5):cropright(0):decelerate(0.5):cropleft(1):queuecommand("Anim") end,
    },
    Def.Sprite{
        Texture="line1",
        InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):y(80):rotationx(-87):zoomy(0.8):blend(Blend.Add):diffuse(color("#d626b7")):diffusealpha(0.5):cropright(1):queuecommand("Anim") end,
        AnimCommand=function(s) s:cropright(1):cropleft(0):sleep(7):decelerate(0.5):cropright(0):decelerate(0.5):cropleft(1):queuecommand("Anim") end,
    },
    Def.Sprite{
        Texture="bottom glow",
        InitCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):diffuse(color("#f86551")):diffusealpha(0.3) end,
    }
}