local pn = ...

local Center1Player = PREFSMAN:GetPreference('Center1Player')
local NumPlayers = GAMESTATE:GetNumPlayersEnabled()
local NumSides = GAMESTATE:GetNumSidesJoined()
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local st = GAMESTATE:GetCurrentStyle():GetStepsType()
local modre = GAMESTATE:PlayerIsUsingModifier(pn,'reverse')

local List = {
	"Tohoku EVOLVED",
	"COVID"
};

local function GradationWidth()
	if st == "StepsType_Dance_Double" then return (2);
	elseif st == "StepsType_Dance_Solo" then return (1.5);
	else return (1);
	end
end

local function DownGradationWidth()
	if st == "StepsType_Dance_Double" then return (SCREEN_WIDTH);
	elseif st == "StepsType_Dance_Solo" then return (384);
	else return (256);
	end
end

local function TextZoom()
	if st == "StepsType_Dance_Double" then return (1.61);
	elseif st == "StepsType_Dance_Solo" then return (1.3);
	else return (1);
	end
end

local FCCheck = {0,0}

local function IsFullCombo()
	if pss:FullCombo() or pss:FullComboOfScore('TapNoteScore_W4') then
		if pn == PLAYER_1 then FCCheck[1] = 1
		else
			FCCheck[2] = 1
		end
		return true
	else
		return false
	end
end

local t = Def.ActorFrame{
	OffCommand=function(s)
		if IsFullCombo() and not has_value(List,GAMESTATE:GetCurrentSong():GetDisplayMainTitle()) then
			local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")
			local CS = overlay:GetChild("ComboSplash"..ToEnumShortString(pn))
			if NumPlayers >= 2 then
				if FCCheck[1] == 1 and FCCheck[2] == 1 then
					CS:get():volume(0.25)
				end
			end
			CS:playforplayer(pn)
		end
	end,
};

local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
local NFWidth = GAMESTATE:GetCurrentStyle():GetWidth(pn)*(NumColumns/1.8)
for i=1,NumColumns do
	local ColumnInfo = GAMESTATE:GetCurrentStyle():GetColumnInfo(pn,i)
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s)
			s:diffusealpha(0)
			if modre then
				s:y(_screen.cy+(THEME:GetMetric("Player","ReceptorArrowsYReverse")+190))
			else
				s:y(_screen.cy+(THEME:GetMetric("Player","ReceptorArrowsYStandard")-190))
			end
		end,
		OffCommand = function(s)
			if IsFullCombo() then
				s:diffuse(FullComboEffectColor[pss:FullComboType()])
			end
		end,
		Def.Sprite{
			Texture="Star",
			InitCommand=function(s) s:blend(Blend.Add)
				s:x((NFWidth/1.6)-(i*tonumber(THEME:GetMetric("ArrowEffects","ArrowSpacing")*2.25)))
			end,
			OffCommand=function(s)
				if IsFullCombo() then
					s:diffusealpha(1):rotationz(-60):zoom(2):linear(0.5):zoom(0.3):rotationz(30)
					:linear(0.25):zoom(0):rotationz(120)
				end
			end,
		},
		Def.Sprite{
			Texture="SStar",
			InitCommand=function(s) s:zoom(0):blend(Blend.Add)
				s:x((NFWidth/1.6)-(i*tonumber(THEME:GetMetric("ArrowEffects","ArrowSpacing")*2.25)))
			end,
			OffCommand=function(s)
				if IsFullCombo() then
					s:diffuse(Color.White):sleep(0.65):diffusealpha(0.8)
					:zoomx(2):zoomy(0):linear(0.1):zoomy(2):rotationz(0):linear(0.5)
					:zoom(1.2):rotationz(90):diffusealpha(0.4):linear(0.05):diffusealpha(0)
				end
			end,
		}
	}
end

