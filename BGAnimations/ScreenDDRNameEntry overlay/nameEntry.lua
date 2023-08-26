local player = ...

local CHARACTER_MAP = {
{"A","B","C","D","E","F","G","H","I","J"},
{"K","L","M","N","O","P","Q","R","S","T"},
{"U","V","W","X","Y","Z"},
{"0","1","2","3","4","5","6","7","8","9"},
{"?","!","$","&","-","."," ","←","Enter"}
}

local SELECTION_X, SELECTION_Y = 1,1

local name = "";
setenv("keysetSDDRN"..ToEnumShortString(player),0)

local p1finished, p2finished = false, false;
function genLetterBox()
	local f = Def.ActorFrame{}
	for rowNum, row in ipairs(CHARACTER_MAP) do
		for colNum, character in ipairs(row) do
			f[#f+1] = Def.ActorFrame{
				InitCommand=function(s)
					if character == "Enter" then
						s:x(53*colNum)
					else
						s:x(50*colNum)
					end
					s:y(50*rowNum)
				end,
				Def.Sprite{
					InitCommand=function(s)
						if character == "Enter" then
							s:Load(THEME:GetPathB("ScreenDDRNameEntry","overlay/endBOX"))
						else
							s:Load(THEME:GetPathB("ScreenDDRNameEntry","overlay/letterBOX"))
						end
					end
				};
				Def.BitmapText{
					Font="_avenirnext lt pro bold/42px",
					InitCommand=function(s)
						if character == "Enter" or character == "←" then
							s:diffuse(Color.White):zoom(0.8):addx(-2)
						else
							s:diffuse(color("#deff02")):zoom(1)
						end
						s:settext(character)
					end
				}
			}
		end
	end
	return f
end

