local bgScripts = dofile(THEME:GetAbsolutePath("BGAnimations/BGScripts/default.lua"))
if bgScripts.worked then
    return bgScripts.bg
else
    return Def.ActorFrame{}
end