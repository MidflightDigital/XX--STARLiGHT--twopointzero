--Player judgment.lua
--From _fallback, author unclear
--Stripped and remodeled for DDR SN3
local c;
local player = Var "Player";
local playerPrefs = ProfilePrefs.Read(GetProfileIDForPlayer(player))

local env = GAMESTATE:Env();

--disable bias in starter mode
local showBias = playerPrefs.bias

local JudgeCmds = {
	TapNoteScore_W1 = THEME:GetMetric( "Judgment", "JudgmentW1Command" );
	TapNoteScore_W2 = THEME:GetMetric( "Judgment", "JudgmentW2Command" );
	TapNoteScore_W3 = THEME:GetMetric( "Judgment", "JudgmentW3Command" );
	TapNoteScore_W4 = THEME:GetMetric( "Judgment", "JudgmentW4Command" );
	TapNoteScore_W5 = THEME:GetMetric( "Judgment", "JudgmentW4Command" );
	TapNoteScore_Miss = THEME:GetMetric( "Judgment", "JudgmentMissCommand" );
};

local OLDJudgeCmds = {
	TapNoteScore_W1 = THEME:GetMetric( "Judgment", "JudgmentW2Command" );
	TapNoteScore_W2 = THEME:GetMetric( "Judgment", "JudgmentW2Command" );
	TapNoteScore_W3 = THEME:GetMetric( "Judgment", "JudgmentW3Command" );
	TapNoteScore_W4 = THEME:GetMetric( "Judgment", "JudgmentW4Command" );
	TapNoteScore_Miss = THEME:GetMetric( "Judgment", "JudgmentMissCommand" );
};

local BiasCmd = THEME:GetMetric("Judgment", "JudgmentBiasCommand");

local TNSFrames = {
	TapNoteScore_W1 = 0;
	TapNoteScore_W2 = 1;
	TapNoteScore_W3 = 2;
	TapNoteScore_W4 = 3;
	TapNoteScore_W5 = 3;
	TapNoteScore_Miss = 4;
};

--frame 1 is the Early frame, 2 is the Late frame and doesn't appear in the table
--it is added by code downstream
local OLDTNSFrames = {
	TapNoteScore_W1 = 0;
	TapNoteScore_W2 = 0;
	TapNoteScore_W3 = 1;
	TapNoteScore_W4 = 2;
	TapNoteScore_W5 = 3;
	TapNoteScore_Miss = 4;
};


local activeFrames = OLDMIX and OLDTNSFrames or TNSFrames;
local activeCmds = OLDMIX and OLDJudgeCmds or JudgeCmds;

local t = Def.ActorFrame {


	InitCommand = function(self)
		c = self:GetChildren();
	end;

	JudgmentMessageCommand=function(self, param)
		if param.Player ~= player then return end;
		if not param.HoldNoteScore then

			local iNumStates = c.Judgment:GetNumStates();
			local iFrame = activeFrames[param.TapNoteScore];
			if not iFrame then return end

			local iTapNoteOffset = param.TapNoteOffset;
			local late = iTapNoteOffset and (iTapNoteOffset > 0);

			self:playcommand("Reset");

			c.Judgment:setstate( iFrame );
			c.Judgment:visible( true );
			activeCmds[param.TapNoteScore](c.Judgment);
			if showBias == true then
				---XXX: don't hardcode this
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

t[#t+1] = LoadActor("Judgment 1x5") .. {
	Name="Judgment";
	InitCommand=function(s) s:pause():visible(false) end,
	OnCommand=THEME:GetMetric("Judgment","JudgmentOnCommand");
	ResetCommand=function(s) s:finishtweening():stopeffect():visible(false) end,
};


if showBias == true then
	t[#t+1] = LoadActor("Deviation 1x2") .. {
		Name="Bias";
		InitCommand=function(s) s:pause():visible(false) end,
		OnCommand=THEME:GetMetric("Judgment","JudgmentBiasOnCommand");
		ResetCommand=function(s) s:finishtweening():stopeffect():visible(false) end,
	};
end
return t;
