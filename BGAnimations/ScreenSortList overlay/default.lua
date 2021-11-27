local steps = GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber())
local timer = SCREENMAN:GetTopScreen():GetChild("Timer"):GetSeconds()

local sortorders = {
	"Title",
	"Genre",
	"Group",
	"BPM",
	"Artist",
	"Recent",
	"EasyMeter",
	"TopGrades",
	"Popularity",
	"Preferred",
}
local mw = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
local curIndex = 1;
-- this handles user input
local function input(event, param)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type ~= "InputEventType_Release" then
		local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")
		if event.GameButton == "Start" then
			overlay:GetChild("start_sound"):play()
			MESSAGEMAN:Broadcast("MusicWheelSort")
			if sortorders[curIndex] == "EasyMeter" then
				mw:ChangeSort("SortOrder_"..ToEnumShortString(steps:GetDifficulty()).."Meter")
			else
				mw:ChangeSort("SortOrder_"..sortorders[curIndex])
			end
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		elseif event.GameButton == "Back" then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		elseif event.GameButton == "MenuRight" then
			if curIndex >= #sortorders then
				curIndex = #sortorders
			else
				curIndex = curIndex+1
				MESSAGEMAN:Broadcast("ChangeRow")
			end
			overlay:GetChild("change_sound"):play()
		elseif event.GameButton == "MenuUp" then
			if curIndex == 1 then
				curIndex = 1
				MESSAGEMAN:Broadcast("ChangeRow")
			elseif curIndex ~= 2 then
				curIndex = curIndex - 2
				MESSAGEMAN:Broadcast("ChangeRow")
			end
			overlay:GetChild("change_sound"):play()
		elseif event.GameButton == "MenuDown" then
			if curIndex >= #sortorders then
				curIndex = #sortorders
				MESSAGEMAN:Broadcast("ChangeRow")
			elseif curIndex ~= #sortorders-1 then
				curIndex = curIndex + 2
				MESSAGEMAN:Broadcast("ChangeRow")
			end
			overlay:GetChild("change_sound"):play()
		elseif event.GameButton == "MenuLeft" then
			if curIndex == 1 then
				curIndex = 1
			else
				curIndex = curIndex-1
				MESSAGEMAN:Broadcast("ChangeRow")
			end
			overlay:GetChild("change_sound"):play()
		end
		MESSAGEMAN:Broadcast("MoveScroller");
	end

	return false
end

local function MakeItem(sortorders, idx)
	return Def.ActorFrame{
		Name="Item"..idx;
		BeginCommand=function(s) s:playcommand(idx == curIndex and "GainFocus" or "LoseFocus") end,
		OnCommand=function(s)
			if idx%2==0 then
				s:addx(200):diffusealpha(0):sleep(idx/12):decelerate(0.2):diffusealpha(1):addx(-200)
			else
				s:addx(-200):diffusealpha(0):sleep(idx/12):decelerate(0.2):diffusealpha(1):addx(200)
			end
		end,
		OffCommand=function(s)
			if idx%2==0 then
				s:accelerate(0.1):addx(200):diffusealpha(0)
			else
				s:accelerate(0.1):addx(-200):diffusealpha(0)
			end
		end,
		MoveScrollerMessageCommand=function(self,param)
			if curIndex == idx then
				self:playcommand("GainFocus")
			else
				self:playcommand("LoseFocus")
			end
		end;
		Def.ActorFrame{
			InitCommand=function(s) 
				if idx%2 == 0 then s:zoomx(-1):zoomy(-1) else
					return
				end
			end,
			LoadActor("TAB.png");
			LoadActor("TABInsert.png")..{
				InitCommand=function(s) s:diffuse(Color.Black) end,
				GainFocusCommand=function(s) s:finishtweening():linear(0.1):diffuse(color("#01a2df")) end,
				LoseFocusCommand=function(s) s:finishtweening():linear(0.1):diffuse(Color.Black) end,
			},
		};
		Def.ActorFrame{
			InitCommand=function(s) 
				if idx%2 == 0 then s:zoomx(-1) else
					return
				end
			end,
			GainFocusCommand=function(s) s:finishtweening():visible(true) end,
			LoseFocusCommand=function(s) s:finishtweening():visible(false) end,
			LoadActor(THEME:GetPathG("","_shared/arrows/arrowb"))..{
				InitCommand=function(s) s:x(-160)
					s:bounce():effectclock("beat"):effectperiod(1):effectmagnitude(-10,0,0):effectoffset(0.2)
				end,
			},
			LoadActor(THEME:GetPathG("","_shared/arrows/arrowb"))..{
				InitCommand=function(s) s:x(100):zoomx(-1)
					s:bounce():effectclock("beat"):effectperiod(1):effectmagnitude(10,0,0):effectoffset(0.2)
				end,
			},
		},
		Def.BitmapText{
			Name="SortText";
			Font="_avenirnext lt pro bold 25px";
			InitCommand=function(s)
				local DisplayName = THEME:GetString("MusicWheel",sortorders.."Text")
				if idx == 7 then
					DisplayName = "Choose by\nLEVEL."
				end
				s:settext(DisplayName):wrapwidthpixels(200)
				if idx%2 == 0 then
					s:x(20)
				else
					s:x(-20)
				end
			end,
		}
	}
end

local ItemList = {};
for i=1,#sortorders do
	ItemList[#ItemList+1] = MakeItem(sortorders[i],i)
end;

local t = Def.ActorFrame{
	InitCommand=function(s) s:Center():queuecommand("Capture") end,
	CaptureCommand=function(s) 
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		SCREENMAN:GetTopScreen():RemoveInputCallback(DDRInput(self))
		SOUND:PlayOnce(THEME:GetPathS("_PHOTwON","back"))
	end,
	LoadActor("Backer")..{
		OnCommand=function(s) s:y(-22):zoomy(0):decelerate(0.2):zoomy(1) end,
	},
	LoadActor("Header")..{
		OnCommand=function(s) s:valign(1):y(0):decelerate(0.2):y(-384) end,
	},
	LoadActor("Instruct")..{
		OnCommand=function(s) s:valign(0):y(0):decelerate(0.2):y(330) end,
	},
	Def.Quad{
		InitCommand=function(s) s:setsize(606,718):y(-22):MaskSource():clearzbuffer(true) end,
	};
	Def.ActorScroller{
		SecondsPerItem=0.1;
		NumItemsToDraw=24;
		InitCommand=function(s) s:MaskDest():ztestmode('ZTestMode_WriteOnFail') end,
		TransformFunction=function(self,offsetFromCenter,itemIndex,numItems)
			self:y((offsetFromCenter * 68)-304);
			if itemIndex%2==0 then
			  self:x(-128)
			  self:addy(0)
			else
			  self:x(120)
			  self:addy(-50)
			end;
		end,
		children=ItemList;
		ChangeRowMessageCommand=function(s,p)
			local curScrollerItem = s:GetCurrentItem()
			if curIndex <= 8 and curScrollerItem - 8 <= 0 then
				s:SetCurrentAndDestinationItem(0)
			else
				s:SetCurrentAndDestinationItem(curIndex-9)
			end
		end,
	}
};

t[#t+1] = LoadActor( THEME:GetPathS("", "MWChange/Default_MWC") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("", "player mine") )..{ Name="change_invalid", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }

return t