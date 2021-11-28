local NoteskinToUse = ...
local curgame = GAMESTATE:GetCurrentGame():GetName()

local GameDirections = { ["dance"] = "Down", ["pump"] = "UpLeft" }

local nbox

if NoteskinToUse ~= "EXIT" then
	nbox = NOTESKIN:LoadActorForNoteSkin( GameDirections[curgame] , "Tap Note", NoteskinToUse or "default" )
else
	nbox = Def.BitmapText{
		Font="_avenirnext lt pro bold 20px",
		Text="EXIT"
	}
end

local AFTContainer = Def.ActorFrameTexture{
	InitCommand=function(self)
		self:SetTextureName("NSKIN"..NoteskinToUse):SetWidth(200):SetHeight(200)
		:EnableAlphaBuffer(true)
		:Create()
	end,
	Def.ActorFrame{
		InitCommand=function(self) self:xy(100,100):zoom(1.5) end,
		Def.Sprite{ Texture=THEME:GetPathB("ScreenSelectMusic","overlay/_OptionsList/optionIcon") },
		nbox
	}
}

local t = Def.ActorFrame{
	AFTContainer,
	Def.Sprite{
		-- 
		Texture="NSKIN"..NoteskinToUse
	}
}

return t
