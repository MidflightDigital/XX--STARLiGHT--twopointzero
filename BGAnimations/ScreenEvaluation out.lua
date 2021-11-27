return Def.ActorFrame{
  StartTransitioningCommand=function(self) SOUND:DimMusic(0,math.huge) end,
  Def.Actor{
    StartTransitioningCommand=function(s) 
        s:sleep(2) 
    end,
  };
  Def.Actor{
    StartTransitioningCommand=function(s)
      SOUND:DimMusic(0.5,math.huge)
    end,
  }
}
