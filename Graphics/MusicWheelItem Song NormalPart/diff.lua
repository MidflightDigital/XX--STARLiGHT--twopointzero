local args = {...};
local graphic = args[1];
local pn = args[2];
local msize = args[3];
local StepsUtil=LoadModule"StepsUtil.lua"

local steps_changed = sesub("CurrentStepsChanged%MessageCommand",pn);

return Def.ActorFrame{
    SetCommand=function(self,param)
		self.CurSong = param.Song;
        self:queuecommand "DiffChange";
	end;
	LoadActor(graphic)..{
		InitCommand=function(s) s:draworder(1)
			if ThemePrefs.Get("WheelType") == "Solo" then
				s:zoomx(pn==PLAYER_1 and 1 or -1)
			end
		end;
		DiffChangeCommand = function(self)
			local cur_song = self:GetParent().CurSong;
			local steps = StepsUtil.SameDiffSteps(cur_song, pn);
            self:visible(steps~=nil);
			if steps then
				self:diffuse(CustomDifficultyToColor(steps:GetDifficulty()));
			end;
		end;
		[steps_changed]=function(s) s:queuecommand('DiffChange') end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand('DiffChange') end,
	};
	Def.BitmapText{
		InitCommand=function(s) s:draworder(2); end;
		Font="_avenirnext lt pro bold/25px";
		DiffChangeCommand=function(self)
			local cur_song = self:GetParent().CurSong;
			local steps = StepsUtil.SameDiffSteps(cur_song, pn);
            self:visible(steps~=nil);
			if steps then
				self:settext(steps:GetMeter()):zoom(msize)
				if ThemePrefs.Get("WheelType") == "A" then
					self:diffuse(CustomDifficultyToColor(steps:GetDifficulty()));
				else
					self:diffuse(color("#FFFFFF"))
				end;
			end;
		end;
		[steps_changed]=function(s) s:queuecommand('DiffChange') end,
		CurrentSongChangedMessageCommand=function(s) s:queuecommand('DiffChange') end,
	};
};
