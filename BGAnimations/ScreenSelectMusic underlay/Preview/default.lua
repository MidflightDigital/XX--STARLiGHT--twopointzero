return Def.ActorFrame{
    Def.Sprite{
		Texture="../Default/wheelunder",
		InitCommand=function(s) s:xy(_screen.cx,_screen.cy-67.5):zoomto(SCREEN_WIDTH,412):draworder(-1) end,
        OnCommand=function(s) s:zoomtowidth(0):linear(0.2):zoomtowidth(SCREEN_WIDTH) end,
        OffCommand=function(s) s:sleep(0.3):decelerate(0.3):zoomtowidth(0) end,
        StartSelectingStepsMessageCommand=function(s) s:queuecommand("Off") end,
  	    SongUnchosenMessageCommand=function(s) s:queuecommand("On") end,
	};
}