local sStage = GAMESTATE:GetCurrentStage();
local tRemap = {
	Stage_1st		= 1,
	Stage_2nd		= 2,
	Stage_3rd		= 3,
	Stage_4th		= 4,
	Stage_5th		= 5,
	Stage_6th		= 6,
};
if tRemap[sStage] == PREFSMAN:GetPreference("SongsPerPlay") then
	sStage = "Stage_Final";
else
	sStage = sStage;
end;

local rename = {
	Stage_1st	= "stage 1",
	Stage_2nd	= "stage 2",
	Stage_3rd	= "stage 3",
	Stage_4th	= "stage 4",
	Stage_5th	= "stage 5",
	Stage_6th	= "stage 6",
	Stage_Final = "stage final",
	Stage_Extra = "stage extra1",
	Stage_Extra1 = "stage extra1",
	Stage_Extra2 = "stage extra2",
}

local asound = rename[sStage]

if GAMESTATE:GetCurrentStageIndex() >= 5 then
	asound = "stage event"
elseif GAMESTATE:GetPlayMode() == 'PlayMode_Oni' then
	asound = "stage oni"
elseif GAMESTATE:GetPlayMode() == 'PlayMode_Nonstop' then
	asound = "stage nonstop"
elseif GAMESTATE:GetCurrentStage() == 'Stage_Final' then
	asound = "stage final"
elseif GAMESTATE:IsExtraStage() then
	asound = "stage extra1"
elseif GAMESTATE:IsExtraStage2() then
	asound = "stage extra2"
end

SOUND:PlayAnnouncer(asound)
	
return t;