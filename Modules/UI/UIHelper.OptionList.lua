return setmetatable({
    song_option = function( name, type, margin, min, max, format )
        return { Name = name, Type = type, Value = "song_option", Margin = margin, Min = min, Max = max, Format = format }
    end,
    -- { Name = "Persp", Type = "list", Value = "player_mod_table", Values = {"Hallway","Incoming","Overhead","Space","Distant"} },
    list = function( name, value, Items, machineSetting )
        return { Name = name, Type = "list", Value = value, Values = Items, MachinePref = machineSetting }
    end,
    -- { Name = "Mini", Type = "number", Margin = 0.01, Format = "%.2f", Value = "player_mod" },
    number = function( name, value, margin, min, max, format )
        return { Name = name, Type = "number", Value = value or 0, Margin = margin or 1, Min = min or 0, Max = max or 1, Format = format or "%d" }
    end,
    -- { Name = "MissCounter", Type="boolean", Value="outfox_pref" },
    boolean = function( name, value )
        return { Name = name, Type="boolean", Value=value }
    end,
    formatToPercent = function( val )
        return string.format("%d%%", math.floor((val*100)+0.5))
    end,
    decimalNumber = function( val )
        return string.format("%.2f", val)
    end,
    findInTable = function( table, value, default )
        for i,v in ipairs( table ) do
			if tostring(v) == tostring(value) then
				return i
			end
        end
		return default or 1
    end,
    -- Returns the value from the container given from self.
    GetItemFromContainerIndex = function(self)
        return self.container.Values[self.container.ValueE]
    end,
    -- Helper functions to obtain Scroll speed informtion
    ObtainSpeedType = function( pOptions )
        local sptype = 1
        if pOptions:XMod() then sptype = 1 end
        if pOptions:CMod() then sptype = 2 end
        if pOptions:MMod() then sptype = 3 end
        if pOptions:AMod() then sptype = 4 end
        if pOptions:CAMod() then sptype = 5 end
    
        return sptype
    end,
    GetSpeed = function( pOptions, CurType )
        if not CurType then return 0 end
    
        if CurType == 1 then return pOptions:XMod()*100 end
        if CurType == 2 then return pOptions:CMod() end
        if CurType == 3 then return pOptions:MMod() end
        if CurType == 4 then return pOptions:AMod() end
        if CurType == 5 then return pOptions:CAMod() end
    
        return 0
    end
},{})