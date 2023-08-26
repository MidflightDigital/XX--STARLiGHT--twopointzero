local size = 200


local t = Def.ActorFrame{}

-- Console background
t[#t+1] = Def.Quad {
	InitCommand = function(s) s:stretchto(0,-size*1.1,_screen.w,0)
		:diffusetopedge(Alpha(Color.Black,0.5)):diffusebottomedge(Alpha(Color.Black,0.8))
	end,
}

-- Console output text
t[#t+1] = Def.BitmapText{
	Font="Common Normal",
	InitCommand = function(s) s:align(0,1):xy(4,-10):zoom(0.7)
		:wrapwidthpixels((_screen.w-8)/0.7))
	end,
	-- Broadcast when new text is logged to the console
	UpdateConsoleMessageCommand=function(s) s:settext(Console:GetText())) end
}

-- Prompt and user input
t[#t+1] = Def.BitmapText{
	Font="Common Normal",
	InitCommand = function(self)
		self:zoom(0.7)
		self:halign(0)
		self:valign(1)
		self:xy(4,-8)

		-- Set up some variables we'll use
		self.CursorVisible = false
		self.InputText = ""
	end,

	-- We've just GOT to have that blinking cursor :)
	OnCommand = function(s) s:queuecommand("Blink") end,

	BlinkCommand = function(self)
		self:sleep(0.3)
		self.CursorVisible = not self.CursorVisible
		self:settext("> " .. self.InputText .. (self.CursorVisible and "_" or ""))
		self:queuecommand("Blink")
	end,

	-- Broadcast from ScreenConsoleInput whenever the input changes
	ConsoleInputMessageCommand = function(self, params)
		self.InputText = params.Text
		self:settext("> " .. self.InputText .. (self.CursorVisible and "_" or ""))
	end,
}

t.AnimateInCommand=function(s) s:ease(0.3,170):y(size) end,
t.AnimateOutCommand=function(s) s:ease(0.3,-170):y(0) end,

return t
