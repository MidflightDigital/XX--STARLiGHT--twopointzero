local pn = ...
local Radar = LoadModule('DDR Groove Radar.lua')
local ScoreAndGrade = LoadModule('ScoreAndGrade.lua')

local ver = ""
if ThemePrefs.Get("SV") == "onepointzero" then
	ver = "1_"
end

local function XPOS(self,offset)
	self:x(pn==PLAYER_1 and (SCREEN_LEFT+240)+offset or (SCREEN_RIGHT-240)+offset)
end

local yspacing = 32
local keyset={}

for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
	if not keyset[pn] then
		keyset[pn] = false
	end
end

local function PlayerPanel()
	local t = Def.ActorFrame{}
	
	t[#t+1] = Def.ActorFrame{
		SetCommand=function(s)
			local c = s:GetChildren()
			
			local SongOrCourse, StepsOrTrail
			if GAMESTATE:IsCourseMode() then
				SongOrCourse = GAMESTATE:GetCurrentCourse()
				StepsOrTrail = GAMESTATE:GetCurrentTrail(pn)
			else
				SongOrCourse = GAMESTATE:GetCurrentSong()
				StepsOrTrail = GAMESTATE:GetCurrentSteps(pn)
			end
			
			if not (SongOrCourse and StepsOrTrail) then
				c.Text_name:settext('')
				c.Text_score:visible(false)
				c.Text_judgments:settext("0\n0\n0\n0\n0\n0")
				c.Grade:visible(false)
				return
			end
			
			local profile
			if PROFILEMAN:IsPersistentProfile(pn) then
				profile = PROFILEMAN:GetProfile(pn)
			else
				profile = PROFILEMAN:GetMachineProfile()
			end
			local scores = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()
			local score = scores[1]
			
			if not score then
				c.Text_name:settext('')
				c.Text_score:visible(false)
				c.Text_judgments:settext("0\n0\n0\n0\n0\n0")
				c.Grade:visible(false)
				return
			end
			c.Text_name:settext(score:GetName())
			c.Text_score:visible(true)
			c.Grade:visible(true)
			s:playcommand('SetScore', { Stats = score, Steps = StepsOrTrail })
			
			local marvelous = score:GetTapNoteScore("TapNoteScore_W1")
			local perfects = score:GetTapNoteScore("TapNoteScore_W2")
			local greats = score:GetTapNoteScore("TapNoteScore_W3")
			local goods = score:GetTapNoteScore("TapNoteScore_W4")
			local oks = score:GetHoldNoteScore("HoldNoteScore_Held")
			local misses = score:GetTapNoteScore("TapNoteScore_W5")+score:GetTapNoteScore("TapNoteScore_Miss")+score:GetTapNoteScore("TapNoteScore_CheckpointMiss")
			c.Text_judgments:settext(
				marvelous .. '\n' ..
				perfects .. '\n' ..
				greats .. '\n' ..
				goods .. '\n' ..
				oks .. '\n' ..
				misses
			)
		end,
		Def.Sprite{
			Name="Bar_underlay",
			Texture="playerbacker",
			InitCommand=function(s) s:y(-20) end,
		},
		Def.BitmapText{
			Font="Common normal",
			Text="",
			Name="Text_name",
			InitCommand=function(s) s:y(-34):maxwidth(300/0.8):zoom(0.8) end,
		},
		ScoreAndGrade.CreateScoreRollingActor{
			Name='Text_score',
			Font='_avenirnext lt pro bold/25px',
			Load='RollingNumbersSongData',
			InitCommand=function(self)
				self:xy(50,-6):zoom(1):halign(1)
			end,
		},
		ScoreAndGrade.CreateGradeActor{
  		Name='Grade',
			InitCommand=function(self)
				self:xy(70,-6)
			end,
		},
		Def.BitmapText{
			Font="Common normal",
			Name="Text_judgmenttitles",
			InitCommand=function(s) s:zoom(0.9):halign(0):addx(-140):addy(80) end,
			OnCommand=function(s) s:settext("Marvelous\nPerfect\nGreat\nGood\nOK\nMiss") end,
		},
		Def.BitmapText{
			Font="Common normal",
			Name="Text_judgments",
			InitCommand=function(s) s:zoom(0.9):halign(1):addx(120):addy(80) end,
		},
	}
	return t
end

