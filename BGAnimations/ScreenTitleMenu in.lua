return Def.Quad{
  InitCommand=function(s) s:diffuse(color("0,0,0,1")):FullScreen() end,
  OnCommand=function(s) s:linear(0.2):diffusealpha(0) end,
};
