return Def.ActorFrame{
  Def.Sprite{
    Texture="DDR STARLIGHT GAME OVER",
    InitCommand=function(s) s:Center()
      SOUND:StopMusic()
      setenv("Credits",false)
    end,
  };
};
