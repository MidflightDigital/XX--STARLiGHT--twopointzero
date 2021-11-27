local xPosPlayer = {
    P1 = SCREEN_LEFT+16,
    P2 = SCREEN_RIGHT-16
}

local ex = ""

if GAMESTATE:IsAnExtraStage() then
	ex = "ex_"
end


local yval
if GAMESTATE:IsDemonstration() then
	yval = SCREEN_BOTTOM-140
else
	yval = SCREEN_BOTTOM-60;
end

local t = Def.ActorFrame{};

--TextBanner
t[#t+1] = Def.ActorFrame{
	InitCommand=function(s)
		if GAMESTATE:IsDemonstration() then
			s:visible(false)
		else
			s:visible(true)
		end
	end,
	Def.ActorFrame{
		InitCommand=function(s) s:xy(_screen.cx,yval+6) end,
		Def.Sprite{
			Texture=ex.."mid.png",
		};
		Def.Sprite{
			Texture=ex.."midglow.png",
			OnCommand=function(s)
				s:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.5")):effectclock('beatnooffset')
			end
		},
	},
	Def.TextBanner{
		InitCommand = function(self) self:Load("TextBannerGameplay")
	  		:x(SCREEN_CENTER_X):y(yval+6):zoom(1.1)
	  		if GAMESTATE:GetCurrentSong() then
				self:SetFromSong(GAMESTATE:GetCurrentSong())
	  		end
		end;
		CurrentSongChangedMessageCommand = function(self)
	  		self:SetFromSong(GAMESTATE:GetCurrentSong())
		end;
	}
};

--ScoreFrames
for _,pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	local profileID = GetProfileIDForPlayer(ToEnumShortString(pn))
	local pPrefs = ProfilePrefs.Read(profileID)
t[#t+1] = Def.ActorFrame{
	InitCommand=function(s)
		local short = ToEnumShortString(pn)
		s:x(xPosPlayer[short])
	end,
	Def.ActorFrame{
		InitCommand=function(s) s:zoom(IsUsingWideScreen() and 1 or 0.8):y(yval) end,
		Def.Sprite{
			Texture=ex.."frame",
			InitCommand=function(s) s:rotationy(pn==PLAYER_1 and 0 or 180):halign(0) end,
		};
		loadfile(THEME:GetPathB("ScreenGameplay","decorations/scoreframe/score_counter"))(pn,pPrefs);
	};
	Def.ActorFrame{
		InitCommand=function(s)
			s:x(GAMESTATE:PlayerIsUsingModifier(pn,'reverse') and 0 or (pn==PLAYER_2 and 21 or 0))
			s:y(GAMESTATE:PlayerIsUsingModifier(pn,'reverse') and (IsUsingWideScreen() and SCREEN_TOP+134 or SCREEN_TOP+111) or (IsUsingWideScreen() and yval-50 or yval-40))
			s:zoom(IsUsingWideScreen() and 1 or 0.8)
		end,
		Def.Sprite{
			Texture=ex.."diffframe",
			InitCommand=function(self)
				self:rotationx(GAMESTATE:PlayerIsUsingModifier(pn,'reverse') and 180 or 0)
				self:halign(pn==PLAYER_2 and 1 or 0)
			end;
		};
		Def.ActorFrame{
			InitCommand=function(s)
				s:y(GAMESTATE:PlayerIsUsingModifier(pn,'reverse') and -4 or 6)
			end,
			Def.ActorFrame{
				InitCommand=function(self)
					local steps;
					if GAMESTATE:IsCourseMode() then
						steps = ToEnumShortString(GAMESTATE:GetCurrentTrail(pn):GetDifficulty());
					else
						steps = ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty());
					end
					local diffP1X = {
						["Beginner"] = 176,
						["Easy"] = 156,
						["Medium"] = 176,
						["Hard"] = 160,
						["Challenge"] = 176,
						["Edit"] = 156,
					};
					local diffP2X = {
						["Beginner"] = -352,
						["Easy"] = -368,
						["Medium"] = -352,
						["Hard"] = -364,
						["Challenge"] = -352,
						["Edit"] = -136,
					};
					self:x(pn==PLAYER_2 and diffP2X[steps] or diffP1X[steps])
				end;
				Def.BitmapText{
					Font="_avenirnext lt pro bold 20px",
					Name="Diff Label",
					SetCommand=function(s)
						s:halign(1)
						local diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty();
						s:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff))):uppercase(true):diffuse(CustomDifficultyToColor(diff))
					end;
					CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
				};
				Def.BitmapText{
					Font="_avenirnext lt pro bold 20px",
					Name = "Difficulty Meter";
					InitCommand=function(self)
						self:x(16)
					end;
					SetCommand=function(s)
						  local meter = GAMESTATE:GetCurrentSteps(pn):GetMeter()
						s:settext(meter)
					end;
					CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
				};
			};
			Def.ActorFrame{
				InitCommand=function(self)
					self:x(pn==PLAYER_2 and -170 or 360)
					self:playcommand("Set")
				end;
				CurrentSongChangedMessageCommand=function(s) s:queuecommand("Set") end,
				Def.BitmapText{
					InitCommand=function(s) s:visible(pPrefs.scorelabel == "Profile") end,
					Font="_avenirnext lt pro bold 20px",
					Name = "Profile Name";
					SetCommand=function(s)
						s:maxwidth(150);
						s:settext(PROFILEMAN:GetProfile(pn):GetDisplayName())
					end;
				};
				loadfile(THEME:GetPathB("ScreenGameplay","decorations/scoreframe/BPMDisplay.lua"))()..{
					InitCommand=function(s) s:visible(pPrefs.scorelabel == "BPM") end,
				}
			};
			
		}
	}
};

end;

return t;
