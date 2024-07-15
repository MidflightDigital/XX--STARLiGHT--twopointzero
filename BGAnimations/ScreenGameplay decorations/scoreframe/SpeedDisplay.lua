

local pn = ...

local songoptions = GAMESTATE:GetSongOptionsString();
local ratemod = string.match(songoptions, "%d.%d");
if ratemod then
	ratemod = tonumber(ratemod);
else
	ratemod = 1.0
end


local function Update(self)
	local pState = GAMESTATE:GetPlayerState(pn);
    local poptions= pState:GetPlayerOptions("ModsLevel_Preferred")
	local songPosition = pState:GetSongPosition()
    local speed = nil
    if poptions:MMod() ~= nil then
        speed=math.round(poptions:MMod())
    elseif poptions:CMod() ~= nil then
        speed=math.round(poptions:CMod())
    else
        speed=poptions:ScrollSpeed()
    end
	local bpm = (songPosition:GetCurBPS() * 60 * ratemod)*speed

	bpmDisplay:settext( string.format("%04d",round(bpm)) )
end

local t = Def.ActorFrame{};

t[#t+1] = Def.ActorFrame{
    Def.BitmapText{
        Font="BPMDisplay bpm",
        Name="Label",
        Text="SPEED",
        InitCommand=function(s) 
            s:x(-90):halign(0):diffuse(Color.Yellow):zoomx(1.3):zoomy(1.1)
        end
    },
    Def.BitmapText{
        Font="BPMDisplay bpm",
        Name="BPMDisplay",
        InitCommand=function(s) 
            bpmDisplay = s
            s:x(80):halign(1):zoomx(1.3):zoomy(1.1)
        end
    }
}

t.InitCommand=function(s) s:SetUpdateFunction(Update) end


return t;