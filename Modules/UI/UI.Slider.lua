-- Generates a slider with a background element.
-- Maximum values are asigned to via a list, which determines the ammount of steps, which are separate click areas,
-- to fill in the approximation.

-- { width, height, xpos, ypos, action, addactors }
return function( Attr )
    Attr.Pos = Attr.Pos or {0,0}
	local curoption = 1
    local t = Def.ActorFrame{
        InitCommand=function(self)
            self.height = Attr.Height
			self:GetChild("BG"):xy( Attr.Pos[1], Attr.Pos[2] )
			self:GetChild("Slider"):xy( Attr.Pos[1], Attr.Pos[2] + (Attr.Height*.25) )
			self:GetChild("BGSlider"):xy( Attr.Pos[1], Attr.Pos[2] + (Attr.Height*.25) )
			self:GetChild("CurrentVal"):xy(
				Attr.Pos[1] + (Attr.Width*.45),
				Attr.Pos[2] - (Attr.Height*.25)
			)
			
			-- Set the initial position of the slider.
			if Attr.Load then
				curoption = Attr.Load( Attr.Values )
				self:GetChild("Slider"):x(  Attr.Pos[1] + scale( curoption, 1, #Attr.Values, -Attr.Width*.4, Attr.Width*.4 ) )
			end
		end,
		UpdateCurrentOptionCommand=function(self,param)
			curoption = param.Val
			self:GetChild("Slider"):stoptweening():decelerate(0.1)
			:x( Attr.Pos[1] + scale( param.Val, 1, #Attr.Values, -Attr.Width*.4, Attr.Width*.4 ) )

			self:GetChild("CurrentVal"):settext( Attr.Values[param.Val] )
		end
    }

	-- Check the ammount of items, and separate the elements.

	t[#t+1] = LoadModule( "UI/UI.ButtonBox.lua" )( Attr.Width, Attr.Height )..{ Name = "BG" }
	--[[
	t[#t+1] = LoadModule( "UI/UI.ClickArea.lua" )( Attr.Width, Attr.Height, function(self)
        --if not GAMESTATE:Env()["OpenedDropdown"] and Attr.Action then
        --    Attr.Action(self)
        --    self:GetParent():GetChild("BG"):stoptweening():diffuse( color("#777777") ):tween(0.5,"easeoutquint"):diffuse(Color.White)
        --end
    end)
	]]

	local sliderwidth = Attr.Width*.8
	local sliderheight = Attr.Height*.35

	for k,v in pairs( Attr.Values ) do
		t[#t+1] = LoadModule( "UI/UI.ClickArea.lua" ){
				Width = (Attr.Width*.85) / #Attr.Values,
				Height = sliderheight,
				Action = function(self)
					self:GetParent():playcommand("UpdateCurrentOption",{ Val = k })
					Attr.Save( Attr.Values, k )
				end,
				RequireHold = true
			}..{
			BeginCommand=function(self)
				self:xy( Attr.Pos[1] + scale( k, 1, #Attr.Values, -Attr.Width*.4, Attr.Width*.4 )
					, Attr.Pos[2] + (Attr.Height*.25) )
			end
		}
	end

	t[#t+1] = Def.Quad{
		Name="BGSlider",
		InitCommand=function(self)
			self:zoomto( sliderwidth, sliderheight*.1 )
		end
	}
	
	t[#t+1] = Def.Quad{
		Name="Slider",
		InitCommand=function(self)
			self:zoomto( 24, sliderheight )
		end
	}

	t[#t+1] = Def.BitmapText{
		Font = "Common Normal",
		Name = "CurrentVal",
		Text = "Summy",
		InitCommand=function(self) self:halign(1) end
	}
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