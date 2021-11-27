local t = LoadFallbackB();

local function InputHandler(event)
	local player = event.PlayerNumber
	local MusicWheel = SCREENMAN:GetTopScreen("ScreenSelectMusic"):GetChild("MusicWheel");
	local overlay = SCREENMAN:GetTopScreen()
	if event.type == "InputEventType_Release" then return false end
	if event.DeviceInput.button == "DeviceButton_left mouse button" then
		MESSAGEMAN:Broadcast("MouseLeftClick")
	  end
	  if MusicWheel ~= nil and getenv("OPList") == 0 then
		if event.GameButton == "MenuLeft" and GAMESTATE:IsPlayerEnabled(player) then
		  overlay:GetChild("MWChange"):play()
		end
		if event.GameButton == "MenuRight" and GAMESTATE:IsPlayerEnabled(player) then
		  overlay:GetChild("MWChange"):play()
		end
	end
end

t[#t+1] = Def.Sound{
	Name="MWChange",
	File=THEME:GetPathS("","MWChange/Default_MWC"),
};

t[#t+1] = Def.Actor{
	OnCommand=function(s)
		SCREENMAN:GetTopScreen():SetPrevScreenName("ScreenSelectMusic")
		local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
		local SB = mw:GetChild("ScrollBar")
		if not SB then return end
		SB:visible(false)
		mw:zbuffer(true):diffusealpha(0):sleep(0.05):diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1)
		:sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(1)
		:SetDrawByZPosition(true)
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
	end,
	OffCommand=function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
		local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
	end,
	MouseLeftClickMessageCommand = function(self)
		if ThemePrefs.Get("Touch") == true then
		  self:queuecommand("PlayTopPressedActor")
		end
	end;
	PlayTopPressedActorCommand = function(self)
		playTopPressedActor()
		resetPressedActors()
	end;
	Def.Sprite{
		Texture="../_cursor",
	};
	CodeMessageCommand = function(self,params)
		if params.Name == "Back" then
			GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
			SCREENMAN:GetTopScreen():Cancel()
		end
	end
}

t[#t+1] = Def.Sprite{
	Texture=THEME:GetPathB("","ScreenSelectMusic underlay/ADeco"),
	InitCommand=function(s) s:halign(0):xy(SCREEN_LEFT,_screen.cy):blend(Blend.Add):diffusealpha(1) end,
	OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(0.75) end,
	OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
};


for i=1,2 do
	Name="Arrows";
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s) s:draworder(99):xy(i==1 and _screen.cx-200 or _screen.cx+500,_screen.cy):zoomx(i==1 and 1 or -1) end,
		OnCommand=function(s)
			s:diffusealpha(0):addx(i==1 and -100 or 100)
			:sleep(0.6):decelerate(0.3):addx(i==1 and 100 or -100):diffusealpha(1)
			s:bounce():effectclock("beat"):effectperiod(1):effectmagnitude(i==2 and 10 or -10,0,0):effectoffset(0.2)
		end,
		OffCommand=function(s) s:stoptweening():sleep(0.2):accelerate(0.2):addx(i==1 and -100 or 100):diffusealpha(0) end,
		StartSelectingStepsMessageCommand=function(s)
			s:accelerate(0.3):addx(i==1 and -100 or 100):diffusealpha(0)
		end,
		NextSongMessageCommand=function(s)
			if i==2 then s:stoptweening():x(_screen.cx+520):decelerate(0.5):x(_screen.cx+500) end
		end, 
		PreviousSongMessageCommand=function(s)
			if i==1 then s:stoptweening():x(_screen.cx-220):decelerate(0.5):x(_screen.cx-200) end
		end, 
		Def.Sprite{ Texture=THEME:GetPathG("","_shared/arrows/base");};
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/arrows/color");
			InitCommand=function(s) s:diffuse(color("#00f0ff")) end,
			NextSongMessageCommand=function(s)
				if i==2 then
					s:stoptweening():diffuse(color("#ff00ea")):sleep(0.5):diffuse(color("#00f0ff"))
				end
			end, 
			PreviousSongMessageCommand=function(s)
				if i==1 then
					s:stoptweening():diffuse(color("#ff00ea")):sleep(0.5):diffuse(color("#00f0ff"))
				end
			end, 
		};
	};
end;

