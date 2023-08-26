local t = Def.ActorFrame{
	Def.Actor{
        Name="WheelActor",
        BeginCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:xy(_screen.cx,_screen.cy-160)
			SCREENMAN:GetTopScreen():GetChild("Header"):visible(false)
		end,
		OnCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:fov(75):rotationx(-55)
			:diffusealpha(0):linear(0.25):diffusealpha(1)
			mw:SetDrawByZPosition(true)
		end,
		OffCommand=function(s)
			local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
			mw:bouncebegin(0.15):zoomx(3):diffusealpha(0)
		end
    };
};
local jk = LoadModule "Jacket.lua"

-- Left/right arrows that bounce to the beat
for i=1,2 do
	Name="Arrows";
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s) s:xy(i==1 and _screen.cx-320 or _screen.cx+320,SCREEN_BOTTOM-260):zoomx(i==1 and 1.5 or -1.5):zoomy(1.5)
			:rotationz(i==1 and 15 or -15)
		end,
		OnCommand=function(s)
			s:diffusealpha(0):addx(i==1 and -100 or 100)
			:sleep(0.6):decelerate(0.3):addx(i==1 and 100 or -100):diffusealpha(1)
			s:bounce():effectclock("beat"):effectperiod(1):effectmagnitude(i==2 and 10 or -10,0,0):effectoffset(0.2)
		end,
		OffCommand=function(s) s:smooth(0.2):addx(i==1 and-50 or 50):diffusealpha(0) end,
		NextSongMessageCommand=function(s)
			if i==2 then s:stoptweening():x(_screen.cx+340):decelerate(0.5):x(_screen.cx+320) end
		end, 
		PreviousSongMessageCommand=function(s)
			if i==1 then s:stoptweening():x(_screen.cx-340):decelerate(0.5):x(_screen.cx-320) end
		end, 
		Def.Sprite{
			Texture=THEME:GetPathG("","_shared/garrows/_selectarroww");
			InitCommand=function(s) s:diffuse(color("#5bec19")) end,
			NextSongMessageCommand=function(s)
				if i==2 then
					s:stoptweening():diffuse(color("#f51a32")):sleep(0.5):diffuse(color("#5bec19"))
				end
			end, 
			PreviousSongMessageCommand=function(s)
				if i==1 then
					s:stoptweening():diffuse(color("#f51a32")):sleep(0.5):diffuse(color("#5bec19"))
				end
			end, 
		};
	};
end;

