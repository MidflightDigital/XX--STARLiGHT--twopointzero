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

local function CreatePaneDisplayItem( _pnPlayer, _sLabel, _rcRadarCategory )
	return Def.ActorFrame {
		LoadFont("Common Bold") .. {
			Text=string.upper( THEME:GetString("PaneDisplay",_sLabel) );
			InitCommand=function(s) s:halign(0):addx(-48) end,
			OnCommand=function(s) s:zoom(0.5875) end,
		};
		LoadFont("Common Bold") .. {
			Text="0";
			InitCommand=function(s) s:x(48):halign(1) end,
			OnCommand=function(s) s:zoom(0.5875) end,
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
					self:settext(0);
				else
					self:settext(GetRadarData( _pnPlayer, _rcRadarCategory ));
				end
			end;
		};
	};
end;

local function CreateShockArrow(_pnPlayer, _sLabel, _rcRadarCategory )
	return Def.ActorFrame {
		Def.Sprite{
			OnCommand=function(s) s:playcommand("Set") end,
			CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentStepsP1ChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentStepsP2ChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentTrailP1ChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentTrailP2ChangedMessageCommand=function(s) s:playcommand("Set") end,
			CurrentCourseChangedMessageCommand=function(s) s:playcommand("Set") end,
			SetCommand=function(self)
				local song = GAMESTATE:GetCurrentSong()
				local course = GAMESTATE:GetCurrentCourse()
				local selection = GAMESTATE:GetCurrentSteps(_pnPlayer);
				if GAMESTATE:IsCourseMode() then
						self:stoptweening();
						self:decelerate(0.2);
						self:zoom(0);
				else
					if selection then
						if GetRadarData( _pnPlayer, _rcRadarCategory) ==0 or not song and not course then
							self:stoptweening();
							self:zoom(1);
							self:diffusealpha(0.7);
							self:Load(THEME:GetPathG("","_shockarrowoff"));
						else
							self:stoptweening();
							self:zoom(1);
							self:diffusealpha(1);
							self:Load(THEME:GetPathG("","_shockarrowon"));
						end;
					end;
				end;
			end;	
		};
	};
end;

--[[ Numbers ]]
t[#t+1] = Def.ActorFrame { 
    InitCommand=function(s) s:y(-8) end,
	CreatePaneDisplayItem( iPN, "Taps", 'RadarCategory_TapsAndHolds' ) .. {
		InitCommand=function(s) s:xy(-90,110) end,
	};
	CreatePaneDisplayItem( iPN, "Jumps", 'RadarCategory_Jumps' ) .. {
		InitCommand=function(s) s:x(-90,110+17) end,
	};
	CreatePaneDisplayItem( iPN, "Holds", 'RadarCategory_Holds' ) .. {
		InitCommand=function(s) s:x(-90,110+17*2) end,
	};
	CreatePaneDisplayItem( iPN, "Mines", 'RadarCategory_Mines' ) .. {
		InitCommand=function(s) s:x(90,110+17) end,
        CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentStepsP1ChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentStepsP2ChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentTrailP1ChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentTrailP2ChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentCourseChangedMessageCommand=function(s) s:playcommand("Set") end,     
        SetCommand=function(self)
            if GetRadarData( iPN, 'RadarCategory_Mines') ==0 then
                self:diffuse(color("#ffffff"))
            else
                self:diffuse(color("#ff0000"))
            end
        end;
	};
	CreatePaneDisplayItem( iPN, "Rolls", 'RadarCategory_Rolls' ) .. {
		InitCommand=function(s) s:x(90,110+17*2) end,
        CurrentSongChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentStepsP1ChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentStepsP2ChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentTrailP1ChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentTrailP2ChangedMessageCommand=function(s) s:playcommand("Set") end,
        CurrentCourseChangedMessageCommand=function(s) s:playcommand("Set") end,      
        SetCommand=function(self)
            if GetRadarData( iPN, 'RadarCategory_Rolls') ==0 then
                self:diffuse(color("#ffffff"))
            else
                self:diffuse(color("#ff0000"))
            end
        end;        
	};    
	CreateShockArrow( iPN, "Mines", 'RadarCategory_Mines' ) .. {
		InitCommand=function(s) s:x(0,110+17):zoom(0.8) end,
	};  
};
return t;