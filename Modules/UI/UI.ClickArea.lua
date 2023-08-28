--[[
	UI.ClickArea

	Generates an Actor given from Width x Height, that can be interacted with other elements.
	Utilizes UI.MouseDetect to measure the position of the area across N level of ActorFrames that
	it resides in.
]]
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
		_NAME = "UI.ClickArea",
	},
	{
		__call = function(this, Attr)
			if type(Attr) ~= "table" then
				lua.ReportScriptError("["..this._NAME.."] This is not a table! Returning empty actor.")
				return Def.Actor{}
			end

			local curparent
			return (Attr.Debug and Def.Quad or Def.Actor){
				OnCommand=function(self)
					self:zoomto( Attr.Width or 64, Attr.Height or 64 )
					:diffusealpha(0.2)
					curparent = self
					while ( curparent:GetParent() ~= nil ) do
						curparent = curparent:GetParent()
					end

					self.ActorFrameToReturn = Attr.ReturnAdjacentActorFrame and self:GetParent() or self

					-- The user can define if the child provided on the Position command is relative to the origin
					-- point where the module was called from, or instead grab from the point of the click area.
					if Attr.Position then
						Attr.Position(self)
					end

					-- The user can also define if this click area position will not change from where it's currently
					-- located, which in that case, will be cached.
					MouseDetect = LoadModule("UI/UI.MouseDetect.lua")(self,true)
					MouseDetect:ProcessCoords(self, Attr.UseTweenTime)
				end,
				CheckClickOrPressCommand=function(self,params)
					-- Do not allow any more clicks after selection has been done and objects are tweening.
					if SCREENMAN:GetTopScreen():IsTransitioning() then return end
					if Attr.Active then
						if not Attr.Active() then return end
					end
					if not Attr.Cache and MouseDetect then
						MouseDetect:ProcessCoords(self)
					end
					self:playcommand("Action",{State = params.IsPressed})
				end,
				MouseLeftClickMessageCommand=function(self,param) self:playcommand("CheckClickOrPress",param) end,
				FingerPressMessageCommand=function(self,param) self:playcommand("CheckClickOrPress",param) end,
				ActionCommand=function(self,params)
					-- Before checking, are we still in the same screen where the areas are from?
					if SCREENMAN:GetTopScreen() ~= curparent then return end

					if MouseDetect:VerifyCollision() then
						if Attr.Action and ((params.State and not Attr.ActionIsAfterLifting and not self.eatinput) or (Attr.ActionIsAfterLifting and not params.State)) then
							-- The user can define if the child provided on the Action command is relative to the origin
							-- point where the module was called from, or instead grab from the point of the click area.
							Attr.Action(self.ActorFrameToReturn)
						end
					else
						if Attr.ActionUnclick then
							-- In the case we're outside of the X area, then we can also interrupt.
							Attr.ActionUnclick(self.ActorFrameToReturn)
						end
					end
				end
			}
		end
	}
)