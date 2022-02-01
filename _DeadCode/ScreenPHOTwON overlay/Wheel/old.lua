local WheelPref = ThemePrefs.Get("WheelType");
local curIndex = 1;

if WheelPref then
  local _ = { "CoverFlow", "A", "Banner", "Jukebox", "Wheel" };
  for i,v in ipairs(_) do
    if v == bgPref then curIndex = i; end;
  end;
else
  curIndex = 1;
end;

local frames = {
  "CoverFlow",
  "A",
  "Banner",
  "Jukebox",
  "Wheel"
};

local numFrames = 5;

local t = Def.ActorFrame{
  Def.Actor{
    Name="MenuBGController";
    PlayerMenuInputMessageCommand=function(self,param)
      if param.MenuState == "MenuState_Wheel" then
        if param.Input == "Start" then
          ThemePrefs.Set("WheelType",frames[curIndex]);
          MESSAGEMAN:Broadcast("MenuStateChanged",{NewState = "MenuState_Main"});
        elseif param.Input == "Back" then
          MESSAGEMAN:Broadcast("MenuStateChanged",{NewState = "MenuState_Main"});
          SOUND:PlayOnce(THEME:GetPathS("","_PHOTwON back.ogg"))
        else
          -- left and right switch frames.
          if param.Input == "Left" or param.Input == "Up" then
            MESSAGEMAN:Broadcast("PreviousWheel");
          elseif param.Input == "Right" or param.Input == "Down" then
            MESSAGEMAN:Broadcast("NextWheel");
          end;
        end;
      end;
    end;
    NextWheelMessageCommand=function(self)
      local prevIndex = curIndex;
      curIndex = curIndex + 1;
      if curIndex > numFrames then curIndex = 1; end;

      MESSAGEMAN:Broadcast("WheelChanged",{NewWheel = frames[curIndex], NewIndex = curIndex, OldIndex = prevIndex});
		end;
		PreviousWheelMessageCommand=function(self)
			local prevIndex = curIndex;
			curIndex = curIndex - 1;
			if curIndex < 1 then curIndex = numFrames; end;

			MESSAGEMAN:Broadcast("WheelChanged",{NewWheel = frames[curIndex], NewIndex = curIndex, OldIndex = prevIndex});
		end;
  };
};

