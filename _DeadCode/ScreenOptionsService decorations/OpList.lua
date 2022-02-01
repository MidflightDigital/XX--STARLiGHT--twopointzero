local MenuState = 'Menustate_GroupList'
local curIndex = 1;
local oldIndex = curIndex;
local screen = SCREENMAN:GetTopScreen();
local row = "";
local name = "";

local mplayer = GAMESTATE:GetMasterPlayerNumber()

local rownames = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"10",
	"11",
	"12"
};

local function MakeRow(rownames, idx)
	return Def.ActorFrame{
		Name="Row"..idx;
		BeginCommand=function(self)
			self:playcommand(idx == curIndex and "GainFocus" or "LoseFocus")
		end;
		MoveScrollerMessageCommand=function(self,param)
			if curIndex == idx then
				self:playcommand("GainFocus")
			elseif oldIndex == idx then
				self:playcommand("LoseFocus")
			end
		end;
		Def.Quad{
			InitCommand=cmd(setsize,557,33;diffuse,color("#797a82"));
			GainFocusCommand=cmd(diffusealpha,0.8);
			LoseFocusCommand=cmd(diffusealpha,0);
		};
		LoadFont("_avenirnext lt pro bold/25px")..{
			Name="Row Name";
			InitCommand=cmd(x,-260;uppercase,true;halign,0;zoom,1;strokecolor,color("0,0,0,0.25"));
			OnCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local screen = SCREENMAN:GetTopScreen();
				if screen then
					index = screen:GetCurrentRowIndex(mplayer)
					row = screen:GetOptionRow(idx-1);
					name = row:GetName();
					local DisplayName = THEME:GetString("OptionTitles",name);
					self:settext(DisplayName)
				end;
			end;
		};
	};
end;

local RowList = {};
for i=1,#rownames do
	RowList[#RowList+1] = MakeRow(rownames[i],i)
end;

local t = Def.ActorFrame{
	InitCommand=cmd(draworder,-10;x,_screen.cx-417;y,SCREEN_CENTER_Y-90);
	OnCommand=cmd(player,PLAYER_1;addy,SCREEN_HEIGHT;sleep,0.2;decelerate,0.2;addy,-SCREEN_HEIGHT);
	OffCommand=cmd(accelerate,0.2;addy,-SCREEN_HEIGHT);
	Def.Actor{
		Name="InputHandler";
		MenuUpP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_1, Input = "Up", }); end;
		MenuDownP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_1, Input = "Down", }); end;
		MenuStartP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_1, Input = "Start", }); end;
		MenuUpP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_2, Input = "Up", }); end;
		MenuDownP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_2, Input = "Down", }); end;
		MenuStartP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Player = PLAYER_2, Input = "Start", }); end;
		CodeMessageCommand=function(self,param)
			MESSAGEMAN:Broadcast("MenuInput", { Player = param.PlayerNumber, Input = param.Name, })
		end;

		MenuInputMessageCommand=function(self,param)
			-- direction
			oldIndex = curIndex
			if param.Input == "Up" then
				if curIndex == 1 then
					curIndex = 12
				else
					curIndex = curIndex - 1
				end
			elseif param.Input == "Down" then
				if curIndex < #RowList then
					curIndex = curIndex + 1
				elseif curIndex <= 12 then
					curIndex = 1
				end
			end
			MESSAGEMAN:Broadcast("MoveScroller",{Input = param.Input});
		end
	};
	Def.ActorFrame{
		LoadActor("DialogBox");
		LoadActor("DialogTop")..{
			InitCommand=cmd(y,-320);
		};
	};
	Def.ActorScroller{
		Name="ListScroller";
		SecondsPerItem=0;
		NumItemsToDraw=30;
		InitCommand=cmd(y,-263);
		TransformFunction=function(self,offsetFromCenter,itemIndex,numItems)
			self:y( offsetFromCenter * 40 );
		end;
		children = RowList;
	};
};


return t;
