local song;
local group;
local getOn = 0;
local getOff = 1;
local SongAttributes = LoadModule "SongAttributes.lua"
--[[
	0 = Left
	1 = Center
	2 = Right
]]

function arrangeXPosition(myself, index)
	if index then
		local xVal = index%3
		myself:x((xVal-1)*250+(math.floor((index+3)/3)-1))
	end;
end

--technika2/3 style hack ;)
function arrangeYPosition(myself, index)
	if index then
	if index%3==0 then
		myself:y(80);
	elseif index%3==1 then
		myself:y(0);
	elseif index%3==2 then
		myself:y(-80);
	end;
end;
end
local t = Def.ActorFrame{
	SetMessageCommand=function(self,params)
		local index = params.Index
		arrangeXPosition(self,index);
		arrangeYPosition(self,index);
		if index ~= nil then
			self:zoom(params.HasFocus and 1.2 or 1);
		end
	end;
};

t[#t+1] = Def.ActorFrame{
	Def.Sprite{ Texture="backer", },
	Def.Sprite{ Texture="glow", InitCommand=function(s) s:diffusealpha(0.5) end, },
	Def.Sprite {
		SetMessageCommand = function(self, params)
			local song = params.Song
			if song then
				self:_LoadSCJacket(song)
			end
			self:setsize(140,140)
			self:xy(2,-1)
		end,
	};
	Def.ActorFrame{
		InitCommand=function(s) s:diffusealpha(0.75):xy(16,104) end,
		Def.Quad{
			InitCommand=function(s) s:setsize(220,30):diffuse(Color.Black) end,
		},
		Def.Quad{
			InitCommand=function(s) s:setsize(214,24):diffuse(Alpha(Color.White,0.5)):diffusetopedge(color("1,1,1,0")) end,
		},
		Def.BitmapText{
			Font="_avenirnext lt pro bold/20px",
			SetMessageCommand=function(s,p)
				local song = p.Song
				if song then
					s:settext(song:GetDisplayMainTitle()):diffuse(SongAttributes.GetMenuColor(song))
				end
				s:maxwidth(200)
			end,
		}
	}
};


t[#t+1] = Def.ActorFrame{
	SetMessageCommand=function(self,params)
		if params.Index ~= nil then
			self:visible( params.HasFocus );
		end
	end;
	OffCommand=function(s) s:stopeffect():sleep(0.2):diffusealpha(0) end,
	LoadActor( 'hl.png' )..{
		InitCommand=function(s) s:diffuseramp():effectcolor1(Alpha(Color.White,0.2)):effectcolor2(Color.White):effectclock('beatnooffset') end,
	};
	Def.ActorFrame{
		InitCommand=function(s) s:diffuseramp():effectcolor1(Alpha(Color.White,0)):effectcolor2(Color.White):effectclock('beatnooffset') end,
		Def.Sprite{
			Texture="cursor.png",
			InitCommand=function(s) s:thump(1):effectmagnitude(1.1,1,0):effectclock('beatnooffset') end,
		};
	};
	Def.Sprite{
		Texture=THEME:GetPathG("","_shared/arrows/arrowb"),
		InitCommand=function(s) s:x(-140):bounce():effectmagnitude(6,0,0):effectclock('beatnooffset') end,
	};
	Def.Sprite{
		Texture=THEME:GetPathG("","_shared/arrows/arrowb"),
		InitCommand=function(s) s:x(140):zoomx(-1):bounce():effectmagnitude(-6,0,0):effectclock('beatnooffset') end,
	};
};

t[#t+1] = Def.ActorFrame{
	SetCommand=function(s,params)
		local song = params.Song
		if song then
			if song:IsLong() or song:IsMarathon() then
				s:visible(true)
			else
				s:visible(false)
			end
		end
	end,
	Def.Quad{
		InitCommand=function(s) s:setsize(140,15):xy(2,70):valign(1):diffuse(Alpha(Color.Black,0.5)) end,
	},
	Def.BitmapText{
		Font="Common normal",
		InitCommand=function(s) s:valign(1):y(68):zoomx(0.7):zoomy(0.6):uppercase(true) end,
		SetMessageCommand=function(s,p)
			local song = p.Song
			local text;
			if song then
				if song:IsLong() then
					text = "Long"
				elseif song:IsMarathon() then
					text = "Marathon"
				else
					text = ""
				end
			else
				text = ""
			end
			s:settext(text)
		end
	},
};

for pn in EnabledPlayers() do
	t[#t+1] = LoadActor("../clear.lua", "./A/glow.png", pn)..{
		OnCommand=function(s) s:diffusealpha(0):sleep(0.7):diffusealpha(1) end,
	}
end;

if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	t[#t+1] = LoadActor("../diff.lua", "./A/diff.png", PLAYER_1,0.7)..{
		OnCommand=function(s) s:xy(-100,-60) end,
	}
end;

if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = LoadActor("../diff.lua", "./A/diff.png", PLAYER_2,0.7)..{
		OnCommand=function(s) s:xy(100,60) end,
	}
end;



return t
