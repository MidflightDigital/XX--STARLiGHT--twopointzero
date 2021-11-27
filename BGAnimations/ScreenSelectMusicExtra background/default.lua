return Def.ActorFrame{
    LoadActor("EXMovie.avi")..{
        InitCommand=function(s) s:Center() end,
    };
}