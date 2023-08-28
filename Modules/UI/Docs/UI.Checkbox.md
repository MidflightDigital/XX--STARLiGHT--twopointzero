# UI.Checkbox
Creates a checkbox frame that can perform an action when clicked or pressed on.

## Requirements
- [UI.ButtonBox.lua](UI.ButtonBox.md) - Background box generation
- [UI.ClickArea.lua](UI.ClickArea.md) - Mouse/Touch generation

## Settings

| Name of Setting | Default Value | Description |
| --------------- | ------------- | ----------- |
| Width | 32 | The width for the checkbox.
| Height | 32 | The height for the checkbox.
| Border | 2 | The border area for the ButtonBox (BG).
| Load | nil | The action called when the checkbox is generated. Determines if the value is already true or not.
| Save | nil | The action called when the checkbox is pressed. This function returns a `value` argument which is the boolean state of the checkbox.

## Usage
```lua
LoadModule("UI/UI.CheckBox.lua"){
	-- Width, Height and Border values, optional.
	-- Used for the Button and Click area generation.
    Width = 64, -- Default: 32
    Height = 64, -- Default: 32
    Border = 2, -- Default: 2
	-- Action performed when the checkbox is pressed.
    Save = function( state )
        lua.ReportScriptError("I am now performing a save with state " .. tostring(state))
    end
}
```