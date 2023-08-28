local commands = {
	Font = "Common Bold",
	Width = 100,
	Height = 32,
	Text = "",
	SpeedFactor = 0.2,
	SleepBeforeStart = 2,
	OverflowSpacing = 32,
	SideFade = 0.02,
	SprHandler = nil,
	handler = nil,
	ActorFrame = nil,
	sechandler = nil,
	SlideLength = 0,
	UseAbsZoom = nil,
	AbsZoom = function(this)
		return this.UseAbsZoom or this.Width*2
	end,
	SetText = function(this, newStr, altText)
		if newStr == this.handler:GetText() then return end

		this.Text = newStr,
		this.ActorFrame:playcommand("UpdateText",{Text=newStr,AltText=altText})
		this.SprHandler:playcommand("CheckSizeForSideFades")
	end,
	SetWidth = function(this, newWidth)
		this.Width = newWidth
		this.ActorFrame:playcommand("UpdateText",{Text=this.handler:GetText()})
		this.SprHandler:playcommand("CheckSizeForSideFades")
	end,
	ApplyToText = function(this, func)
		func(this.handler)
		func(this.sechandler)
	end,
	GetTextSlideLength = function(this)
		return this.SlideLength
	end,
	IsTextScrollable = function(this)
		return this:IsOverflowing( this.ActorFrame:GetChild("Main") )
	end,
	IsOverflowing = function(this, text)
		return text:GetZoomedWidth() > this:AbsZoom()
	end,
	Create = function(this)
		local AFT = Def.ActorFrameTexture{
			Name="AFT",
			InitCommand=function(self)
				-- AFT textures cannot have the same name, they must be unique.
				self:SetWidth( this.Width*2 ):SetHeight( this.Height*2 )
				:EnableAlphaBuffer(true)
				:Create()
			end,

			-- First copy of text, will be the initial pass.
			Def.ActorFrame{
				Name="TextContainer",
				InitCommand=function(self)
					this.ActorFrame = self
					self:GetChild("Main"):x( 2 )

					self:RunCommandsRecursively(
						function(self)
							if self.settext then
								self:y(this.Height*2*.5)
								:zoom(2):halign(0)
							end
						end
					)

					self:GetChild("Second"):x(
						self:GetChild("Main"):GetZoomedWidth() + this.OverflowSpacing
					)
				end,
				UpdateTextCommand=function(self,params)
					-- Stop any action.
					self:finishtweening()
					self:GetChild("Main"):settext( params.Text, params.AltText or params.Text )
					self:GetChild("Second"):settext( params.Text, params.AltText or params.Text )
					:x(
						self:GetChild("Main"):GetZoomedWidth() + this.OverflowSpacing
					)

					--[[
						Check the contents of the length, and see if it's
						going past the width of the AFT area.
					]]
					local IsOverflowing = this:IsOverflowing( self:GetChild("Main") )
					self:GetChild("Second"):visible(IsOverflowing)
					if IsOverflowing then
						self:playcommand("BeginSlide")
					end
					-- self:playcommand("VerifyOverflow")
				end,
				BeginSlideCommand=function(self)
					-- To make the times of the text mostly similar,
					-- calculate the length of the text and multiply by a factor,
					local slideLength = string.len( self:GetChild("Main"):GetText() ) * this.SpeedFactor
					local returnSpeedRate = clamp( slideLength*.25, 2, slideLength )
					this.SlideLength = slideLength + this.SleepBeforeStart
					self:sleep(this.SleepBeforeStart):linear( slideLength )
					:x( -self:GetChild("Main"):GetZoomedWidth() - (this.OverflowSpacing - 2) )
					:sleep(0):x(2):queuecommand("BeginSlide")
				end,
				OffCommand=function(self) self:finishtweening() end,
				CancelCommand=function(self) self:finishtweening() end,

				Def.BitmapText{
					Font=this.Font,
					Text=this.Text,
					Name="Main",
					InitCommand=function(self)
						this.handler = self
					end
				},

				-- Second copy of text, will be the overflow attach.
				Def.BitmapText{
					Font=this.Font,
					Text=this.Text,
					Name="Second",
					InitCommand=function(self)
						this.sechandler = self
					end
				}
			}
		}

		local t = Def.ActorFrame{}

		t[#t+1] = AFT

		-- Generate sprite that will display the contents from the AFT.
		t[#t+1] = Def.Sprite{
			Name="Sprite",
			InitCommand=function(self)
				this.SprHandler = self
			end,
			OnCommand=function(self)
				self:SetTexture( self:GetParent():GetChild("AFT"):GetTexture() )
				:zoom(.5)
			end,
			CheckSizeForSideFadesCommand=function(self)
				local side = 0
				if this.handler:GetZoomedWidth() > this.Width*2 then
					side = this.SideFade
				end
				self:fadeleft(side):faderight(side)
			end
		}

		return t
	end
}

return setmetatable( commands, {
	__call = function(this, Attr)
		this.Text = Attr.Text or ""
		this.Font = Attr.Font or "Common Bold"
		this.Width = Attr.Width or 100
		this.Height = Attr.Height or 32
		this.SpeedFactor = Attr.SpeedFactor or 0.2
		this.SleepBeforeStart = Attr.SleepBeforeStart or 2
		this.OverflowSpacing = Attr.OverflowSpacing or 32
		this.SideFade = Attr.Fade or 0.02
		this.UseAbsZoom = Attr.AbsZoom or nil
		return this
	end
}  )
