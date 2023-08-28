# UI.OptionList
A module that allows you to create a simple node-tree option list, with customization options.

## Usage
Put the file in your theme's Modules folder and just call it with the LoadModule command inside of an actorframe or as the entire object itself.
```lua
-- Creates a base list that has no choices.
return LoadModule("UI.OptionList.lua"){ List = { Name="BaseList" } }
```

## Requirements
- [UI.ClickArea.lua](UI.ClickArea.md) (Mouse/Touch compatible area for interaction)
- Save.PlayerPrefs.lua (PrefsManager, a batch version of Config.Load/Save.lua, used for OutFoxPrefs)
- Config.Load.lua (Load configuration)
- Config.Save.lua (Save configuration)

## Settings

| Name of Setting | Default Value | Description |
| --------------- | ------------- | ----------- |
NumChoices | 13 | Set how many choices will be shown on screen at once.
InputTiedTo | nil | Locks input to a specific player.
TransformationCommand | ```self:y(32 * (index-1))``` | Use a transformation function to make the flow of each item be unique. You can use all kinds of mathematical operations here.
Frame | Def.Quad | Set a custom Frame for each option row to use.
Cursor | Def.Quad | Set a custom Cursor that will be the visual indicator.
ColorBooleanSwitches | false | Set to true if you want the boolean switch (on/off) to be player colored.
ItemWidth | 368 | Sets the width for each item.
List | none | The actual list of choices for the menu list.
UseDedicatedController | false | Skips installing the input system to the OptionList, allows you to add your own.
UseMetatable | false | Returns the list as a Metatable function namespace.

Only the ***List*** attribute is required to contain data in order to create its list.

## Setting custom Frames or cursors
The Frame and Cursor items can be customized to include any kind of ActorFrame-set combination.
In these functions the `itemWidth` and `player` arguments are provided which is the width of each item, and the player that represents this item; which will
help you align the frame/cursor with the rest of the items that will be drawn on top of and the
coloring of the frame if you may so choose.

```lua
Frame = function( itemWidth, player )
	return Def.ActorFrame{
		Def.Quad{
			InitCommand=function(self)
				self:diffuse( PlayerColor(player) )
				:zoomto( itemWidth, 64 )
			end
		}
	}
end
```

## Metatable version
When using `UseMetatable` in the list of settings, the following functions are available to use.

### `Create()`
Generates the OptionList itself to be placed on an actorframe.

### `GetCursorIndex()`
Get the position of the cursor in the current menu.

### `InSpecialMenu()`
Returns true if the user is currently on a menu that requires special attention. This applies specially when running on Three-Button enviroments.

### `ChangeValue(offset, player)`
Changes the value of an option by `offset` for `player`. If `InputTiedTo` is set, then it will ignore any input from `player` that does not match.

### `MoveSelection(offset, player`
Moves the cursor by `offset` for `player`. If `InputTiedTo` is set, then it will ignore any input from `player` that does not match.

### `UseNewMenu(table)`
Updates the current menu list for the option list with the one from `table`. Upon a successful update, the cursor for the list will be reset,
and returned back to the root of the table provided.

## Available entry choice types

### bool
Sets a true/false state option row as an answer type. The user can press left/right or start (in three button navigation) to toggle between them.

```lua
{ Name = "Boolean Choice", Type = "bool", Value = false }
```

### number
Data type that allows for incremental modification of a value.
The Margin value can be used as its steps, to increment the value accordingly.
```lua
{ Name = "3", Type = "number", Margin = 1, Value = 1 }
```

If you want to change the visual representation of the value, you can use
the `FormatVisible` argument that defines the variable via a function.
```lua
{ FormatVisible = function(val) return string.format("%.2f", val) end }
```

Helper functions for FormatVisible are available on the `UIHelper.OptionList` file alongside.

### table
Allows a row to contain a fixed ammount of choices that can contain unique values, and can be mixed data types. It is recommended that the option to be processed is performed when the option is saved.
```lua
{
	Name = "A table example",
	Type = "list",
	Choice = 1, -- Set the default value to choose from.
	Values = {"m1","m2","m3","m4"}
}
```

