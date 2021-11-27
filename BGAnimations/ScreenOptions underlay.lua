local t = Def.ActorFrame{
  Def.Quad{
		InitCommand=function(s) s:diffuse(color("0,0,0,0.5")):FullScreen() end,
	};
};

return t;
