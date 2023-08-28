-- Generates a block quad with a border, from the ButtonBox module,
-- and creates a clickable absolute area from the ClickArea module,
-- to provide a presentable button for actions.

-- { Width, Height, Pos (relative), Cache, Debug, ReturnAdjacentActorFrame, Action, AddActors }
return function( Attr )
    Attr.Pos = Attr.Pos or {0,0}
    local t = Def.ActorFrame{
        InitCommand=function(self)
            self.height = Attr.Height
			if self:GetChild("BG") then
				self:GetChild("BG"):xy( Attr.Pos[1], Attr.Pos[2] )
			end
			self:GetChild("Click"):xy( Attr.Pos[1], Attr.Pos[2] )
            if self:GetChild("Extra") then
                self:GetChild("Extra"):xy( Attr.Pos[1], Attr.Pos[2] )
            end
		end
    }

	--lua.ReportScriptError( rin_inspect( Attr ) )
	if Attr.UseImage then
		t[#t+1] = Attr.UseImage..{ Name="BG" }
		--Attr.Height = Attr.UseImage..{}
		--Attr.Width = Attr.UseImage..{}
	else
		t[#t+1] = LoadModule( "UI/UI.ButtonBox.lua" )( Attr.Width, Attr.Height, Attr.Border, Attr.Player )..{ Name = "BG" }
	end

	t[#t+1] = LoadModule( "UI/UI.ClickArea.lua" ){
		Width = Attr.Width,
		Height = Attr.Height,
		Cache = Attr.Cache,
		Debug = Attr.Debug,
		ActionIsAfterLifting = Attr.ActionIsAfterLifting,
		ReturnAdjacentActorFrame = Attr.ReturnAdjacentActorFrame,
		Active = Attr.Active,
		UseTweenTime = Attr.UseTweenTime,
		Action = function(self)
			if not GAMESTATE:Env()["OpenedDropdown"] then
				if Attr.Action(self) then
					if self:GetParent():GetChild("BG") then
						local ogColor = self:GetParent():GetChild("BG"):GetDiffuse()
						self:GetParent():GetChild("BG"):stoptweening():diffuse( color("#777777") ):easeoutquint(0.5):diffuse(ogColor)
					end
				end
			end
    	end
	}..{ Name="Click" }

	-- Any additional actors can be added here.
    if Attr.AddActors then
	    t[#t+1] = Attr.AddActors..{ Name = "Extra", ActionPlayCommand = Attr.Action }
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