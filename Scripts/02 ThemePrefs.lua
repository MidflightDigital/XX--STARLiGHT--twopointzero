--[[
	Please don't edit this file for more customization options.
]]

local Prefs =
{
	SV = {
		Default = "twopointzero",
		Choices = {"onepointzero","twopointzero"},
		Values = { "onepointzero","twopointzero"}
	},
	Touch = 
	{
		Default = false,
		Choices = {"Off", "On"},
		Values = { false, true}
	},
	RadarLimit = 
	{
		Default = false,
		Choices = {"Off", "On"},
		Values = { false, true}
	},
	EXScore = 
	{
		Default = false,
		Choices = {"Off", "On"},
		Values = { false, true}
	},
	CutIns =
	{
		Default = true,
		Choices = { "Off", "On" },
		Values = { false, true }
	},
	ComboUnderField =
	{
		Default = true,
		Choices = { "Off", "On" },
		Values = { false, true }
	},
	JudgeUnderField =
	{
		Default = true,
		Choices = { "Off", "On" },
		Values = { false, true }
	},
	ConvertScoresAndGrades =
	{
		Default = false,
		Choices = {"No", "Yes"},
		Values = {false, true}
	},
	ComboColorMode =
	{
		Default = "arcade",
		Choices = {"Arcade Style", "Wii Style", "Waiei Style"},
		Values = {"arcade", "wii", "waiei"}
	},
	MenuBG =
	{
		Default = "Default",
		Choices = { "Default", "2019", "2012", "SN3", "NG2" },
		Values = { "Default", "OG", "OLD", "SN3", "NG2" }
	},
	MenuMusic =
	{
		Default = "Default",
		Choices = { "Default"},
		Values = { "Default"}
	},
	WheelType =
	{
		Default = "Default",
		Choices = { "Default", "CoverFlow", "A", "Banner", "Jukebox", "Wheel", "Solo", "Preview" },
		Values = { "Default", "CoverFlow", "A", "Banner", "Jukebox", "Wheel", "Solo", "Preview" }
	},
	ShowHTP = 
	{
		Default = false,
		Choices = {"No", "Yes"},
		Values = {false, true}
	},
	ShowDiffSelect = 
	{
		Default = true,
		Choices = {"No","Yes"},
		Values = {false,true}
	},
	CDTITLE = 
	{
		Default = false,
		Choices = {"No","Yes"},
		Values = {false,true}
	},
	ComboPerRow = 
	{
		Default = true,
		Choices = {"One Note","Multiple Notes"},
		Values = {false,true}
	},
	OLOrPO = 
	{
		Default = "Options List",
		Choices = {"Options List","Player Options"},
		Values = {"Options List", "Player Options"}
	},
	BurnInProtect =
	{
		Default = false,
		Choices = {"Off", "On"},
		Values = {false,true}
	},
	ExclusiveNS = 
	{
		Default = false,
		Choices = {"Off", "On"},
		Values = {false,true}
	},
	PauseMenu = 
	{
		Default = false,
		Choices = {"Off", "On"},
		Values = {false,true},
	},
	MachinePrefsSaveToDisk = 
	{
		Default = false,
		Choices = {"No", "Yes"},
		Values = {false, true},
	},
	AutoSelectStyle = 
	{
		Default = '',
		Choices = {'Off', 'Single', 'Double', 'Versus'},
		Values = {'', 'single', 'double', 'versus'},
	},
};

ThemePrefs.InitAll(Prefs)

function OptionsListOrPlayerOptions()
	if ThemePrefs.Get("OLOrPO") == "Options List" then
		return true
	else
		return false
	end
end

--[[function Branding()
	--I'm too lazy to rename the actual files so uhhhh string.lower to the rescue LMAO
	if GAMESTATE:GetCoinMode() == "CoinMode_Home" then
		return string.lower(ThemePrefs.Get("Branding").."_")
	else
		return "project_"
	end
end]]

function SMUsePO()
	if ThemePrefs.Get("OLOrPO") == "Player Options" then
		return true
	else
		return false
	end
