-- UI.Checkbox
-- Creates a checkbox frame that can perform an action when clicked or pressed on.
local enabled = false
return function( Attr )
	local width = Attr.Width or 32
	local height = Attr.Height or 32
	local allowClick = Attr.AllowClick or true
	if Attr.Load then
		enabled = Attr.Load()
	end
	return Def.ActorFrame{
		OnCommand=function(self)
			-- Toggle the current state of the check
			local bordersize = Attr.Border or 2
			self:GetChild("Enabled"):zoom( LoadModule("Lua.Resize.lua")(
				self:GetChild("Enabled"):GetZoomedWidth(), self:GetChild("Enabled"):GetZoomedHeight(), width-bordersize, height-bordersize)
			)
			:visible( enabled )
		end,
		-- Create background
		LoadModule("UI/UI.ButtonBox.lua")( width, height, Attr.Border or 2 ),
		-- Create Checkmark
		Def.Sprite{ Name="Enabled", Texture=THEME:GetPathG("","UI/Tick") },

		-- Create an area that will contain the action that will be done when clicked/pressed.
		LoadModule("UI/UI.ClickArea.lua"){
			Width = width - 4,
			Height = height - 4,
			Action = function(self)
				if not allowClick then return end
				-- Toggle the state
				enabled = not enabled
				self:GetChild("Enabled"):visible( enabled )
				-- Call the save function if available.
				if Attr.Save then
					Attr.Save(enabled)
				end
			end,
			ReturnAdjacentActorFrame = true
		}
	}
end
