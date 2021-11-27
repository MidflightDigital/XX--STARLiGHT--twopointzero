local t = Def.ActorFrame{
    SetMessageCommand=function(s,p)
        if p.DrawIndex then
            if p.DrawIndex == 8  then
                s:diffusealpha(0.7)
            elseif p.DrawIndex == 9 then
                s:diffusealpha(0.5)
            elseif p.DrawIndex == 10 then
                s:diffusealpha(0.3)
            elseif p.DrawIndex >= 11 or p.DrawIndex < 2 then
                s:diffusealpha(0)
            else
                s:diffusealpha(1)
            end
        end
    end,
} 
local jk = LoadModule "Jacket.lua"
local SongAttributes = LoadModule "SongAttributes.lua"

local TB = Def.BitmapText{
	Font="_avenirnext lt pro bold 36px";
    InitCommand=function(s) s:halign(0):maxwidth(350):strokecolor(color("0,0,0,0.3")) end,
};


t[#t+1] =  Def.ActorFrame{
    Def.Sprite{
        Texture=THEME:GetPathG("MusicWheelItem","Song NormalPart/Solo/bg.png"),
        InitCommand=function(s) s:diffusealpha(0.7) end,
    },
    Def.ActorFrame{
        InitCommand=function(s) s:diffuseramp():effectcolor1(color("1,1,1,0.2"))
            :effectcolor2(color("1,1,1,1")):effectclock('beatnooffset')
        end,
        SetMessageCommand=function(s,p)
            if p.Index then s:visible(p.HasFocus) end
        end,
        Def.Sprite{
            Texture=THEME:GetPathG("MusicWheelItem","Song NormalPart/Solo/HL.png"),
            SetMessageCommand=function(s,p)
                local group = p.Text
                s:diffuse(SongAttributes.GetGroupColor(group))
            end,
        };
    };
    Def.ActorFrame{
        InitCommand=function(s) s:x(-470) end,
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenSelectMusic","overlay/SoloDeco/JacketMask.png"),
            InitCommand=function(s) s:MaskSource(true):zoom(0.13) end,
        };
        Def.Sprite{
            Texture=THEME:GetPathB("ScreenSelectMusic","overlay/SoloDeco/JacketMask.png"),
            InitCommand=function(s) s:zoom(0.14) end,
        };
        Def.Sprite{
            InitCommand=function(s) s:MaskDest():ztestmode('ZTestMode_WriteOnFail') end,
            SetCommand=function(s,p)
                s:Load(jk.GetGroupGraphicPath(p.Text,"Jacket",GAMESTATE:GetSortOrder()))
                :setsize(60,60)
            end
        };
    };
    Def.ActorFrame{
        InitCommand=function(s) s:x(-430) end,
		ChangedLanguageDisplayMessageCommand=function(s) s:queuecommand("Set") end,
		Name="TextBanner",
		TB..{
            Name="GroupText",
			SetMessageCommand=function(self, param)
				local group = param.Text;
                self:diffuse(SongAttributes.GetGroupColor(group));
		        self:settext(SongAttributes.GetGroupName(group));
			end;
		};
	};
}

return t;