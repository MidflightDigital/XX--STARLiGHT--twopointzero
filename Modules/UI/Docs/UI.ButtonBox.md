# UI.ButtonBox
A module that generates a two quad box that can be customized with a different width, height, border and player color.

## Usage
Put the file in your theme's Modules folder and just call it with the LoadModule command inside of an [ActorFrame][ActFr].
```lua
-- Creates a box with a size of 30x30 with a border to 2px.
return LoadModule("UI.OptionList.lua")(30,30,2)
```

If you want to attach player colors to the box, use the 4th argument, which is tied to the player.
```lua
-- Creates a box with a size of 30x30 with a border to 2px.
-- Including this has the player, which will color it based on the value
-- from GameColor.
return LoadModule("UI.OptionList.lua")(30,30,2,player)
```

## Metatable version
If the 5th argument is given, the box will return a function instead of the box, which allows for more flexible control for reactive elements.
```lua
-- Creates a box with a size of 30x30 with a border to 2px.
-- The fifth element has been given, so this doesn't return an actor,
-- but instead a set of functions that can be called.
return LoadModule("UI.OptionList.lua")(30,30,2,nil,true)
```

### Available functions on the Metatable version

#### `Generate(width, height, border, plr, actorname)`
Creates the box with the given parameters. If a box already exists on the generated instance, it will be replaced by this one.

#### `UpdateSize(width, height, border)`
Updates the size coordinates for the box.

#### `ChangeColor(OutColor, InColor, Ease, Duration)`
Changes the color for the box, `OutColor` being the border area of the box,
and `InColor` the background area. `Ease` and `Duration` are optional arguments that allow you to add easing to the application of the color.

#### `RunCommand(commands)`
Allows you to run commands directly to the [ActorFrame][ActFr] generated from the module.

#### `RunRecursively(commands)`
Same as [RunCommand](#RunCommand), but it applies to all actors available in the [ActorFrame][ActFr].

#### `GetTotalWidth()`
Returns the total width of the area of the box.

#### `GetTotalHeight()`
Returns the total height of the area of the box.

#### `Handle()`
Returns the `self` handle from the [ActorFrame][ActFr], for direct access to actors. You can use this function to perform the same things as [RunCommand](#RunCommand).

#### `Create()`
Returns the [ActorFrame][ActFr] that will be generated.

### Metatable version actor example
```lua
-- Create the variable which contains the box
-- This will contain a 30x30 box with a border of 2px.
local myBox = LoadModule("UI.OptionList.lua")(30,30,2,nil,true)

-- Create an actorframe which will contain the box.
return Def.ActorFrame{
	InitCommand=function(self)
		-- Calling this command, we'll change the color to a shade of
		-- yellow.
		-- No additional arguments are given to the function aside from
		-- the colors to make the change instant.
		myBox:ChangeColor( color("#667700"), color("#334400") )

		-- Let's make the box bigger, by calling ChangeSize.
		-- Now it will become a 64x64 box.
		myBox:UpdateSize( 64,64,2 )

		-- Let's spin the box.
		-- Method 1: Using RunCommand
		myBox:RunCommand(function(self) self:spin() end)

		-- Method 2: Using the handle
		myBox:Handle():spin()
	end,
	-- To obtain the box to be drawn, we call the Create command.
	myBox:Create()
}
```

[ActFr]: https://outfox.wiki/dev/actors/actortypes/actorframe/