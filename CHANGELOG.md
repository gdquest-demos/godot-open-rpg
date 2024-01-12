# Changelog

## v0.2.0 Cutscene Demo 💬

### New

The demo scene has been reworked to include cutscenes, the videogame equivalent of a short scene in a film. For example, dialogue may be displayed, the scene may switch to show key NPCs performing an event, or the inventory may be altered. Gameplay on the field is [b]stopped[/b] until the cutscene concludes, though this may span a combat scenario (e.g. epic bossfight).

The demo introduces:
- 3 main classes: Custcenes, Interactions, and Triggers
- 5 template Cutscenes
	- Tresasure chests (that can be closed!)
	- Lock-able doors
	- Item pickups
	- Simple area transitions (all within the same scene, for now)
	- conversations, implemented via Dialogic 2
- 3 simple areas to explore
- Music and sound effects sprinkled throughout the demo
- A simple inventory implementation
- Screen transitions, both fade and texture-based

### Changes

- Reworked the demo scenario, adding a handful of areas to explore, a (fetch) quest to fulfill, and a simple puzzle to solve. If you're stuck, try talking to the energetic child...
- Rearranged the folder structure.
- Included the Dialogic 2 Alpha addon. **Note that input has been changed to respond to the event's releasing (rather than when pressed).**
- Miscellaneous fixes throughout the demo.

***

## v0.1.0 Project Demo 🏃

### New

The initial demo is to verify the direction of the 4.0 rewrite. The codebase is rewritten from scratch, being refactored to include Godot 4 updates as well as GDQuest best practices. 

This first demo tackles player movement throughout the gameworld. This is accomplished primarily via Godot's built-in physics engine, which is used to govern "where everything is and may be". 

Gamepiece movement is grid-based (as in the original Final Fantasy and similar games) and concurrent (gamepieces may move simultaneously). The player may move via gamepad, touch screen, or mouse + keyboard. The source code is documented and should provide a robust starting point for any RPG or Roguelike.

Please turn on 'Debug/Visible Collision Shapes' in the editor to better see where everything is located on the grid.

### Changes

- Changed game assets to use Kenney's Tiny Town set. The art is upscaled 5x in-game.
- Updated the changelog and reset the versioning, as this is essentially a new project.
- Added a credits file providing attribution to project assets.
