# Changelog

## v0.3.2 Combat UI Demo 🖱️ - Battler Actions & User Interface

### Guide the player through action selection
The player can now choose actions! The demo makes use of real-time combat, which means that the player needs to be able to queue actions, and perhaps select a new action to react to the changing battlefield.
	- The player first selects a battler from the list of player-controlled battlers.
	- The player may then select one (valid) action from the battlers action list.
	- Finally, the player must choose a target from a dynamically-created list of valid targets.
	- Once this is done, the action is 'queued' for the selected battler, which will perform the action once it has fully charged.
	- The player may reselect the battler to cancel the queued action, and may go 'forward' and 'backward' through the menu hierarchy as much as desired in order to choose the best possible action.

### Random 'AI'
CPU-controlled Battlers have a sample 'AI' that randomly selects actions from a list specified by the designer. Targets are chosen randomly from the list of valid targets.

### Other improvements
A number of other improvements have been implemented:
	- a turn bar shows when battlers will act in relation to each other
	- UI elements are generated to display 'miss', damage, and healing labels as actions are played out.
	- the entire player input system is designed to respond to signals, making the UI flexible and less error-prone than an await-based solution.
	- bugfixes!

## v0.3.1 Combat Demo ⚔️ - Battlers, Stats, and Animations

### New

Combat instances have been fleshed out to include several new combat-specific nodes:
	- Battlers form two 'teams' and face off against each other. One team wins when the other's battlers have all been defeated (health points have been depleted).
	- BattlerStats track a Battlers given numerical characteristics, including health points.
	- A BattlerAnim(ation) node brings Battlers to life, animating in response to various stimuli acting on the battler.
	- an 'active turn queue' allows battlers to act in sequence as time passes.
	- A Battler has a repertoire of BattlerActions, selecting one (alongside any necessary targets) to perform on its turn.

### Changes
- Combat resolves (victory or loss on the player's part) automatically when one 'team' is defeated.
- A series of cyber-themed elements dictate how Battlers and actions play out statistically.
- Actions and combat resolution wait for animations and timers to play out, allowing for a smooth combat experience.
- Miscellaneous fixes to the demo.

## v0.3.0 Combat Demo ⚔️

### New

The demo scene has been reworked to include combat.

The demo introduces:
- A Main scene separated into two main gameplay objects, the Field and Combat.
- 1 additional template Cutscene:
	- Combat Trigger, that runs when colliding with the player. This is designed to be used with roaming encounters that may pounce on the player in the field. Winning removes the encounter from the Field, whereas losing will lead to a game-over.
- An example combat that is run from a conversation. Winning or losing leads to different dialogue options.
- Combat-related music.
- Smooth transitions to and from combat.

### Changes
- Added a handful of combat events that allow objects to hook into changes in a given combat.
- Refactored ScreenTransition into an autoload, since only one should ever be active at a given moment anyways.
- Updated Dialogic 2 to the most recent build. ***Note that input has been modified to respond to the input events being released, rather than pressed.***
- Miscellaneous fixes to the demo.

## v0.2.0 Cutscene Demo 💬

### New

The demo scene has been reworked to include cutscenes, the videogame equivalent of a short scene in a film. For example, dialogue may be displayed, the scene may switch to show key NPCs performing an event, or the inventory may be altered. Gameplay on the field is **stopped** until the cutscene concludes, though this may span a combat scenario (e.g. epic bossfight).

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
- Included the Dialogic 2 Alpha addon. ***Note that input has been modified to respond to the input events being released, rather than pressed.***
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
