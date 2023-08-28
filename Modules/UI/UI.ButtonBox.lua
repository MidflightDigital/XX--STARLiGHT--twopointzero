local a = {
	-- Container for the actors
	actorFrame = nil,
	width = 0,
	-- Handle to grab said actors inside  the actorframe.
	handle = nil,
	Generate = function(this, width, height, border, plr, actorname)
		local bsize = border or 6
		local colortextHighlight = ColorLightTone(BoostColor(PlayerColor(plr), 1.2))
		local t = Def.ActorFrame{
			Name=actorname,
			InitCommand=function(self)
				this.handle = self
			end,
			UpdateSizeCommand=function(self,params)
				if not this.handle then return end
				if not params.Width or not params.Height then return end
				self:GetChild("BGOut"):hurrytweening(0):tween(params.Length or 0,params.Ease or "linear")
				:zoomto( params.Width, params.Height )

				self:GetChild("BGIn"):hurrytweening(0):tween(params.Length or 0,params.Ease or "linear")
				:zoomto( params.Width - (params.Border or bsize), params.Height - (params.Border or bsize) )
			end,
			ChangeColorCommand=function(self,params)
				if not this.handle then return end
				self:GetChild("BGOut"):hurrytweening(0):tween(params.Length or 0,params.Ease or "linear"):diffuse( params.Out )
				self:GetChild("BGIn"):hurrytweening(0):tween(params.Length or 0,params.Ease or "linear"):diffuse( params.In )
			end,
			Def.Quad{
				Name = "BGOut",
				InitCommand=function(self)
					self:zoomto( width , height ):diffuse( plr and colortextHighlight or GameColor.Custom["MenuButtonBorder"] )
				end
			},
			-- inner frame
			Def.Quad{
				Name = "BGIn",
				InitCommand=function(self)
					self:zoomto( width - bsize , height - bsize )
					:diffusetopedge( plr and ColorDarkTone(PlayerColor(plr)) or GameColor.Custom["MenuButtonBase"] )
					:diffusebottomedge( plr and ColorDarkTone(PlayerColor(plr)) or ColorDarkTone( GameColor.Custom["MenuButtonGradient"] ) )
				end
			}
		}

		this.actorFrame = t
		return this
	end,
	UpdateSize = function(this, width, height, border, ease, duration)
		this.actorFrame.UpdateSizeCommand(this.handle, { Width = width, Height = height, Border = border, Ease = ease, Length = duration })
	end,
	ChangeColor = function(this, OutColor, InColor, ease, duration)
		this.actorFrame.ChangeColorCommand(this.handle, { Out = OutColor, In = InColor, Ease = ease, Length = duration })
	end,
	-- Allow the user to run custom commands to the entire set.
	RunCommand = function(this, commands)
		commands(this.handle)
	end,
	RunRecursively = function(this, commands)
		this.handle:RunCommandsRecursively( function(self) commands(self) end )
	end,
	GetTotalWidth = function(this)
		return this.handle:GetChild("BGOut"):GetZoomedWidth()
	end,
	GetTotalHeight = function(this)
		return this.handle:GetChild("BGOut"):GetZoomedHeight()
	end,
	Handle = function(this)
		return this.handle
	end,
	Create = function(this)
		return this.actorFrame
	end,
	__call = function(this, width, height, border, plr, metatab, actorname)
		this.width = width or 0
		this:Generate( width, height, border, plr, actorname )
		if metatab then
			return this
		end
		return this:Create()
	end
}

return setmetatable(a,a)
--[[
	Copyright 2021-2022 Jose Varela, Project OutFox

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
