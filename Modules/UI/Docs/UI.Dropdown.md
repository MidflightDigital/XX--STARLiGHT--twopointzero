# UI.Dropdown
Creates a dropdown menu-like actorframe that is controlled via metatable functions.

## Requirements
- [UI.ButtonBox.lua](UI.ButtonBox.md) - Background box generation
- [UI.ClickArea.lua](UI.ClickArea.md) - Mouse/Touch generation

## Settings

| Name of Setting | Default Value | Description |
| --------------- | ------------- | ----------- |
| Width | 200 | The width for the dropdown.
| Height | 32 | The height for the dropdown.
| XPos | 32 | X position for the dropdown.
| YPos | 32 | Y position for the dropdown.
| List | {} | The table of contents for the dropdown menu.
| currentItem | 1 | The item that is selected upon generating the dropdown menu.
| perItemAction | nil | The function to execute when choosing an option from the dropdown menu.
| player | nil | Dedicated player assigned to this dropdown.

## Commands

#### `AllowInput(bool)`
Enables/Disabled input in the dropdown. A MessageCommand is broadcasted (`DropdownMenuStateChanged`) to alert other actors that may also be using Input Filters to let them know that operation can either continue or must be halted for the dropdown to function.

#### `MoveOption(offset)`
Tells the dropdown menu to move the cursor by `offset`.

#### `ConfirmChoice()`
Confirms the selection made by the user on this dropdown.

#### `CloseMenu()`
Cancels the current choice and closes the dropdown menu.

## Usage
```lua
-- This example will report a choice when it's selected.
LoadModule("UI/UI.DropDown.lua"){
	Width = 200,
	Height = 48,
	-- X and Y position are already defaulted to 0,
	-- so they're not used here.
	List = {
		"Option 1",
		"Option 2",
		"Option 3",
	},
	currentItem = function(self, list, player)
		-- Let's just auto select the first option.
		return 1
	end,
	perItemAction = function(self, list, a)
		SCREENMAN:SystemMessage( "You've chosen ".. list[a] .."!" )
	end
}
```

An item on the list can also contain an image. An example on how to utilize these goes as follows:

```lua
-- This example will report a choice when it's selected.
-- But now we show pictures!
LoadModule("UI/UI.DropDown.lua"){
	Width = 200,
	Height = 48,
	-- X and Y position are already defaulted to 0,
	-- so they're not used here.
	List = {
		-- These images are blank, so put your own textures and see what happens!
		{Name = "Option 1", Icon=THEME:GetPathG("","_blank")},
		{Name = "Option 2", Icon=THEME:GetPathG("","_blank")},
		{Name = "Option 3", Icon=THEME:GetPathG("","_blank")},
	},
	currentItem = function(self, list, player)
		-- Let's just auto select the first option.
		return 1
	end,
	perItemAction = function(self, list, a)
		SCREENMAN:SystemMessage( "You've chosen ".. list[a].Name .."!" )
	end
}
```