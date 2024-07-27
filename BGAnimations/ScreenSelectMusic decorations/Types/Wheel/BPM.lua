local LoadingScreen = Var "LoadingScreen"
--smcmd is "screen metrics command", gmcmd is "general metrics command"
--these make it require a little less typing to run useful BPMDisplay related commands
local smcmd, gmcmd
do
	smcmd = function(s, name)
		return (THEME:GetMetric(LoadingScreen, name))(s)
	end
	gmcmd = function(s, name)
		return (THEME:GetMetric("BPMDisplay", name))(s)
	end
end

local counter = 0
local targetDelta = 1/60
local timer = GetUpdateTimer(targetDelta)

--displays 3 digit numbers 000, 111, 222... 999, 000... every 1/60 of a second (about)
local function RandomBPM(self, _)
	local s = self:GetChild"BPMDisplay"
	if not timer() then return end
	s:settext(string.rep(tostring(counter),3))
	counter = (counter+1)%10
end

local function textBPM(dispBPM)
	return string.format("%03d", math.floor(dispBPM+0.5))
end

local dispBPMs = {0,0}

return Def.ActorFrame{
	--only ActorFrames and classes based on ActorFrame have update functions, which we need
	Name="SNBPMDisplayHost",
	Def.BitmapText{
		Font="_avenirnext lt pro bold/25px",
		Name="BPMDisplay",
		InitCommand=function(s) s:aux(0):zoom(1.2):settext "000":x(-274)
			:y(-84); return gmcmd(s, "SetNoBpmCommand") end,
		OnCommand=function(s) s:zoom(0.8):cropright(0.5):cropleft(0.5):sleep(0.3):decelerate(0.2):cropright(0):cropleft(0) end,
		OffCommand=function(s) s:decelerate(0.3):cropright(0.5):cropleft(0.5) end,
		StartSelectingStepsMessageCommand=function(s) s:playcommand("Off") end,
		SongUnchosenMessageCommand=function(s) s:playcommand("On") end,
		CurrentSongChangedMessageCommand = function(s, _)
			local song = GAMESTATE:GetCurrentSong()
			if song then
				if song:IsDisplayBpmRandom() or song:IsDisplayBpmSecret() then
					gmcmd(s, song:IsDisplayBpmRandom() and "SetRandomCommand" or "SetExtraCommand")
					--I do not believe that it is necessary to reset this counter every time.
					--It may even be incorrect.
					counter = 0
					timer = GetUpdateTimer(targetDelta)
					--an aux value of -1 is intended as a special value but it is not used.
					s:aux(-1):settext "999":GetParent():SetUpdateFunction(RandomBPM)
				else
					--if the display BPM is random, GetDisplayBpms returns nonsense, so only do it here.
					dispBPMs = song:GetDisplayBpms()
					s:aux(dispBPMs[1]):settext(textBPM(dispBPMs[1]))
					if song:IsDisplayBpmConstant() then
						gmcmd(s, "SetNormalCommand")
						s:GetParent():SetUpdateFunction(nil)
					else
						gmcmd(s, "SetChangeCommand")
						s:settextf("%03d - %03d",math.floor(dispBPMs[1]+0.5),math.floor(dispBPMs[2]+0.5))
						s:GetParent():SetUpdateFunction(nil)
					end
				end
			else
				gmcmd(s, "SetNoBpmCommand")
				s:aux(0):settext "":GetParent():SetUpdateFunction(nil)
			end
		end
	}
}
