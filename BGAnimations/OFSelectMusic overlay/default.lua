-- The wheels we support/have.
local Wheels = {
	"DDR1st1.5Wheel",
	"DDR2ndMIXCLUBVERSiON2Wheel",
	"DDR3rdMixPlusWheel",
	"DDR4thMixPlusWheel",
	"DDR5thMixWheel",
	--"DDRMAXWheel",

	---"Popn10Wheel",
}

-- The Styles that are defined for the game mode.
local GameModeStyles = {
	["dance"] = "dance_single",
	["pump"] = "pump_single",
	["ez2"] = "ez2_single",
	["para"] = "para_single",
	["ds3ddx"] = "ds3ddx_single",
	["beat"] = "bm_single7",
	["maniax"] = "maniax_single",
	["techno"] = "techno_single4",
	["popn"] = "pnm_nine",
	["gddm"] = "gddm_new",
	["gdgf"] = "guitar_five",
	["gh"] = "gh_solo",
	["kbx"] = "kb4_single",
	["taiko"] = "taiko",
	["lights"] = "lights_cabinet",
	["kickbox"] = "kickbox_human"
}

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
return LoadModule("Wheel.Default.lua")(GameModeStyles[GAMESTATE:GetCurrentGame():GetName()] or "dance_single")

--Debugging.
--return LoadModule("Wheel.Popn10Wheel.lua")(GameModeStyles[GAMESTATE:GetCurrentGame():GetName()] or "dance_single")