local t = {
	Setting = nil,
	DefaultFont = THEME:GetPathF("Combo","numbers"),
	GetDefaultFont = function(this)
		return THEME:HasMetric("Common","DefaultCombo") and THEME:GetMetric("Common","DefaultCombo") or this.DefaultFont
	end,
	GetComboUserName = function( this )
		return this.Setting or this:GetDefaultFont()
	end,
	FindTexture = function( this )
		if THEME:GetMetric("Common","UseAdvancedJudgments") then 
			if GAMESTATE:IsDemonstration() then
				return LoadModule("Options.SmartCombo.lua")()[LoadModule("Options.ChoiceToValue.lua")(LoadModule("Options.SmartCombo.lua")("Show"),this:GetDefaultFont())] 
			end
			return LoadModule("Options.SmartCombo.lua")()[LoadModule("Options.ChoiceToValue.lua")(LoadModule("Options.SmartCombo.lua")("Show"),this:GetComboUserName())]
		end
		return this:GetDefaultFont()
	end,
	GetTexture = function( this )
		local result = this:FindTexture()
		if not result then
			return this:GetDefaultFont()
		end
		return result
	end,
	GetPathToTexture = function( this )
		if FILEMAN:DoesFileExist( this:GetTexture().."/"..this:GetComboUserName()..".ini" ) then
			return this:GetTexture().."/"..this:GetComboUserName()..".ini"
		end
	
		-- No match, then default back to the regular font texture.
		return this.DefaultFont
	end,
	HasCustomJudgmentScript = function( this )
		return FILEMAN:DoesFileExist( this:GetPathFolder().."commands.lua" )
	end,
	GetPathFolder = function( this )
		if this:GetTexture() then
			return this:GetTexture().."/"
		end

		return this.DefaultFont
	end,
	__call = function(this, SmartComboSetting, DefaultFont)
		this.Setting = SmartComboSetting
		this.DefaultFont = DefaultFont
		return this
	end
}

return setmetatable(t,t)