t[#t+1] = Def.ActorFrame{
	OnCommand=function(s)
		s:diffusealpha(0):linear(0.05):diffusealpha(0.75)
		:linear(0.1):diffusealpha(0.25):linear(0.1):diffusealpha(1)
	end,
	OffCommand=function(s)
		s:diffusealpha(1):sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(0.5)
		:sleep(0.05):diffusealpha(0):sleep(0.05):diffusealpha(0.25):sleep(0.05)
		:linear(0.05):diffusealpha(0)
	end,
	InitCommand=function(s) s:xy(_screen.cx-250,_screen.cy-400):diffusealpha(0):draworder(99) end,
	Def.Sprite{Texture="course title.png"},
	Def.BitmapText{
		Font="_avenirnext lt pro bold 36px";
		InitCommand = function(s) s:halign(0):xy(-350,-26):maxwidth(600):diffuse(Color.Black):uppercase(true) end,
		SetCommand = function(self)
			local course = GAMESTATE:GetCurrentCourse()
			self:settext(course and course:GetDisplayFullTitle() or "")
		end,
		CurrentCourseChangedMessageCommand = function(s) s:queuecommand("Set") end,
		ChangedLanguageDisplayMessageCommand = function(s) s:queuecommand("Set") end,
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold 25px";
		InitCommand = function(s) s:xy(320,54):maxwidth(120):zoom(0.65):align(0.5,0) end,
		SetCommand = function(self)
			local curTrail = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber())
			if curTrail:IsSecret() then
				self:settext("???")
			else
				local bpmlow = {}
				local bpmhigh = {}
				for i=1,#curTrail:GetTrailEntries() do
					local ce = curTrail:GetTrailEntry(i-1):GetSong():GetDisplayBpms()
					table.insert(bpmlow,ce[1])
					table.insert(bpmhigh,ce[#ce])
				end
				self:settextf("%03d - %03d",math.floor(math.min(unpack(bpmlow))+0.5),math.floor(math.max(unpack(bpmhigh)))+0.5)
			end
		end,
		CurrentCourseChangedMessageCommand = function(s) s:queuecommand("Set") end,
		ChangedLanguageDisplayMessageCommand = function(s) s:queuecommand("Set") end,
	};
	Def.Sprite{
		Texture="course title.png",
		InitCommand=function(s) s:MaskSource(true) end,
    };
	Def.Sprite{
		Texture=THEME:GetPathB("","ScreenSelectMusic overlay/ADeco/grad.png"),
		InitCommand=function(s) s:setsize(102,144):diffusealpha(0.5):blend(Blend.Add):MaskDest():ztestmode("ZTestMode_WriteOnFail") end,
		OnCommand=function(s) s:queuecommand("Anim") end,
		AnimCommand=function(s) s:x(-480):sleep(4):smooth(1.5):x(480):queuecommand("Anim") end,
		OffCommand=function(s) s:stoptweening() end,
	};
};

t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:xy(SCREEN_LEFT+218,_screen.cy+240):zoom(0.75) end,
	OnCommand=function(s) s:addx(-SCREEN_WIDTH):sleep(0.2):decelerate(0.2):addx(SCREEN_WIDTH) end,
	OffCommand=function(s) s:linear(0.2):addx(-SCREEN_WIDTH) end,
	Def.Sprite{
		Texture=THEME:GetPathB("","ScreenSelectMode decorations/windowmid"),
		OnCommand=function(self)
			self:accelerate(0.1):croptop(0.5):cropbottom(0.5):sleep(0.1):accelerate(0.2):croptop(0):cropbottom(0)
		end;
	};
	Def.ActorFrame{
		OnCommand=function(self)
			self:accelerate(0.1):y(0):sleep(0.1):accelerate(0.2):y(-172)
		end;
		Def.Sprite{
			Texture=THEME:GetPathB("","ScreenSelectMode decorations/windowtop"),
			InitCommand=function(s) s:valign(1) end,
		};
		Def.Sprite{
			Texture="SONG LIST.png",
			InitCommand=function(s) s:zoom(1.35):y(-20) end,
		};
	};
	Def.Sprite{
		Texture=THEME:GetPathB("","ScreenSelectMode decorations/windowbottom"),
		InitCommand=function(s) s:y(172):valign(0); end,
		OnCommand=function(self)
			self:accelerate(0.1)
			:y(0)
			:sleep(0.1)
			:accelerate(0.2)
			:y(172)
		end;
	};
	StandardDecorationFromFileOptional("CourseContentsList","CourseContentsList")..{
		InitCommand=function(s) s:zoom(1.25):xy(0,-150) end,
	}
};

t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:xy(SCREEN_LEFT,_screen.cy-320) end,
	OnCommand=function(s) s:stoptweening():addx(-400):decelerate(0.2):addx(400) end,
		OffCommand=function(s) s:decelerate(0.2):addx(-400) end,
	Def.Sprite{
		Texture="headerbox.png",
		InitCommand=function(s) s:halign(0) end,
	};
	Def.Sprite{
		Texture="headertext.png",
		InitCommand=function(s) s:x(190)
			:diffuseshift():effectcolor1(Alpha(Color.White,1)):effectcolor2(Alpha(Color.White,0.5)):effectperiod(2)
		end,
	};
}

t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_OptionsList/default.lua"))()..{
	InitCommand=function(s) s:draworder(100) end,
}

for pn in EnabledPlayers() do
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectCourse","decorations/_Difficulty"))(pn)..{
		InitCommand=function(s) s:diffusealpha(0):draworder(40)
			:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,_screen.cy-230)
		end,
		OnCommand=function(s) s:diffusealpha(0):linear(0.2):diffusealpha(1) end,
		OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
	};
end


return t;
