return Def.ActorFrame{
    Def.Quad{
        InitCommand=function(s) s:setsize(473,100):skewx(-0.5):MaskSource() end,
    };
    Def.Quad{
        InitCommand=function(s) s:setsize(473,100):skewx(-0.5):diffuse(Alpha(Color.Black,0.75)) end,
    };
    Def.Sprite{
        Texture=THEME:GetPathG("","_banners/random");
        InitCommand=function(s)
            s:setsize(473,148):MaskDest():ztestmode('ZTestMode_WriteOnFail')
            :croptop(0.22):cropbottom(0.22):zoom(1.2)
            :diffusetopedge(color("1,1,1,0.5")):diffuserightedge(color("1,1,1,0"))
        end
    };
}