return Def.ActorFrame{
    Def.Sprite{
        Texture="XX.png",
        InitCommand=function(s) s:xy(362,16) end,
    },
    Def.Sprite{
        Texture="starlight.png",
        InitCommand=function(s) s:xy(22,84) end,
    };
    Def.Sprite{
        Texture="twopointzero.png",
        InitCommand=function(s) s:xy(112,126) end,
    };
    Def.Sprite{
        Texture="main.png",
        InitCommand=function(s)
            s:xy(-64,-32)
        end,
    };
}