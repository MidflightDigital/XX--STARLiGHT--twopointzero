# UI.RadioList.lua

Creates a radio button list system that can contain N number of choices
that can be selected by either keyboard/buttons or mouse/touch.

Choices are provided, which can contain a Message, which is a string that explains
what the option will perform when selected.

## Options
| Name | Default | Description |
|-|-|-|
| Visible | true | Tells if the radio list is visible by default.
| TransformationCommand | nil | Transformation command to position each item. Has to be a function.
| Choices | {} | The actual options.
| RadioButton* | nil | Sprite or ActorFrame that contains the visual representation of the RadioButton.
| Load | nil | Function to obtain the currently selected option.
| Save | nil | Function to save the selected option.

*If an ActorFrame is used on this parameter, you must provide the set Width and Height so the 
click area contains the proper size. This can be done by using `SetWidth()` and `SetHeight()` on
the ActorFrame.

## Functions

### `ToggleUse(bool)`
Tells the option to appear visible or not.

### `ShowPrompt()`
Shortcut for `ToggleUse(true)`.

### `HidePrompt()`
Shortcut for `ToggleUse(false)`.

### `Create()`
Creates the actorframe to be generated.