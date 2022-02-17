local SongAttributes = LoadModule "SongAttributes.lua"

local PS = Def.ActorFrame{};
for pn in EnabledPlayers() do
  PS[#PS+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/BannerDeco/TwoPart.lua"))(pn);
  PS[#PS+1] = Def.ActorFrame{
    InitCommand=function(s) s:xy(pn==PLAYER_1 and SCREEN_LEFT+200 or SCREEN_RIGHT-200,IsUsingWideScreen() and _screen.cy+220 or _screen.cy-240) end,
    CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
		["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
    loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler"))(pn);
    create_ddr_groove_radar("radar",0,0,pn,125,Alpha(PlayerColor(pn),0.25))..{
			OnCommand=function(s) s:zoom(0):rotationz(-360):decelerate(0.4):zoom(1):rotationz(0) end,
      OffCommand=function(s) s:sleep(0.3):decelerate(0.3):rotationz(-360):zoom(0) end,
    };
    Def.BitmapText{
			Font="_avenirnext lt pro bold/42px",
      InitCommand=function(s) s:shadowlengthy(5):y(-170):zoom(0) end,
      OnCommand=function(s) s:sleep(0.3):bounceend(0.25):zoom(0.75) end,
		  OffCommand=function(s) s:sleep(0.5):bouncebegin(0.25):zoom(0) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSteps(pn) then
					s:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())))
					s:diffuse(CustomDifficultyToColor(ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())))
				else
					s:settext("")
				end
			end,
		};
    Def.BitmapText{
			Font="CFBPMDisplay",
			InitCommand=function(s) s:y(130):diffuse(color("#dff0ff")):strokecolor(color("#00baff")):maxwidth(200) end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSteps(pn) then
          local sa = GAMESTATE:GetCurrentSteps(pn):GetAuthorCredit()
					s:settext(sa ~= "" and sa or "" )
				else
					s:settext("")
				end
			end,
		};
  };
  PS[#PS+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_ShockArrow/default.lua"))(pn)..{
    InitCommand=function(s)
        s:xy(pn==PLAYER_1 and _screen.cx-340 or _screen.cx+340,_screen.cy):zoom(0.5)
    end,
    SetCommand=function(s)
        local song = GAMESTATE:GetCurrentSong()
        if song then
            local steps = GAMESTATE:GetCurrentSteps(pn)
            if steps then
                if steps:GetRadarValues(pn):GetValue('RadarCategory_Mines') >= 1 then
                    s:queuecommand("Anim")
                else
                    s:queuecommand("Hide")
                end
            else
                s:queuecommand("Hide")
            end
        else
            s:queuecommand("Hide")
        end
    end,
    CurrentSongChangedMessageCommand=function(s) s:stoptweening():queuecommand("Set") end,
    ["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s) s:stoptweening():queuecommand("Set") end,
    OffCommand=function(s) s:queuecommand("Hide") end,	
}
end

return Def.ActorFrame{
  Def.Actor{
    Name="WheelActor",
    BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      mw:xy(_screen.cx,_screen.cy+240)
      SCREENMAN:GetTopScreen():GetChild("Header"):visible(false)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:diffusealpha(0):sleep(0.4):linear(0.1):diffusealpha(1):SetDrawByZPosition(true)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
    end,
    StartSelectingStepsMessageCommand=function(self)
      SCREENMAN:GetTopScreen():GetChild("Help"):diffusealpha(0)
    end;
    SongUnchosenMessageCommand=function(self)
      SCREENMAN:GetTopScreen():GetChild("Help"):diffusealpha(1)
    end;
  };
  Def.ActorFrame{
    InitCommand=function(self)
      self:xy(_screen.cx,SCREEN_BOTTOM+604):valign(1)
    end;
    StartSelectingStepsMessageCommand=function(self)
      self:stoptweening():decelerate(0.5):y(SCREEN_BOTTOM)
    end;
    SongUnchosenMessageCommand=function(self)
      self:stoptweening():decelerate(0.25):y(SCREEN_BOTTOM+604)
    end;
    OffCommand=function(self)
      self:stoptweening():decelerate(0.25):y(SCREEN_BOTTOM+604)
    end;
    Def.Quad{
      InitCommand=function(self)
        self:valign(1):setsize(SCREEN_WIDTH,604):y(4)
        :diffuse(color("0,0,0,0.5")):diffusebottomedge(color("0.5,0.3,1,0.5")):blend(Blend.Multiply)
      end;
    };
    Def.Sprite{
      Texture="backerthing",
      InitCommand=function(s) s:valign(1):y(0) end,
    };
    Def.BitmapText{
      Font="_avenirnext lt pro bold/25px",
      Text="&MENULEFT;&MENURIGHT; TO SELECT DIFFICULTY  &MENUUP;&MENUDOWN; TO CANCEL  &START; TO CONFIRM",
      InitCommand=function(s) s:y(-70):strokecolor(Color.Black) end,
    };
  };
  
  Def.Quad{
    InitCommand=function(s) s:MaskSource():xy(_screen.cx,_screen.cy-118):setsize(612,112) end,
  };
  Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx+10,_screen.cy-8):MaskDest():ztestmode("ZTestMode_WriteOnPass") end,
    OnCommand=function(s) s:addy(-100):sleep(0.3):decelerate(0.2):addy(100) end,
    OffCommand=function(s) s:sleep(0.2):bouncebegin(0.175):zoomy(0) end,
    CurrentSongChangedMessageCommand = function(s) s:queuecommand("Set") end,
    CurrentCourseChangedMessageCommand = function(s) s:queuecommand("Set") end,
    ChangedLanguageDisplayMessageCommand = function(s) s:queuecommand("Set") end,
    SetCommand=function(s)
      local song = GAMESTATE:GetCurrentSong()
      local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
      if not mw then return end
      if song then
        s:GetChild("Title"):visible(true):settext(song:GetDisplayFullTitle())
        :diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
        s:GetChild("Artist"):visible(true):settext(song:GetDisplayArtist()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
      elseif mw:GetSelectedType('WheelItemDataType_Section') then
        s:GetChild("Title"):visible(true):settext(SongAttributes.GetGroupName(mw:GetSelectedSection()))
        :diffuse(SongAttributes.GetGroupColor(mw:GetSelectedSection())):strokecolor(ColorDarkTone(SongAttributes.GetGroupColor(mw:GetSelectedSection())))
        s:GetChild("Artist"):visible(false):settext("")
      else
        s:GetChild("Title"):visible(true):settext("")
        s:GetChild("Artist"):visible(false):settext("")
      end
    end,
    Def.Sprite{
      Texture="songbox.png",
      InitCommand=function(s)
        if GAMESTATE:IsAnExtraStage() then
          s:Load(THEME:GetPathB("ScreenSelectMusic","overlay/BannerDeco/extra_songbox"))
        end
      end,
    };
    Def.BitmapText{
      Name="Title",
      Font="_avenir next demi bold/20px";
      InitCommand=function(s) s:maxwidth(480):strokecolor(Alpha(Color.Black,0.5)):y(-35) end,
    };
    Def.BitmapText{
      Name="Artist",
      Font="_avenir next demi bold/20px";
      InitCommand=function(s) s:maxwidth(480):y(-10):strokecolor(Alpha(Color.Black,0.5)) end,
    };
    loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/DefaultDeco/BPM"))(0.5)..{
      InitCommand=function(s) s:y(18) end,
    };
    loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_CDTITLE.lua"))(320,-10)..{
      InitCommand=function(s)
        s:visible(ThemePrefs.Get("CDTITLE"))
      end,
    }
  };
  PS;
}