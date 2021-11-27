local t = Def.ActorFrame{};
t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/Header/default.lua"))();

t[#t+1] = Def.Sprite{
  Texture=THEME:GetPathG("","ScreenWithMenuElements Header/old.png"),
  InitCommand=function(s) s:xy(_screen.cx,SCREEN_TOP+160) end,
  OnCommand=function(s)s :addx(-SCREEN_WIDTH):linear(0.2):addx(SCREEN_WIDTH) end,
  OffCommand=function(s)s :linear(0.2):addx(SCREEN_WIDTH) end,
};

t[#t+1] = StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
  InitCommand=function(s) s:zoom(1.25) end,
};

t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/DefaultDeco/BPM.lua"))(0.5)..{
  InitCommand=function(s) s:xy(_screen.cx,_screen.cy+10) end,
};

t[#t+1] = Def.Quad{
  InitCommand=function(self)
    self:valign(1)
    self:xy(_screen.cx,SCREEN_BOTTOM)
    self:setsize(SCREEN_WIDTH,578);
    self:diffuse(color("1,1,1,1")):diffusetopedge(color("0.5,0.5,1,1"))
  end;
  OnCommand=function(self)
    self:diffusealpha(0)
  end;
  StartSelectingStepsMessageCommand=function(self)
    self:linear(0.25)
    self:diffusealpha(0.75)
  end;
  SongUnchosenMessageCommand=function(self)
    self:linear(0.25)
    self:diffusealpha(0)
  end;
  OffCommand=function(self)
    self:linear(0.25)
    self:diffusealpha(0)
  end;
}

for pn in ivalues( GAMESTATE:GetHumanPlayers() ) do
  t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/BannerDeco/TwoPart.lua"))(pn);
end


for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
  t[#t+1] = Def.ActorFrame{
    InitCommand=function(s) s:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,RadarY()) end,
    loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler"))(pn);
    create_ddr_groove_radar("radar",0,0,pn,125,Alpha(PlayerColor(pn),0.25))..{
			OnCommand=function(s) s:zoom(0):rotationz(-360):decelerate(0.4):zoom(1):rotationz(0) end,
        	OffCommand=function(s) s:sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
		};

  };
end

local Textbox = Def.BitmapText{
  Font="_avenirnext lt pro bold 25px";
  InitCommand=function(s) s:maxwidth(480):strokecolor(Color.Black) end,
};

t[#t+1] = Def.ActorFrame{
	OnCommand=function(s) s:zoomy(0):sleep(0.3):bounceend(0.175):zoomy(1) end,
	OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
  InitCommand=function(s) s:xy(_screen.cx,_screen.cy-14) end,
  CurrentSongChangedMessageCommand = function(s) s:queuecommand("Set") end,
	CurrentCourseChangedMessageCommand = function(s) s:queuecommand("Set") end,
	ChangedLanguageDisplayMessageCommand = function(s) s:queuecommand("Set") end,
	Textbox..{
		SetCommand = function(self)
			local song = GAMESTATE:GetCurrentSong()
			self:settext(song and song:GetDisplayFullTitle() or "")
		end,
	};
	Textbox..{
		SetCommand = function(self)
			local song = GAMESTATE:GetCurrentSong()
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			if song then
				self:settext("");
			elseif mw:GetSelectedType('WheelItemDataType_Section') then
				local group = mw:GetSelectedSection()
				if group_name[group] ~= nil then
					self:settext(group_rename[group])
				else
					self:settext(group)
				end;
			else
				self:settext("");
			end;
		end,
	};
};

t[#t+1] = Def.Sprite{
  Texture="consel.png",
  InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM-40):visible(false) end,
  OnCommand=function(s) s:addy(100):decelerate(0.2):addy(-100) end,
  OffCommand=function(s) s:accelerate(0.2):addy(100) end,
  StartSelectingStepsMessageCommand=function(self)
    self:visible(true)
  end;
  SongUnchosenMessageCommand=function(self)
    self:visible(false)
  end;
};

return t;
