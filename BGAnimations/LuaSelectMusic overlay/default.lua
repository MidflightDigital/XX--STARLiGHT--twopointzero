-- The Styles that are defined for the game mode.
local GameModeStyles = LoadModule("Gameplay.Styles.lua")

if SONGMAN:GetNumSongs() == 0 then
	-- Don't do anything, this is going to be a failsafe to then move to the install song
	-- helper.
	return Def.ActorFrame{
		OnCommand=function(self)
			SCREENMAN:SetNewScreen("ScreenHowToInstallSongs")
		end
	}
end

-- The last defined wheel, Its like smart shuffle, We dont want to get the same wheel twice.
if not Last then Last = 0 end

-- Our random suffle function.
local function RandButNotLast(Amount)
	local Now
	while true do
		Now = math.random(1,Amount)
		if Now ~= Last then break end
	end
	Last = Now
	return Now
end

--Return the Def table that contains all the stuff, Check the module folder for the wheels.
return LoadModule("Wheel/Wheel.Default.lua")(GameModeStyles[GAMESTATE:GetCurrentGame():GetName()] or "dance_single")..{
	CancelCommand=function(self)
		self:playcommand("Off")
	end
}