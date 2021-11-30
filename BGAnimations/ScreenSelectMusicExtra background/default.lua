return Def.ActorFrame{
    LoadActor("EXMovie.mp4")..{
        InitCommand=function(s) s:Center() end,
    };
}