### screen
Sets the row to become a way to exit the current screen to one of choice defined in the `Value` tag.
```lua
{
	Name = "Let's get out of here!",
	Type = "screen",
	-- Send the user to the service options menu.
	Value = "ScreenOptionService"
}
```

### cancel
Similar to `screen`, this row exits the screen via the opposite direction, by perfoming a cancel action, as if the user is requesting to discard actions from the current screen.
```lua
{
	Name = "Let's get out of here!",
	Type = "cancel",
}
```

### menu
Adds a submenu to the existing menu that the user can go into. This can be any number of levels deep, as long as the next menu is inserted to the previous menu. Menus inside of menus can also have its own items.
```lua
{
	Name = "I'm a menu",
	Menu = {
		Name = "I'm another menu",
		Menu = {
			Name = "And another one!",
			{ Name = "This is the end.", Type = "label" }
		}
	}
}
```

### action
A universal use case row that allows for function-like actions
upon selecting the row. Contents from the row are available in `self.container`.
```lua
{
	Name="I'm an action",
	Type = "action",
	Value = function(self, player)
		lua.ReportScriptError( "This is an action from the action called: ".. self.container.Name )
	end
}
```

### label
A completely visual row that just displays some text. Will be skipped while scrolling.
```lua
{
	Name = "I do nothing.",
	Type = "label"
}
```

### message
Allows the choice to broadcast a message when interacted with that subscribed actors can listen to and react accordingly. Any message that wants to interact with it, should
contain the the name of the option row that it falls into with the values to use.

```lua
{
	Name = "A Message",
	Type = "message",
	Value = {Name="ActivateExternalActor",Values={Test="1"}}
}
```

## Obtaining/Setting Data
The rows can obtain and get data from other sources, such as preferences, Player / Song modifiers, and OutFox preferences. These are defined by using flags on the `Value` tag.

| Name | Description |
| ---- | ----------- |
| player_mod | Looks up the name of the current option via the Player Option (drunk, tipsy, boost, etc.) |
| song_option | Looks up the name of the current option via the Song Option (MusicRate, AssistClap, etc.)
| player_mod_table | Used for the `list` entry choice type, finds the active choice from the table in the available choices on the list.
| outfox_pref | Looks up the preference from the player's OutFoxPrefs.ini file, or the Save folder's version of it, for global related settings.
| outfox_pref_table | Used for the `list` entry choice type for outfox_pref, by looking at the active choice available from the list.
| system_option | Looks up the preference from the game's main preferences (Preferences.ini).
| system_option_table | Used for the `list` entry choice type for system_option, by looking at the active choice available from the list.

## Arbitrary Load/Save
If the need comes to use custom operations for loading or saving data, you can overwrite the Value flag by
using the Load and Save arguments in your item to perform the actions.

### `Load( self, Player )`
Function to load the value into the row. This function must return the corresponding value that matches with
it's value type. If it's `number`, it must be a number, if it's `table`, it must be the index of the table, etc.
The `self` argument provided is the container actor itself, which controls the actorframe that the values are from.
To access the container data, it's located under `self.container`.
```lua
-- This example is a variation of what it can be done with the player_mod flag on Value.
Load = function( self, Player )
	local pOptions = GAMESTATE:GetPlayerState(Player):GetPlayerOptions("ModsLevel_Preferred")
	return pOptions:Mini(pOptions)
end
```

### `Save( self, Player )`
Function to save the value from the row into a place. This function doesn't need to return anything, as it is void.
To access the container data, it's located under `self.container`.
```lua
Save = function( self, Player )
	local val = self.container.ValueE -- Get the current value.
	PREFSMAN:SavePreference("Windowed", val)
end
```

## Message Subscriptions
Rows can be subscribed into other rows, which will start listening until their subscribed row performs an action and requests a response from them. This can be useful to remote control other rows upon the action of another.