local difficulties = {
	'Difficulty_Beginner',
	'Difficulty_Easy',
	'Difficulty_Medium',
	'Difficulty_Hard',
	'Difficulty_Challenge',
	'Difficulty_Edit',
}
local function DifficultyPanel()
	local t = Def.ActorFrame{}
	for diff in ivalues(difficulties) do
		t[#t+1] = Def.ActorFrame{
			InitCommand=function(s) s:y((Difficulty:Reverse()[diff] * yspacing)) end,
			SetCommand=function(s)
				local c = s:GetChildren()
				
				local SongOrCourse, StepsOrTrail, curDiff
				if GAMESTATE:IsCourseMode() then
					SongOrCourse = GAMESTATE:GetCurrentCourse()
					StepsOrTrail = GAMESTATE:GetCurrentTrail(pn)
					curDiff = StepsOrTrail:GetDifficulty()
				else
					SongOrCourse = GAMESTATE:GetCurrentSong()
					if SongOrCourse then
						local stepType = GAMESTATE:GetCurrentStyle():GetStepsType()
						StepsOrTrail = SongOrCourse:GetOneSteps(stepType, diff)
					end
					curDiff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty()
				end
				
				if not (SongOrCourse and StepsOrTrail) then
					c.Bar_underlay:diffuse(Alpha(Color.White,0.2))
					c.Text_meter:visible(false)
					c.Text_difficulty:visible(false)
					c.Text_score:visible(false)
					c.Grade:visible(false)
					return
				end
				local diffColor = CustomDifficultyToColor(diff)
				
				c.Text_meter:visible(true)
				c.Text_meter:settext(IsMeterDec(StepsOrTrail:GetMeter()))

				c.Text_difficulty:visible(true)
				c.Text_difficulty:settext(THEME:GetString('CustomDifficulty', ToEnumShortString(diff)))
				c.Text_difficulty:diffuse(diffColor)
				
				if diff == curDiff then
					c.Bar_underlay:diffuse(diffColor)
				else
					c.Bar_underlay:diffuse(Color.White)
				end
				
				local profile
				if PROFILEMAN:IsPersistentProfile(pn) then
					profile = PROFILEMAN:GetProfile(pn)
				else
					profile = PROFILEMAN:GetMachineProfile()
				end
				local scores = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()
				local score = scores[1]
				
				if not score then
					c.Text_score:visible(false)
					c.Grade:visible(false)
					return
				end
				c.Text_score:visible(true)
				c.Grade:visible(true)
				
				s:playcommand('SetScore', { Stats = score, Steps = StepsOrTrail })
			end,
			Def.ActorFrame{
				Name='Bar_underlay',
				Def.Quad{
					InitCommand=function(s) s:setsize(312,26):faderight(0.75):diffusealpha(0.5) end,
				},
				Def.Quad{
					InitCommand=function(s) s:y(-12):setsize(312,2):faderight(0.5):diffusealpha(0.5) end,
				},
			},
			Def.BitmapText{
				Font='_avenirnext lt pro bold/25px',
				Name='Text_meter',
				InitCommand=function(s) s:x(-6):strokecolor(Alpha(Color.Black,0.5)) end,
			},
			Def.BitmapText{
				Font='_avenirnext lt pro bold/20px',
				Name='Text_difficulty',
				InitCommand=function(s) s:x(-150):halign(0):strokecolor(Alpha(Color.Black,0.5)) end,
			},
			ScoreAndGrade.CreateScoreActor{
				Name='Text_score',
				Font='_avenirnext lt pro bold/20px',
				InitCommand=function(self)
					self:x(120):halign(1):diffuse(Color.White):strokecolor(Color.Black)
				end,
			},
			ScoreAndGrade.CreateGradeActor{
				Name='Grade',
				InitCommand=function(self)
					self:x(146)
				end,
			},
		}
	end
	return t
end

