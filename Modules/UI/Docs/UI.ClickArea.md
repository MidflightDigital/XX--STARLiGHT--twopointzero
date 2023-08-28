# UI.ClickArea
Generates an [Actor][Act] given from `Width` x `Height`, that can be interacted with other elements.

## Requirements
- [UI.MouseDetect.lua](UI.MouseDetect.md) (Recursive mouse position measurement)

## Settings

| Name of Setting | Default Value | Description |
| --------------- | ------------- | ----------- |
| Width | 64 | Set the width of the click area. |
| Height | 64 | Set the height of the click area. |
| Debug | false | Toggles the debug mode. If on, the click area will be drawn as a white box. |
| Position | nil | A function that can be used to position the click area. |
| eatinput | false | Tells the module its input must not be listened to. |
| Cache | false | If on, the module will stop generating new coordinates in the case the actor moves. This does not affect the metatable version. |
| ReturnAdjacentActorFrame | false | Returns the [ActorFrame][ActFr] where this click area module has been installed into instead of the module itself. Can be useful for interactions with separate actors and to avoid the tangle of `self:GetParent()`. |
| Action* | nil | The action performed when the click area has been clicked. |
| ActionUnclick* | nil | The action perform when a click is performed outside of the area. |

*\*if **ReturnAdjacentActorFrame** is active, the setting will return the parent ActorFrame rather than the module itself.*
## Usage
```lua
return LoadModule( "UI.ClickArea.lua" ){
	Width = 64, -- defaults to 64.
	Height = 64, -- defaults to 64.
	Debug = false, -- Optional
	-- Optional
	Position = function(self)
		-- Put the area in the center of the screen.
		self:Center()
	end,
	eatinput = false, -- Optional
	-- Optional, returns the actorframe the Click Area has been installed to,
	-- instead of the area itself.
	ReturnAdjacentActorFrame = false,
	-- The action to perform if the area is clicked.
	Action = function(self)
		SCREENMAN:SystemMessage("This click area has been clicked!")
	end,
	-- The action to perform if the area is clicked outside of itself.
	ActionUnclick = function(self)
		SCREENMAN:SystemMessage("This click area has been clicked outside!")
	end
}
```

[ActFr]: https://outfox.wiki/dev/actors/actortypes/actorframe/
[Act]: https://outfox.wiki/dev/actors/actortypes/actor/