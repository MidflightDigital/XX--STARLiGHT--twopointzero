# UI.ButtonChooser.lua

Generates a layout with two buttons and a middle info pane.

## Requirements
- [UI.ButtonBox.lua](UI.ButtonBox.md) - Background box generation
- [UI.ClickArea.lua](UI.ClickArea.md) - Mouse/Touch generation

## Settings

| Name of Setting | Default Value | Description |
| --------------- | ------------- | ----------- |
| Width | nil | Width for the entire chooser.
| Height | nil | Height for the entire chooser.
| Pos | {0,0} | Relative position for the chooser.
| IsValueIncremental | false | Determines if the value returned from this chooser has no limit, and can be incremented/decremented via a margin instead.
| Choices* | nil | Uses an array of string/function/number values.
| Steps** | nil | Determines the value margin for each value.
| Choices* | nil | Visual representation of the values in Choices. Uses an array of string/function/number values.
| Load (self) | nil | Function to determine the initial value. This function must return a number value. `self` gives the items from the table. If IsValueIncremental is on, `self.Values` is nil.
| NotifyOfSelection(self,Value) | nil | NOTE: `self` in this case, is not the table itself, but the button click area correspondant of where the user has clicked. `Value` is the current result index selected by the user.
| Save (self,Value) | nil | Function to perform when the user has confirmed their selection. `Value` is the end result index selected by the user. If IsValueIncremental is on, `self.Values` is nil.

\* Only available when IsValueIncremental is true.

\*\* Only available when IsValueIncremental is false.