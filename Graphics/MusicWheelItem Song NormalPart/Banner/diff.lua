local xspacing = 110
local DiffList = Def.ActorFrame{}

local function DrawDiffListItem(diff)
    local DifficultyListItem = Def.ActorFrame{
        InitCommand=function(s) s:x((Difficulty:Reverse()[diff]*xspacing)-290)
            :diffuse(CustomDifficultyToColor(diff))
        end,
        CurrentSongChangedMessageCommand=function(s) s:queuecommand('Set') end,
        Def.Sprite{
            Name="Foot",
            Texture="Icon",
            InitCommand=function(s) s:x(-4):halign(1) end,
        };
        Def.ActorFrame{
            Def.BitmapText{
                Font="_avenirnext lt pro bold 36px",
                InitCommand=function(s) s:zoom(0.8):halign(0) end,
                SetCommand=function(s,p)
                    local song = p.Song;
                    local st = GAMESTATE:GetCurrentStyle():GetStepsType()
                    if song then
                        if song:HasStepsTypeAndDifficulty(st, diff) then
                            local steps = song:GetOneSteps(st,diff)
                            s:settext(steps:GetMeter())
                        else
                            s:settext("00")
                        end
                    end
                    s:strokecolor(Alpha(Color.Black,0.5))
                end
            }
        };
    };
    return DifficultyListItem
end
local difficulties = {"Difficulty_Beginner", "Difficulty_Easy", "Difficulty_Medium", "Difficulty_Hard", "Difficulty_Challenge", "Difficulty_Edit"}


for diff in ivalues(difficulties) do
    DiffList[#DiffList+1] = DrawDiffListItem(diff)
end

return Def.ActorFrame{
    Def.Sprite{
        Texture="box",
    };
    DiffList;
}