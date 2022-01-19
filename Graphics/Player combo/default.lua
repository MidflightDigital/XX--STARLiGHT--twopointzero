local c;
local cf;
local cfInv;
local player = Var "Player";
local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt");
local Pulse = THEME:GetMetric("Combo", "PulseCommand");
local PulseLabel = THEME:GetMetric("Combo", "PulseLabelCommand");
local xxState;

local NumberMinZoom = THEME:GetMetric("Combo", "NumberMinZoom");
local NumberMaxZoom = THEME:GetMetric("Combo", "NumberMaxZoom");
local NumberMaxZoomAt = THEME:GetMetric("Combo", "NumberMaxZoomAt");

local LabelMinZoom = THEME:GetMetric("Combo", "LabelMinZoom");
local LabelMaxZoom = THEME:GetMetric("Combo", "LabelMaxZoom");

--you can pass nil to this function, it acts the same as passing nothing
--however, i think that passing nil makes the intent clearer -tertu
local function cfShowOnly(...)
	local cfMembersToShow = {...}

	--build an inverse version of the argument table to speed up lookup
	local cfMTSInv = {}
	for _, name in pairs(cfMembersToShow) do
		cfMTSInv[name] = true
	end

	for name, a in pairs(cf) do
		--"if the name of this actor was passed, make it visible, otherwise
		--hide it"
		a:visible(cfMTSInv[name] == true)
	end
end

local t = Def.ActorFrame {
	Def.ActorFrame {
		Name="ComboFrame";
		Def.BitmapText{
			Name="NumberW1";
			Font="combo marv",
			OnCommand = THEME:GetMetric("Combo", "NumberOnCommand");
		};
		Def.BitmapText{
			Name="NumberW2";
			Font="combo perf",
			OnCommand = THEME:GetMetric("Combo", "NumberOnCommand");
		};
		Def.BitmapText{
			Name="NumberW3";
			Font="combo great",
			OnCommand = THEME:GetMetric("Combo", "NumberOnCommand");
		};
		Def.BitmapText{
			Name="NumberW4";
			Font="combo good",
			OnCommand = THEME:GetMetric("Combo", "NumberOnCommand");
		};
		Def.BitmapText{
			Name="NumberNormal";
			Font="combo normal",
			OnCommand = THEME:GetMetric("Combo", "NumberOnCommand");
		};
		Def.Sprite{
			Texture="_combomarv",
			Name="LabelW1";
			OnCommand = THEME:GetMetric("Combo", "LabelOnCommand");
		};
		Def.Sprite{
			Texture="_comboperfect",
			Name="LabelW2";
			OnCommand = THEME:GetMetric("Combo", "LabelOnCommand");
		};
		Def.Sprite{
			Texture="_combogreat",
			Name="LabelW3";
			OnCommand = THEME:GetMetric("Combo", "LabelOnCommand");
		};
		Def.Sprite{
			Texture="_combogood",
			Name="LabelW4";
			OnCommand = THEME:GetMetric("Combo", "LabelOnCommand");
		};
		Def.Sprite{
			Texture="_combonormal",
			Name="LabelNormal";
			OnCommand = THEME:GetMetric("Combo", "LabelOnCommand");
		};
	};
	InitCommand = function(self)
		c = self:GetChildren();
		cf = c.ComboFrame:GetChildren();
		-- Inclu
		cfShowOnly(nil);
	end;
	ComboCommand=function(self, param)
		if not xxState then
			cfShowOnly(nil);
			return;
		end
		if param.Misses then
			cfShowOnly(nil);
			return;
		end
		local iCombo = param.Combo;
		if not iCombo or iCombo < ShowComboAt then
			cfShowOnly(nil);
			return;
		end

		local Number = xxState.Number;
		local Label = xxState.Label

		param.Zoom = scale( iCombo, 0, NumberMaxZoomAt, NumberMinZoom, NumberMaxZoom );
		param.Zoom = clamp( param.Zoom, NumberMinZoom, NumberMaxZoom );

		param.LabelZoom = scale( iCombo, 0, NumberMaxZoomAt, LabelMinZoom, LabelMaxZoom );
		param.LabelZoom = clamp( param.LabelZoom, LabelMinZoom, LabelMaxZoom );

		cfShowOnly(Number, Label);

		-- Pulse
		Pulse( cf[Number], param );
		PulseLabel( cf[Label], param)
		
		local cstr = tostring(iCombo);
		cf[Number]:settext( cstr );
		
	end;
	AfterStatsEngineMessageCommand=function(s, param)
		if param.Player ~= player then return end;
		xxState = param.Data.XXComboState;
	end;
};

return t;
