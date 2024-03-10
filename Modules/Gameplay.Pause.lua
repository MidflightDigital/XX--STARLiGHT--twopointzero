local Paused = false
-- Global variable because ???
-- Betting old themes use this variable a lot.
course_stopped_by_pause_menu = false
local CurSel = 1

local Choices = {
	{
		Name = "continue_playing",
		Action = function( screen )
			screen:PauseGame(false)
		end
	},
	{
		Name = "restart_song",
		Action = function( screen )
			screen:SetPrevScreenName('ScreenStageInformation'):begin_backing_out()
		end
	},
	{
		Name = "forfeit_song",
		Action = function( screen )
			screen:SetPrevScreenName(SelectMusicOrCourse()):begin_backing_out()
		end
	},
}

if GAMESTATE:IsCourseMode() then
	Choices = {
		{
			Name = "continue_playing",
			Action = function( screen )
				screen:PauseGame(false)
			end
		},
		{
			Name = "skip_song",
			Action = function( screen )
				screen:PostScreenMessage('SM_NotesEnded', 0)
			end
		},
		{
			Name = "forfeit_course",
			Action = function( screen )
				screen:SetPrevScreenName(SelectMusicOrCourse()):begin_backing_out()
			end
		},
		{
			Name = "end_course",
			Action = function( screen )
				course_stopped_by_pause_menu = true
				screen:PostScreenMessage('SM_LeaveGameplay', 0)
			end
		},
	}
end

local Selections = Def.ActorFrame{
	Name="Selections",
	InitCommand=function(self)
		-- As this process is starting, we'll already highlight the first option with the color.
		self:GetChild(1):DiffuseAndStroke(color("#dff0ff"),color("#00baff"))
	end
}

local function ChangeSel(self,offset)
	-- Do not allow cursor to move if we're not in the pause menu.
	if not Paused then return end

	CurSel = CurSel + offset
	SOUND:PlayOnce(THEME:GetPathS("","Codebox/o-change"))
	if CurSel < 1 then CurSel = 1 end
	if CurSel > #Choices then CurSel = #Choices end
	
	for i = 1,#Choices do
		self:GetChild("Frame"):GetChild("Selections"):GetChild(i):diffuse( i == CurSel and color("#dff0ff") or Color.White )
		:strokecolor( i == CurSel and color("#00baff") or Color.Black )
	end
end

for i,v in ipairs(Choices) do
	Selections[#Selections+1] = Def.BitmapText{
		Name=i,
		Font="_avenirnext lt pro bold/glow/24.ini",
		Text=THEME:GetString("PauseMenu", v.Name),
		OnCommand=function(self) self:y(-120+(60*i)) end
	}
end

return Def.ActorFrame{
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(LoadModule("Lua.InputSystem.lua")(self))
		self:visible(false):Center()
		self:GetChild("Frame"):zoomy(0)
		self:GetChild("BG"):diffusealpha(0)
		self:GetChild("Header"):diffusealpha(0)
	end,
	NonGameBackCommand=function(self)
		if not Paused then 
			SCREENMAN:GetTopScreen():PauseGame(true) 
			ChangeSel(self,0)
			self:visible(true)
			self:GetChild("Frame"):decelerate(0.2):zoomy(1)
			self:GetChild("BG"):decelerate(0.2):diffusealpha(0.5)
			self:GetChild("Header"):diffusealpha(0):sleep(0.25):linear(0.05)
			:diffusealpha(0.5):linear(0.05):diffusealpha(0):linear(0.05)
			:diffusealpha(1):linear(0.05):diffusealpha(0):linear(0.05)
			:diffusealpha(0.5):decelerate(0.1):diffusealpha(1):queuecommand("Anim")
			SOUND:PlayOnce(THEME:GetPathS("","Codebox/o-open"))
		end
		Paused = true
	end,
	AnimCommand=function(s) s:glowshift():effectcolor1(color("1,1,1,0.5")):effectcolor2(color("1,1,1,0")):effectperiod(1.5) end,
	StartCommand=function(self)
		if Paused then 
			Choices[CurSel].Action( SCREENMAN:GetTopScreen() )
			self:visible(false)
			self:GetChild("Frame"):zoomy(0)
			self:GetChild("BG"):diffusealpha(0)
			self:GetChild("Header"):diffusealpha(0)
			SOUND:PlayOnce(THEME:GetPathS("","Codebox/o-close"))
		end
		Paused = false
	end,
	MenuUpCommand=function(self) if Paused then ChangeSel(self,-1) end end,
	MenuDownCommand=function(self) if Paused then ChangeSel(self,1) end end,
	MenuLeftCommand=function(self) if Paused then ChangeSel(self,-1) end end,
	MenuRightCommand=function(self) if Paused then ChangeSel(self,1) end end,
	Def.Quad{
		Name="BG",
		OnCommand=function(s) s:setsize(SCREEN_WIDTH,SCREEN_HEIGHT):diffuse(Color.Black) end,
	},
	Def.BitmapText{
		Name="Header",
		Font="_avenir next demi bold/28px header",
		Text="PAUSED",
		OnCommand=function(s) s:y(-300):DiffuseAndStroke(color("#dff0ff"),color("#00baff")) end,
	},
	Def.ActorFrame{
		Name="Frame",
		Def.Sprite{
			Texture=THEME:GetPathB("","ScreenSelectMusic overlay/InfoPanel/Backer.png"),
		},
		Selections
	},
	
}