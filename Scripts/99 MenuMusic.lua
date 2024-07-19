do
	--if there isn't music for a specific screen it falls back to common
	local music = {
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
			["Default"] = "_swoosh in.ogg";
			["saiiko"] = "_swoosh in.ogg";
			["vortivask"] = "_swoosh in.ogg";
			["inori"] = "_swoosh in.ogg";
			["RGTM"] = "_swoosh in.ogg";
			["fancy cake"] = "_swoosh in.ogg";
			["leeium"] = "MenuMusic/Title/leeium.ogg";
			["SN3"] = "_swoosh in.ogg";
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
	--thanks to this code
	for name,child in pairs(music) do
		if name ~= "common" then
			setmetatable(child, {__index=music.common})
		end
	end
	function GetMenuMusicPath(type, relative)
		local possibles = music[type]
			or error("GetMenuMusicPath: unknown menu music type "..type, 2)
		local selection = ThemePrefs.Get("MenuMusic")
		local file = possibles[selection]
			or error("GetMenuMusicPath: no menu music defined for selection"..selection, 2)
		return relative and file or THEME:GetPathS("", file)
	end

	--[[This doesn't work right
	local musicfb = {
		common = {
			["Default"] = "MenuMusic/Default/common (loop).ogg"
		},
		profile = {
			["Default"] = "MenuMusic/Default/profile (loop).ogg"
		},
		results = {
			["Default"] = "MenuMusic/Default/results (loop).ogg"
		},
		music = {
			["Default"] = "MenuMusic/Default/common (loop).ogg"
		},
		stage = {
			["Default"] = "_Door.ogg"
		},
		title = {
			["Default"] = "Title_In.ogg"
		},
		options = {
			["Default"] = "MenuMusic/Default/options (loop).ogg"
		},

	}
	function GetMenuMusicPath(type, relative)
		local paths = {
			THEME:GetCurrentThemeDirectory().."/Sounds/MenuMusic/"..ThemePrefs.Get("MenuMusic").."/"..type.." (loop).ogg",
			THEME:GetCurrentThemeDirectory().."/Sounds/MenuMusic/"..ThemePrefs.Get("MenuMusic").."/"..type.." .ogg",
			THEME:GetCurrentThemeDirectory().."/Sounds/MenuMusic/"..ThemePrefs.Get("MenuMusic").."/"..type..".ogg",
		}
		for path in ivalues(paths) do
			if FILEMAN:DoesFileExist(path) then
				return path
			elseif FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Sounds/MenuMusic/"..ThemePrefs.Get("MenuMusic").."/common (loop).ogg") and 
			(type ~= "title" or type ~= "stage") then
				return THEME:GetCurrentThemeDirectory().."/Sounds/MenuMusic/"..ThemePrefs.Get("MenuMusic").."/common (loop).ogg"
			end
		end
		return THEME:GetPathS("",musicfb[type]["Default"])
	end]]
end
