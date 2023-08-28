--[[
	Generates a layout with two buttons and a middle info pane.
	{
		Width = number,
		Height = number,
		Pos = { number, number } (Optional, default is {0,0} (TopLeft of screen)),
		IsValueIncremental = bool (Optional),
		Choices = { string/function/number } (Optional) (Only not IsValueIncremental),
		Steps = number (Only IsValueIncremental),
		Values = { string/function/number } (Only not IsValueIncremental),
		Load = function( self )
			-- self gives the items from the table..
			-- If IsValueIncremental is on, self.Values is nil.

			-- This function must return a number value.
		end,
		NotifyOfSelection = function( self, Value )
			-- NOTE: Self in this case, is not the table itself, but the
			-- button click area correspondant of where the user has clicked.
			-- Value is the current result index selected by the user.
		end,
		Save = function( self, Value )
			-- If IsValueIncremental is on, self.Values is nil.
			-- Value is the end result index selected by the user.
		end
	}
]]
return function( Attr )
    Attr.Pos = Attr.Pos or {0,0}
	local isincremental = Attr.IsValueIncremental
	local curoption = 1

	local ButtonLeftPos = -Attr.Width*.4

	if not isincremental then
		assert( Attr.Values , "No table with values has been found.")
	else
		Attr.Steps = Attr.Steps or 1
	end

    local t = Def.ActorFrame{
        InitCommand=function(self)
			self:xy( Attr.Pos[1], Attr.Pos[2] )
			self:GetChild("ButtonL"):x( -Attr.Width*.4 )
			self:GetChild("ButtonR"):x( Attr.Width*.4 )
			
			-- Set the initial position of the slider.
			if Attr.Load then
				curoption = Attr.Load( Attr )
			end

			self:playcommand("UpdateCurrentOption",{ Val = 0 })
			self:GetChild("CurrentVal"):xy( 0,-8 ):zoom(
				LoadModule("Lua.Resize.lua")(
					self:GetChild("CurrentVal"):GetZoomedWidth(),
					self:GetChild("CurrentVal"):GetZoomedHeight(),
					Attr.Width*.34, Attr.Height
				)
			)
		end,
		UpdateCurrentOptionCommand=function(self,param)
			curoption = curoption + param.Val

			if not isincremental then
				if curoption < 1 then curoption = 1 end
				if curoption > #Attr.Values then curoption = #Attr.Values end
				self:GetChild("IndexButton"):playcommand("HandleInput")
			end

			self:GetChild("CurrentVal"):settext(
				isincremental and curoption or ( Attr.Choices and Attr.Choices[curoption] or Attr.Values[curoption])
			)
		end,
		OffCommand=function(self)
			if Attr.Save ~= nil then
				Attr.Save( Attr, curoption )
			end
		end
    }

	-- Check the ammount of items, and separate the elements.
	t[#t+1] = LoadModule( "UI/UI.ButtonBox.lua" )( Attr.Width*.68, Attr.Height )..{ Name = "BG" }
	
	t[#t+1] = LoadModule( "UI/UI.ButtonBox.lua" )( 64, Attr.Height )..{ Name = "ButtonL" }
	t[#t+1] = LoadModule( "UI/UI.ClickArea.lua" )( Attr, 64, Attr.Height, function(self)
		self:GetParent():GetChild("ButtonR"):stoptweening():diffuse( color("#777777") ):easeoutquint(0.5):diffuse(Color.White)
		self:GetParent():playcommand("UpdateCurrentOption",{ Val = isincremental and Attr.Steps or 1 })
		Attr.NotifyOfSelection( self, curoption )
    end).. {
		InitCommand=function(self)
			self:x( Attr.Width*.4 )
		end
	}

	t[#t+1] = LoadModule( "UI/UI.ButtonBox.lua" )( 64, Attr.Height )..{ Name = "ButtonR" }
	t[#t+1] = LoadModule( "UI/UI.ClickArea.lua" )( Attr, 64, Attr.Height, function(self)
		self:GetParent():GetChild("ButtonL"):stoptweening():diffuse( color("#777777") ):easeoutquint(0.5):diffuse(Color.White)
		self:GetParent():playcommand("UpdateCurrentOption",{ Val = isincremental and -Attr.Steps or -1 })
		Attr.NotifyOfSelection( self, curoption )
    end).. {
		InitCommand=function(self)
			self:x( -Attr.Width*.4 )
		end
	}

	local VertGallery = {
		RightTriangle = {
			{ {-(64*.2),-15,0}, Color.White },
			{ {(64*.2),0,0}, Color.White },
			{ {-(64*.2),15,0}, Color.White },
		},
		LeftTriangle = {
			{ {(64*.2),-15,0}, Color.White },
			{ {-(64*.2),0,0}, Color.White },
			{ {(64*.2),15,0}, Color.White },
		},
		Plus = {
			-- Horizontal block
			{ {-(72*.2),-5,0}, Color.White },
			{ {-(72*.2),5,0}, Color.White },
			{ {(72*.2),5,0}, Color.White },
			{ {(72*.2),-5,0}, Color.White },

			-- Vertical block
			{ {-5,-(72*.2),0}, Color.White },
			{ {-5,(72*.2),0}, Color.White },
			{ {5,(72*.2),0}, Color.White },
			{ {5,-(72*.2),0}, Color.White },
		},
		Minus = {
			-- Horizontal block
			{ {-(72*.2),-5,0}, Color.White },
			{ {-(72*.2),5,0}, Color.White },
			{ {(72*.2),5,0}, Color.White },
			{ {(72*.2),-5,0}, Color.White },
		}
	}

	local statetype = "DrawMode_".. (isincremental and "Quads" or "Triangles")

	t[#t+1] = Def.ActorMultiVertex{
		InitCommand=function(self)
			self:SetDrawState{ Mode=statetype }
			self:x( Attr.Width*.4 )
			:SetVertices(
				isincremental and VertGallery.Plus or VertGallery.RightTriangle
			)
		end
	}

	t[#t+1] = Def.ActorMultiVertex{
		InitCommand=function(self)
			self:SetDrawState{ Mode=statetype }
			self:x( -Attr.Width*.4 )
			:SetVertices(
				isincremental and VertGallery.Minus or VertGallery.LeftTriangle
			)
		end
	}

	local sliderwidth = Attr.Width*.8
	local sliderheight = Attr.Height*.35

	t[#t+1] = Def.BitmapText{
		Font = "Common Normal",
		Name = "CurrentVal",
	}

	if not isincremental then
		local indexbutton = Def.ActorFrame{
			Name="IndexButton",
			InitCommand=function(self) self:y(12) end,
			HandleInputCommand=function(self,param)
				if #Attr.Values < 2 then return end

				for i = 1, #Attr.Values do
					self:GetChild("")[i]:diffuse( curoption == i and Color.White or color("#777777") )
				end
			end
		}
		for k,v in pairs( Attr.Values ) do
			indexbutton[#indexbutton+1] = Def.Quad{
				InitCommand=function(self)
					self:zoomto(8,8):x( scale( k, 1, #Attr.Values, -Attr.Width*.2, Attr.Width*.2 ) )
				end
			}
		end
		t[#t+1] = indexbutton
	end
    return t
end

--[[
	Copyright 2021 Jose Varela, Project OutFox

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]]