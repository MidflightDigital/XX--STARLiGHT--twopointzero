--The function will first try to look up the style by StepsType.
--Failing that, it will look it up by StyleType.
--If that fails, it will throw an error as every style type should be in this table.
--If the result is a function, that will be run.
local function NormalX()
	return WideScale(175, 235)
end

local xOffsetControl = {
	StepsType = {
		StepsType_Dance_Solo = 0,
		StepsType_Dance_Couple = function() return WideScale(175, 160) end,
	},
	StyleType = {
		StyleType_OnePlayerOneSide = NormalX,
		StyleType_OnePlayerTwoSides = 0,
		StyleType_TwoPlayersTwoSides = NormalX,
		StyleType_TwoPlayersSharedSides = 0
	}
}

function ScreenGameplay_X(pn)
	local st = GAMESTATE:GetCurrentStyle()
	local scale = pn=='PlayerNumber_P1' and -1 or 1

	local determiner = xOffsetControl.StepsType[st:GetStepsType()]
	if not determiner then
		local styletype = st:GetStyleType()
		determiner = xOffsetControl.StyleType[styletype]
		if not determiner then
			error("No position information for StyleType "..styletype)
		end
	end

	local x = type(determiner) == "function" and determiner() or determiner
	return x * scale + SCREEN_CENTER_X
end

function TitleChoices()
	local coinMode = GAMESTATE:GetCoinMode()
	if coinMode == 'CoinMode_Home' then
		return "Start"
	else
		return "ArcStart"
	end
end;

function ModeChoices()
	local coinMode = GAMESTATE:GetCoinMode()
	if coinMode == 'CoinMode_Home' then
		return SN3Debug and "Options,Edit,GameStart,Customize,Jukebox,Exit" or "Options,Edit,GameStart,Customize,Exit"
	else
		return "GameStart"
	end
end;
