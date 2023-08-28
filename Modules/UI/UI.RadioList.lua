-- This generates a radio button system that can contain N
-- number of choices that can be selected by either
-- keyboard/buttons or mouse/touch.

local t = {
	Attr = nil,
	handler = nil,
	isAbleToUse = true,
	curChoice = 1,
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
	LoadVal = function(this)
		if this.Attr.Load then
			this.curChoice = this.Attr.Load(this.Attr.Choices)
		end
	end,
	Create = function(this)
		local a = Def.ActorFrame{
			InitCommand=function(self)
				this.handler = self
				self:visible( this.Attr.Visible or true )
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
				Def.ActorFrame{
					Name="Choice",
					InitCommand=function(self)
						self:playcommand("UpdateChoices",{choice = this.curChoice})
					end,
					Def.BitmapText{
						Font="Common Normal",
						Name="Message",
						Text=v.Message or "No message!",
						InitCommand=function(self)
							self:halign(0):x( -100 )
						end
					},

					-- Generate the radio button area.
					(this.Attr.RadioButton and this.Attr.RadioButton..{
						Name="Radio",
						InitCommand=function(self)
							self.index = i
						end
					} or Def.Sprite{
						Name="Radio",
						Texture=THEME:GetPathG("","radio"),
						InitCommand=function(self)
							self:animate(0):zoom(0.5):x(100)
						end,
						UpdateChoicesCommand=function(self)
							self:setstate( this.curChoice == i and 1 or 0 )
						end,
					})
				},
				LoadModule( "UI/UI.ClickArea.lua" ){
					Width = 40,
					Height = 40,
					Debug = true,
					Position = function(self)
						-- Get the radio icon, and resize the click area to it.
						local r = self:GetParent():GetChild("Choice"):GetChild("Radio")
						self:zoomto( r:GetZoomedWidth(), r:GetZoomedHeight() )
						-- And now just position the item to where the radio image is.
						:x( 100 )
					end,
					ReturnAdjacentActorFrame = true,
					Action = function(self)
						-- Is the prompt available to be clicked?
						if not this.isAbleToUse then return end
						this.curChoice = i
						self:GetParent():playcommand("UpdateChoices",{choice = i})
						if this.Attr.Save then
							this.Attr.Save(i, this.Attr.Choices)
						end
					end
				}
			}
		end
		return a
	end,
	__call = function(this, Attributes)
		this.Attr = Attributes
		this:LoadVal()
		return this
	end
}

return setmetatable(t,t)