local screen = Var 'LoadingScreen'
local pf = ''
local out = ''

if IsAnExtraStage() then
	pf = 'ex '
end

local List = {
	'Tohoku EVOLVED',
	'COVID'
}

return Def.ActorFrame {
	--Top
	Def.ActorFrame {
		InitCommand=function(s) s:CenterX():y(-130) end,
		AnOnCommand=function(s) s:y(-130):sleep(0.2):diffusealpha(1):decelerate(0.2):addy(260) end,
		AnOffCommand=function(s) s:y(130):diffusealpha(1):accelerate(0.2):addy(-260):sleep(0):diffusealpha(0) end,
		
		Def.Sprite {
			Texture=pf .. 'mult',
			InitCommand=function(s) s:blend('BlendMode_WeightedMultiply'):diffusealpha(0.25) end,
		},
		Def.Sprite {
			Texture=pf .. 'base',
			AnOnCommand=function(s) s:diffuse(color('0.5,0.5,0.5,1')):sleep(0.5):decelerate(1):diffuse(color('1,1,1,1')) end,
			AnOffCommand=function(s) s:queuecommand('AnOn') end,
			SetFailCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/f base.png')) end,
		},
		Def.Sprite {
			Texture='mid base',
			InitCommand=function(s) s:y(-9) end,
		},
		Def.Sprite {
			Texture=pf .. 'mid progress',
			InitCommand=function(s) s:y(-9):cropright(1) end,
			AnOnCommand=function(s) s:cropright(1):sleep(0.5):decelerate(2):cropright(0) end,
			AnOffCommand=function(s) s:queuecommand('AnOn') end,
			SetFailCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/f mid progress.png')) end,
		},
		Def.Sprite {
			Texture=pf .. 'side lasers.png',
			InitCommand=function(s) s:y(-5) end,
			AnOnCommand=function(s) s:cropbottom(1):sleep(0.5):decelerate(2):cropbottom(0) end,
			AnOffCommand=function(s) s:queuecommand('AnOn') end,
			SetFailCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/f side lasers.png')) end,
		},
		Def.ActorFrame {
			InitCommand=function(s) s:visible(true) end,
			SetNoneCommand=function(s) s:visible(false) end,
			
			Def.Sprite {
				Texture=pf .. 'Initializing.png',
				InitCommand=function(s) s:y(-50):diffusealpha(0) end,
				AnOnCommand=function(s) s:diffusealpha(0):sleep(0.5):linear(0.05):diffusealpha(0.5):linear(0.05):diffusealpha(0)
					:linear(0.05):diffusealpha(1):linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(0.5):decelerate(0.1):diffusealpha(1)
				end,
				AnOffCommand=function(s) s:queuecommand('AnOn') end,
				SetOffCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/out/Initializing.png')) end,
				SetFailCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/out/ERROR.png')) end,
			},
			Def.Sprite {
				Texture=pf .. 'Starlight.png',
				InitCommand=function(s) s:y(23):diffusealpha(0) end,
				AnOnCommand=function(s) s:sleep(1.5):decelerate(0.5):diffusealpha(1) end,
				AnOffCommand=function(s) s:queuecommand('AnOn') end,
				SetOffCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/out/starlight.png')) end,
				SetFailCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/out/SONG CRASH.png')) end,
			},
		},
	},
	
	--Bottom
	Def.ActorFrame {
		InitCommand=function(s) s:CenterX():y(SCREEN_BOTTOM+130) end,
		AnOnCommand=function(s) s:y(SCREEN_BOTTOM+130):sleep(0.2):diffusealpha(1):decelerate(0.2):addy(-260) end,
		AnOffCommand=function(s) s:y(SCREEN_BOTTOM-130):diffusealpha(1):accelerate(0.2):addy(260):sleep(0):diffusealpha(0) end,
		
		Def.Sprite {
			Texture=pf .. 'mult',
			InitCommand=function(s) s:zoomy(-1):blend('BlendMode_WeightedMultiply'):diffusealpha(0.25) end,
		},
		Def.Sprite {
			Texture=pf .. 'base',
			InitCommand=function(s) s:zoomy(-1) end,
			AnOnCommand=function(s) s:diffuse(color('0.5,0.5,0.5,1')):sleep(0.5):decelerate(1):diffuse(color('1,1,1,1')) end,
			AnOffCommand=function(s) s:queuecommand('AnOn') end,
			SetFailCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/f base.png')) end,
		},
		Def.Sprite {
			Texture='mid base',
			InitCommand=function(s) s:y(9):zoomy(-1) end,
		},
		Def.Sprite {
			Texture=pf .. 'mid progress',
			InitCommand=function(s) s:y(9):cropright(1):zoomy(-1) end,
			AnOnCommand=function(s) s:cropleft(1):sleep(0.5):decelerate(2):cropleft(0) end,
			AnOffCommand=function(s) s:queuecommand('AnOn') end,
			SetFailCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/f mid progress.png')) end,
		},
		Def.Sprite {
			Texture=pf .. 'side lasers.png',
			InitCommand=function(s) s:y(5):cropbottom(1):zoomy(-1) end,
			AnOnCommand=function(s) s:sleep(0.5):decelerate(2):cropbottom(0) end,
			AnOffCommand=function(s) s:queuecommand('AnOn') end,
			SetFailCommand=function(s) s:Load(THEME:GetPathB('','_StageDoors/f side lasers.png')) end,
		},
		Def.Sprite {
			Texture=pf .. 'dance.png',
			InitCommand=function(s) s:y(-24):diffusealpha(0) end,
			AnOnCommand=function(s) s:diffusealpha(0):sleep(0.5):linear(0.05):diffusealpha(0.5):linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(1)
			:linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(0.5):decelerate(0.1):diffusealpha(1)
			end,
			SetFailCommand=function(s) s:visible(true):Load(THEME:GetPathB('','_StageDoors/out/DID YOU DO YOUR BEST.png')) end,
			SetOffCommand=function(s) 
				if has_value(List,GAMESTATE:GetCurrentSong():GetDisplayMainTitle()) then
					s:Load(THEME:GetPathB('','_StageDoors/out/OUR THOUGHTS.png'))
				else
					s:visible(false)
				end
			end
		},
		Def.Sprite {
			Texture=pf .. 'prep.png',
			InitCommand=function(s) s:y(50):diffusealpha(0) end,
			AnOnCommand=function(s) s:diffusealpha(0):sleep(0.5):linear(0.05):diffusealpha(0.5):linear(0.05):diffusealpha(0)
			:linear(0.05):diffusealpha(1):linear(0.05):diffusealpha(0):linear(0.05):diffusealpha(0.5):decelerate(0.1):diffusealpha(1)
			end,
			SetFailCommand=function(s) s:visible(true):Load(THEME:GetPathB('','_StageDoors/out/EXITING GAMEPLAY.png')) end,
			SetOffCommand=function(s) 
				if has_value(List,GAMESTATE:GetCurrentSong():GetDisplayMainTitle()) then
					s:Load(THEME:GetPathB('','_StageDoors/out/AND PRAYERS ARE WITH YOU.png'))
				else
					s:visible(false)
				end 
			end,
		},
	},
}