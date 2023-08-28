# UI.MouseDetect.lua

A module that calculates if the position of the current [Actor][Act] assigned in `self` is overlapping with the mouse cursor / finger.
If you are sure that the mouse position will stay static on its position, the mouse information can be cached to avoid performing
new calculations for coordinates.

```lua
return Def.Quad{
	InitCommand=function(self)
		-- Position object
		self:Center():zoomto(64,64)
	end,
	LeftMouseClickMessageCommand=function(self,params)
		if params.IsPressed then
			if LoadModule("UI/UI.MouseDetect.lua")(self) then
				SCREENMAN:SystemMessage( "The mouse is overlapping this object!" )
			end
		end
	end
}
```

## Usage (Cached Method)
When you're sure you want to cache the position, assign `true` to the second argument to obtain a metatable version of the table.

```lua
-- First argument is ignored as VerifyCollision() can handle the very same action.
local mDetection = LoadModule("UI/UI.MouseDetect.lua")(nil,true)
```

## Metatable Functions

### `ProcessCoords(self)`
Process coordinates for the [Actor][Act] `self`. This will generate the absolute position necessary for the module to work.
if `self.GetAbsoluteDestX/Y` is not available on the scope of `self`, then it will iterate through all possible [Actors][Act]
upwards to achieve the same data via `self.GetDestX/Y`.

### `VerifyCollision()`
The function that determines if the cursor is currently colliding with the defined mouse area created by `ProcessCoords(self)`.
Returns a boolean.

This example shows the module used directly with the [Actor][Act]. The module takes care of generating the collision data and verifying that it collides with the cursor when its called.

```lua
return Def.Quad{
	InitCommand=function(self)
		-- Position object
		self:Center():zoomto(64,64)
		-- The first argument in this case becomes redundant if the
		-- second one is provided.
		self.MouseDetect = LoadModule("UI/UI.MouseDetect.lua")(nil,true)
		-- Generate the coords.
		self.MouseDetect:ProcessCoords(self)
	end,
	LeftMouseClickMessageCommand=function(self,params)
		if params.IsPressed then
			-- Now verify collision data generated from ProcessCoords.
			if self.MouseDetect:VerifyCollision() then
				SCREENMAN:SystemMessage( "The mouse is overlapping this object!" )
			end
		end
	end
}
```

[Act]: https://outfox.wiki/dev/actors/actortypes/actor/