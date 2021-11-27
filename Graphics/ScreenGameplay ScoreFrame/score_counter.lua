local args = {...}
local player = args[1]


local short_plr = ToEnumShortString(player)
local ex_score = false;
--ex_score = getenv("EXScore"..short_plr)
local rn_type = "RollingNumbers"
local data_source = "AScoring"

if ex_score then
    rn_type = "RollingNumbersEXScore"
    data_source = "EXScore"
end

local metrics_prefix = "ScoreCustom"..short_plr
local loading_screen = Var "LoadingScreen"
local x_pos = tonumber(THEME:GetMetric(loading_screen,metrics_prefix..'X'))
local y_pos = tonumber(THEME:GetMetric(loading_screen,metrics_prefix..'Y'))
local last_value = 0

return Def.RollingNumbers{
	Name="ScoreCounter"..short_plr,
	Font=THEME:GetPathF("ScoreDisplayNormal","Text"),
	InitCommand=function(s) s:Load(rn_type):xy(x_pos,y_pos) end,
	OnCommand=THEME:GetMetric(loading_screen,metrics_prefix.."OnCommand"),
	OffCommand=THEME:GetMetric(loading_screen,metrics_prefix.."OffCommand"),
	AfterStatsEngineMessageCommand=function(s,p)
		if not p.Player == player then return end
		local value = p.Data[data_source].Score 
		if value~=last_value then 
			s:targetnumber(value) 
			last_value = value 
		end 
	end
}
