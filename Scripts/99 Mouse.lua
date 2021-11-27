local topActor
local topActorZ = 0
local topActorName

-- To check the Z axis for getting the topmost actor upon clicking:
-- Give an actor a Z value and call addPressedActors(self) inside any command.
-- (e.g. MouseLeftClickMessageCommand)
-- If the actor is supposed to react to the click (e.g. button), add a TopPressedCommand to the actor.
-- TopPressedCommand will be called for a single actor with the highest Z value.


-- Call this when left/right click event occurs and isOver() is true.
-- Sets the actor calling this as the top actor if it has the highest Z value.
function addPressedActors(actor)
	local z = actor:GetZ()
	if z > topActorZ then
		topActorZ = z
		topActor = actor
		topName = actor:GetName()
	end
end

-- Resets the variables back to original values.
function resetPressedActors()
	topActor = nil
	topActorZ = 0
	topActorName = nil
end

-- Plays the TopPressed Command on the current top actor.
function playTopPressedActor()
	if topActor ~= nil then 
		topActor:playcommand("TopPressed")
	end
end


--Gets the true X/Y Position by recursively grabbing the parents' position.
--Does not take zoom into account.
function getTrueX(actor)
	if actor == nil then
		return 0
	end;
	if actor:GetParent() == nil then
		return actor:GetX() or 0
	else
		return actor:GetX()+getTrueX(actor:GetParent())
	end;
end;

function getTrueY(actor)
	if actor == nil then
		return 0
	end;
	if actor:GetParent() == nil then
		return actor:GetY() or 0
	else
		return actor:GetY()+getTrueY(actor:GetParent())
	end;
end;

--Button Rollovers
function isOver(actor)
	local x = getTrueX(actor)
	local y = getTrueY(actor)
	local hAlign = actor:GetHAlign()
	local vAlign = actor:GetVAlign()
	local w = actor:GetZoomedWidth()
	local h = actor:GetZoomedHeight()

	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()

	local withinX = (mouseX >= (x-(hAlign*w))) and (mouseX <= ((x+w)-(hAlign*w)))
	local withinY = (mouseY >= (y-(vAlign*h))) and (mouseY <= ((y+h)-(vAlign*h)))

	return (withinX and withinY)
end;


function quadButton(z)
	local t = Def.Quad{
		InitCommand= function(self) 
			self:z(z)
		end;
		MouseLeftClickMessageCommand = function(self)
			if isOver(self) then
				addPressedActors(self)
			end
		end;
		TopPressedCommand = function(self)
		end;
	}

	return t
end