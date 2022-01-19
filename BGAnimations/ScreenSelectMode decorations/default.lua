local t = Def.ActorFrame{}

if GAMESTATE:GetCoinMode() == 'CoinMode_Home' then
--XXX: it's easier to have it up here

local heardBefore = false

t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:zoom(1)
	end;
	Def.Sound{
		File=GetMenuMusicPath "title",
		OnCommand=function(s) s:play() end,
	};
    loadfile(THEME:GetPathB("","_Logo/default.lua"))()..{
        InitCommand=function(s) s:Center() end,
    };
    Def.Sprite{
        Texture=THEME:GetPathB("","_Logo/xxlogo.png"),
        InitCommand=function(s) s:xy(_screen.cx+104,_screen.cy+16):blend(Blend.Add):diffusealpha(0):queuecommand("Anim") end,
        AnimCommand=function(s) s:diffusealpha(0):sleep(1):linear(0.75):diffusealpha(0.3):sleep(0.1):linear(0.4):diffusealpha(0):queuecommand("Anim") end,
    };
    loadfile(THEME:GetPathB("","_Dancer/default.lua"))()..{
        InitCommand = function(s) s:xy(_screen.cx-540,_screen.cy+30) end,
    };
	Def.Quad{
		InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0)) end,
		OnCommand=function(s) s:decelerate(0.4):diffusealpha(0.5) end,
	};
    loadfile(THEME:GetPathB("","_HudPanels/Header/default.lua"))();
	Def.ActorFrame{
		InitCommand=function(s) s:xy(_screen.cx-435,_screen.cy-10) end,
		OnCommand=function(s) s:addx(-SCREEN_WIDTH):sleep(0.2):decelerate(0.2):addx(SCREEN_WIDTH) end,
		OffCommand=function(s) s:linear(0.2):addx(-SCREEN_WIDTH) end,
		Def.Sprite{
			Texture="windowmid",
			TitleSelectionMessageCommand=function(self, params)
				self:finishtweening()
				if heardBefore then
					self:accelerate(0.1);
				else heardBefore = true end
				self:croptop(0.5):cropbottom(0.5):sleep(0.1):accelerate(0.2):croptop(0):cropbottom(0)
			end;
		};
		Def.Sprite{
			Name="ImageLoader";
			TitleSelectionMessageCommand=function(self, params)
				choice = string.lower(params.Choice)
				self:finishtweening()
				if heardBefore then
					self:accelerate(0.1);
				else heardBefore = true end
				self:croptop(0.5):cropbottom(0.5):queuecommand("TitleSelectionPart2")
			end;
			TitleSelectionPart2Command=function(self, params)
				self:Load(THEME:GetPathG("","_TitleImages/"..choice))
				self:sleep(0.1)
				self:accelerate(0.2);
				self:croptop(0):cropbottom(0)
			end;
			OffCommand=function(s) s:accelerate(.4):croptop(0.5):cropbottom(0.5) end,
		};
		Def.Sprite{
			Texture="windowtop",
			InitCommand=function(s) s:y(-172):valign(1) end,
			TitleSelectionMessageCommand=function(self, params)
				self:finishtweening()
				if heardBefore then
					self:accelerate(0.1);
				else heardBefore = true end
				self:y(0):sleep(0.1):accelerate(0.2):y(-172)
			end;
		};
		Def.Sprite{
			Texture="windowbottom",
			InitCommand=function(s) s:y(172):valign(0); end,
			TitleSelectionMessageCommand=function(self, params)
				self:finishtweening()
				if heardBefore then
					self:accelerate(0.1);
				else heardBefore = true end
				self:y(0):sleep(0.1):accelerate(0.2):y(172)
			end;
		};
	};
	Def.ActorFrame{
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy+276) end,
		OnCommand=function(s) s:zoomy(0):sleep(0.1):accelerate(0.3):zoomy(1) end,
		OffCommand=function(s) s:linear(0.2):zoomy(0) end,
		Def.Sprite{Texture="exp.png",};
		Def.Sprite{
			Texture="expglow.png",
			InitCommand=function(s) s:diffuseramp():effectcolor1(color("1,1,1,0.5")):effectcolor2(color("1,1,1,1")):effectperiod(1.5) end,
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px";
			Text="";
			InitCommand=function(self) self:hibernate(0.4):zoom(0.7):maxwidth(570):wrapwidthpixels(570):vertspacing(2) end;
			TitleSelectionMessageCommand=function(self, params) self:settext(THEME:GetString("ScreenTitleMenu","Description"..params.Choice)) end;
			OnCommand=function(s) s:cropbottom(1):sleep(0.1):accelerate(0.3):cropbottom(0) end,
		};
	}
};
end

--[[t[#t+1] = Def.ActorFrame {
	Def.BitmapText{
	Font="Common normal",
	Text=themeInfo["Name"] .. " " .. themeInfo["Version"] .. " by " .. themeInfo["Author"] .. (SN3Debug and " (debug mode)" or "") ,
	InitCommand=function(s) s:halign(1):xy(SCREEN_RIGHT-10,SCREEN_TOP+90):diffusealpha(0):wrapwidthpixels(400) end,
	OnCommand=function(s) s:sleep(0.3):decelerate(0.6):diffusealpha(0.5) end,
  };}]]

return t
