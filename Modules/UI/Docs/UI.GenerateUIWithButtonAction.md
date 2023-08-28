# UI.GenerateUIWithButtonAction
Generates a block quad with a border, from the [ButtonBox module][BTBox], and creates a clickable absolute area
from the [ClickArea module][ClArea] to provide a presentable button for actions.

## Requirements
- [UI.ButtonBox.lua][BTBox] (Creating the block quad)
- [UI.ClickArea.lua][ClArea] (Absolute mouse area)

## Settings

| Name of Setting | Default Value | Description |
| --------------- | ------------- | ----------- |
| Width | 64 | Set the width of the click area. |
| Height | 64 | Set the height of the click area. |
| Debug | false | Toggles the debug mode. If on, the click area will be drawn as a white box. |
| Position | nil | A function that can be used to position the click area. |
| Cache | false | If on, the [ClickArea module](UI.ClickArea.md) will stop generating new coordinates in the case the [Actor][Act] moves. |
| ReturnAdjacentActorFrame | false | Returns the [ActorFrame][ActFr] where this click area module has been installed into instead of the module itself. Can be useful for interactions with separate actors and to avoid the tangle of `self:GetParent()`. |
| AddActors | nil | Allows implementation of an [ActorFrame][ActFr] that can contain visual elements that are drawn inside of the box. The [ActorFrame][ActFr] assigned will be given the name of `"Extra"`.

[BTBox]: UI.ButtonBox.md
[ClArea]: UI.ClickArea.md
[ActFr]: https://outfox.wiki/dev/actors/actortypes/actorframe/
[Act]: https://outfox.wiki/dev/actors/actortypes/actor/