end

function SMUseOL()
	if ThemePrefs.Get("OLOrPO") == "Options List" then
		return true
	else
		return false
	end
end

function ComboUnderField()
	return ThemePrefs.Get("ComboUnderField")
end

function JudgeUnderField()
	return ThemePrefs.Get("JudgeUnderField")
end

function ReadOrCreateAppearancePlusValueForPlayer(PlayerUID, MyValue)
	local AppearancePlusFile = RageFileUtil:CreateRageFile()
	if AppearancePlusFile:Open("Save/AppearancePlus/"..PlayerUID..".txt",1) then 
		local str = AppearancePlusFile:Read();
		MyValue =str;
	else
		AppearancePlusFile:Open("Save/AppearancePlus/"..PlayerUID..".txt",2);
		AppearancePlusFile:Write("Visible");
		MyValue="Visible";
	end
	AppearancePlusFile:Close();
	return MyValue;
end

function SaveAppearancePlusValueForPlayer( PlayerUID, MyValue)

	
	local AppearancePlusFile2 = RageFileUtil:CreateRageFile();
	AppearancePlusFile2:Open("Save/AppearancePlus/"..PlayerUID..".txt",2);
	AppearancePlusFile2:Write(tostring(MyValue));
	AppearancePlusFile2:Close();
end

function OptionRowAppearancePlusUseFile()
	local t = {
		Name="Appearance",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		--Choices = { "Visible", 'Hidden', 'Sudden', 'Stealth', 'Hidden+', 'Sudden+', 'Hidden+&Sudden+', },
		Choices = { "Visible", 'Hidden', 'Sudden', 'Stealth', 'Hidden+', 'Sudden+', },
		LoadSelections = function(self, list, pn)
			local AppearancePlusValue = "Visible";
			local pf = PROFILEMAN:GetProfile(pn);
			local PlayerUID = "";
			
			if pf then 
				PlayerUID = pf:GetGUID()  
				AppearancePlusValue = ReadOrCreateAppearancePlusValueForPlayer(PlayerUID,AppearancePlusValue);
			else
				PlayerUID = "UnknownPlayerUID"
				AppearancePlusValue = "Visible";
			end
			
			if AppearancePlusValue ~= nil then
				if AppearancePlusValue == "Hidden" then
					list[2] = true
				elseif AppearancePlusValue == "Sudden" then
					list[3] = true
				elseif AppearancePlusValue == "Stealth" then
					list[4] = true
				elseif AppearancePlusValue == "Hidden+" then
					list[5] = true
				elseif AppearancePlusValue == "Sudden+" then
					list[6] = true
				elseif AppearancePlusValue == "Hidden+&Sudden+" then
					list[7] = true
				else
					list[1] = true
				end
			else
				SaveAppearancePlusValueForPlayer(PlayerUID,"Visible")
				list[1] = true
			end
			
		end,
		SaveSelections = function(self, list, pn)
			local pName = ToEnumShortString(pn)
			local found = false
			local PlayerUID = "";
			local pf = PROFILEMAN:GetProfile(pn);
			
			if pf then 
				PlayerUID = pf:GetGUID()  
			else
				PlayerUID = "UnknownPlayerUID"
			end
			
			for i=1,#list do
				if not found then
					if list[i] == true then
						local val = "Visible";
						if i==2 then
							val = "Hidden";
						elseif i==3 then
							val = "Sudden";
						elseif i==4 then
							val = "Stealth";
						elseif i==5 then
							val = "Hidden+";
						elseif i==6 then
							val = "Sudden+";
						elseif i==7 then
							val = "Hidden+&Sudden+";
						else
							val = "Visible";
						end
						setenv("AppearancePlus"..pName,val)
						SaveAppearancePlusValueForPlayer(PlayerUID,val)
						found = true
						break;
					end
				end
			end
		end,
	};
	setmetatable(t, t)
	return t
end

function JudgmentTransformCommand( self, params )
	self:x( 0 )
	self:y( params.bReverse and 67 or -76 )
end
