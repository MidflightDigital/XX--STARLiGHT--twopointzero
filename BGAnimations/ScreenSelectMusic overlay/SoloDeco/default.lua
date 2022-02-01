local SongAttributes = LoadModule "SongAttributes.lua"
local jk = LoadModule"Jacket.lua"

local t = Def.ActorFrame{
    Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
            mw:xy(SCREEN_RIGHT-500,_screen.cy+60)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:fov(60):vanishpoint(_screen.cx,_screen.cy)
			mw:SetDrawByZPosition(true)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:sleep(1):diffusealpha(0)
		end
    };
    OnCommand=function(s)
        local numwh = THEME:GetMetric("MusicWheel","NumWheelItems")+4
		if SCREENMAN:GetTopScreen() then
			local wheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetChild("MusicWheelItem")
			for i=1,numwh do
				local inv = numwh-math.round( (i-numwh/2) )+1
				wheel[i]:rotationx(180):diffusealpha(0)
				:sleep( (i < numwh/2) and i/20 or inv/20 )
				:bounceend(0.25):rotationx(0):diffusealpha(1)
			end
		end
    end;
    OffCommand=function(s)
        local numwh = THEME:GetMetric("MusicWheel","NumWheelItems")+4
		if SCREENMAN:GetTopScreen() then
			local wheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetChild("MusicWheelItem")
			for i=1,numwh do
				local inv = numwh-math.round( (i-numwh/2) )+1
				wheel[i]:sleep( (i < numwh/2) and i/20 or inv/20 )
				:bouncebegin(0.25):rotationx(360):diffusealpha(0)
			end
		end
    end;
};

t[#t+1] = StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
  InitCommand=function(s)
    s:xy(_screen.cx,SCREEN_TOP+104)
  end,
}

--Banner Area
t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:xy(SCREEN_LEFT+480,SCREEN_CENTER_Y-140):diffusealpha(1):draworder(1):fov(10) end,
  OffCommand=function(s) s:sleep(1):decelerate(1):addx(SCREEN_WIDTH) end,
  Def.ActorFrame{
    InitCommand=function(s) s:zoom(1.05) end,
    NextSongMessageCommand=function(s) s:stoptweening():rotationz(0):bounceend(0.3):rotationz(-360) end,
    PreviousSongMessageCommand=function(s) s:stoptweening():rotationz(0):bounceend(0.3):rotationz(360) end,
    Def.Sprite{
      Texture="JacketMask.png",
      InitCommand=function(s) s:MaskSource(true) end,
    };
    Def.Sprite{
      InitCommand=function(s) s:MaskDest():ztestmode("ZTestMode_WriteOnFail") end,
      CurrentSongChangedMessageCommand=function(s)
        local song = GAMESTATE:GetCurrentSong()
        local so = GAMESTATE:GetSortOrder();
        local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
        if not mw then return end
        if song then
          s:Load(jk.GetSongGraphicPath(song))
        elseif mw:GetSelectedType('WheelItemDataType_Section')  then
          if mw:GetSelectedSection() == "" then
            s:Load(THEME:GetPathG("","_jackets/Random"))
          else
            s:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Jacket",so))
          end
        else
          s:Load( THEME:GetPathG("","MusicWheelItem fallback") );
        end;
        s:setsize(430,430)
      end;
    };
  };
  Def.Sprite{
    Texture="JacketRing.png",
    CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
    SetCommand=function(s)
      local song = GAMESTATE:GetCurrentSong()
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			local so = ToEnumShortString(GAMESTATE:GetSortOrder())
			if not mw then return end
      s:diffuse(SongAttributes.GetGroupColor(mw:GetSelectedSection()))
    end
  };
};

t[#t+1] = Def.ActorFrame{
  --Group Name
  InitCommand=function(s) s:xy(SCREEN_LEFT+480,_screen.cy+110) end,
  Def.BitmapText{
    Font="_avenir next demi bold/20px",
    InitCommand=function(s) s:maxwidth(400):wrapwidthpixels(2^24):diffusealpha(0.5) end,
    CurrentSongChangedMessageCommand=function(s)
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      if not mw then return end
      if mw:GetSelectedType('WheelItemDataType_Section') then
        local group = mw:GetSelectedSection()
        if group then
          s:settext(GAMESTATE:GetSortOrder('SortOrder_Group') and SongAttributes.GetGroupName(group) or "")
        end
      else
        s:settext("")
      end
    end;
  };
};

t[#t+1] = Def.ActorFrame{
  InitCommand=function(s) s:xy(SCREEN_LEFT+480,SCREEN_CENTER_Y+180) end,
  Def.Sprite{
    Texture="DiffBack",
    InitCommand=function(s) s:diffusealpha(0.9) end,
  }
}

for pn in EnabledPlayers() do
  t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/SoloDeco/_Difficulty"))(pn)..{
		InitCommand=function(s) s:xy(SCREEN_LEFT+480,SCREEN_CENTER_Y+180) end,
	};
end

return t;
