return Def.ActorFrame{
  LoadActor("DDR STARLIGHT GAME OVER")..{
    InitCommand=function(s) s:Center()
      SOUND:StopMusic()
      setenv("Credits",false)
    end,
  };
};
