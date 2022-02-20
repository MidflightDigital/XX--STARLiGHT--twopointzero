return Def.ActorFrame{
    Def.Sprite{
    Texture="panels",
    InitCommand=function(s) s:xy(10,338) end,
    };
    Def.Sprite{
    Texture="panels",
    InitCommand=function(s) s:xy(10,338):blend(Blend.Add)
        :diffuseshift():effectcolor1(Alpha(Color.White,0.3)):effectcolor2(Alpha(Color.White,0)):effectperiod(5)
    end,
    };
    Def.Sprite{ Texture="new dancer", };
  };