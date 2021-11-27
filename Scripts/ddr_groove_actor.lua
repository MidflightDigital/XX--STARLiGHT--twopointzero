-- Usage:
-- Put ddr_groove_data.lua and ddr_groove_actor.lua in Scripts/ in the theme.
-- In ScreenSelectMusic, find the place where you want the groove radar.
-- Call create_ddr_groove_radar and pass it these things:
--   The name of the actor.
--   The x position.
--   The y position.
--   The PlayerNumber of the player it is for.
--   The distance from the center to the edge. (optional)
--   The color at the center. (optional)
--   A table of colors to use for each category. (optional)
--   The name of the tween function to use when changing. (optional)
--   The time to spend tweening. (optional)
-- Examples:
--   t[#t+1]= create_ddr_groove_radar("P1_radar", _screen.cx * .5, _screen.cy, PLAYER_1)
--   t[#t+1]= create_ddr_groove_radar("P2_radar", _screen.cx*1.5, _screen.cy,
--     PLAYER_2, PlayerColor(PLAYER_2), 75,
--     {Color.Red, Color.Blue, Color.Green, Color.Yellow, Color.Orange},
--     "accelerate", .5)

local radar_category_to_index= {
	RadarCategory_Stream= 1,
	RadarCategory_Voltage= 2,
	RadarCategory_Air= 3,
	RadarCategory_Freeze= 4,
	RadarCategory_Chaos= 5,
}
local num_categories= 5
-- The category data is in the above order, but going clockwise around in AC
-- DDR, the order is SCFAV, with stream at the top.  So make
-- angle_per_category negative to make the categories go AC way.
local angle_per_category= -(2 * math.pi) / num_categories
-- stream_angle is the angle the stream radar value should be at.
-- math.pi * -.5 puts stream at the top.
local stream_angle= math.pi * -.5

-- The show_failed_lookup_message value exists for debugging, so that someone
-- verifying whether songs are found in the database can see a message.
local show_failed_lookup_message= false

local function scale_ddr_radar_to_sm(value)
	-- 200 seems to limit the output to 1 and just giving the output without dividing it causes
	-- for the correct table value but we end up with decimals for the generated radar numbers if
	-- we multiply them by 100. So we divide by 100 so we get integers after the fact. This affects
	-- the actual radar size though. See line 135 for the reason.
	return value/100
end

function lookup_ddr_radar_values(song, steps, pn)
	local title= ""
	-- GetMainTitle added in 5.0.10 to bypass the ShowNativeLanguage pref.
	-- That preference interferes with looking up a song, because it makes
	-- GetDisplayMainTitle return the transliterated title instead of the
	-- TITLE field. -Kyz
	if song.GetMainTitle then
		title= song:GetMainTitle()
	else
		local old_show_native= PREFSMAN:GetPreference("ShowNativeLanguage")
		PREFSMAN:SetPreference("ShowNativeLanguage", true)
		title= song:GetDisplayMainTitle()
		PREFSMAN:SetPreference("ShowNativeLanguage", old_show_native)
	end
	local radars= {}
	local steps_radar= steps:GetRadarValues(pn)
	for category, index in pairs(radar_category_to_index) do
		-- Cap radar values at 1 because stepmania doesn't have a cap anymore.
		if ThemePrefs.Get("RadarLimit") == true then
			radars[index]= math.min(steps_radar:GetValue(category), 3)
		else
			radars[index]= steps_radar:GetValue(category)
		end
	end
	local radars_for_type= LoadModule("ddr_groove_data.lua",steps:GetStepsType())
	if not radars_for_type then
		return radars, false
	end
	local radars_for_song= radars_for_type[title]
	if not radars_for_song then
		return radars, false
	end
	local radars_for_difficulty= radars_for_song[ToEnumShortString(steps:GetDifficulty())]
	if not radars_for_difficulty then
		return radars, false
	end
	for index, value in ipairs(radars_for_difficulty) do
		if value ~= -1 then
			radars[index]= scale_ddr_radar_to_sm(value)
		end
	end
	return radars, true
end

function self_play_set(self, param) self:playcommand("Set", param) end

function create_ddr_groove_radar(actor_name, x, y, pn, size, center_color, category_colors, tween_type, tween_time)
	size= size or 50
	center_color= center_color or {1, 1, 1, 1}
	category_colors= category_colors or {}
	for i= 1, num_categories do
		if not category_colors[i] then
			category_colors[i]= ColorLightTone(PlayerColor(pn))
		end
	end
	tween_type= tween_type or "linear"
	tween_time= tween_time or .25
	local currently_displayed_steps= false
	return Def.ActorFrame{
		Name= actor_name, InitCommand= function(self)
			self:xy(x, y)
		end,
		Def.ActorMultiVertex{
			Name= "radar", InitCommand= function(self)
				self:SetDrawState{Mode="DrawMode_Fan"}
			end,
			SongChangedMessageCommand= self_play_set,
			["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]= self_play_set,
			SetCommand= function(self)
				local player_steps= GAMESTATE:GetCurrentSteps(pn)
				if not player_steps then
					self:stoptweening()[tween_type](self, tween_time):zoom(0)
					return
				end
				currently_displayed_steps= player_steps
				local curr_song= GAMESTATE:GetCurrentSong()
				if not curr_song then
					self:stoptweening()[tween_type](self, tween_time):zoom(0)
					return
				end
				self:stoptweening()[tween_type](self, tween_time):zoom(1)
				local radars, succeeded= lookup_ddr_radar_values(curr_song, player_steps, pn)
				if not succeeded and show_failed_lookup_message then
					self:GetParent():GetChild("failed_lookup"):visible(true)
				else
					self:GetParent():GetChild("failed_lookup"):visible(false)
				end
				local verts= {{{0, 0, 0}, center_color}}
				for cat_index, value in ipairs(radars) do
					local angle= stream_angle + ((cat_index-1) * angle_per_category)
					-- we halve the values as the fix for radar numbers results in a radar twice as large as
					-- before.
					local vert_x= math.cos(angle) * size * value/2
					local vert_y= math.sin(angle) * size * value/2
					verts[#verts+1]= {{vert_x, vert_y, 0}, category_colors[cat_index]}
				end
				-- Add an extra vert on the end so that DrawMode_Fan will draw all the
				-- way around.
				verts[#verts+1]= verts[2]
				self:SetVertices(verts)
			end,
		},
		Def.BitmapText{
			Name= "failed_lookup", Font= "Common Normal", Text= "Not Found",
			InitCommand= function(self)
				self:visible(false):diffuse{.8, .8, .8, .8}
			end
		},
	}
end