local function RivalsPanel()
	local t = Def.ActorFrame{}
	local rivals = {1, 2, 3, 4, 5}
	for idx, rival in ipairs(rivals) do
		t[#t+1] = Def.ActorFrame{
			InitCommand=function(s) s:y((idx - 1)*yspacing) end,
			SetCommand=function(s)
				local c = s:GetChildren()
				
				local SongOrCourse, StepsOrTrail
				if GAMESTATE:IsCourseMode() then
					SongOrCourse = GAMESTATE:GetCurrentCourse()
					StepsOrTrail = GAMESTATE:GetCurrentTrail(pn)
				else
					SongOrCourse = GAMESTATE:GetCurrentSong()
					StepsOrTrail = GAMESTATE:GetCurrentSteps(pn)
				end
				
				if not (SongOrCourse and StepsOrTrail) then
					c.Bar_underlay:diffuse(Alpha(Color.White, 0.2))
					c.Text_score:visible(false)
					c.Text_name:visible(false)
					c.Grade:visible(false)
					return
				end
				
				local profile
				if PROFILEMAN:IsPersistentProfile(pn) then
					profile = PROFILEMAN:GetProfile(pn)
				else
					profile = PROFILEMAN:GetMachineProfile()
				end
				local scores = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()
				local score = scores[rival]
				
				if not score then
					c.Bar_underlay:diffuse(Alpha(Color.White, 0.2))
					c.Text_score:visible(false)
					c.Text_name:visible(false)
					c.Grade:visible(false)
					return
				end
				c.Bar_underlay:diffuse(Color.White)
				c.Text_score:visible(true)
				c.Text_name:visible(true)
				c.Grade:visible(true)
				
				if rival == 1 then
					c.Bar_place:diffuse(color("#3cbbf6"))
				elseif rival == 2 then
					c.Bar_place:diffuse(color("#d6d7d4"))
				elseif rival == 3 then
					c.Bar_place:diffuse(color("#f6cc40"))
				else
					c.Bar_place:diffuse(color("#f22133"))
				end
				
				local name = score:GetName()
				if not name or name == ''  then
					c.Text_name:settext('(NO NAME)')
				else
					c.Text_name:settext(name)
				end
				
				s:playcommand('SetScore', { Stats = score, Steps = StepsOrTrail })
			end,
			Def.ActorFrame{
				Name='Bar_underlay',
				Def.Quad{
					InitCommand=function(s) s:setsize(312,26):faderight(0.75):diffusealpha(0.5) end,
				},
				Def.Quad{
					InitCommand=function(s) s:y(-12):setsize(312,2):faderight(0.5):diffusealpha(0.5) end,
				},
			},
			Def.Quad{
				Name='Bar_place',
				InitCommand=function(s) s:x(-140):setsize(20,20) end,
			},
			Def.BitmapText{
				Font='_avenirnext lt pro bold/25px',
				Name='Text_place',
				Text=rival,
				InitCommand=function(s) s:x(-140):strokecolor(Alpha(Color.Black,0.5)):zoom(0.7) end,
			},
			Def.BitmapText{
				Name='Text_name',
				Font='_avenirnext lt pro bold/20px',
				InitCommand=function(s) s:x(-120):halign(0):diffuse(Color.White):strokecolor(Color.Black) end,
			},
			ScoreAndGrade.CreateScoreActor{
				Name='Text_score',
				Font='_avenirnext lt pro bold/20px',
				InitCommand=function(self)
					self:x(120):halign(1):diffuse(Color.White):strokecolor(Color.Black)
				end,
			},
			ScoreAndGrade.CreateGradeActor{
				Name='Grade',
				InitCommand=function(self)
					self:x(146)
				end,
			},
		}
	end
	return t
end

local function RadarPanel()
	local GR = {
		{-1,-122, "Stream"}, --STREAM
		{-120,-43, "Voltage"}, --VOLTAGE
		{-108,72, "Air"}, --AIR
		{108,72, "Freeze"}, --FREEZE
		{120,-43, "Chaos"}, --CHAOS
	}
	local t = Def.ActorFrame{}
	t[#t+1] = Def.ActorFrame{
		Def.ActorFrame{
			Name="Radar",
			Def.Sprite{
				Texture=THEME:GetPathG("","_shared/Radar/"..ver.."GrooveRadar base.png"),
			},
			Def.Sprite{
				Texture=THEME:GetPathG("","_shared/Radar/sweep.png"),
				InitCommand = function(s) s:zoom(1.35):spin():effectmagnitude(0,0,100) end,
			},
			Radar.create_ddr_groove_radar("radar",0,0,pn,125,Alpha(PlayerColor(pn),0.25)),
		}
	}
	for i,v in ipairs(GR) do
		t[#t+1] = Def.ActorFrame{
			InitCommand=function(s)
				s:xy(v[1],v[2])
			end,
			Def.Sprite{
				Texture=THEME:GetPathG("","_shared/Radar/"..ver.."RLabels"),
				OnCommand=function(s) s:animate(0):setstate(i-1) end,
			},
			Def.BitmapText{
				Font="_avenirnext lt pro bold/20px",
				SetCommand=function(s)
					local song = GAMESTATE:GetCurrentSong()
					if song then
						local steps = GAMESTATE:GetCurrentSteps(pn)
						local value = lookup_ddr_radar_values(song, steps, pn)[i]
						s:settext(math.floor(value*100+0.5))
					else
						s:settext("")
					end
					s:strokecolor(color("#1f1f1f")):y(28)
				end,
			}
		}
	end
	return t
