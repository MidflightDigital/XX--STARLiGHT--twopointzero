-- I got this idea for using a single sprite instead of PerChoiceScrollElement
-- from k//eternal's PROJEKTXV theme.
--
-- The "GameCommand" var is defined in ScreenSelectMaster.cpp:
--   LuaThreadVariable var("GameCommand", LuaReference::Create(&mc));
local style = Var("GameCommand"):GetName()

local ver = ""
if ThemePrefs.Get("SV") == "onepointzero" then
  ver = "1_"
end

-- Loads the graphic which matches the choice name from metrics.ini!
return Def.ActorFrame{
	OnCommand=function(s) s:addx(SCREEN_WIDTH):sleep(0.2):decelerate(0.2):addx(-SCREEN_WIDTH) end,
	OffCommand=function(s) s:linear(0.2):addx(SCREEN_WIDTH) end,
	GainFocusCommand=function(self)
		MESSAGEMAN:Broadcast("TitleSelection", {Choice=style})
	end,
	Def.Sprite{
		Texture=THEME:GetPathG("ScreenSelectMode","scroller/"..ver.."box"),
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/glow/24.ini",
		InitCommand=function(s)
			if THEME:HasString("ScreenTitleMenu",style) then
				s:settext(string.upper(THEME:GetString("ScreenTitleMenu",style)))
			else
				s:settext(string.upper(style))
			end
			s:DiffuseAndStroke(color("#dff0ff"),color("#00baffDD"))
		end,
	};
	Def.Sprite{
		Texture=ver.."hl",
		OnCommand=function(s) s:queuecommand("Anim") end,
		GainFocusCommand=function(s) s:finishtweening():queuecommand("Anim"):diffusealpha(0):linear(0.1):diffusealpha(1) end,
		LoseFocusCommand=function (s) s:finishtweening():linear(0.1):diffusealpha(0) end,
		AnimCommand=function(s) s:diffuseshift():effectcolor1(color("#00ffffDD")):effectcolor2(color("#00baff55")):effectperiod(1) end,
	};
	Def.Sprite{
		Texture=ver.."box",
		InitCommand=function(s) s:blend(Blend.Add) end,
		OnCommand=function(s) s:queuecommand("Anim") end,
		GainFocusCommand=function(s) s:finishtweening():queuecommand("Anim"):diffusealpha(0):linear(0.1):diffusealpha(1) end,
		LoseFocusCommand=function (s) s:finishtweening():linear(0.1):diffusealpha(0) end,
		AnimCommand=function(s) s:diffuseshift():effectcolor1(color("#00ffffDD")):effectcolor2(color("#00baff55")):effectperiod(1) end,
	};
};