For example:
```lua
-- This row will start listening for a row called 'Broadcaster', which can manually determine if it should update.
{
	Name = "Regular Row", Type = "label", SubscribedMessage = "Broadcaster",
	-- This function will be called when the message checker verifies the subscribed message.
	UpdateFromMessage = function(Container,newValue,player)
		SCREENMAN:SystemMessage("I have been requested!")
	end
},
{ Name = "Broadcaster", Type = "boolean", Value = false }
```

## Request a function load after loading
Sometimes you may want to perform extra operations once all data from a row has been processed. For this, you can add the `AfterLoad` argument
to perform actions.

```lua
{
	Name = "Just a bool",
	Type = "boolean", 
	Value = false,
	AfterLoad = function(self)
		SCREENMAN:SystemMessage("I am done with operations!")
	end
}
```

## Disabling an option
If an option is required to be skipped by itself or via external means, use the `Disabled` flag on the item.
```lua
-- This example will disable an entire menu.
{
	Name = "I'm a menu",
	Disabled = true,
	Menu = {
		{ Name = "Secrets are located here!", Type = "label" }
	}
}
```
If the need arrives to add toggling of this value via an external actor (for example to open a submenu), attach such
item to a message subcriber and use the `UpdateFromMessage` command on the item to toggle its `Disabled` state.
```lua
SubscribedMessage = "Toggler",
UpdateFromMessage = function(Container,newValue,player)
	-- Do the inverse of the value to give in the effect.
	Container.Disabled = not newValue
end
```

## Skipping an option entirely
If disabling an option is not enough, an item can be completely removed from the menu using the `SkipIf` flag.

```lua
-- This example will disable an entire menu if we're not in Course mode..
{
	Name = "I'm a menu for course options!",
	SkipIf = not GAMESTATE:IsCourseMode(),
	Menu = {
		{ Name = "Secrets are located here!", Type = "label" }
	}
}
```

Just like the example above for `Disabled`, an external actor can broadcast a message back using the `SubscribedMessage` and `UpdateFromMessage` functions.

## Usage Example
```lua
return LoadModule("UI/UI.OptionList.lua"){
	-- Settings:
	-- Set how many choices will be shown on screen at once.
	NumChoices = 13,
	-- InputTiedTo is not used here, so input will go to both players.
	-- Use a transformation function to make the flow of each item be unique.
	-- You can use all kinds of mathematical operations here.
	TransformationCommand = function(self, index)
		self:xy( 0, 30 * index )
	end,
	-- We'll use a custom cursor and frame to store the items for each row.
	Frame = Def.Quad{ InitCommand=function(self) self:zoomto(300,28):diffuse(color("#777777")) end },
	Cursor = Def.Quad{ InitCommand=function(self) self:zoomto(300,28):diffuse(color("#ffffff55")) end },

	-- Choices to be shown on the list.
	List = {
		Name = "New Area!",
		{
			Name = "OptionSet1",
			Menu = {
				{
					Name = "I'm a new option that goes to another menu!",
					{ Name = "Language", Type = "boolean", Value = false },
					{ Name = "Theme", Type = "boolean", Value = false },
					{ Name = "Announcer", Type = "boolean", Value = false },
					{ Name = "I'm a broadcaster button!", Type = "message", Value = "ActivateExternalActor", Params={Test="1"} },
					{ Name = "Get me out of here!", Type = "screen", Value = "ScreenOptionsService" },
					{ Name = "3", Type = "number", Margin = 1, Value = 1 },
					{
						Name = "yes",
						Menu = {
							Name = "Wow!",
							{
								Name = "Choice lists",
								Type = "list",
								Choice = 1,
								Values = {"m1","m2","m3","m4"}
							}
						}
					}
				}
			}
		}
		,{
			Name = "OptionSet2",
			Menu = {
				{ Name = "wot" }
			}
		}
	}
}
```

## Copyright
Copyright 2021-2022 Jose Varela, Project OutFox.
This module forms part of the "Alpha V: Dance" Theme and is part of Project OutFox
Licensed under the Apache License, Version 2.0.