end

local function PlayerInfo(pn)
	return Def.ActorFrame{
		PlayerPanel()..{
			InitCommand=function(s) s:valign(1):y(-20) end
		}
	}
end

local function Scroller(pn)
	local t = Def.ActorFrame{}
	t[#t+1] = Def.ActorScroller{
		Name="ScrollerMain",
		NumItemsToDraw=1,
		SecondsPerItem=0.1,
		OnCommand=function(s)
			s:SetDestinationItem(0):SetFastCatchup(true)
			:SetMask(320,20):fov(60):zwrite(true):draworder(8):z(8)
		end,
		TransformFunction=function(s,o,i,n)
			s:x(math.floor(o*(10))):diffusealpha(1-math.abs(o))
		end,
		CodeMessageCommand=function(s,p)
			local DI = s:GetCurrentItem()
			if p.PlayerNumber == pn and keyset[pn] then
				if p.Name=="PaneLeft" then
					if DI>0 then
						s:SetDestinationItem(DI-1)
						SOUND:PlayOnce(THEME:GetPathS("","MusicWheel expand"))
					end
				end
				if p.Name=="PaneRight" then
					if DI<2 then
						s:SetDestinationItem(DI+1)
						SOUND:PlayOnce(THEME:GetPathS("","MusicWheel expand"))
					end
				end
			end
		end,
		Def.ActorFrame{
			Name="ScrollerItem1",
			DifficultyPanel()..{
				InitCommand=function(s) s:y(-260) end
			},
			Def.BitmapText{
				Font="_stagetext",
				Text="DIFFICULTY INFORMATION",
				Name="Header",
				InitCommand=function(s) s:zoom(0.7):y(-290):DiffuseAndStroke(color("#dff0ff"),color("0,0.7,1,0.5")) end,
			},
		},
		Def.ActorFrame{
			Name="ScrollerItem2",
			RadarPanel()..{
				InitCommand=function(s) s:y(-165):zoom(0.8) end,
			},
			Def.BitmapText{
				Font="_stagetext",
				Text="RADAR INFORMATION",
				Name="Header",
				InitCommand=function(s) s:zoom(0.7):y(-290):DiffuseAndStroke(color("#dff0ff"),color("0,0.7,1,0.5")) end,
			},
		},
		-- scores
		Def.ActorFrame{
			Name="ScrollerItem3",
			RivalsPanel()..{
				InitCommand=function(s) s:y(-260) end,
			},
			Def.BitmapText{
				Font="_stagetext",
				Text="RIVAL INFORMATION",
				Name="Header",
				InitCommand=function(s) s:zoom(0.7):y(-290):DiffuseAndStroke(color("#dff0ff"),color("0,0.7,1,0.5")) end,
			},
		},
	}
	return t
end

local t = Def.ActorFrame{
	InitCommand=function(s,p) XPOS(s,0) s:visible(false)
	end,
	OffCommand=function(s) s:sleep(0.5):decelerate(0.3):addx(pn==PLAYER_1 and -500 or 500) end,
	BeginCommand=function(s) s:playcommand("Set") end,
	CurrentSongChangedMessageCommand=function(s,p) s:queuecommand("Set") end,
	["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s,p) s:queuecommand("Set") end,
	["CurrentTrail"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(s,p) s:queuecommand("Set") end,
	CodeMessageCommand=function(s,p)
		
		if p.PlayerNumber == pn then
			if p.Name == "OpenPanes1" or p.Name == "OpenPanesEFUp" then
				if keyset[pn] == false then
					keyset[pn] = true
				else
					keyset[pn] = false
				end
				s:visible(keyset[pn])
				SOUND:PlayOnce(THEME:GetPathS("MusicWheel","expand"))
			end
		end
	end,
	Def.Sprite{
		Texture="backer.png",
	},
	PlayerInfo(pn)..{
		InitCommand=function(s) s:addy(90) end,
	},
	Scroller(pn)..{
		InitCommand=function(s) s:addy(90) end,
	},
	Def.BitmapText{
		Font="_stagetext",
		Text="[PRESS ARROW PANELS TO CHANGE WINDOWS]",
		InitCommand=function(s) s:zoom(0.5):y(240):DiffuseAndStroke(color("#dff0ff"),color("0,0.7,1,0.5")) end,
	},
}

return t
