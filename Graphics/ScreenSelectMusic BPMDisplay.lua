return Def.BPMDisplay{
	Name="BPMDisplay";
	File=THEME:GetPathF("", "_avenirnext lt pro bold 25px");
	CurrentSongChangedMessageCommand=function(self)
		self:SetFromGameState()
	end;
};
