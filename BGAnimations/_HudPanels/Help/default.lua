return Def.ActorFrame{
	InitCommand=function(s) s:xy(_screen.cx,SCREEN_BOTTOM-50) end,
	OnCommand=function(s) s:zoomy(0):sleep(0.2):linear(0.1):zoomy(1) end,
	OffCommand=function(s) s:linear(0.1):zoomy(0) end,
    Def.Sprite{
        Texture="backer",
    },
    Def.HelpDisplay{
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