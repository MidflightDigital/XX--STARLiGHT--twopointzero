return Def.ActorFrame{
    Def.Quad{
        InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0.5)) end,
    },
    Def.Sprite{
        Texture=THEME:GetPathB("","ScreenOptionsService decorations/expbox"),
		InitCommand=function(s) s:xy(_screen.cx-640,_screen.cy+120) end,
    };
    Def.Quad{
        InitCommand=function(s) s:setsize(1100,560):halign(0):xy(_screen.cx-320,_screen.cy+120):diffuse(Alpha(Color.Black,0.5)) end,
    },
}