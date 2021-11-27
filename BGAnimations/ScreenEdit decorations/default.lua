return Def.ActorFrame{
    Def.Quad{
        InitCommand=function(s) s:Center()
            local style = GAMESTATE:GetCurrentStyle(PLAYER_1)
            local width = style:GetWidth(PLAYER_1)
            s:setsize(width+64,SCREEN_HEIGHT):MaskSource(true)
        end,
    },
    Def.Quad{
        InitCommand=function(s) s:FullScreen():diffuse(Alpha(Color.Black,0.5)):MaskDest():ztestmode("ZTestMode_WriteOnPass") end,
    },
    
}
--[[
t[#t+1] = Def.ActorFrame{
    InitCommand=function(s) s:xy(_screen.cx-700,_screen.cy-300) end,
    LoadActor(THEME:GetPathB("","ScreenSelectMusic overlay/2014Deco/_jacket back"));
    Def.Banner{
        InitCommand=function(s)
            local song = GAMESTATE:GetCurrentSong()
            s:Load(song:GetJacketPath())
            s:zoomto(378,378);
        end,
    },
    Def.ActorFrame{
        InitCommand=function(s) s:y(250) end,
        LoadActor(THEME:GetPathB("","ScreenSelectMusic overlay/2014Deco/titlebox"));
        LoadFont("_avenirnext lt pro bold 20px") .. {
            InitCommand = function(s) s:y(-8):maxwidth(400):maxheight(20):playcommand("Set") end,
            SetCommand = function(self)
                local song = GAMESTATE:GetCurrentSong()
                if song then
                    self:settext(song:GetDisplayFullTitle()):diffuse(SongAttributes.GetMenuColor(song))
                else
                    self:settext""
                end
            end,
        };
        LoadFont("_avenirnext lt pro bold 20px") .. {
            InitCommand = function(s) s:y(20):maxwidth(400):maxheight(20):playcommand("Set") end,
            SetCommand = function(self)
                local song = GAMESTATE:GetCurrentSong()
                if song then
                    self:settext(song:GetDisplayArtist()):diffuse(SongAttributes.GetMenuColor(song))
                else
                    self:settext""
                end
            end,
        };
    };
}

t[#t+1] = Def.ActorFrame{
    InitCommand=function(s) s:Center() end,
    Def.BitmapText{
        Font="_avenirnext lt pro bold 20px";
        InitCommand=function(s)
            local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
            if steps then
                local Rad = steps:GetRadarValues(PLAYER_1)
                local Data = Rad:GetValue('RadarCategory_Notes')
                s:settext(Data)
            end
        end,
    },
}]]