--Player judgment.lua
--From _fallback, author unclear
--Stripped and remodeled for DDR SN3
local c;
local player = Var "Player";
local playerPrefs = ProfilePrefs.Read(GetProfileIDForPlayer(player))

local env = GAMESTATE:Env();

--disable bias in starter mode
local showBias = playerPrefs.bias

local TimingMode = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini") or "Unknown"
local NoBads = (TimingMode == "DDR Modern" and true or false)

local JudgeCmds = {}
local TNSFrames = {}
-- Hi, I'm a hack lmao. -Sunny
if NoBads then
	JudgeCmds = {
		TapNoteScore_W1 = THEME:GetMetric( "Judgment", "JudgmentW1Command" );
		TapNoteScore_W2 = THEME:GetMetric( "Judgment", "JudgmentW2Command" );
		TapNoteScore_W3 = THEME:GetMetric( "Judgment", "JudgmentW3Command" );
		TapNoteScore_W4 = THEME:GetMetric( "Judgment", "JudgmentW4Command" );
		TapNoteScore_W5 = THEME:GetMetric( "Judgment", "JudgmentW4Command" );
		TapNoteScore_Miss = THEME:GetMetric( "Judgment", "JudgmentMissCommand" );
	};
	TNSFrames = {
		TapNoteScore_W1 = 0;
		TapNoteScore_W2 = 1;
		TapNoteScore_W3 = 2;
		TapNoteScore_W4 = 3;
		TapNoteScore_W5 = 3;
		TapNoteScore_Miss = 5;
	};
else
	JudgeCmds = {
		TapNoteScore_W1 = THEME:GetMetric( "Judgment", "JudgmentW1Command" );
		TapNoteScore_W2 = THEME:GetMetric( "Judgment", "JudgmentW2Command" );
		TapNoteScore_W3 = THEME:GetMetric( "Judgment", "JudgmentW3Command" );
		TapNoteScore_W4 = THEME:GetMetric( "Judgment", "JudgmentW4Command" );
		TapNoteScore_W5 = THEME:GetMetric( "Judgment", "JudgmentW5Command" );
		TapNoteScore_Miss = THEME:GetMetric( "Judgment", "JudgmentMissCommand" );
	};
	TNSFrames = {
		TapNoteScore_W1 = 0;
		TapNoteScore_W2 = 1;
		TapNoteScore_W3 = 2;
		TapNoteScore_W4 = 3;
		TapNoteScore_W5 = 4;
		TapNoteScore_Miss = 5;
	};
end

local OLDJudgeCmds = {
	TapNoteScore_W1 = THEME:GetMetric( "Judgment", "JudgmentW2Command" );
	TapNoteScore_W2 = THEME:GetMetric( "Judgment", "JudgmentW2Command" );
	TapNoteScore_W3 = THEME:GetMetric( "Judgment", "JudgmentW3Command" );
	TapNoteScore_W4 = THEME:GetMetric( "Judgment", "JudgmentW4Command" );
	TapNoteScore_W5 = THEME:GetMetric( "Judgment", "JudgmentW5Command" );
	TapNoteScore_Miss = THEME:GetMetric( "Judgment", "JudgmentMissCommand" );
};

local BiasCmd = THEME:GetMetric("Judgment", "JudgmentBiasCommand");

local t = Def.ActorFrame {


	InitCommand = function(self)
		c = self:GetChildren();
	end;

	JudgmentMessageCommand=function(self, param)
		if param.Player ~= player then return end;
		if not param.HoldNoteScore then

			local iNumStates = c.Judgment:GetNumStates();
			local iFrame = TNSFrames[param.TapNoteScore];
			if not iFrame then return end

			local iTapNoteOffset = param.TapNoteOffset;
			local late = iTapNoteOffset and (iTapNoteOffset > 0);

			self:playcommand("Reset");

			c.Judgment:setstate( iFrame );
			c.Judgment:visible( true );
			JudgeCmds[param.TapNoteScore](c.Judgment);
			if showBias == true then
				---XXX: don't hardcode this
				if GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):Reverse() == 1 then
					c.Bias:y(-20)
				else
					c.Bias:y(20)
				end
				if param.TapNoteScore ~= 'TapNoteScore_W1' and
					param.TapNoteScore ~= 'TapNoteScore_Miss' then
					c.Bias:visible(true);
					c.Bias:setstate( late and 1 or 0 );
					BiasCmd(c.Bias);
				end
			end
		end
	end;
};

local profileID = GetProfileIDForPlayer(player)
local pPrefs = ProfilePrefs.Read(profileID)

t[#t+1] = Def.Sprite{
	Texture=pPrefs.Judgment.." 1x6",
	Name="Judgment";
	InitCommand=function(s) s:pause():visible(false) end,
	OnCommand=THEME:GetMetric("Judgment","JudgmentOnCommand");
	ResetCommand=function(s) s:finishtweening():stopeffect():visible(false) end,
};


if showBias == true then
	t[#t+1] = Def.Sprite{
		Texture="Deviation 1x2",
		Name="Bias";
		InitCommand=function(s) s:pause():visible(false) end,
		OnCommand=THEME:GetMetric("Judgment","JudgmentBiasOnCommand");
		ResetCommand=function(s) s:finishtweening():stopeffect():visible(false) end,
	};
end
return t;
