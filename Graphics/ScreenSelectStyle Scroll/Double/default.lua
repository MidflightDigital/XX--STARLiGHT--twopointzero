local NumPlayers = GAMESTATE:GetNumPlayersEnabled()

local Image = Def.ActorFrame{
	GainFocusCommand=function(s) s:stoptweening():smooth(0.3):zoom(1) end,
	LoseFocusCommand=function(s) s:stoptweening():smooth(0.3):zoom(0.825) end,
	Def.Sprite{
		Texture="pad",
		InitCommand=function(s) s:diffusealpha(0):zoomx(1):xy(2,288) end,
		OnCommand=function(s) s:zoom(0):sleep(0.5):linear(0.1):diffusealpha(1):zoom(1):smooth(0.1):zoom(0.9):smooth(0.1):zoom(1) end,
		GainFocusCommand=function(s) s:smooth(0.3):diffusealpha(1):diffuseshift():effectcolor1(Color.White):effectcolor2(color("0.75,0.75,0.75,1")):effectperiod(2) end,
		LoseFocusCommand=function(s) s:stopeffect():diffuse(color("0.75,0.75,0.75,1")) end,
	};
	Def.Sprite{
		Texture=Branding().."char.png",
		InitCommand=function(s) s:diffusealpha(0):zoomx(0.5):xy(0,20) end,
		OnCommand=function(s) s:sleep(0.6):linear(0.1):diffusealpha(1):zoomy(0.2):linear(0.1):zoomy(0.5):zoomx(0.6):linear(0.1):zoomx(0.5) end,
	};
};

local t = Def.ActorFrame{
	Def.ActorFrame{
		GainFocusCommand=function(s) s:stoptweening():smooth(0.3):zoom(1) end,GainFocusCommand=function(s) s:stoptweening():smooth(0.3):zoom(1)
			:queuecommand("Play")
		end,
		PlayCommand=function(s)
			if s:GetVisible() then SOUND:PlayAnnouncer("select style comment double") end
		end,LoseFocusCommand=function(s) s:stoptweening():smooth(0.3):zoom(0.825) end,
		Def.Sprite{
			Texture="pad",
			InitCommand=function(s) s:diffusealpha(0):zoomx(1):xy(2,288) end,
			OnCommand=function(s) s:zoom(0):sleep(0.5):linear(0.1):diffusealpha(1.0):zoom(1):smooth(0.1):zoom(0.9):smooth(0.1):zoom(1) end,
			GainFocusCommand=function(s) s:smooth(0.3):diffusealpha(1):diffuseshift():effectcolor1(Color.White)
				:effectcolor2(color("0.75,0.75,0.75,1")):effectperiod(2)
			end,
			LoseFocusCommand=function(s) s:stopeffect():diffuse(color("0.75,0.75,0.75,1")) end,
		};
		Def.Sprite{
			Texture=Branding().."char.png",
			InitCommand=function(s) s:diffusealpha(0):basezoom(0.5):y(20) end,
			OnCommand=function(s) s:sleep(0.6):linear(0.1):diffusealpha(1):zoomy(0.5)
				:linear(0.1):zoomy(1):zoomx(1.5):linear(0.1):zoomx(1)
			end,
		};
	};
	Def.Sprite{
		Texture="title small",
		InitCommand=function(s) s:diffusealpha(0):xy(178,-120) end,
		MenuLeftP1MessageCommand=function(s) s:playcommand("Change1") end,
		MenuRightP1MessageCommand=function(s) s:playcommand("Change1") end,
    	MenuUpP1MessageCommand=function(s) s:playcommand("Change1") end,
    	MenuDownP1MessageCommand=function(s) s:playcommand("Change1") end,
    	MenuLeftP2MessageCommand=function(s) s:playcommand("Change1") end,
    	MenuRightP2MessageCommand=function(s) s:playcommand("Change1") end,
    	MenuUpP2MessageCommand=function(s) s:playcommand("Change1") end,
    	MenuDownP2MessageCommand=function(s) s:playcommand("Change1") end,
		OnCommand=function(self)
			self:playcommand("Change1")
		end;
		Change1Command=function(self)
		  local env = GAMESTATE:Env()
		  if env.DOUBLESELECT then
			self:queuecommand("GainFocus")
		  else
			self:finishtweening():linear(0.1):x(100):zoom(0):sleep(0.3):queuecommand("Change2")
		  end;
		end;
		Change2Command=function(s) s:x(100):zoom(0):diffusealpha(1):linear(0.1)
			:zoom(1.25):x(158):linear(0.1):zoom(1):queuecommand("Animate")
		end,
		GainFocusCommand=function(self)
		  local env = GAMESTATE:Env()
		  env.DOUBLESELECT = true
		  self:stoptweening():linear(0.1):zoomy(0)
		end;
		LoseFocusCommand=function(self)
		  local env = GAMESTATE:Env()
		  env.DOUBLESELECT = false
		end;
		AnimateCommand=function(s) s:linear(0.05):rotationz(3):linear(0.05):rotationz(-3)
			:linear(0.05):rotationz(3):linear(0.05):rotationz(-3):linear(0.05):rotationz(0)
			:sleep(1):queuecommand("Animate")
		end,
		OffCommand=function(s) s:stoptweening():smooth(0.2):zoom(0):diffusealpha(0) end,
	  };
};



return t;
