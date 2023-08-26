return Def.ActorFrame{
	Def.Sprite{
		Texture="_footer/backer",
	};
	Def.HelpDisplay {
		File = THEME:GetPathF("HelpDisplay", "text");
		InitCommand=function(self)
			local s = THEME:GetString(Var "LoadingScreen","HelpText");
			self:SetTipsColonSeparated(s);
			self:SetSecsBetweenSwitches(5)
			self:shadowlength(0)
		end;
		SetHelpTextCommand=function(self, params)
			self:SetTipsColonSeparated( params.Text );
		end;
	};
}