return function( title, list, width, height, xpos, ypos, player )
    xpos = xpos or 0
    ypos = ypos or 0
    local t = Def.ActorFrame{
        InitCommand=function(self)
            self.height = height
        end
    }

    t[#t+1] = Def.BitmapText{
        Font = "Common Normal",
        Text = title,
        OnCommand=function(self)
            self:halign( 0 ):xy(  xpos-width*.25, ypos )
        end
    }
    
    t[#t+1] = LoadModule("UI/UI.DropDown.lua"){
        Width = width * .25,
        Height = height,
        XPos = xpos+width*.25,
        YPos = ypos,
        List = list,
        perItemAction = function() return 1 end,
        Player = player or GAMESTATE:GetMasterPlayerNumber()
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