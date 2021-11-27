local curgame = GAMESTATE:GetCurrentGame():GetName()

local GameDirections = { ["dance"] = "Down", ["pump"] = "UpLeft" }

local t = Def.ActorFrame{
    OnCommand=function(s) s:zoom(1.5) end,
    Def.Sprite{ Texture="optionIcon", };
}


if highlightedNoteSkin ~= "EXIT" then
    local icon = "/Appearance/NoteSkins/"..curgame.."/"..highlightedNoteSkin.."/_icon (doubleres).png";
	local noteskinpath = NOTESKIN:GetPathForNoteSkin(GameDirections[curgame], "Tap Note", highlightedNoteSkin);
    if FILEMAN:DoesFileExist(icon) then
        t[#t+1] = Def.ActorFrame{
            Def.Sprite{
                Texture=icon,
                InitCommand=function(s) s:scaletoclipped(68,68) end,
            };
        };
    else
        t[#t+1] = Def.ActorFrame{
            NOTESKIN:LoadActorForNoteSkin(GameDirections[curgame],"Tap Note",highlightedNoteSkin or "default");
            
        }
    end
else
    t[#t+1] = Def.BitmapText{
        Font="_avenirnext lt pro bold 20px",
        Text="EXIT"
    };
end

return t;
