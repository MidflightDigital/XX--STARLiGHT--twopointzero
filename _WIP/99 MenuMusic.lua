do
	--if there isn't music for a specific screen it falls back to common
	local choices = {
		common = {
			["Default"] = "MenuMusic/common/Default (loop).ogg";
			["saiiko"] = "MenuMusic/common/sk2_menu2 (loop).ogg";
			["vortivask"] = "MenuMusic/common/djvortivask (loop).ogg";
			["inori"] = "MenuMusic/common/inori (loop).ogg";
			["RGTM"] = "MenuMusic/common/128beat (loop).ogg";
			["fancy cake"] = "MenuMusic/common/fancycake (loop).ogg";
			["leeium"] = "MenuMusic/common/leeium (loop).ogg";
			["SN3"] = "MenuMusic/common/SN3 (loop).ogg";
			["Off"] = "_silent.ogg";
		};
		profile = {
			["Default"] = "MenuMusic/profile/Default (loop).ogg";
			["saiiko"] = "MenuMusic/profile/sk2_menu1 (loop).ogg";
			["vortivask"] = "MenuMusic/common/djvortivask (loop).ogg";
			["inori"] = "MenuMusic/profile/inori (loop).ogg";
			["RGTM"] = "MenuMusic/profile/128beat (loop).ogg";
			["fancy cake"] = "MenuMusic/profile/fancycake (loop).ogg";
			["leeium"] = "MenuMusic/profile/leeium (loop).ogg";
			["SN3"] = "MenuMusic/profile/SN3 (loop).ogg";
			["Off"] = "_silent.ogg";
		};
		results = {
			["Default"] = "MenuMusic/common/Default (loop).ogg";
			["saiiko"] = "MenuMusic/results/sk2_menu3 (loop).ogg";
			["vortivask"] = "MenuMusic/common/djvortivask (loop).ogg";
			["inori"] = "MenuMusic/common/inori (loop).ogg";
			["RGTM"] = "MenuMusic/results/128beat (loop).ogg";
			["fancy cake"] = "MenuMusic/results/fancycake (loop).ogg";
			["leeium"] = "MenuMusic/common/leeium (loop).ogg";
			["SN3"] = "MenuMusic/common/SN3 (loop).ogg";
			["Off"] = "_silent.ogg";
		};
		music = {
			["Default"] = "MenuMusic/common/Default (loop).ogg";
			["saiiko"] = "MenuMusic/common/sk2_menu2 (loop).ogg";
			["vortivask"] = "MenuMusic/common/djvortivask (loop).ogg";
			["inori"] = "MenuMusic/common/inori (loop).ogg";
			["RGTM"] = "MenuMusic/common/128beat (loop).ogg";
			["fancy cake"] = "MenuMusic/common/fancycake (loop).ogg";
			["leeium"] = "MenuMusic/common/leeium (loop).ogg";
			["SN3"] = "MenuMusic/common/SN3 (loop).ogg";
			["Off"] = "_silent.ogg";
		};
		stage = {
			["Default"] = "_Door.ogg";
			["saiiko"] = "_Door.ogg";
			["vortivask"] = "_Door.ogg";
			["inori"] = "_Door.ogg";
			["RGTM"] = "_Door.ogg";
			["fancy cake"] = "_Door.ogg";
			["leeium"] = "MenuMusic/StageInfo/leeium.ogg";
			["SN3"] = "MenuMusic/StageInfo/SN3.ogg";
			["Off"] = "_silent.ogg";
		};
		title = {
			["Default"] = "Title_In.ogg";
			["saiiko"] = "Title_In.ogg";
			["vortivask"] = "Title_In.ogg";
			["inori"] = "Title_In.ogg";
			["RGTM"] = "Title_In.ogg";
			["fancy cake"] = "Title_In.ogg";
			["leeium"] = "MenuMusic/Title/leeium.ogg";
			["SN3"] = "Title_In.ogg";
			["Off"] = "_silent.ogg";
		};
		options = {
			["Default"] = "MenuMusic/options/Default (loop).ogg";
			["saiiko"] = "MenuMusic/options/Default (loop).ogg";
			["vortivask"] = "MenuMusic/options/djvortivask (loop).ogg";
			["inori"] = "MenuMusic/options/Default (loop).ogg";
			["RGTM"] = "MenuMusic/options/128beat (loop).ogg";
			["fancy cake"] = "MenuMusic/options/Default (loop).ogg";
			["leeium"] = "MenuMusic/options/Default (loop).ogg";
			["SN3"] = "MenuMusic/options/SN3 (loop).ogg";
			["Off"] = "_silent.ogg";
		}
	}

	local names = {}
	local common = {}
	local profile = {}
	local results = {}
	local music = {}
	local stage = {}
	local title = {}
	local options = {}
	--Create Common Table
	function GetAllPotentialBGMs()
		local output = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory().."/Customization/BGM/",true,false)
		table.sort(output)
		return output
	end
	function GetAllBGMs()
		local potentials = GetAllPotentialBGMs()
		for bgmName in ivalues(potentials) do
			if FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Customization/BGM/"..bgmName.."/common (loop).ogg") then
				table.insert(names,bgmName)
				table.insert(common,"/Customization/BGM/"..bgmName.."/common (loop).ogg")
			end
			if FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Customization/BGM/"..bgmName.."/profile (loop).ogg") then
				table.insert(profile,"/Customization/BGM/"..bgmName.."/profile (loop).ogg")
			else
				table.insert(profile,"/Customization/BGM/"..bgmName.."/common (loop).ogg")
			end
			if FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Customization/BGM/"..bgmName.."/results (loop).ogg") then
				table.insert(results,"/Customization/BGM/"..bgmName.."/results (loop).ogg")
			else
				table.insert(results,"/Customization/BGM/"..bgmName.."/common (loop).ogg")
			end
			if FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Customization/BGM/"..bgmName.."/music (loop).ogg") then
				table.insert(music,"/Customization/BGM/"..bgmName.."/music (loop).ogg")
			else
				table.insert(music,"/Customization/BGM/"..bgmName.."/common (loop).ogg")
			end
			if FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Customization/BGM/"..bgmName.."/title (loop).ogg") then
				table.insert(title,"/Customization/BGM/"..bgmName.."/title (loop).ogg")
			else
				table.insert(title,"Sounds/Title_In.ogg")
			end
		end
	end
	GetAllBGMs()
	function GetMenuMusicPath(type, relative)
		--[[local possibles = names
			or error("GetMenuMusicPath: unknown menu music type "..type, 2)
		local selection = ThemePrefs.Get("MenuMusic")
		local file = type[selection]
			or error("GetMenuMusicPath: no menu music defined for selection "..selection, 2)]]
		return THEME:GetCurrentThemeDirectory()..profile[1]
	end
	--thanks to this code
	--[[for name,child in pairs(choices) do
		if name ~= "common" then
			setmetatable(child, {__index=choices.common})
		end
	end
	function GetMenuMusicPath(type, relative)
		SCREENMAN:SystemMessage(music[1])
		local possibles = choices[type]
			or error("GetMenuMusicPath: unknown menu music type "..type, 2)
		local selection = ThemePrefs.Get("MenuMusic")
		local file = possibles[selection]
			or error("GetMenuMusicPath: no menu music defined for selection"..selection, 2)
		return relative and file or THEME:GetPathS("", file)
	end]]
end
