local function RemoveSpaces(str)
	return str:gsub(" ", "")
end

local t = {
	Container = {},
	File = nil,
	ChangesMade = false,
	Load = function(this,file)
		this.File = file
		if not FILEMAN:DoesFileExist(file) then
			Warn("[Save.PlayerPrefs] Could not find file ".. file .. ".")
			return this
		end

		local configfile = RageFileUtil.CreateRageFile()
		configfile:Open(file, 1)

		local configcontent = configfile:Read()

		configfile:Close()
		configfile:destroy()

		local Caty = true
		local Cat = ""

		for line in string.gmatch(configcontent.."\n", "(.-)\n") do
			-- for Con in string.gmatch(line, "%[(.-)%]") do
			-- 	if Con == Cat or Cat == nil then Caty = true else Caty = false end
			-- end
			for KeyVal, Val in string.gmatch(line, "(.-)=(.+)") do
				-- if Cat ~= "" then
				-- end
				local value = Val
				if Val == "true" then value = true end
				if Val == "false" then value = false end
				this.Container[KeyVal] = value
			end
		end

		return this,true
	end,
	Set = function(this,setting,value)
		this.ChangesMade = true
		this.Container[RemoveSpaces(setting)] = value
		return this
	end,
	Get = function(this,setting,defaultVal)
		local val = this.Container[RemoveSpaces(setting)]
		if val == nil then
			return defaultVal
		end
		if tonumber(val) then return tonumber(val) end
		if val == "true" then return true end
		if val == "false" then return false end
		return val
	end,
	SaveToFile = function(this)
		if not this.ChangesMade then return end
		local configfile = RageFileUtil.CreateRageFile()

		local output = ""

		for k,v in pairs(this.Container) do
			output = output..k.."="..tostring(v).."\n"
		end

		configfile:Open(this.File, 2)
		configfile:Write(output)
		configfile:Close()
		configfile:destroy()
		return this
	end,
	__call = function(this)
		return this
	end
}

return setmetatable(t,t)
