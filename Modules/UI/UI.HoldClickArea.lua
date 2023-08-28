--[[
	UI.ClickArea (Holding version)

	Generates an Actor given from Width x Height, that can be interacted with other elements.
	Utilizes UI.MouseDetect to measure the position of the area across N level of ActorFrames that
	it resides in.
]]

local IsNowHolding = false
local MouseDetect
return setmetatable(
	{
		_LICENSE = [[
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
		]],
		_NAME = "UI.HoldClickArea",
	},
	{
		__call = function(this, Attr)
			if type(Attr) ~= "table" then
				lua.ReportScriptError("["..this._NAME.."] This is not a table! Returning empty actor.")
				return Def.Actor{}
			end

			local curparent
			return Def.ActorFrame{
				OnCommand=function(self)
					curparent = self
					while ( curparent:GetParent() ~= nil ) do
						curparent = curparent:GetParent()
					end

					-- The user can define if the child provided on the Position command is relative to the origin
					-- point where the module was called from, or instead grab from the point of the click area.
					if Attr.Position then
						Attr.Position(self)
					end

					self.ActorFrameToReturn = Attr.ReturnAdjacentActorFrame and self:GetParent() or self

					-- The user can also define if this click area position will not change from where it's currently
					-- located, which in that case, will be cached.
					MouseDetect = LoadModule("UI/UI.MouseDetect.lua")(nil,true)
					MouseDetect:ProcessCoords(self:GetChild("Detection"))

					-- Not neccesarily a good idea; it's the reason why this is a separate module.
					-- We often don't recommend using UpdateFunctions unless you're really sure about it, as this is performed
					-- on every update.
					-- In our case, this will do actions when the user is holding the button (And is inside the area beforehand),
					-- and nothing more. This will save on cycles as the mouse boundry check will keep in mind the areas
					-- that are allowed to click, stopping the update function when its not needed.
					self:SetUpdateFunction(
						function( self, deltaTime )
							if not IsNowHolding then return end
							-- Before checking, are we still in the same screen where the areas are from?
							if SCREENMAN:GetTopScreen() ~= curparent then return end

							if not Attr.Cache then
								MouseDetect:ProcessCoords(self:GetChild("Detection"))
							end
				
							self:playcommand("Action",{ delta = deltaTime })
						end
					)
				end,
				MouseLeftClickMessageCommand=function(self,param) self:playcommand("CheckClickOrPress",param) end,
				FingerPressMessageCommand=function(self,param) self:playcommand("CheckClickOrPress",param) end,
				CheckClickOrPressCommand=function(self,param)
					-- BEFORE CHECK, see if we're inside the area.
					if param.IsPressed then
						if MouseDetect:VerifyCollision() then
							-- We're inside the area, start the update.
							IsNowHolding = true
						end
					else
						IsNowHolding = false
						if Attr.ActionUnclick then
							Attr.ActionUnclick(self.ActorFrameToReturn)
							return
						end
					end
				end,
				ActionCommand=function(self,params)
					if MouseDetect:VerifyCollision(IsNowHolding) then
						if (Attr.Action and not self.eatinput) then
							-- The user can define if the child provided on the Action command is relative to the origin
							-- point where the module was called from, or instead grab from the point of the click area.
							Attr.Action(self.ActorFrameToReturn, params)
						end
					else
						if Attr.ActionUnclick then
							Attr.ActionUnclick(self.ActorFrameToReturn, params)
							-- In the case we're outside of the X area, then we can also interrupt.
							return
						end
					end
				end,

				Def.Quad{
					Name="Detection",
					InitCommand=function(self)
						self:visible( Attr.Debug or false ):diffusealpha(0.1):zoomto( Attr.Width or 64, Attr.Height or 64 )
					end
				}
			}
		end
	}
)