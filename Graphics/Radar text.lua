local iPN = ...;
assert(iPN,"[Graphics/PaneDisplay text.lua] No PlayerNumber Provided.");

local t = Def.ActorFrame {};
local function GetRadarData( pnPlayer, rcRadarCategory )
	local tRadarValues;
	local StepsOrTrail;
	local fDesiredValue = 0;
	if GAMESTATE:GetCurrentSteps( pnPlayer ) then
		StepsOrTrail = GAMESTATE:GetCurrentSteps( pnPlayer );
		fDesiredValue = StepsOrTrail:GetRadarValues( pnPlayer ):GetValue( rcRadarCategory );
	elseif GAMESTATE:GetCurrentTrail( pnPlayer ) then
		StepsOrTrail = GAMESTATE:GetCurrentTrail( pnPlayer );
		fDesiredValue = StepsOrTrail:GetRadarValues( pnPlayer ):GetValue( rcRadarCategory );
	else
		StepsOrTrail = nil;
	end;
	return fDesiredValue;
end;

local function CreatePaneDisplayGraph( _pnPlayer, _sLabel, _rcRadarCategory )
	return Def.ActorFrame {
		Def.BitmapText{
			Font="Common Normal",
			InitCommand=function(s) s:zoom(0.8):x(30) end,
			CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentStepsP1ChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentStepsP2ChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentTrailP1ChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentTrailP2ChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentCourseChangedMessageCommand=function(s) s:playcommand("Set") end,
			SetCommand=function(self)
				local song = GAMESTATE:GetCurrentSong()
				local course = GAMESTATE:GetCurrentCourse()
				if not song and not course then
					self:settext(_sLabel.."")
				else
					self:settextf("%0.0f",GetRadarData( _pnPlayer, _rcRadarCategory )*100);
				end
			end;
		};
	};
end;

--[[ Numbers ]]
t[#t+1] = Def.ActorFrame {
	--percentage stuff for groove radar
	CreatePaneDisplayGraph( iPN, "S", 'RadarCategory_Stream' ) .. {
		InitCommand=function(s) s:x(-32+1):y(-112+5+4+2+1) end,
	};
	CreatePaneDisplayGraph( iPN, "V", 'RadarCategory_Voltage' ) .. {
		InitCommand=function(s) s:x(-142+3+1+2):y(-50+5+4+1+1) end,
	};
	CreatePaneDisplayGraph( iPN, "A", 'RadarCategory_Air' ) .. {
		InitCommand=function(s) s:x(-112+3+2):y(52+4+4+1) end,
	};
	CreatePaneDisplayGraph( iPN, "F", 'RadarCategory_Freeze' ) .. {
		InitCommand=function(s) s:x(49-3-1):y(52+4+4) end,
	};
	CreatePaneDisplayGraph( iPN, "C", 'RadarCategory_Chaos' ) .. {
		InitCommand=function(s) s:x(78-3):y(-50+5+4+1) end,
	};
};
return t;