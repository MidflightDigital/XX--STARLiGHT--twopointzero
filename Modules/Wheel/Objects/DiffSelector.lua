local DiffSpacing = 46

return function( args )
	local player = args.Player
	local lastIndex = 1
	-- The difficulties.
	local Diffs = Def.ActorFrame{
		Name="Diffs",
	}

	for i = 1,6 do
		Diffs[#Diffs+1] = Def.ActorFrame{
			UpdateDiffsCommand=function(self,params,Diff)
				local newdata = params.Data[i+1]
				local actor = self:GetChild("DiffItem")
				local large = self:GetChild("LargeDiff")
				actor:x(player == PLAYER_1 and (-SCREEN_WIDTH/5) or (SCREEN_WIDTH/5))

				self:stoptweening()
				actor:stoptweening():linear(0.1)
				if newdata then
					actor:visible(true)
					actor:GetChild("DiffBlock"):diffuse( GameColor.Difficulty[ newdata:GetDifficulty() ] )
					actor:GetChild("Meter"):settext(newdata:GetMeter())
					if i == params.Index-1 then
						actor:x(player == PLAYER_1 and (-SCREEN_WIDTH/5)+10 or (SCREEN_WIDTH/5)-10)
						large:visible(true)
						large:GetChild("DiffName"):settext(THEME:GetString("CustomDifficulty",ToEnumShortString(newdata:GetDifficulty())) )
						:diffuse(GameColor.Difficulty[newdata:GetDifficulty()])
						large:GetChild("LargeMeter"):settext(newdata:GetMeter())
					else
						actor:x(player == PLAYER_1 and (-SCREEN_WIDTH/5)+0 or (SCREEN_WIDTH/5)-0)
						large:visible(false)
					end
				else
					actor:visible(false)
					large:visible(false)
				end

			end,
			Def.ActorFrame{
				Name="DiffItem",
				InitCommand=function(s) s:y(-160) end,
				Def.Quad{
					Name="DiffBlock",
					InitCommand=function(s)
						s:setsize(5,36):xy(player == PLAYER_1 and -4 or 4,DiffSpacing*i)
					end,
				},
				Def.BitmapText{
					Name="Meter",
					Font="_avenirnext lt pro bold/25px",
					InitCommand=function(s,params) s:halign(player == PLAYER_1 and 0 or 1):diffuse(Color.Black):strokecolor(color("#dedede"))
						:xy(player == PLAYER_1 and 14 or -14,DiffSpacing*i)
					end,
				};
			},
			Def.ActorFrame{
				Name="LargeDiff",
				Def.BitmapText{
					Name="DiffName",
					Font="_avenirnext lt pro bold/42px",
					OnCommand=function(s) s:y(-180):shadowlengthy(5) end,
				},
				Def.BitmapText{
					Name="LargeMeter",
					Font="ScreenSelectMusic difficulty",
					OnCommand=function(s) s:y(20):shadowlengthy(5) end,
				},
			}
		}
	end

	local t = Def.ActorFrame{
		Name="DiffSelector",
		Def.ActorFrame{
			Name="Radar",
			Def.Sprite{
				Texture=THEME:GetPathG("","_SelectMusic/Default/RadarBase.png"),
				InitCommand=function(s) s:y(10):blend(Blend.Add):zoom(1.35):diffuse(ColorMidTone(PlayerColor(player))):diffusealpha(0.75) end,
			};
		};
		create_ddr_groove_radar("radar",0,20,player,350,Alpha(PlayerColor(player),0.25))..{
			Name="Radar",
		};
		Diffs..{
			PlayerSwitchedStepMessageCommand=function(self,params)
				if params.Player ~= args.Player then return end
				if not GAMESTATE:IsPlayerEnabled(args.Player) then return end
				if type(params.Song) == "string" then
					-- lua.ReportScriptError("not song")
					self:stoptweening():linear(0.1):diffusealpha(0)
					return
				end
	
				self:stoptweening():linear(0.1):diffusealpha(1)
	
				local curSteps = params.Song[params.Index]
	
				self:playcommand("UpdateDiffs",{Data=params.Song,Index = params.Index})
			end,
		},
	}

	return t
end
