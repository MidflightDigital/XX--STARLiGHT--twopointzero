local sort_wheel = setmetatable({disable_wrapping = false}, sick_wheel_mt)
local sort_orders = {
	"Group",
	"Title",
	"BPM",
	"TopGrades",
	"Popularity",
}

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type ~= "InputEventType_Release" then
		local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")

		if event.GameButton == "MenuRight" then
			sort_wheel:scroll_by_amount(1)
			overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			sort_wheel:scroll_by_amount(-1)
			overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			overlay:GetChild("start_sound"):play()
			MESSAGEMAN:Broadcast('Sort',{order=sort_wheel:get_actor_item_at_focus_pos().info})
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")

		elseif event.GameButton == "Back" then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end

	return false
end


-- the metatable for an item in the sort_wheel
local wheel_item_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
					subself:MaskDest()
				end
			}

			af[#af+1] = LoadFont("Common Normal")..{
				Text="",
				InitCommand=function(subself)
					subself:diffusealpha(0)
					subself:horizalign(left)
					subself:addx(-30);
					subself:addy(-25);
					self.text= subself
				end,
				OnCommand=function(self)
					self:addx(-30);
					self:addy(-25);
					self:sleep(0.13)
					self:horizalign(left)
					self:linear(0.05)
					self:diffusealpha(1)
				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus,subself)
			self.container:finishtweening()

			if has_focus then
				self.container:accelerate(0.15)
				self.container:zoom(1)
				self.container:diffuse(color("#ffffff"))
				self.container:glow(color("1,1,1,0.5"))
				self.sortmenu=subself
			else
				self.container:glow(color("1,1,1,0"))
				self.container:accelerate(0.15)
				self.container:zoom(1)
				self.container:diffuse(color("#888888"))
				self.container:glow(color("1,1,1,0"))
			end

			self.container:y(28 * (item_index - math.ceil(num_items/2)))

			if item_index <= 1 or  item_index >= num_items then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end
		end,

		set = function(self, info)
			self.info= info
			if not info then self.text:settext("") return end
			self.text:settext(THEME:GetString("ScreenSortList", info))
		end
	}
}

local t = Def.ActorFrame {
	InitCommand=function(self)
		sort_wheel:set_info_set(sort_orders, 1)
		-- override sick_wheel's default focus_pos, which is math.floor(num_items / 2)
		sort_wheel.focus_pos = 4
		-- "scroll" the wheel (0 positions) just so that the override takes immediate effect
		sort_wheel:scroll_by_amount(0)
		self:queuecommand("Capture")
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,

	-- BG of the sortlist box
	Def.Sprite{
		Texture="SortFrame",
		InitCommand=function(s) s:Center() end,
	},


	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	sort_wheel:create_actors( "sort_wheel", 7, wheel_item_mt, _screen.cx, _screen.cy )
}

t[#t+1] = Def.Sound{
	File=THEME:GetPathS("ScreenSelectMaster", "change"),
	Name="change_sound",
	SupportPan = false
}
t[#t+1] = Def.Sound{
	THEME:GetPathS("common", "start"),
	Name="start_sound",
	SupportPan = false
}

return t
