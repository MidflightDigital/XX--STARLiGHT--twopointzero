local xspacing = 80
local DiffList = Def.ActorFrame{}
local pn = ...

local function DrawDiffListItem(diff)
    local DifficultyListItem = Def.ActorFrame{
        InitCommand=function(s) s:x(Difficulty:Reverse()[diff]*xspacing)
        end,
        CurrentSongChangedMessageCommand=function(s) s:queuecommand('Set') end,
        Def.BitmapText{
            Name="Foot",
            Font="_avenir next demi bold 20px",
            Text=THEME:GetString("CustomDifficulty",ToEnumShortString(diff)),
            InitCommand=function(s) s:xy(-4,24):halign(0):maxwidth(100):zoomx(0.6):zoomy(0.7) end,
            SetCommand=function(s,p)
                local song = p.Song;
                local st = GAMESTATE:GetCurrentStyle():GetStepsType()
                if song then
                    if song:HasStepsTypeAndDifficulty(st, diff) then
                        local steps = song:GetOneSteps(st,diff)
                        s:diffusealpha(0.7)
                    else
                        s:diffusealpha(0)
                    end
                end
            end
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
                            s:settext("")
                        end
                        if GAMESTATE:GetCurrentSteps(pn):GetDifficulty() == diff then
                            s:diffuse(PlayerColor(pn))
                        else
                            s:diffuse(Alpha(Color.White,0.7))
                        end
                    end
                end
            }
        };
    };
    return DifficultyListItem
end

for diff in ivalues(Difficulty) do
    DiffList[#DiffList+1] = DrawDiffListItem(diff)
end

return Def.ActorFrame{
    ["CurrentSteps" .. ToEnumShortString(pn) .. "ChangedMessageCommand"]=function(s) s:finishtweening():queuecommand("Set") end,
    DiffList;
}