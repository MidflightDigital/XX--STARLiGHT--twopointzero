--[[
    UIHelper.ClickArea

    This is a helper file to deal with multiple click areas that must cooperate with eachother for collision,
    communication, interaction and order of operation.

    The order for this is last come, first served. The latest item to be added to the stack
    will be the first to be check upon.
]]

local MouseDetect = LoadModule("UI/UI.MouseDetect.lua")
return setmetatable(
    {
        _LICENSE = [[
			Copyright 2023 Jose Varela, Project OutFox

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
        
        -- Store the generated click areas here to be processed.
        areas = {},
        Attr = {},

        AddArea = function(self, area)
            -- TODO: Add support for debug.
            local actor = Def.Actor{
                InitCommand=function(self)
                    self.Width = area.Width
                    self.Height = area.Height
                    self.name = area.Name
                    self:zoomto( self.Width, self.Height )
                    if area.Position then
                        area.Position(self)
                    end
                    self.Action = area.Action
                end
            }
            self.areas[#self.areas+1] = actor
            return self
        end,

        -- Deploy the listener to the actorframe to begin operation.
        -- It performs the same actions as UI.ClickArea, but will stop upon the first successful operation.
        -- Due to its nature, this listener must be installed on the root level of your ActorFrame to ensure
        -- proper positioning.
        InstallListener = function(this)
            local curparent
            return Def.ActorFrame{
                children = this.areas,
                OnCommand=function(self)
                    curparent = self
					while ( curparent:GetParent() ~= nil ) do
						curparent = curparent:GetParent()
					end

                    self.ActorFrameToReturn = this.Attr.ReturnAdjacentActorFrame and self:GetParent() or self
                end,

                CheckClickOrPressCommand=function(self,params)
					-- Do not allow any more clicks after selection has been done and objects are tweening.
					if SCREENMAN:GetTopScreen():IsTransitioning() then return end

                    -- Before checking, are we still in the same screen where the areas are from?
					if SCREENMAN:GetTopScreen() ~= curparent then return end

                    if not params.IsPressed then return end
                    
                    -- Go through all the click areas and check if they're available to click.
                    local c = self:GetChildren()[""]
                    local achievedAction = false
                    for i = #c, 1, -1 do
                        local v = self:GetChildren()[""][i]
                        -- MouseDetect:ProcessCoords(v)
                        if MouseDetect(v) then
                            if v.Action then
                                -- The user can define if the child provided on the Action command is relative to the origin
                                -- point where the module was called from, or instead grab from the point of the click area.
                                v.Action(self.ActorFrameToReturn)
                            end
                            -- Stop all operation now, if there's any kind of click operation that needs to be done,
                            -- it now has to remove the item above it for it to be operational.
                            achievedAction = true
                            break
                        end
                    end

                    -- If we have reached this area, it means that all click areas have failed, and thus a possible
                    -- unclick action can be performed.
                    if not achievedAction and this.Attr.UnclickAction then
                        this.Attr.UnclickAction(self)
                    end
				end,

                MouseLeftClickMessageCommand=function(self,param) self:playcommand("CheckClickOrPress",param) end,
            }
        end
    },
    {
        __call = function(self, attributes)
            if attributes then
                self.Attr = attributes
            end
            return self
        end
    }
)