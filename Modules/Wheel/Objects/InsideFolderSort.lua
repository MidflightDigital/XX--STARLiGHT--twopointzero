return function( args )

	return Def.ActorFrame{
		Name="SortingMethodsInsideFolder",
		BeginCommand=function(self)
			self:addx(-20):diffusealpha(0):easeoutexpo(0.5):diffusealpha(1):addx(20)
		end,
		OffCommand=function(self)
			self:stoptweening():easeinexpo(0.2):diffusealpha(0):addx(20)
		end,
		UpdateSongSortCommand=function(self,params)
			self:GetChild("Name"):settext(
				THEME:GetString("SortingModes", params.Mode)
			)
		end,

		Def.Text{
			Font=THEME:GetPathF("","IBMPlexSans-Bold.ttf"),
			Size=40,
			Text=THEME:GetString("LuaSelectMusic","SortContentFoldersBy"),
			InitCommand=function(self)
				self:xy( -args.Width*.5 + 10, -6 ):zoom(0.26):skewx(-0.2)
				:diffusealpha(0.8)
				:MainActor():halign(0):zoomtowidth(480)
				self:StrokeActor():visible(false)
			end
		},
		Def.BitmapText{
			Font="_Bold",
			Name="Name",
			InitCommand=function(self)
				self:halign(0):uppercase(true):y(6):zoom(0.8):maxwidth( 760 )
				:x( -args.Width*.5 + 10 )
			end
		},

	}
end