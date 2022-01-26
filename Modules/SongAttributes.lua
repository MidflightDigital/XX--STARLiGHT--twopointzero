--SongAttributes.lua
--reads waiei's group.ini format (http://sm.waiei.net/other/group.html)
--written with reference to waiei's readers

--Okay the idea here is we hold a strong reference on the attribute data for the
--duration of a game or the duration of the module, whichever is longer. After
--that, we keep it in the cache in case the game starts again before the
--garbage collector gets it.
local data_map
do
	local env
	if GAMESTATE then
		env = GAMESTATE:Env()
	end
	
	data_map = env and env.SongAttributesData
	if not data_map then
		data_map = StarlightCache.SongAttributesData
		if not data_map then
			data_map = {}
			StarlightCache.SongAttributesData = data_map
		end
		if env then
			env.SongAttributesData = data_map
		end
	end
end

--these functions deal with loading

--for example, given a group named DDR Extreme 2, this returns
--"/Themes/(starlight's root)/Other/GroupFallback/ddrextreme2.ini"
local function fallback_ini_path(group_name)
    return THEME:GetCurrentThemeDirectory() ..
    "/Other/GroupFallback/" .. 
    string.lower(group_name):gsub("%s","") .. ".ini"
end

--specifically, group name to group.ini path
local function group_name_to_path(group_name)
    local tests = {
        "/Songs/"..group_name.."/group.ini",
        "/AdditionalSongs/"..group_name.."/group.ini",
	fallback_ini_path(group_name)
    }
    for i,v in ipairs(tests) do
        if FILEMAN:DoesFileExist(v) then
            return v
        end
    end
end

local function split_and_trim(sep, txt)
    local tbl = split(sep, txt)
    for k, v in pairs(tbl) do
        tbl[k] = v:gsub("^%s*",""):gsub("%s*$","")
    end
    return tbl
end

local function song_specific_dir(song)
    local parts = split_and_trim("/", song:GetSongDir())
    return string.lower(parts[#parts-1])
end

--actually converts the text into a table
local function parse(text)

    --right now this tolerates things the original readers don't and doesn't
    --tolerate things the original readers do but if you make your files right
    --there shouldn't be a problem

    --step 1: remove comments
    text = text:gsub("^//.-\n", ""):gsub("\n//.-\n","")

    --step 2: collect and split tags
    local output = {}
    --right now this supports multiple tags per line. DON'T DO THIS!
    for tag, content in text:gmatch("#(%w+):(.-);") do
        output[tag:lower()] = split_and_trim(":",content)
    end

	return output
end

local function get_or_prepare(group)
	if data_map[group] then return data_map[group] end
	local path = group_name_to_path(group)
	local result = {}
	if path then
		local f = RageFileUtil.CreateRageFile()
		f:Open(path, 1)
		local text = f:Read()
		f:Close()
		f:destroy()
		result = parse(text)
	end
	data_map[group] = result
	return result
end

--functions for dealing with commonly used data items

local function parse_rgba(text)
    local output = split(",", text)
    if #output == 4 then
        for k, v in pairs(output) do
            local check = tonumber(v)
            if check and check >= 0 and check <= 1 then
                output[k] = check
            else
                return nil
            end
        end
        return output
    end
    return nil
end

local parse_metertype
do
	local conversion = {
		ddr = '_MeterType_DDR',
		['ddr x'] = '_MeterType_DDRX',
		itg = '_MeterType_ITG',
		pump = '_MeterType_Pump'
	}
	parse_metertype = function(text)
		return conversion[string.lower(text)] or nil
	end
end

local function parse_list(text)
    return split_and_trim("|", text)
end

-- more involved functions

--/\default and /\valid are chosen because they are impossible song dir names on any platform
local function read_overrides(group_data, key, parse_function, default)
    if type(group_data[key]) == "table" and group_data[key]["/\\valid"] then
        return group_data[key]
    end
    if (not group_data[key]) or next(group_data[key]) == nil then
        group_data[key] = {["/\\default"]=default, ["/\\valid"]=true}
        return group_data[key]
    end
    local new_section = {["/\\valid"]=true, ["/\\default"]=default}
    for _, data in pairs(group_data[key]) do
        local temp_storage = parse_function(data)
        if temp_storage then
            new_section["/\\default"] = temp_storage
        end
        temp_storage = parse_list(data)
        if #temp_storage >= 2 then
            --there must be at least an item and a song
            local provisional_item = parse_function(temp_storage[1])
            if provisional_item then
                for i=2,#temp_storage do
                    new_section[string.lower(temp_storage[i])] = provisional_item
                end
            end
        end
    end
    group_data[key] = new_section


    return new_section
end

return {
GetMenuColor=function(song)
    local group = song:GetGroupName()
    local mc_data = read_overrides(get_or_prepare(group),'menucolor',parse_rgba,{1,1,1,1})
    return mc_data[song_specific_dir(song)] or mc_data["/\\default"]
end;

GetMeterType=function(song)
	local group = song:GetGroupName()
	local mt_data = read_overrides(get_or_prepare(group), 'metertype', parse_metertype, '_MeterType_Default')
	return mt_data[song_specific_dir(song)] or mt_data["/\\default"]
end;

GetGroupName=function(group)
	local group_data = {pcall(get_or_prepare, group)}
	if group_data[1] == true then
		local name = group_data[2].name
		if type(name) == "table" and name[1] then
			return name[1]
		end
	end
    --gsub the group name to remove the sort number
    return string.gsub(group,"^%d%d? ?%- ?", "")
end;

GetGroupColor=function(group)
	local group_data = {pcall(get_or_prepare, group)}
	if group_data[1] == true then
		local name = group_data[2].groupcolor
		if type(name) == "table" and name[1] then
			local color = parse_rgba(name[1])
			if color then
				return color
			end
		end
	end
	return {1,1,1,1}
end;
}
