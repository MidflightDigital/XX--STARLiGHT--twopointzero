local bgPref = ThemePrefs.Get("MenuMusic");
local curIndex = 1;
local oldIndex = curIndex;

local frames = {
  {"Default", "DEFAULT (fz)"},
  {"saiiko", "saiiko"},
  {"vortivask", "DJ Vortivask"},
  {"inori", "Inori"},
  {"RGTM", "RGTM"},
  {"fancy cake", "fancy cake!!"},
  {"leeium", "leeium"},
  {"SN3", "SuperNOVA3"},
  {"Off", "Off"},
};

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
    MoveScrollerBGMMessageCommand=function(self,param)
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
      OnCommand=function(s) s:y(20):queuecommand("Set") end,
      SetCommand=function(self)
        self:Load(THEME:GetPathB("","ScreenPHOTwON overlay/BGM/CDs/"..GetFrame(frames, "file")..".png"));
      end;
    };
    Def.ActorFrame{
      InitCommand=function(s) s:y(-94) end,
      Def.Sprite{
        Texture="../item.png",
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/20px";
        OnCommand=function(s) s:zoom(0.8):playcommand("Set") end,
        SetCommand=function(self)
          local DisplayName = GetFrame(frames, "name")
          local bgPref = ThemePrefs.Get("MenuMusic");
          self:settext(DisplayName);
          if bgPref == GetFrame(frames, "file") then
            self:diffuse(Color.Green)
            setenv("SetBGM",DisplayName)
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
  Name="BGMMenu";
  InitCommand=function(s)
    s:xy(_screen.cx+2,_screen.cy+SCREEN_HEIGHT)
  end,
  MenuStateChangedMessageCommand=function(self,param)
		if param.NewState == "MenuState_BGM" then
			self:playcommand("ShowBGM")
		elseif param.NewState == "MenuState_Main" then
			self:playcommand("HideBGM")
		end;
	end;
  ShowBGMCommand=function(self)
    self:stoptweening():linear(0.2):y(_screen.cy)
  end;
  HideBGMCommand=function(self)
    self:stoptweening():linear(0.2):y(_screen.cy+SCREEN_HEIGHT)
  end;
  Def.Actor{
    Name="MenuBGController";
    PlayerMenuInputMessageCommand=function(self,param)
      oldIndex = curIndex
      if param.MenuState == "MenuState_BGM" then
        if param.Input == "Start" then
          ThemePrefs.Set("MenuMusic",frames[curIndex][1]);
          setenv("SetBGM",frames[curIndex][2])
          MESSAGEMAN:Broadcast("MenuStateChanged",{NewState = "MenuState_Main"});
        elseif param.Input == "Back" then
          MESSAGEMAN:Broadcast("MenuStateChanged",{NewState = "MenuState_Main"});
          SOUND:PlayOnce(THEME:GetPathS("","_PHOTwON back.ogg"))
        elseif param.Input == "Up" or param.Input == "Left" then
          if curIndex == 1 then
  					curIndex = 1
  				else
  					curIndex = curIndex - 1
            MESSAGEMAN:Broadcast("ChangeRow")
  				end
  			elseif param.Input == "Down" or param.Input == "Right" then
  				if curIndex < #RowList then
  					curIndex = curIndex + 1
            MESSAGEMAN:Broadcast("ChangeRow")
  				elseif curIndex <= 2 then
  					curIndex = 2
  				end
        end;
        MESSAGEMAN:Broadcast("MoveScrollerBGM",{ Player = param.PlayerNumber, Input = param.Input});
      end;
    end;
  };
  Def.Actor{
    MoveScrollerBGMMessageCommand=function(self,param)
      if curIndex == 1 then
				SOUND:PlayMusicPart(THEME:GetPathS("","MenuMusic/common/Default (loop).ogg"), 0, 130, 0, 0, true)
			elseif curIndex == 2 then
        SOUND:PlayMusicPart(THEME:GetPathS("","MenuMusic/common/sk2_menu2 (loop).ogg"), 0, 52.95, 0, 0, true)
      elseif curIndex == 3 then
				SOUND:PlayMusicPart(THEME:GetPathS("","MenuMusic/common/djvortivask (loop).ogg"), 0, 25.263, 0, 0, true)
      elseif curIndex == 4 then
        SOUND:PlayMusicPart(THEME:GetPathS("","MenuMusic/common/inori (loop).ogg"), 0, 51.217, 0, 0, true)
      elseif curIndex == 5 then
        SOUND:PlayMusicPart(THEME:GetPathS("","MenuMusic/common/128beat (loop).ogg"), 0, 60, 0, 0, true)
      elseif curIndex == 6 then
        SOUND:PlayMusicPart(THEME:GetPathS("","MenuMusic/common/fancycake (loop).ogg"), 0, 23.9, 0, 0, true)
      elseif curIndex == 7 then
        SOUND:PlayMusicPart(THEME:GetPathS("","MenuMusic/common/leeium (loop).ogg"), 0, 32, 0, 0, true)
      elseif curIndex == 8 then
        SOUND:PlayMusicPart(THEME:GetPathS("","MenuMusic/common/SN3 (loop).ogg"), 0, 13, 0, 0, true)
			end
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
      Text="BACKGROUND MUSIC";
      InitCommand=function(s) s:y(-338):zoom(1.1) end,
    };
  };
	Def.ActorScroller{
		Name="ListScroller";
		SecondsPerItem=0;
		NumItemsToDraw=20;
		InitCommand=function(s) s:y(-250):MaskDest():ztestmode('ZTestMode_WriteOnFail') end,
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
