local getOn = 0;
local getOff = 0;
local set;
local t = Def.ActorFrame{}
local Crstext = THEME:GetString("MusicWheel","CustomItemCrsText");

t[#t+1] = Def.ActorFrame{
	SetCommand=function(self,params)
		local song = params.Text
		local index = params.DrawIndex
		if song then
			if getOn == 0 then
				if index then
				if index == 4 then
					self:finishtweening():zoom(0):sleep(0.3):decelerate(0.4):zoom(1)
				elseif index < 4 then
					self:finishtweening():addx(-SCREEN_WIDTH):sleep(0.3):decelerate(0.4):addx(SCREEN_WIDTH)
				elseif index > 4 then
					self:finishtweening():addx(SCREEN_WIDTH):sleep(0.3):decelerate(0.4):addx(-SCREEN_WIDTH)
				end;
			end;
			end;
		end;
		self:queuecommand("SetOn");
	end;
	SetOnCommand=function(self)
		getOn = 1;
	end;
	Def.Sprite{
		SetMessageCommand=function(self,params)
			self:visible(false);
			if params.Label == Crstext then
				self:Load(THEME:GetPathG("","MusicWheelItem Custom OverPart/Default/COURSE.png")):visible(true)
			end;
			self:setsize(230,230)
		end;
	},
}

return t
