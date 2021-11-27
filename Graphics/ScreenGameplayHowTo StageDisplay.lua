local StageDisplay = Def.ActorFrame{
	BeginCommand=function(s) s:playcommand("Set") end,
	CurrentSongChangedMessageCommand=function(s) s:finishtweening():playcommand("Set") end,
};

function MakeBitmapText()
	return LoadFont("_avenirnext lt pro bold 36px") .. {
		InitCommand=function(s) s:maxwidth(180) end,
	};
end

StageDisplay[#StageDisplay+1] = MakeBitmapText() .. {
	SetCommand=function(self, params)
		self:settext( "HOW TO PLAY" );
	end;
};

return StageDisplay;
