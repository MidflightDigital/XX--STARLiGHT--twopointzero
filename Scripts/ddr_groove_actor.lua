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
	-- the actual radar size though.
	return value/100
end

local r = Enum.Reverse(Difficulty)
local customDiff = { 'beginner', 'basic', 'difficult', 'expert', 'challenge', 'edit' }

function lookup_ddr_radar_values(song, steps, pn)
	local radars = {}
	local steps_radar = steps:GetRadarValues(pn)
	
	for category, index in pairs(radar_category_to_index) do
		-- Cap radar values at 1 because stepmania doesn't have a cap anymore.
		if ThemePrefs.Get("RadarLimit") then
			radars[index]= math.min(steps_radar:GetValue(category), 3)
		else
			radars[index]= round(steps_radar:GetValue(category), 6)
		end
	end
	
	if DDR_groove_radar_values then
		local radars_for_group = DDR_groove_radar_values[song:GetGroupName()]
		
		if radars_for_group then
			local songName = Basename(song:GetSongDir())
			local radars_for_song = radars_for_group[songName]
			
			if radars_for_song then
				local style = split('_', steps:GetStepsType())
				local diff = steps:GetDifficulty()
				local st = string.lower(style[3]) .. "-" .. customDiff[r[diff]+1]
				local radars_for_steps= radars_for_song[st]
				
				if radars_for_steps then
					radars = { 0, 0, 0, 0, 0 }
					
					for index, value in ipairs(radars_for_steps) do
						if value ~= -1 then
							radars[index] = round(scale_ddr_radar_to_sm(value), 3)
						end
					end
					
					return radars, true
				end
			end
		end
	end
	
	return radars, false
end

local function RadarItems(pn, size, center_color, category_colors, tween_type, tween_time)
	local cat_colors = category_colors
	local t = Def.ActorFrame {};

	for i=1, 2 do	---	1(border), 2(interior)
		t[#t+1] = Def.ActorMultiVertex {
			Name= "radar",
			InitCommand= function(self)
				self:SetDrawState{ Mode="DrawMode_Fan" };
			end,
			CurrentSongChangedMessageCommand=function(self)
				self:playcommand('Set')
			end;
			["CurrentSteps" .. pname(pn) .. "ChangedMessageCommand"]=function(self)
				self:playcommand( 'Set' )
			end,
			SetCommand= function(self, param)				
				local player_steps = GAMESTATE:GetCurrentSteps(pn)
				local curr_song = GAMESTATE:GetCurrentSong()
				
				if not player_steps or not curr_song then
					self:stoptweening()[tween_type](self, tween_time):zoom(0)
					return
				end
				
				self:stoptweening()[tween_type](self, tween_time):zoom(1)
				
				local radars, succeeded= lookup_ddr_radar_values(curr_song, player_steps, pn)
				
				if i==1 then
					for j=1, 5 do
						radars[j] = radars[j]+0.015
					end
				end
				
				if not succeeded and show_failed_lookup_message then
					self:GetParent():GetChild("failed_lookup"):visible(true)
				else
					self:GetParent():GetChild("failed_lookup"):visible(false)
				end
				
				local verts= {{{0, 0, 0}, center_color}}
				
				for cat_index, value in ipairs(radars) do
					local angle = stream_angle + ((cat_index-1) * angle_per_category)
					local vert_x
					local vert_y
					if ThemePrefs.Get("RadarLimit") then
						vert_x = math.cos(angle) * size * value/4
						vert_y = math.sin(angle) * size * value/4
					else
						vert_x = math.cos(angle) * size * value/2
						vert_y = math.sin(angle) * size * value/2
					end
					
					if i==1 then
						category_colors = {color("0,0,0,0.8"), color("0,0,0,0.8"), color("0,0,0,0.8"), color("0,0,0,0.8"), color("0,0,0,0.8")}
					else
						category_colors = cat_colors
					end
					
					verts[#verts+1] = {{vert_x, vert_y, 0}, category_colors[cat_index]}
				end
				-- Add an extra vert on the end so that DrawMode_Fan will draw all the
				-- way around.
				verts[#verts+1] = verts[2]
				self:SetVertices(verts)
			end,
		}
	end
	
	for j=1, 5 do
		t[#t+1] = Def.Quad {
			InitCommand=function(s) s:valign(1):setsize(2,size):rotationz(-72*(j-1)):zoomy(0):diffuse(Alpha(Color.Black,0.3)) end,
			CurrentSongChangedMessageCommand=function(self)
				self:playcommand('Set')
			end;
			["CurrentSteps" .. pname(pn) .. "ChangedMessageCommand"]=function(self)
				self:playcommand('Set')
			end;
			SetCommand=function(self,params)
				local song = GAMESTATE:GetCurrentSong()
				local player_steps = GAMESTATE:GetCurrentSteps(pn)
				
				if song and player_steps then
					local radars = lookup_ddr_radar_values(song, player_steps, pn)
					self:stoptweening()[tween_type](self, tween_time):zoomy(radars[j]/2)
				else
					self:stoptweening()[tween_type](self, tween_time):zoomy(0)
				end
			end;
		}
	end
	
	t[#t+1] = Def.BitmapText { Font="Common Normal" } .. {
		Name="failed_lookup",
		Text= "Not Found",
		InitCommand=function(s) s:visible(false):diffuse(color('0.8,0.8,0.8,0.8')) end,
	}
	
	return t
end
	
function create_ddr_groove_radar(actor_name, x, y, pn, size, center_color, category_colors, tween_type, tween_time)
	size = size or 50
	center_color = center_color or {1, 1, 1, 1}
	category_colors = category_colors or {}
	tween_type = tween_type or "linear"
	tween_time = tween_time or .1
	
	for i = 1, num_categories do
		if not category_colors[i] then
			category_colors[i] = ColorLightTone(PlayerColor(pn))
		end
	end
	
	return Def.ActorFrame {
		Name = actor_name,
		InitCommand=function(s) s:xy(x,y) end,
		
		children = RadarItems(pn, size, center_color, category_colors, tween_type, tween_time)
	}
end