t[#t+1] = Def.ActorFrame{
	InitCommand=function(s) s:diffusealpha(0) end,
	OffCommand = function(s)
		if IsFullCombo() then
			s:diffuse(FullComboEffectColor[pss:FullComboType()])
		end
	end,
	--Up Gradient
	Def.Sprite{
		Texture="Down",
		InitCommand=function(s) s:valign(1)
			if modre then
				s:y(SCREEN_BOTTOM)
				:zoomy(1)
			else
				s:y(SCREEN_TOP):zoomy(-1)
			end
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				if modre then
					s:diffusealpha(0.5):zoomtowidth(NFWidth)
					:linear(0.25):diffusealpha(0.25):zoomtowidth(NFWidth+0.25):zoomy(2):linear(0.25)
					:zoomtowidth(NFWidth):zoomy(1.5):diffusealpha(0)
				else
					s:diffusealpha(0.5):zoomtowidth(NFWidth)
					:linear(0.25):diffusealpha(0.25):zoomtowidth(NFWidth+0.25):zoomy(-2):linear(0.25)
					:zoomtowidth(NFWidth):zoomy(-1.5):diffusealpha(0)
				end
			end
		end,
	},
	Def.Sprite{
		Texture="Star",
		InitCommand=function(s)
			s:blend(Blend.Add)
			if modre then
				s:y(_screen.cy+(THEME:GetMetric("Player","ReceptorArrowsYReverse")+190))
			else
				s:y(_screen.cy+(THEME:GetMetric("Player","ReceptorArrowsYStandard")-190))
			end
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				if modre then
					s:diffusealpha(1):zoomx(0):linear(0.1):zoomx(6):zoomy(1):linear(0.12)
					:zoomx(1):addy(-180):linear(0.36):addy(-1080)
				else
					s:diffusealpha(1):zoomx(0):linear(0.1):zoomx(6):zoomy(1):linear(0.12)
					:zoomx(1):addy(180):linear(0.36):addy(1080)
				end
			end
		end,
	},
	--Bottom Gradient
	Def.Sprite{
		Texture="Down",
		InitCommand=function(s) s:valign(1)
			if modre then
				s:y(SCREEN_TOP)
			else
				s:y(SCREEN_BOTTOM)
			end
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				if modre then
					s:y(SCREEN_TOP):diffusealpha(0):sleep(0.48):diffusealpha(0.5):zoomto(96,0):linear(0.5)
					:zoomto(NFWidth+42,-SCREEN_HEIGHT):linear(0.3):diffusealpha(0):zoomto(NFWidth,-SCREEN_HEIGHT)
				else
					s:y(SCREEN_BOTTOM):diffusealpha(0):sleep(0.48):diffusealpha(0.5):zoomto(96,0):linear(0.5)
					:zoomto(NFWidth+42,SCREEN_HEIGHT):linear(0.3):diffusealpha(0):zoomto(NFWidth,SCREEN_HEIGHT)
				end
			end
		end,
	},
	--Left Gradient
	Def.Sprite{
		Texture="Gradation",
		InitCommand=function(s)
			s:align(0,1)
			if modre then
				s:y(SCREEN_BOTTOM)
			else
				s:y(SCREEN_TOP)
			end
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				s:zoomx(1.125):zoomy(-0.75):diffusealpha(0)
				:sleep(0.24):diffusealpha(1):linear(0.24):zoomy(-1)
				:linear(0.5):zoomx(-1):addx(-21):linear(0.1):addx(-42):linear(0.2):addx(-(NFWidth/2)-96)
				:diffusealpha(0)
			end
		end,
	},
	--Right Gradient
	Def.Sprite{
		Texture="Gradation",
		InitCommand=function(s)
			s:align(0,1)
			if modre then
				s:y(SCREEN_BOTTOM)
			else
				s:y(SCREEN_TOP)
			end
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				s:zoomx(-1.125):zoomy(-0.75):diffusealpha(0)
				:sleep(0.24):diffusealpha(1):linear(0.24):zoomy(-1):linear(0.5)
				:zoomx(1):addx(21):linear(0.1):addx(42):linear(0.2):addx((NFWidth/2)+96)
				:diffusealpha(0)
			end
		end,
	},
	Def.Sprite{
		Texture="Star",
		InitCommand=function(s)
			s:blend(Blend.Add):zoom(0)
			s:y(_screen.cy)
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				s:sleep(0.65):diffusealpha(1):zoomx(3):zoomy(0):linear(0.1)
				:zoomy(3):rotationz(0):linear(0.5):zoom(1.8):rotationz(90):diffusealpha(0.4)
				:linear(0.05):diffusealpha(0)
			end
		end,
	},
	Def.Sprite{
		Texture="SStar",
		InitCommand=function(s)
			s:blend(Blend.Add):zoom(0)
			s:y(_screen.cy)
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				s:diffuse(Color.White):sleep(0.65):diffusealpha(0.8):zoomx(3):zoomy(0):linear(0.1)
				:zoomy(3):rotationz(0):linear(0.5):zoom(1.8):rotationz(90):diffusealpha(0.4)
				:linear(0.05):diffusealpha(0)
			end
		end,
	},
	Def.Sprite{
		Texture="Fullcombo01",
		InitCommand=function(s)
			s:zoom(0)
			s:y(_screen.cy)
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				s:sleep(0.65):zoomx(3):zoomy(0):linear(0.1):zoomy(3)
				:rotationz(0):linear(0.5):zoom(1.8):rotationz(90):linear(0.15)
				:zoomy(0):zoomx(0.75):diffusealpha(0)
			end
		end,
	},
	Def.Sprite{
		Texture="Fullcombo02",
		InitCommand=function(s)
			s:zoom(0)
			s:y(_screen.cy)
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				s:sleep(0.65):zoomx(6):zoomy(0):linear(0.1):zoomy(6)
				:rotationz(0):linear(0.5):zoom(1.875):rotationz(-90):linear(0.15)
				:zoomy(0):zoomx(0.75):diffusealpha(0)
			end
		end,
	},
	Def.Sprite{
		Texture="SStar",
		InitCommand=function(s)
			s:diffusealpha(0):blend(Blend.Add)
			s:y(_screen.cy)
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				if modre then
					s:diffusealpha(0.95):zoomx(0):linear(0.1):zoomx(6):zoomy(1)
					:linear(0.12):zoomx(1):addy(-180):linear(0.36):addy(-1080)
				else
					s:diffusealpha(0.95):zoomx(0):linear(0.1):zoomx(6):zoomy(1)
					:linear(0.12):zoomx(1):addy(180):linear(0.36):addy(1080)
				end
			end
		end,
	},
	Def.Sprite{
		InitCommand=function(s)
			s:y(_screen.cy)
		end,
		OffCommand=function(s)
			if IsFullCombo() then
				if pss:FullComboOfScore('TapNoteScore_W1') then
					s:Load(THEME:GetPathB("ScreenGameplay","overlay/FullCombo/FCM.png"))
				elseif pss:FullComboOfScore('TapNoteScore_W2') then
					s:Load(THEME:GetPathB("ScreenGameplay","overlay/FullCombo/FCP.png"))
				elseif pss:FullComboOfScore('TapNoteScore_W3') then
					s:Load(THEME:GetPathB("ScreenGameplay","overlay/FullCombo/FCGr.png"))
				elseif pss:FullComboOfScore('TapNoteScore_W4') or pss:FullComboOfScore('TapNoteScore_W5') then
					s:Load(THEME:GetPathB("ScreenGameplay","overlay/FullCombo/FCGo.png"))
				end
				s:diffusealpha(0):rotationz(-5):sleep(0.6):diffusealpha(1):zoomy(0)
				:linear(0.1):zoom(TextZoom()):linear(0.5):zoom(TextZoom()*1.73):linear(0.05)
				:diffusealpha(0.66):zoomx(TextZoom()*1.75):linear(0.1):zoomy(0):zoomx(TextZoom()*1.8):diffusealpha(0)
			end
		end,
	}
}

for i=1,(NumColumns*0.75) do
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(s)
			s:diffusealpha(0)
			if modre then
				s:y(_screen.cy+(THEME:GetMetric("Player","ReceptorArrowsYReverse")+190))
			else
				s:y(_screen.cy+(THEME:GetMetric("Player","ReceptorArrowsYStandard")-190))
			end
		end,
		OffCommand = function(s)
			if IsFullCombo() then
				s:diffuse(FullComboEffectColor[pss:FullComboType()])
			end
		end,
		Def.Sprite{
			Texture="Slim",
			InitCommand=function(s) s:blend(Blend.Add)
				s:x((NFWidth/2)-(i*tonumber(THEME:GetMetric("ArrowEffects","ArrowSpacing")*2.25)))
			end,
			OffCommand=function(s)
				if IsFullCombo() then
					s:diffusealpha(0.5):zoomx(0):zoomy(0.5):linear(0.25):diffusealpha(0.25)
					:zoomx(1):zoomy(1.75):linear(0.25):zoomx(0):zoomy(0.5):diffusealpha(0)
				end
			end,
		},

	}
end

return t