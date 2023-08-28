return setmetatable(
{
	CompleteBoxSet = {},
	RestoreColors = function(this,colorScheme)
        -- Clear the table in case it has anything on it.
        this.CompleteBoxSet = {}

        -- First, figure out what ColorScheme were looking for.
        local CurrentScheme = colorScheme or LoadModule("Config.Load.lua")("CurrentColorScheme","Save/OutFoxPrefs.ini")

        -- If we can't find the current ColorScheme, write the default one to the file.
        if not CurrentScheme then
            CurrentScheme = "default"
            LoadModule("Config.Save.lua")( "CurrentColorScheme", "default", "Save/OutFoxPrefs.ini" )
        end

        -- Now, load the coloring file.
        local File = IniFile.ReadFile( "/Appearance/ColorSets/"..CurrentScheme..".ini" )

        -- If we didn't find anything, then return the fallback table.
        if File == {} then
            Warn( "[Theme.Colors] The colorfile for ".. CurrentScheme .. " has not been found. Using backup color." )
			File = IniFile.ReadFile( THEME:GetPathO("Color","default.ini") )
            --return File
        end

        -- Before loading anything custom, let's load the file contents from the default color scheme as a fallback.
        local fallback = IniFile.ReadFile( THEME:GetPathO("Color","default") )

		if fallback ~= {} then
        	if fallback then for k,v in pairs( fallback["Shared"] ) do this.CompleteBoxSet[k] = color(v) end end
		end

        -- Now append the shared table (if there is one) and the current theme's colors.
        if File["Shared"] then for k,v in pairs( File["Shared"] ) do this.CompleteBoxSet[k] = color(v) end end

        -- Theme specific colors.
        local ThemeName = THEME:GetCurThemeName()
        if File[ ThemeName ] then for k,v in pairs( File[ThemeName] ) do this.CompleteBoxSet[k] = color(v) end end

        -- Special Case, some coloring bits are desired to be changable, so for that, we'll call it.
        if File["System"] then
            -- Player colors might want to be changed
            for i,pn in pairs(PlayerNumber) do
                local sh = ToEnumShortString(pn)
                if File["System"]["Player".. sh ] then
                    GameColor.PlayerColors["PLAYER_"..i] = color(File["System"]["Player".. sh ])
                end
            end
        end

        return this
    end,
    Values = {},
    GetListOfColors = function(this)
        if #this.Values == 0 then
            local list  = FILEMAN:GetDirListing("/Appearance/ColorSets/",false,true)
            this.Values[#this.Values+1] = "default"
            for _,v in pairs(list) do
                local _,file,_ = string.match(v,"^(.-)([^//]-)%.([^//%.]-)%.?")
                this.Values[#this.Values+1] = file
            end
        end
        return this.Values
    end,
},
{
	__call = function(this)
		return this:RestoreColors()
	end,
    __index = function(this, Item)
        if this.CompleteBoxSet[Item] then return this.CompleteBoxSet[Item] end
        return Color.White
    end}
)
