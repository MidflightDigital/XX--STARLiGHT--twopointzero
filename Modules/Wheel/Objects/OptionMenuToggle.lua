return function( args )
	local function ObtainSpeedType( pOptions )
		local sptype = 1
        if pOptions:XMod() then sptype = 1 end
        if pOptions:CMod() then sptype = 2 end
        if pOptions:MMod() then sptype = 3 end
        if pOptions:AMod() then sptype = 4 end
        if pOptions:CAMod() then sptype = 5 end

		return sptype
	end

	local function GetSpeed( pOptions, CurType )
		local stype = CurType or ObtainSpeedType(pOptions)

		if stype == 1 then return pOptions:XMod()*100 end
        if stype == 2 then return pOptions:CMod() end
        if stype == 3 then return pOptions:MMod() end
        if stype == 4 then return pOptions:AMod() end
        if stype == 5 then return pOptions:CAMod() end

		return 0
	end

	local speedCalc = LoadModule("Gameplay/Speed.Calculate.lua")
	local t = Def.ActorFrame{
		InitCommand=function(self)
			self:xy( -args.Width*.5 + 50 ,SCREEN_CENTER_Y + 45)
			self:playcommand("ObtainSpeedChange")
		end,
		CurrentSongChangedMessageCommand=function(self)
			self:playcommand("ObtainSpeedChange")
		end,
		PlayerSwitchedStepMessageCommand=function(self,params)
			if params.Player ~= args.Player then return end
			if not GAMESTATE:IsPlayerEnabled(args.Player) then return end
			if type(params.Song) == "string" then
				-- lua.ReportScriptError("not song")
				self:stoptweening():linear(0.1):diffusealpha(0)
				return
			end
			self:stoptweening():linear(0.1):diffusealpha(1)

			
			local curSteps = params.Song[ params.Index ]
			local colboost = BoostColor( ColorDarkTone(GameColor.Difficulty[ curSteps:GetDifficulty() ]), 0.95)
			-- self:GetChild("MainBG"):stoptweening():linear(0.1):diffuse( BoostColor(colboost, 2.2)  )
		end,
		ObtainSpeedChangeCommand=function(self,params)
			local type = params and params.Type or nil
			local speed = params and params.Speed or nil
			local sp,info,ratedsp = speedCalc( args.Player, type, speed )
			
			if sp and info then
				self:GetChild("SpeedInfo"):settext( sp )
				if sp == ratedsp or not ratedsp then
					self:GetChild("RateIndicator"):visible(false)
					self:GetChild("RateSpeedInfo"):visible(false)
				else
					local SIWidth = self:GetChild("SpeedInfo"):GetZoomedWidth()
					self:GetChild("RateIndicator"):visible(true):x( SIWidth + 20 )
					self:GetChild("RateSpeedInfo"):visible(true):settext( ratedsp )
					:x( SIWidth + 24 )
				end
				self:GetChild("CurrentSpeed"):settext( info )
			end
		end,
		SpeedChangeMessageCommand=function(self,params)
			self:playcommand("ObtainSpeedChange",params)
		end,
		PlayerOptionChangeMessageCommand=function(self,params)
			if params.Option ~= "MusicRate" then return end
			self:playcommand("ObtainSpeedChange",params)
		end,
	}
	
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(self)
			self:zoom(0.6):x(-25)
		end,
		PlayerOptionChangeMessageCommand=function(self,params)
			-- lua.ReportScriptError(rin_inspect(params))
			if params.Option == "NoteSkin" and params.Player == args.Player then
				-- Clean out the actorframe from it's actors.
				self:RemoveAllChildren()

				-- And now load the noteskin.
				self:AddChild(
					function()
						return NOTESKIN:LoadActorForNoteSkin( "Left", "Tap Note", GAMESTATE:GetPlayerState(args.Player):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin() )
					end
				)
			end
		end,
		NOTESKIN:LoadActorForNoteSkin( "Left", "Tap Note", GAMESTATE:GetPlayerState(args.Player):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin() )
	}

	t[#t+1] = Def.BitmapText{
		Font="_Bold",
		Name="CurrentSpeed",
		InitCommand=function(self)
			self:halign(0):xy( 0, -8 ):diffuse(ColorLightTone(PlayerColor(args.Player)))
		end
	}

	t[#t+1] = Def.BitmapText{
		Font="_Bold",
		Name="SpeedInfo",
		InitCommand=function(self)
			self:zoom(0.7):halign(0):xy( 0, 10 ):diffuse(PlayerColor(args.Player))
		end
	}

	t[#t+1] = Def.Sprite{
		Texture=THEME:GetPathG("","UI/Back"),
		Name="RateIndicator",
		InitCommand=function(self)
			self:zoom(0.5):halign(0):xy( 74, 10 )
			:rotationz(180)
		end
	}

	t[#t+1] = Def.BitmapText{
		Font="_Bold",
		Name="RateSpeedInfo",
		InitCommand=function(self)
			self:zoom(0.7):halign(0):xy( 78, 10 ):diffuse(PlayerColor(args.Player))
		end
	}

	t[#t+1] = Def.ActorFrame{
		Name="ButtonAction",
		Condition = args.Touch,
		InitCommand=function(self)
			self:x( args.Width*.5 )
		end,
		LoadModule("UI/UI.ButtonBox.lua")(args.Width*.5, 38, 2, args.Player)..{
			OnCommand=function(self) self:x( 40 ) end
		},

		Def.BitmapText{
			Font="_Bold",
			Text=ToUpper("Options"),
			InitCommand=function(self)
				self:zoom(0.8):halign(0):x( -10 )
				:diffuse(ColorLightTone(PlayerColor(args.Player)))
			end
		},
	
		LoadModule("UI/UI.ClickArea.lua"){
			Width = args.Width*.5,
			Height = 38,
			Debug = true,
			Position = function(self)
				self:x( 40 )
			end,
			Action = function(self)
				args.ActionPress()
				-- self:halign(0):diffuse(ColorLightTone(PlayerColor(args.Player)))
			end
		}
	}

	return t
end