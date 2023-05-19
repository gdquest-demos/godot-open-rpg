# Changelog

## v0.1.0 Project Demo 🏃 2023-05-19

### New

The initial demo is to verify the direction of the 4.0 rewrite. The codebase is rewritten from scratch, being refactored to include Godot 4 updates as well as GDQuest best practices. 

This first demo tackles player movement throughout the gameworld. This is accomplished primarily via Godot's built-in physics engine, which is used to govern "where everything is and may be". 

Gamepiece movement is grid-based (as in the original Final Fantasy and similar games) and concurrent (gamepieces may move simultaneously). The player may move via gamepad, touch screen, or mouse + keyboard. The source code is documented and should provide a robust starting point for any RPG or Roguelike.

Please turn on 'Debug/Visible Collision Shapes' in the editor to better see where everything is located on the grid.

### Changes

- Changed game assets to use Kenney's Tiny Town set. The art is upscaled 5x in-game.
- Updated the changelog and reset the versioning, as this is essentially a new project.
- Added a credits file providing attribution to project assets.