local t = Def.ActorFrame{
	Def.ActorFrame{
		Name="Panes",
		Def.ActorFrame{
			InitCommand=function(self)
				self:shadowlength(0):zoomy(0)
			end;
			OnCommand=function(s) s:sleep(0.3):linear(0.3):zoomy(1) end,
			OffCommand=function(self)
				self:linear(0.1):zoomy(0)
			end;
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/BG01"),
			};
			Def.Quad{
				InitCommand=function(s) s:setsize(512,440):y(-20):diffuse(Alpha(Color.Black,0.75)) end,
			};
		};
		Def.ActorFrame{
			InitCommand=function(s) s:y(-292) end,
			OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(-292) end,
     		OffCommand=function(self)
				self:linear(0.1):y(0):sleep(0):diffusealpha(0)
			end;
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/BGTOP_"..ToEnumShortString(player)),
				InitCommand=function(s) s:valign(1) end,
			};
		};
		Def.ActorFrame{
			Name="Bottom";
			InitCommand=function(self)
			  self:shadowlength(0)
			end;
			OnCommand=function(s) s:y(0):sleep(0.3):linear(0.3):y(286) end,
			OffCommand=function(self)
				self:linear(0.1):y(0):sleep(0):diffusealpha(0)
			end;
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/BGBOTTOM"),
				InitCommand=function(s) s:valign(0) end,
			};
			Def.Sprite{
				Texture=THEME:GetPathG("","ScreenSelectProfile/start game"),
			  	InitCommand=function(s) s:valign(0):diffusealpha(0) end,
			  	OnCommand=function(s) s:sleep(0.8):diffusealpha(1) end,
			};
		};
	},
	Def.ActorFrame{
		InitCommand=function(s) s:hibernate(0.6) end,
		OffCommand=function(s) s:diffusealpha(0) end,
		genLetterBox()..{
			InitCommand=function(s) s:xy(-276,-120) end,
		};
		Def.Quad{
			InitCommand=function(s) s:xy(-228,-68):diffuse(Alpha(Color.Red,0.75)):blend(Blend.Add):setsize(40,35) end,
			NextScreenCommand=function(s)
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
			end,
			CodeMessageCommand=function(s, params)
				if params.PlayerNumber ~= player then return end
				if getenv("SDDRNJoined"..player) == 1 then
					if params.Name == "Left" or params.Name == "Left2" then
						if SELECTION_X == 1 and SELECTION_Y == 1 then
							SELECTION_X = 9
							SELECTION_Y = 5
						elseif SELECTION_X > 1 then
							SELECTION_X = SELECTION_X -1
						elseif SELECTION_Y > 1 then
							SELECTION_Y = SELECTION_Y-1
							SELECTION_X = #CHARACTER_MAP[SELECTION_Y]
						end
						SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change"), true)
					elseif params.Name == "Right" or params.Name == "Right2" then
						if SELECTION_X == 9 and SELECTION_Y == 5 then
							SELECTION_X = 1
							SELECTION_Y = 1
						elseif SELECTION_X < #CHARACTER_MAP[SELECTION_Y] then
							SELECTION_X = SELECTION_X + 1;
						elseif SELECTION_Y < #CHARACTER_MAP then
							SELECTION_X = 1
							SELECTION_Y = SELECTION_Y+1
						end
						SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change"), true)
					elseif params.Name == "Up" or params.Name == "Up2" then
						if SELECTION_Y == 1 then
							SELECTION_Y = 5
							if SELECTION_X == 10 then
								SELECTION_X = 9
							end
						elseif SELECTION_Y == 4 and (SELECTION_X >= 7 and SELECTION_X <= #CHARACTER_MAP[SELECTION_Y]) then
							SELECTION_Y = 2
						elseif SELECTION_Y > 1  and SELECTION_X < #CHARACTER_MAP[SELECTION_Y-1]+1 then
							SELECTION_Y = SELECTION_Y - 1;
						end
						SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change"), true)
					elseif params.Name == "Down" or params.Name == "Down2" then
						if SELECTION_Y == 4 and SELECTION_X == 10 then
							SELECTION_Y = 5
							SELECTION_X = 9
						elseif SELECTION_Y == 5 then
							SELECTION_Y = 1
							if SELECTION_X == 9 then
								SELECTION_X = 10
							end
						elseif SELECTION_Y == 2 and (SELECTION_X >= 7 and SELECTION_X <= #CHARACTER_MAP[SELECTION_Y]) then
							SELECTION_Y = 4
						elseif SELECTION_Y < #CHARACTER_MAP and SELECTION_X < #CHARACTER_MAP[SELECTION_Y+1]+1 then
							SELECTION_Y = SELECTION_Y + 1
						end
						SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change"), true)
					elseif params.Name == "Start" then
						local selection = CHARACTER_MAP[SELECTION_Y][SELECTION_X]
						if selection == "Enter" then
							if string.len(name) == 0 then
								name = "STARLGHT"
							end
							PROFILEMAN:GetProfile(player):SetDisplayName(name)
							setenv("keysetSDDRN"..ToEnumShortString(player),1)
							if GAMESTATE:GetNumPlayersEnabled() == 1 then
								local mp = GAMESTATE:GetMasterPlayerNumber()
								s:sleep(0.5):queuecommand("NextScreen")
							else
								if getenv("keysetSDDRNP1") == 1 and getenv("keysetSDDRNP2") == 1 then
									s:sleep(0.5):queuecommand("NextScreen")
								end
							end
						elseif selection == "←" then
							if string.len(name) > 0 then
								name=string.sub(name,1,-2)
							else
								name=""
							end
						else
							if string.len(name) < 7 then
								name=name..selection
							else
								SELECTION_X = 9
								SELECTION_Y = 5
								if string.len(name) < 7 or string.len(name) ~= 8 then
									name=name..selection
								end
							end
						end
						SOUND:PlayOnce(THEME:GetPathS("Common","start"), true)
					end;
				
					local selection = CHARACTER_MAP[SELECTION_Y][SELECTION_X]
					if selection == "Enter" then
						s:x((53*SELECTION_X)-276)
						s:setsize(92,35)
					else
						s:x((50*SELECTION_X)-276):setsize(40,35)
					end
					s:y((50*SELECTION_Y)-120)
					s:GetParent():GetChild("NameActor"):settext(name)
				end
			end;
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/36px",
			InitCommand=function(s) s:xy(-250,-190):halign(0):zoom(0.9):strokecolor(Color.Black) end,
			Text="Register a DANCER NAME.\nEnter the name you want to use."
		};
		Def.Sprite{
			Texture="nameframe",
			InitCommand=function(s) s:y(-120) end,
		};
		Def.BitmapText{
			Font="DDRName Large",
			Name="NameActor";
			InitCommand=function(s) s:halign(1):xy(256,-120) end,
		};
	}

};
	

return t;