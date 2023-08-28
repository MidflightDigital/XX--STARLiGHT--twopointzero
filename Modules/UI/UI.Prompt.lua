-- This generates a prompt system that can contain N
-- number of choices that can be controlled by either
-- keyboard/buttons or mouse/touch.

local t = {
	Attr = nil,
	handler = nil,
	isAbleToUse = true,
	ToggleUse = function(this, state)
		this.isAbleToUse = state
	end,
	ShowPrompt = function(this)
		this.handler:visible(true)
		this:ToggleUse(true)
	end,
	HidePrompt = function(this)
		this.handler:visible(false)
		this:ToggleUse(false)
	end,
	Create = function(this)
		local a = Def.ActorFrame{
			InitCommand=function(self)
				this.handler = self
				self:visible( this.Attr.Visible )
			end
		}
		local transformCmd = this.Attr.TransformationCommand
		for i,v in ipairs( this.Attr.Choices ) do
			a[#a+1] = Def.ActorFrame{
				Name="Button"..i,
				InitCommand=function(self)
					if transformCmd then
						transformCmd( self, i, #this.Attr.Choices )
					end
				end,
				-- If it contains a table then it generates the actors. Otherwise, it could
				-- be a string so instead generate a template-like button.
				(v.Actors or Def.ActorFrame{
					Def.Sprite{
						Name="BG",
						Texture=THEME:GetPathG("ScreenMenu small button","base"),
						OnCommand=function(self) self:zoom(1.4):diffuse(color("#113472")) end,
					},
					Def.BitmapText{
						Font="Common Normal",
						Name="Message",
						Text=v.Message or "No message!",
					},
				}),
				LoadModule( "UI/UI.ClickArea.lua" ){
					Width = 340,
					Height = 60,
					ReturnAdjacentActorFrame = true,
					Action = function(self)
						-- Is the prompt available to be clicked?
						if not this.isAbleToUse then return end							
						if v.Action then
							local res = v.Action(self)
							if res then
								this:HidePrompt()
							end
						end
					end
				}
			}
		end

		if this.Attr.Question then
			a[#a+1] = Def.BitmapText{
				Font="Common Normal",
				Text=this.Attr.Question,
				InitCommand=function(self)
					self:xy( SCREEN_CENTER_X,200 )
				end
			}
		end
		return a
	end,
	__call = function(this, Attributes)
		this.Attr = Attributes
		return this
	end
}

return setmetatable(t,t)