for pn in ivalues( GAMESTATE:GetHumanPlayers() ) do
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_Difficulty/default.lua"))(pn)..{
		InitCommand=function(s) s:xy(pn==PLAYER_1 and SCREEN_LEFT+250 or SCREEN_RIGHT-250,_screen.cy+250):draworder(40) end,
	}
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s) s:xy(pn==PLAYER_1 and SCREEN_LEFT+250 or SCREEN_RIGHT-250,_screen.cy+100) end,
		loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/RadarHandler"))(pn);
		Def.BitmapText{
			Font="CFBPMDisplay",
			InitCommand=function(s) s:zoom(0.7):diffuse(color("#dff0ff")):strokecolor(color("#00baff")):maxwidth(200):y(60) end,
			OffCommand=function(s) s:sleep(0.3):decelerate(0.3):diffusealpha(0) end,
			CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
			SetCommand=function(s)
				if GAMESTATE:GetCurrentSong() then
					if GAMESTATE:GetCurrentSteps(pn) then
						if GAMESTATE:GetCurrentSteps(pn):GetAuthorCredit() ~= "" then
							s:settext("Step Credits: \n"..GAMESTATE:GetCurrentSteps(pn):GetAuthorCredit())
						else
							s:settext("Step Credits: \n")
						end
					else
						s:settext("")
					end
				else
					s:settext("")
				end
			end,
		};
	}
	t[#t+1] = loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/_ShockArrow/default.lua"))(pn)..{
		InitCommand=function(s)
			s:xy(pn==PLAYER_1 and SCREEN_LEFT+370 or SCREEN_RIGHT-370,_screen.cy+15):zoom(0.3)
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
	SongUnchosenMessageCommand=function(s) 
		s:sleep(0.2):queuecommand("Remove")
	end,
	RemoveCommand=function(s) s:RemoveChild("TwoPartDiff") end,
	SongChosenMessageCommand=function(self)
		self:AddChildFromPath(THEME:GetPathB("ScreenSelectMusic","overlay/TwoPartDiff"));
	end;
	Def.Sprite{
		Texture="Header.png",
		InitCommand=function(s) s:xy(_screen.cx,SCREEN_TOP):valign(0) end,
		OnCommand=function(s) s:addy(-220):sleep(0.1):decelerate(0.2):addy(220) end,
		OffCommand=function(s) s:accelerate(0.2):addy(-220) end,
	};
	Def.ActorFrame{
		Name="FocusedCD",
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy+200):diffusealpha(0) end,
		CurrentSongChangedMessageCommand=function(s) s:finishtweening():linear(0.1):addy(-SCREEN_HEIGHT):linear(0.1):addy(SCREEN_HEIGHT) end,
		OffCommand=function(s) s:finishtweening():sleep(0.1):linear(0.1):addy(-200):sleep(0.1):accelerate(0.15):zoom(5):rotationz(360):diffusealpha(0) end,
		OnCommand=function(s) s:diffusealpha(1) end,
		Def.Sprite{
			Texture=THEME:GetPathG("","MusicWheelItem Song NormalPart/Jukebox/cd/cd_mask"),
			InitCommand=function(s) s:blend(Blend.NoEffect):zwrite(1):clearzbuffer(true) end,
			CurrentSongChangedMessageCommand=function(s,p)
				local song = GAMESTATE:GetCurrentSong()
				if song then
					local songtit = song:GetDisplayMainTitle()
					if CDImage[songtit] ~= nil or jk.DoesSongHaveCD(song) == true then
						s:visible(false)
					else
						s:visible(true)
					end
				else
					s:visible(false)
				end
			end,
		};
		Def.Sprite{
			BeginCommand=function(s) s:queuecommand("Set") end,
			CurrentSongChangedMessageCommand=function(s,p)
				local song = GAMESTATE:GetCurrentSong();
				local so = GAMESTATE:GetSortOrder();
				local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
				if not mw then return end
				if song then
					s:ztest(1)
					local songtit = song:GetDisplayMainTitle();
					if CDImage[songtit] ~= nil then
						local diskImage = CDImage[songtit];
						s:Load(THEME:GetPathG("","MusicWheelItem Song NormalPart/Jukebox/cd/"..diskImage));
						s:zoomtowidth(475):zoomtoheight(475);
					else
						s:Load(jk.GetSongGraphicPath(song,"CD"))
					end
				elseif mw:GetSelectedType('WheelItemDataType_Section') then
					s:ztest(0)
					s:Load(jk.GetGroupGraphicPath(mw:GetSelectedSection(),"Jacket",so))
				else
					s:Load( THEME:GetPathG("","MusicWheelItem fallback") );
				end
				s:scaletofit(-237.5,-237.5,237.5,237.5)
			end,
		};
		Def.Sprite{
			CurrentSongChangedMessageCommand=function(s)
				if not GAMESTATE:IsAnExtraStage() then
					local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
					if not mw then return end
					if mw:GetSelectedType() == 'WheelItemDataType_Custom' then
						s:Load(THEME:GetPathG("","_jackets/COURSE.png")):visible(true)
					else
						s:visible(false)
					end
					s:scaletofit(-237.5,-237.5,237.5,237.5)
				end
			end,
		};
		Def.Sprite{
			Name="SongLength",
			Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
			InitCommand=function(s) s:animate(0):zoom(0.75):xy(160,0) end,
			CurrentSongChangedMessageCommand=function(s,p)
				local song = GAMESTATE:GetCurrentSong()
				if song then
					if song:IsLong() then
						s:setstate(0)
						s:visible(true)
					elseif song:IsMarathon() then
						s:setstate(1)
						s:visible(true)
					else
						s:visible(false)
					end
				else
					s:visible(false)
				end
			end,
		};
		Def.Sprite{
			InitCommand=function(s) s:visible(false) end,
			Texture=THEME:GetPathG("","MusicWheelItem Song NormalPart/Jukebox/cd/overlay"),
			CurrentSongChangedMessageCommand=function(s)
				local song = GAMESTATE:GetCurrentSong();
				if song then
					local songtit = song:GetDisplayMainTitle();
					if CDImage[songtit] ~= nil or jk.DoesSongHaveCD(song) == true then
						s:visible(false)
					else
						s:visible(true)
					end
				else
					s:visible(false)
				end
			end,
		};
	};
	loadfile(THEME:GetPathB("ScreenSelectMusic","overlay/JukeboxDeco/BannerHandler.lua"))(jk);
	t;
	StandardDecorationFromFileOptional("StageDisplay","StageDisplay")..{
		InitCommand=function(s) s:xy(_screen.cx-234,_screen.cy-270):zoom(1):draworder(100):halign(0) end,
	};
}
