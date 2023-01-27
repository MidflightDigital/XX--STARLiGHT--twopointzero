local args = {...}
local player = args[1]


local short_plr = ToEnumShortString(player)

local profileID = GetProfileIDForPlayer(player)
local pPrefs = ProfilePrefs.Read(profileID)
local ex_score = pPrefs.ex_score
--ex_score = getenv("EXScore"..short_plr)
local rn_type = "RollingNumbers"
local data_source = "AScoring"

if ex_score then
    rn_type = "RollingNumbersEXScore"
    data_source = "EXScore"
end

local metrics_prefix = "ScoreCustom"..short_plr
local loading_screen = Var "LoadingScreen"
local last_value = 0

return Def.ActorFrame{
	Def.RollingNumbers{
		Name="ScoreCounter"..short_plr,
		Font=THEME:GetPathF("ScoreDisplayNormal","Text"),
		InitCommand=function(s) s:Load(rn_type):xy(player==PLAYER_1 and (ex_score and 480 or 264) or (ex_score and -30 or -246),-2)
			:halign(ex_score and 1 or 0.5)
		end,
		OnCommand=THEME:GetMetric(loading_screen,metrics_prefix.."OnCommand"),
		OffCommand=THEME:GetMetric(loading_screen,metrics_prefix.."OffCommand"),
		AfterStatsEngineMessageCommand=function(s,p)
			if p.Player == player then
				local value = p.Data[data_source].Score 
				if value~=last_value then 
					s:targetnumber(value) 
				last_value = value 
				end 
			end
		end
	},
	Def.BitmapText{
		Font="_avenirnext lt pro bold/36px",
		Text="EX",
		InitCommand=function(s) s:visible(ex_score):xy(player==PLAYER_1 and 40 or -460,-2):halign(0):zoomy(0.9)
			:diffuse(Color.Yellow)
		end,
	};
};
