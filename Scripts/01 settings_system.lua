--settings_system from Consensual by Kyzentun.
--github.com/kyzentun/consensual
local settings_prefix= "/MidflightDigital/"

--These live in 01 misc.lua in Consensual, but in this theme they are only used here
--so they don't get a separate file.
local function string_needs_escape(str)
	if str:match("^[a-zA-Z_][a-zA-Z_0-9]*$") then
		return false
	else
		return true
	end
end

local function lua_table_to_string(t, indent, line_pos)
	indent= indent or ""
	line_pos= (line_pos or #indent) + 1
	local internal_indent= indent .. "  "
	local ret= "{"
	local has_table= false
	for k, v in pairs(t) do if type(v) == "table" then has_table= true end
	end
	if has_table then
		ret= "{\n" .. internal_indent
		line_pos= #internal_indent
	end
	local separator= ""
	local function do_value_for_key(k, v, need_key_str)
		if type(v) == "nil" then return end
		local k_str= k
		if type(k) == "number" then
			k_str= "[" .. k .. "]"
		else
			if string_needs_escape(k) then
				k_str= "[" .. ("%q"):format(k) .. "]"
			else
				k_str= k
			end
		end
		if need_key_str then
			k_str= k_str .. "= "
		else
			k_str= ""
		end
		local v_str= ""
		if type(v) == "table" then
			v_str= lua_table_to_string(v, internal_indent, line_pos + #k_str)
		elseif type(v) == "string" then
			v_str= ("%q"):format(v)
		elseif type(v) == "number" then
			if v ~= math.floor(v) then
				v_str= ("%.6f"):format(v)
				local last_nonz= v_str:reverse():find("[^0]")
				if last_nonz then
					v_str= v_str:sub(1, -last_nonz)
				end
			else
				v_str= tostring(v)
			end
		else
			v_str= tostring(v)
		end
		local to_add= k_str .. v_str
		if type(v) == "table" then
			if separator == "" then
				to_add= separator .. to_add
			else
				to_add= separator .."\n" .. internal_indent .. to_add
			end
		else
			if line_pos + #separator + #to_add > 80 then
				line_pos= #internal_indent + #to_add
				to_add= separator .. "\n" .. internal_indent .. to_add
			else
				to_add= separator .. to_add
				line_pos= line_pos + #to_add
			end
		end
		ret= ret .. to_add
		separator= ", "
	end
	-- do the integer indices from 0 to n first, in order.
	do_value_for_key(0, t[0], true)
	for n= 1, #t do
		do_value_for_key(n, t[n], false)
	end
	for k, v in pairs(t) do
		local is_integer_key= (type(k) == "number") and (k == math.floor(k)) and k >= 0 and k <= #t
		if not is_integer_key then
			do_value_for_key(k, v, true)
		end
	end
	ret= ret .. "}"
	return ret
end

function string_in_table(str, tab)
	if not str or not tab then return false end
	for i, s in ipairs(tab) do
		if s == str then return i end
	end
	return false
end

function force_table_elements_to_match_type(candidate, must_match, depth_remaining, exceptions)
	for k, v in pairs(candidate) do
		if not string_in_table(k, exceptions) then
			if type(must_match[k]) ~= type(v) then
				candidate[k]= nil
			elseif type(v) == "table" and depth_remaining ~= 0 then
				force_table_elements_to_match_type(v, must_match[k], depth_remaining-1, exceptions)
			end
		end
	end
	for k, v in pairs(must_match) do
		if type(candidate[k]) == "nil" then
			if type(v) == "table" then
				candidate[k]= DeepCopy(v)
			else
				candidate[k]= v
			end
		end
	end
end

local function id_to_prof_dir(id, reason)
	local prof_dir= nil
	if id == "!MACHINE" then
		prof_dir= "Save"
	elseif id:match("^!MC[01]$") then
		local player= (id=="!MC0") and 'PlayerNumber_P1' or 'PlayerNumber_P2'
		if not PROFILEMAN:ProfileWasLoadedFromMemoryCard(player) then
			return
		end
		local slot= ({['PlayerNumber_P1']='ProfileSlot_Player1',['PlayerNumber_P2']='ProfileSlot_Player2'})[player]
		if slot then
			prof_dir= PROFILEMAN:GetProfileDir(slot)
		end
	elseif id and id~="" then
		prof_dir= PROFILEMAN:LocalProfileIDToDir(id)
	end
	return (prof_dir~="") and prof_dir or nil
end

function load_conf_file(fname)
	local file= RageFileUtil.CreateRageFile()
	local ret= {}
	if file:Open(fname, 1) then
		local data= loadstring(file:Read())
		setfenv(data, {})
		local success, data_ret= pcall(data)
		if success then
			ret= data_ret
		end
		file:Close()
	end
	file:destroy()
	return ret
end

local setting_mt= {
	__index= {
		init= function(self, name, file, default, match_depth, exceptions, use_global_as_default)
			assert(type(default) == "table", "default for setting must be a table.")
			self.name= name
			self.file= file
			self.default= default
			self.match_depth= match_depth
			self.dirty_table= {}
			self.data_set= {}
			self.exceptions= exceptions
			self.use_global_as_default= use_global_as_default
			return self
		end,
		apply_force= function(self, cand, id)
			if self.match_depth and self.match_depth ~= 0 then
				force_table_elements_to_match_type(
					cand, self:get_default(id), self.match_depth-1, self.exceptions)
			end
		end,
		get_default= function(self, id)
			if not self.use_global_as_default or not id or id == "" then
				return self.default
			end
			if not self.data_set[""] then
				self:load()
			end
			return self.data_set[""]
		end,
		load= function(self, id)
			id= id or ""
			local prof_dir= id_to_prof_dir(id, "read " .. self.name)
			if not prof_dir then
				self.data_set[id]= DeepCopy(self:get_default(id))
			else
				local fname= self:get_filename(id)
				if not FILEMAN:DoesFileExist(fname) then
					self.data_set[id]= DeepCopy(self:get_default(id))
				else
					local from_file= load_conf_file(fname)
					if type(from_file) == "table" then
						self:apply_force(from_file, id)
						self.data_set[id]= from_file
					else
						self.data_set[id]= DeepCopy(self:get_default(id))
					end
				end
			end
			return self.data_set[id]
		end,
		is_loaded= function(self, id)
			id= id or ""
			return self.data_set[id]~=nil
		end,
		get_data= function(self, id)
			id= id or ""
			return self.data_set[id] or self.default
		end,
		set_data= function(self, id, data)
			id= id or ""
			self.data_set[id]= data
		end,
		set_dirty= function(self, id)
			id= id or ""
			self.dirty_table[id]= true
		end,
		check_dirty= function(self, id)
			id= id or ""
			return self.dirty_table[id]
		end,
		clear_id= function(self, id)
			id= id or ""
			self.dirty_table[id]= nil
			self.data_set[id]= nil
		end,
		get_filename= function(self, id)
			id= id or ""
			local prof_dir= id_to_prof_dir(id, "write " .. self.name)
			if not prof_dir then return end
			return prof_dir .. settings_prefix .. self.file
		end,
		save= function(self, id)
			id= id or ""
			if not self:check_dirty(id) then return end
			local fname= self:get_filename(id)
			local file_handle= RageFileUtil.CreateRageFile()
			if not file_handle:Open(fname, 2) then
				Warn("Could not open '" .. fname .. "' to write " .. self.name .. ".")
			else
				local output= "return " .. lua_table_to_string(self.data_set[id])
				file_handle:Write(output)
				file_handle:Close()
				file_handle:destroy()
			end
		end,
		save_all= function(self)
			for id, data in pairs(self.data_set) do
				self:save(id)
			end
		end
}}

function create_setting(name, file, default, match_depth, exceptions, use_global_as_default)
	return setmetatable({}, setting_mt):init(name, file, default, match_depth, exceptions, use_global_as_default)
end