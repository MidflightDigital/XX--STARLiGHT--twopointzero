local t = {
	startlimitx = 0,
	endlimitx = 0,
	startlimity = 0,
	endlimity = 0,
	isValidToClick = true,

	ProcessCoords = function(this,self,useTweenTime)
		local canUseAbsolute = self.GetAbsoluteDestX

		-- Objects can go in a N ammount of parents, that can have other locations.
		-- iterate through all of them to reobtain the absolute position of the object.
		local sumx = self:GetDestX()
		local sumy = self:GetDestY()
		local curparent = self
		this.isValidToClick = true
		while ( curparent:GetParent() ~= nil )
		do
			curparent = curparent:GetParent()
			if not canUseAbsolute then
				sumx = sumx + curparent:GetDestX()
				sumy = sumy + curparent:GetDestY()
			end
			
			-- During this process, they've might have been a parent actor that has
			-- performed a modification to its coordinates or sizes. And in those cases,
			-- it might not be required to have the button active, so turn them off if that's the case.
			if curparent:GetZoom() == 0 then this.isValidToClick = false end
			if not curparent:GetVisible() then this.isValidToClick = false end
			if curparent:GetDiffuseAlpha() < 0.5 then this.isValidToClick = false end
			if useTweenTime then 
				if curparent:GetTweenTimeLeft() > 0 then this.isValidToClick = false end
			end
		end
		if canUseAbsolute then
			sumx = self:GetAbsoluteDestX()
			sumy = self:GetAbsoluteDestY()
		end
		
		this.startlimitx = sumx - (self:GetZoomedWidth() * self:GetHAlign())
		this.endlimitx = sumx + (self:GetZoomedWidth() * (1 - self:GetHAlign()))
		this.startlimity = sumy  - (self:GetZoomedHeight() * self:GetVAlign())
		this.endlimity = sumy  + (self:GetZoomedHeight() * (1 - self:GetVAlign()))
	end,

	VerifyCollision = function(this, requiresHold)
		if not this.isValidToClick then return false end
		local coords = { x = INPUTFILTER:GetMouseX(), y = INPUTFILTER:GetMouseY() }
		if (coords.x > this.startlimitx and coords.x < this.endlimitx) or requiresHold then
			-- A common thing with operating systems is that if you begin dragging an item, like a slider,
			-- the action can still happen while dragging out of the area, ie. dragging left/right while outside of the
			-- vertical mouse point area where the slider is.
			if (coords.y > this.startlimity and coords.y < this.endlimity) or requiresHold then
				return true
			end
		end

		return false
	end,

	__call = function(this,self,CacheInformation)
		if not CacheInformation then
			this:ProcessCoords(self)
			return this:VerifyCollision()
		end
		return this
	end
}

return setmetatable(t,t)

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