local t = Def.ActorFrame{
  Def.Quad{
    InitCommand=cmd(diffuse,color("0,0,0,1");FullScreen);
  };
};

t[#t+1] = Def.ActorFrame{
  LoadActor("../ScreenWithMenuElements background")..{
    InitCommand=cmd(diffusealpha,0);
    OnCommand=cmd(sleep,1;linear,0.4;diffusealpha,1);
  };
};

t[#t+1] = Def.ActorFrame{
  LoadActor("flourish") .. {
  	-- Swoosh under the dancer
  	InitCommand = cmd(xy,_screen.cx,_screen.cy+92;diffusealpha,0.5),
    OnCommand=cmd(cropright,1;sleep,2.5;linear,0.3;cropright,0);
  };
  LoadActor("streak") .. {
  	-- Swoosh behind the logo text
  	InitCommand = cmd(xy,_screen.cx+25,_screen.cy+8),
    OnCommand=cmd(cropright,1;sleep,2;linear,0.3;cropright,0);
  };
  LoadActor("dancer") .. {
  	InitCommand = cmd(clearzbuffer,true;
  		xy,_screen.cx-432,_screen.cy+11),
    OnCommand=cmd(diffusealpha,0;sleep,4;linear,0.3;diffusealpha,1);
  };
  LoadActor("spotlight") .. {
  	InitCommand = cmd(zoomtoheight,_screen.h;
  		xy,_screen.cx-414,_screen.cy),
    OnCommand=cmd(diffusealpha,0;sleep,4.5;linear,0.3;diffusealpha,1);
  };
};

t[#t+1] = Def.ActorFrame{
  LoadActor(THEME:GetPathS("","Title/shing.ogg"))..{
    OnCommand=cmd(queuecommand,"Play");
    PlayCommand=cmd(play);
  };
  LoadActor(THEME:GetPathS("","MenuMusic/common/Default (loop).ogg"))..{
    OnCommand=cmd(sleep,1;queuecommand,"Play");
    PlayCommand=cmd(play);
  };
}

t[#t+1] = Def.ActorFrame{
  LoadActor("XXwhi")..{
    InitCommand=cmd(Center;diffusealpha,0);
    OnCommand=cmd(sleep,0.2;diffusealpha,1;sleep,0;linear,0.4;diffusealpha,1;zoom,20;diffusealpha,0);
  };
  LoadActor("XXwhi")..{
    InitCommand=cmd(Center;diffusealpha,0);
    OnCommand=cmd(addx,-SCREEN_WIDTH;decelerate,0.2;addx,SCREEN_WIDTH;diffusealpha,1;linear,0.4;diffusealpha,0);
  };
  LoadActor("XXwhi")..{
    InitCommand=cmd(Center;diffusealpha,0);
    OnCommand=cmd(addx,SCREEN_WIDTH;decelerate,0.2;addx,-SCREEN_WIDTH;diffusealpha,1;linear,0.4;diffusealpha,0);
  };
  LoadActor("XX.png")..{
    InitCommand=cmd(Center;diffusealpha,0);
    OnCommand=cmd(sleep,0.2;linear,0.2;diffusealpha,1;sleep,1;decelerate,0.4;x,SCREEN_CENTER_X+360);
  };
  LoadActor("starlight.png")..{
    InitCommand=cmd(xy,_screen.cx-20,_screen.cy+10;diffusealpha,0);
    OnCommand=cmd(addy,20;sleep,3;linear,0.4;diffusealpha,1;addy,-20);
  };
  LoadActor("main.png")..{
    InitCommand=cmd(xy,_screen.cx-100,_screen.cy-90;diffusealpha,0);
    OnCommand=cmd(addx,-20;sleep,2;linear,0.4;diffusealpha,1;addx,20);
  };
};

t[#t+1] = Def.ActorFrame{
  Def.Quad {
  	InitCommand = cmd(zoomto,80,504;xy,_screen.cx-562,_screen.cy+4;skewx,3;
  		MaskSource,true),
  	OnCommand = cmd(sleep,4;queuecommand,"Animate"),
  	AnimateCommand = cmd(x,_screen.cx-562;linear,0.8;addx,1500;
  	 sleep,7;queuecommand,"Animate"),
  };
  LoadActor("shine.png") .. {
	-- Using WriteOnFail here allows us to display only what is UNDER the
	-- mask instead of only what is NOT UNDER it.
	InitCommand = cmd(xy,_screen.cx+106,_screen.cy+4;
		MaskDest;ztestmode,"ZTestMode_WriteOnFail"),
  };
};

local coinmode = GAMESTATE:GetCoinMode()

t[#t+1] = Def.Quad{
  InitCommand=cmd(FullScreen;diffuse,color("0,0,0,1"));
  OnCommand=cmd(diffusealpha,0;sleep,20;linear,0.297;diffusealpha,1);
};

-- top message
t[#t+1] = Def.Sprite{
	InitCommand=function(s) s:xy(_screen.cx,_screen.cy+340):diffuseshift():effectcolor1(Color.White):effectcolor2(color("#B4FF01")) end,
  BeginCommand=function(s) s:queuecommand("Set") end,
  OnCommand=function(s) s:diffusealpha(0):sleep(3):linear(0.2):diffusealpha(1) end,
	CoinInsertedMessageCommand=function(s) s:queuecommand("Set") end,
	SetCommand=function(s)
	  if coinmode == 'CoinMode_Free' then
		s:Load(THEME:GetPathB("","ScreenTitleJoin underlay/_press start"))
	  else
		if GAMESTATE:EnoughCreditsToJoin() == true then
		  s:Load(THEME:GetPathB("","ScreenTitleJoin underlay/_press start"))
		else
		  s:Load(THEME:GetPathB("","ScreenTitleJoin underlay/_insert coin"))
		end
	  end
	end
  };

return t;
