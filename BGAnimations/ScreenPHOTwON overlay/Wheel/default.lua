local bgPref = ThemePrefs.Get("WheelType");
local curIndex = 1;
local oldIndex = curIndex;

local frames

if SN3Debug then
  frames = {
    {"Default", "DEFAULT"},
    {"CoverFlow", "COVERFLOW"},
    {"A", "GRID"},
    {"Banner", "4thMIX"},
    {"Jukebox", "JUKEBOX"},
    {"Wheel","WHEEL"},
    {"Solo","SOLO"},
    {"Preview","PREVIEW"}
  };
else
  frames = {
    {"Default", "DEFAULT"},
    {"CoverFlow", "COVERFLOW"},
    {"A", "GRID"},
    {"Banner", "4thMIX"},
    {"Jukebox", "JUKEBOX"},
    {"Wheel","WHEEL"},
  };
end

local function GetFrame(frames, key)
  for i,v in ipairs(frames) do
    if key == "file" then
      return frames[1]
    elseif key == "name" then
      return frames[2]
    end
  end
end



local function MakeRow(frames, idx)
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
      InitCommand=function(s) s:setsize(400,260):diffuse(color("0,0,0,0")) end,
      GainFocusCommand=function(s) s:stoptweening():diffusealpha(0.5) end,
      LoseFocusCommand=function(s) s:stoptweening():diffusealpha(0) end,
    };
    Def.Sprite{
      OnCommand=function(s) s:zoom(0.98):queuecommand("Set") end,
      SetCommand=function(self)
        self:Load(THEME:GetPathB("","ScreenPHOTwON overlay/Wheel/"..GetFrame(frames, "file")..".png"));
      end;
    };
    Def.ActorFrame{
      InitCommand=function(s) s:xy(8,-94) end,
      Def.Sprite{
        Texture="../item.png",
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/20px";
        OnCommand=function(s) s:zoom(0.8):playcommand("Set") end,
        ShowCommand=function(s) s:playcommand("Set") end,
        SetCommand=function(self)
          local DisplayName = GetFrame(frames, "name")
          local bgPref = ThemePrefs.Get("WheelType");
          self:settext(DisplayName);
          if bgPref == GetFrame(frames, "file") then
            self:diffuse(Color.Green)
            setenv("SetWheel",DisplayName)
          else
            self:diffuse(Color.White)
          end;
        end;
      };
    };
  };
end;

local RowList = {};
for i=1,#frames do
	RowList[#RowList+1] = MakeRow(frames[i],i)
end;

local t = Def.ActorFrame{
  Name="WheelMenu";
  InitCommand=function(s) s:xy(_screen.cx+2,_screen.cy+SCREEN_HEIGHT) end,
  ShowCommand=function(s) s:stoptweening():linear(0.2):y(_screen.cy) end,
  HideCommand=function(s) s:stoptweening():linear(0.2):y(_screen.cy+SCREEN_HEIGHT) end,
  MenuStateChangedMessageCommand=function(self,param)
		if param.NewState == "MenuState_Wheel" then
			self:playcommand("Show")
		elseif param.NewState == "MenuState_Main" then
			self:playcommand("Hide")
		end;
	end;
  Def.Actor{
    Name="MenuBGController";
    PlayerMenuInputMessageCommand=function(self,param)
      oldIndex = curIndex
      if param.MenuState == "MenuState_Wheel" then
        if param.Input == "Start" then
          ThemePrefs.Set("WheelType",frames[curIndex][1]);
          setenv("SetWheel",frames[curIndex][2])
          MESSAGEMAN:Broadcast("MenuStateChanged",{NewState = "MenuState_Main"});
        elseif param.Input == "Back" then
          MESSAGEMAN:Broadcast("MenuStateChanged",{NewState = "MenuState_Main"});
          SOUND:PlayOnce(THEME:GetPathS("","_PHOTwON back.ogg"))
        elseif param.Input == "Up" or param.Input == "Left" then
          if curIndex == 1 then
  					curIndex = 1
  				else
  					curIndex = curIndex - 1
  				end
  			elseif param.Input == "Down" or param.Input == "Right" then
  				if curIndex < #RowList then
  					curIndex = curIndex + 1
  				elseif curIndex <= 2 then
  					curIndex = 2
  				end
        end;
      end;
      MESSAGEMAN:Broadcast("MoveScroller",{ Player = param.PlayerNumber, Input = param.Input});
    end;
  };
  Def.ActorFrame{
    InitCommand=function(s) s:visible(true) end,
    Def.Sprite{
      Texture="../page.png",
      InitCommand=function(self)
        self:y(60):setsize(1280,744):diffusealpha(0.75)
      end;
    };
    Def.Quad{
      InitCommand=function(s) s:y(60):setsize(1280,744):MaskSource():clearzbuffer(true) end,
    };
    Def.Sprite{
      Texture="../topper.png",
      InitCommand=function(s) s:y(-340) end,
    };
    Def.BitmapText{
      Font="_handel gothic itc std Bold/24px";
      Text="WHEEL TYPE";
      InitCommand=function(s) s:y(-338):zoom(1.1) end,
    };
  };
	Def.ActorScroller{
		Name="ListScroller";
		SecondsPerItem=0;
		NumItemsToDraw=20;
		InitCommand=function(s) s:y(-250) end,
		TransformFunction=function(self,offsetFromCenter,itemIndex,numItems)
      self:y(offsetFromCenter * 80);
      if itemIndex%3==0 then
        self:x(-400)
        self:addy(80)
      elseif itemIndex%3==1 then
        self:x(0)
        self:addy(0)
      else
        self:x(400)
        self:addy(-80)
      end;
		end;
		children = RowList;
    ChangeRowMessageCommand=function(s,p)
			local curScrollerItem = s:GetCurrentItem()
			if curIndex <= 7 and curScrollerItem - 7 <= 0 then
				s:SetCurrentAndDestinationItem(0)
			else
				s:SetCurrentAndDestinationItem(curIndex-6)
			end
		end,
	};
};

return t;
