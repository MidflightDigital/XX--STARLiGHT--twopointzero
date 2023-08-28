return function( args )

	return Def.ActorFrame{
		Name="GroupChooser",
		BeginSearchCommand=function(self)
			self:GetChild("Click"):visible(false)
		end,
		UpdateSongInfoCommand=function(self,params)
			self:GetChild("Text"):settext( type(params.Data) == "table" and params.Data[1]:GetGroupName() or "" )
		end,
		OnCommand=function(self)
			local needsToShow = GAMESTATE:GetNumPlayersEnabled() == 1 and 1 or 0
			self:finishtweening():addy(20):diffusealpha(0):easeoutexpo(0.5):diffusealpha(needsToShow):addy(-20)
		end,
		OffCommand=function(self)
			self:stoptweening():easeinexpo(0.2):diffusealpha(0):addy(20)
		end,

		Def.Sprite{
			Texture=THEME:GetPathG("Folder","Icon"),
			InitCommand=function(self)
				self:zoom(0.36):x( -args.Width*.5 + 30 )
			end
		},
		
		Def.BitmapText{
			Font="_Bold",
			Name="Text",
			InitCommand=function(self)
				self:halign(0)
				:x( -args.Width*.5 + 50 )
				:zoom(0.8):maxwidth( args.Width - 20 )
			end
		},
	}
end