DDR ={}

function DDRInput(self)
    return function(event)
        if not event.PlayerNumber then return end
		self.pn = event.PlayerNumber
        if ToEnumShortString(event.type) == "FirstPress" then
            self:queuecommand(event.GameButton)
    	end
        if ToEnumShortString(event.type) == "Release" then
            self:queuecommand(event.GameButton.."Release")
        end
		if ToEnumShortString(event.type) == "Repeat" then
			self:queuecommand(event.GameButton.."Repeat")
		end
    end
end