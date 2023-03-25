# Changelog

## v0.1.0 Project Demo 🏃 2023-03-23

### New

The initial demo is to verify the direction of the 4.0 rewrite. The codebase is rewritten from scratch, being refactored to include Godot 4 updates as well as GDQuest best practices. 

This first demo takes the first pass at player movement throughout the gameworld, including the following:
- Setup simple program architecture. Main serves as the point of entry and delegates gameplay to the currently active game state.
- The gameboard is setup from the tiles and characters painted onto the "field map". It creates several RefCounted/Resource objects that store the state of the game.
	- The gameboard is built dynamically from the terrain and obstacle tilemaps.
	- A special debug scene may be shown to display which cells are occupied or blocked.
	- Pathfinding is performed by an AStar2D pathfinder which accounts for the 
- Gamepieces (formerly pawns) are placed onto the gameboard and occupy a given cell. They may also follow paths to move around the gameboard.
	- Gamepieces move along the grid, either cell by cell (as in traditional Final Fantasy games) or along a set path (as in RPGMaker games).
	- An animation scene may be supplied to a gamepiece and will draw the character/object at it's position. The animation may also be given a facing which will play a directional animation (for example idle_north instead of idle) if it is available.
- The local player is given a controller that focuses on a single gamepiece. The controller responds to player input and gives the focus a path to follow.
	- Any gamepiece may be set as the controller focus.
	- The controller makes use of key/gamepad input as well as mouse/touch input to choose a path for the focus.
	- The player may not move onto a blocked cell and may move UP TO but not on top of a gamepiece by clicking on said gamepiece.
- A cursor scene shows what is currently highlighted by the mouse.
	- The cursor may be supplied with a "highlight strategy" (is it a strategy if it's encapsulated by an object?) to change how highlighting works. Examples include AOE selection (multiple cells), highlighting a path, highlighting a single cell, etc.

### Changes

- Changed game assets to use Kenney's Tiny Town set. The art is upscaled 5x in-game.
- Updated the changelog and reset the versioning, as this is essentially a new project.
- Added a credits file providing attribution to project assets.
