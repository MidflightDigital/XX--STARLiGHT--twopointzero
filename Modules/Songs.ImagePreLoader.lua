local Songs = TF_WHEEL.Songs
local Modes = TF_WHEEL.Modes

local Images = Def.ActorFrame {Name="PreLoad"}

for i = 1,#Songs do
    if type(Songs[i]) ~= "string" then
        if string.find(string.lower(Modes), "banner") then
            Images[#Images+1] = Def.Sprite {
                Name=Songs[i][1]:GetBannerPath(),
                Texture=Songs[i][1]:GetBannerPath()
            }
        end
        if string.find(string.lower(Modes), "background") then
            Images[#Images+1] = Def.Sprite {
                Name=Songs[i][1]:GetBackgroundPath(),
                Texture=Songs[i][1]:GetBackgroundPath()
            }
        end
    else
        if SONGMAN:GetSongGroupBannerPath(Songs[i]) ~= "" then
            Images[#Images+1] = Def.Sprite {
                Name=SONGMAN:GetSongGroupBannerPath(Songs[i]),
                Texture="../../../../"..SONGMAN:GetSongGroupBannerPath(Songs[i])
            }
        end
    end
end

return Images