--menu
local menu = Def.ActorFrame{
  Name="WheelMenu";
	--InitCommand=cmd(x,SCREEN_WIDTH+SCREEN_CENTER_X;y,SCREEN_CENTER_Y*0.5); -- scroller
  MenuStateChangedMessageCommand=function(self,param)
		if param.NewState == "MenuState_Wheel" then
			self:playcommand("Show")
		elseif param.NewState == "MenuState_Main" then
			self:playcommand("Hide")
		end;
	end;
  Def.Quad{
    Name="BG";
    InitCommand=cmd(blend,Blend.Subtract;diffuse,color("0,0,0,0.8");setsize,800,700;halign,1;xy,SCREEN_RIGHT+800,_screen.cy+100);
    ShowCommand=cmd(stoptweening;linear,0.2;x,SCREEN_RIGHT);
  	HideCommand=cmd(stoptweening;linear,0.2;x,SCREEN_RIGHT+800);
  };
  Def.ActorFrame{
    InitCommand=cmd(xy,SCREEN_RIGHT+400,_screen.cy+100);
    ShowCommand=cmd(stoptweening;linear,0.2;x,SCREEN_RIGHT-496);
  	HideCommand=cmd(stoptweening;linear,0.2;x,SCREEN_RIGHT+400);
    Def.ActorFrame{
      InitCommand=cmd(x,-266;y,-280);
      Def.Quad{
        InitCommand=cmd(halign,0;xy,-20,12;setsize,232,94;blend,Blend.Subtract;diffuse,color("0.25,0.25,0.25,1"));
      };
      Def.Quad{
        InitCommand=cmd(halign,0;x,-4;setsize,200,40;diffuse,color("0.7,0.7,0.7,1"));
      };
      LoadActor("Selected")..{
        BeginCommand=function(self)
          self:xy(-10,12)
    		end;
        ShowCommand=cmd(playcommand,"Set");
        SetCommand=function(self)
          local WheelPref = ThemePrefs.Get("WheelType");
          if WheelPref == "CoverFlow" then
            self:visible(true)
          else
            self:visible(false)
          end;
        end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="DEFAULT";
        BeginCommand=function(self)
          self:halign(0):maxwidth(192):diffuse(color("0,0,0,1"))
    		end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Wheel Type";
        BeginCommand=function(self)
          self:halign(0):maxwidth(214):diffuse(color("0.7,0.7,0.7,1")):xy(-4,40)
    		end;
      };
      LoadActor("selector")..{
        BeginCommand=function(self)
          self:xy(-30,12):halign(0)
    			self:playcommand(curIndex == 1 and "GainFocus" or "LoseFocus");
    		end;
    		GainFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,1);
    		LoseFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,0);
    		WheelChangedMessageCommand=function(self,param)
    			if param.OldIndex == 1 then
    				self:playcommand("LoseFocus");
    			end;
    			if param.NewIndex == 1 then
    				self:playcommand("GainFocus");
    			end;
    		end;
      };
    };

    Def.ActorFrame{
      InitCommand=cmd(x,0;y,-280);
      Def.Quad{
        InitCommand=cmd(halign,0;xy,-20,12;setsize,232,94;blend,Blend.Subtract;diffuse,color("0.25,0.25,0.25,1"));
      };
      Def.Quad{
        InitCommand=cmd(halign,0;x,-4;setsize,200,40;diffuse,color("0.7,0.7,0.7,1"));
      };
      LoadActor("Selected")..{
        BeginCommand=function(self)
          self:xy(-10,12)
    		end;
        ShowCommand=cmd(playcommand,"Set");
        SetCommand=function(self)
          local WheelPref = ThemePrefs.Get("WheelType");
          if WheelPref == "A" then
            self:visible(true)
          else
            self:visible(false)
          end;
        end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Grid";
        BeginCommand=function(self)
          self:halign(0):maxwidth(192):diffuse(color("0,0,0,1"))
    			self:playcommand(curIndex == 2 and "GainFocus" or "LoseFocus");
    		end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Wheel Type";
        BeginCommand=function(self)
          self:halign(0):maxwidth(214):diffuse(color("0.7,0.7,0.7,1")):xy(-4,40)
    			self:playcommand(curIndex == 2 and "GainFocus" or "LoseFocus");
    		end;
      };
      LoadActor("selector")..{
        BeginCommand=function(self)
          self:xy(-30,12):halign(0)
    			self:playcommand(curIndex == 2 and "GainFocus" or "LoseFocus");
    		end;
    		GainFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,1);
    		LoseFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,0);
    		WheelChangedMessageCommand=function(self,param)
    			if param.OldIndex == 2 then
    				self:playcommand("LoseFocus");
    			end;
    			if param.NewIndex == 2 then
    				self:playcommand("GainFocus");
    			end;
    		end;
      };
    };

    Def.ActorFrame{
      InitCommand=cmd(x,266;y,-280);
      Def.Quad{
        InitCommand=cmd(halign,0;xy,-20,12;setsize,232,94;blend,Blend.Subtract;diffuse,color("0.25,0.25,0.25,1"));
      };
      Def.Quad{
        InitCommand=cmd(halign,0;x,-4;setsize,200,40;diffuse,color("0.7,0.7,0.7,1"));
      };
      LoadActor("Selected")..{
        BeginCommand=function(self)
          self:xy(-10,12)
    		end;
        ShowCommand=cmd(playcommand,"Set");
        SetCommand=function(self)
          local WheelPref = ThemePrefs.Get("WheelType");
          if WheelPref == "Banner" then
            self:visible(true)
          else
            self:visible(false)
          end;
        end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Banner";
        BeginCommand=function(self)
          self:halign(0):maxwidth(192):diffuse(color("0,0,0,1"))
    			self:playcommand(curIndex == 3 and "GainFocus" or "LoseFocus");
    		end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Wheel Type";
        BeginCommand=function(self)
          self:halign(0):maxwidth(214):diffuse(color("0.7,0.7,0.7,1")):xy(-4,40)
    			self:playcommand(curIndex == 3 and "GainFocus" or "LoseFocus");
    		end;
      };
      LoadActor("selector")..{
        BeginCommand=function(self)
          self:xy(-30,12):halign(0)
    			self:playcommand(curIndex == 3 and "GainFocus" or "LoseFocus");
    		end;
    		GainFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,1);
    		LoseFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,0);
    		WheelChangedMessageCommand=function(self,param)
    			if param.OldIndex == 3 then
    				self:playcommand("LoseFocus");
    			end;
    			if param.NewIndex == 3 then
    				self:playcommand("GainFocus");
    			end;
    		end;
      };
    };

    Def.ActorFrame{
      InitCommand=cmd(x,-266;y,-180);
      Def.Quad{
        InitCommand=cmd(halign,0;xy,-20,12;setsize,232,94;blend,Blend.Subtract;diffuse,color("0.25,0.25,0.25,1"));
      };
      Def.Quad{
        InitCommand=cmd(halign,0;x,-4;setsize,200,40;diffuse,color("0.7,0.7,0.7,1"));
      };
      LoadActor("Selected")..{
        BeginCommand=function(self)
          self:xy(-10,12)
    		end;
        ShowCommand=cmd(playcommand,"Set");
        SetCommand=function(self)
          local WheelPref = ThemePrefs.Get("WheelType");
          if WheelPref == "Jukebox" then
            self:visible(true)
          else
            self:visible(false)
          end;
        end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Jukebox";
        BeginCommand=function(self)
          self:halign(0):maxwidth(192):diffuse(color("0,0,0,1"))
    			self:playcommand(curIndex == 4 and "GainFocus" or "LoseFocus");
    		end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Wheel Type";
        BeginCommand=function(self)
          self:halign(0):maxwidth(214):diffuse(color("0.7,0.7,0.7,1")):xy(-4,40)
    			self:playcommand(curIndex == 4 and "GainFocus" or "LoseFocus");
    		end;
      };
      LoadActor("selector")..{
        BeginCommand=function(self)
          self:xy(-30,12):halign(0)
    			self:playcommand(curIndex == 4 and "GainFocus" or "LoseFocus");
    		end;
    		GainFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,1);
    		LoseFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,0);
    		WheelChangedMessageCommand=function(self,param)
    			if param.OldIndex == 4 then
    				self:playcommand("LoseFocus");
    			end;
    			if param.NewIndex == 4 then
    				self:playcommand("GainFocus");
    			end;
    		end;
      };
    };

    Def.ActorFrame{
      InitCommand=cmd(x,0;y,-180);
      Def.Quad{
        InitCommand=cmd(halign,0;xy,-20,12;setsize,232,94;blend,Blend.Subtract;diffuse,color("0.25,0.25,0.25,1"));
      };
      Def.Quad{
        InitCommand=cmd(halign,0;x,-4;setsize,200,40;diffuse,color("0.7,0.7,0.7,1"));
      };
      LoadActor("Selected")..{
        BeginCommand=function(self)
          self:xy(-10,12)
    		end;
        ShowCommand=cmd(playcommand,"Set");
        SetCommand=function(self)
          local WheelPref = ThemePrefs.Get("WheelType");
          if WheelPref == "Wheel" then
            self:visible(true)
          else
            self:visible(false)
          end;
        end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Wheel";
        BeginCommand=function(self)
          self:halign(0):maxwidth(192):diffuse(color("0,0,0,1"))
    			self:playcommand(curIndex == 5 and "GainFocus" or "LoseFocus");
    		end;
      };
      Def.BitmapText{
        Font="_avenirnext lt pro bold/25px";
        Text="Wheel Type";
        BeginCommand=function(self)
          self:halign(0):maxwidth(214):diffuse(color("0.7,0.7,0.7,1")):xy(-4,40)
    			self:playcommand(curIndex == 5 and "GainFocus" or "LoseFocus");
    		end;
      };
      LoadActor("selector")..{
        BeginCommand=function(self)
          self:xy(-30,12):halign(0)
    			self:playcommand(curIndex == 5 and "GainFocus" or "LoseFocus");
    		end;
    		GainFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,1);
    		LoseFocusCommand=cmd(stoptweening;linear,0.1;diffusealpha,0);
    		WheelChangedMessageCommand=function(self,param)
    			if param.OldIndex == 5 then
    				self:playcommand("LoseFocus");
    			end;
    			if param.NewIndex == 5 then
    				self:playcommand("GainFocus");
    			end;
    		end;
      };
    };
  };
};

t[#t+1] = menu;

return t;
