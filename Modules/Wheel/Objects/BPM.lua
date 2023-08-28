local counter = 0
local targetDelta = 1/60
local timer = GetUpdateTimer(targetDelta)

--displays 3 digit numbers 000, 111, 222... 999, 000... every 1/60 of a second (about)
local function RandomBPM(self, _)
	local s = self:GetChild("Text")
	s:settext("BPM "..string.rep(tostring(counter),3))
	counter = (counter+1)%10
end

local function textBPM(dispBPM)
	return string.format("BPM %03d", math.floor(dispBPM+0.5))
end

local function VariedBPM(self, _)
	local s = self:GetChild("Text")
	s:settextf("BPM %03d - %03d",math.floor(dispBPMs[1]+0.5),math.floor(dispBPMs[2]+0.5))
end
return function( args )
    return Def.ActorFrame{
        Name="BPM",
        InitCommand=function(self)
            local af = self:GetParent()
            self:xy( SCREEN_CENTER_X, SCREEN_CENTER_Y+120)

            -- Add a wrapper state to this actorframe as I can't seem to control it's tweens anymore.
            self:AddWrapperState()
        end,
        UpdateSongInfoCommand=function(self,params)
            local c = self:GetChildren()
            if params and type(params.Data) ~= "string" then
                local pSong = params.Data[1]
                if pSong:IsDisplayBpmRandom() or pSong:IsDisplayBpmSecret() then
                    counter = 0
                    timer = GetUpdateTimer(targetDelta)
                    c.Text:diffuse(Color.Red):aux(-1):settext("BPM 999"):GetParent():SetUpdateFunction(RandomBPM)
                else
                    c.Text:diffuse(Color.White)
                    local dispBPMs = pSong:GetDisplayBpms()
		    		if pSong:IsDisplayBpmConstant() then
		    			c.Text:settextf("BPM %03d",math.floor(dispBPMs[1]+0.5)):GetParent():SetUpdateFunction(nil)
		    		else
		    			c.Text:settextf("BPM %03d - %03d",math.floor(dispBPMs[1]+0.5),math.floor(dispBPMs[2]+0.5)):GetParent():SetUpdateFunction(nil)
		    		end
                end
            end
        end,
        Def.BitmapText{
            Name="Text",
            Font="_avenirnext lt pro bold/25px",
         InitCommand=function(s)
                s:diffuse(Color.White):strokecolor(Alpha(Color.Black,0.5)):aux(0)
            end,
        }
    }
end