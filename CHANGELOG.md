# Changelog

## [UNRELEASED] v0.4.0: Quests 📃🖋

### New

#### Quest system

- Start, complete quests, and have multiple objectives per quest

#### core

- Save and Load the game: currently only for party members

### Fixes

- Fixed jerky move animation the first time a Pawn moves on the map
- Only start interaction when clicking on the NPCs' area

### Source code

- Split GrowthStats and CharacterStats
- Added docstrings to a number of files and methods in the codebase, to help understand the code a little better

## v0.3.0: Motion and Dialogues 😮💬

### New

#### Battle system

- Added support for extensible AI on battlers, allowing the ability to craft custom AI on a per enemy type/character basis.
- Mouse and touch controls

#### Map

- Leader and followers now reflect the player's party's size
- Touch controls with pathfinding
- NPCs now have two interaction modes and look directions: they can be triggered by walking in an area around them or by pressing space in front of them
- Characters on the map now have a dedicated skin and animations so characters reflect the party

#### Dialogues

- Character database: you can now reference a character and an expression by name when writing dialogues
- Portrait: the dialogue box displays full-body portraits of the characters
- The player's spawning point now displays as a rectangle

#### Interface

- CircularMenu: open and close animations
- Added an interface to represent the characters' turn order in combat

#### Core

- Skills can now be unlocked as characters gain levels. Change the `level` property of the `Skill` to set the unlock level
- Pathfinder class to find the path between two points with AStar

#### Art

- Added map sprites for Robi and Godette
- Added a simple tileset for the grasslands

#### Tools

- RectExtents: a node to represent an animated character's bounding box/touch area
- Manipulator to edit RectExtents (BattlerAnim bounding boxes) directly on the 2d canvas

### Changed

- Updated to Godot 3.1 alpha 3
- Nicholas simplified and restructured the Battlers and Party members' code to make it more robust and easier to understand. Now the `Battler` delegates more calculations and logic to `CombatAction`
- Party Members now have a battler attached to them
- Increased the map's size

#### Code structure

- Improved the Grid's code
- Refactored the grid, pawns, battlers and party to make the code easier to follow
- Added docstrings to a few GDScript files
- Cleaned up and removed unused functions and files

### Fixes

- A skill that misses will now still reduce the battler's mana
- The link to the Code of Conduct in the readme is now correct
- Fixed a bug with life bars where if your max hp is higher than 100, the bar wouldn't be properly filled all the way
- Fixed death animation not playing when a battler dies
- Fixed touch input sometimes passing through buttons
- Fixed jerky animation when moving the player's pawn on the map
- Fixed skills learned by characters at the wrong level

## v0.2.0: Better Encounters ⚔🌟 - 2018-12-01

This version brings a lot of new features and improvements to the project's codebase thanks to the help of @godofgrunts, @nhydock, @salvob41, @MarianoGnu, @henriiquecampos, and @guilhermehto! We did at least twice as much as we planned thanks to everyone's help 😄

### New

#### Battle system

- Basic skill system. Allows to create special attacks, magic, etc.
  - CombatAction for skills
  - Simple menu to select CombatActions: Attack, Skill, etc.
  - Skills can be executed on a given probablity
- Character growth
  - Experience points are awarded at the end of battle to gain levels
  - The value of the characters' stats is based on Godot's curves
- Battle Formations for monsters and the player's party, based on .tscn files
- Added support for multiple targets. The interface to do it from the game is not available yet but you can now pass pass multiple targets to any combat action/command and it will affect all of them
- Animated pop-up labels. They show how much damage a character to took or how much mana someone lost. There's also animations ready for healing effects.
- The battlers now have a bounding rectangle based on the RectExtents node: we use it to place the interface or to determine the size of a character

#### Core

- Inventory and items: also manages the party's currency
- Persistent data between the combat and the map: after an encounter, the experience and items the characters earned gets transfered to the Party. This will allow us to add savegame support

#### Map

- Grid-based character movement
  - Follower pawns follow the leader or playable one with a one-step delay
- Dialogue system

#### User Interface

- Mana bars
- Circular menu: a radial menu you can use for battle, for the character to pick one of multiple CombatActions to use on its opponent. E.g. attack, a specific skill...
- Rewards screen: old-school, time-based rewards screen

#### Art

Added sprites for Godette, Robi, the porcupine, and the grasslands battle background sprites. There's also the first combat icon for Robi's base attack, the bilboshot.

None of the art is animated yet.

#### Audio

There is now a battle theme and a placeholder victory fanfare

### Changed

- Characters and Monsters now have mana
- Enemies now have a small chance of choosing the target with the lowest health; otherwise, they randomly choose targets
- Fixed job node duplicating itself with the tool mode
- Refactored the initialize loop and getting battlers
- Fixed incorrect indentation in Battler.gd
- Improved Data persistence in and out of combat
- Added some asserts in the code to help with debugging

## v0.1.0: Combat prototype ⚔ - 2018-11-04

Base combat prototype: the characters can only attack in a turn-based fashion. Health, damage, target selection, and winning and losing the fight are all present in a basic form.

### New

- Link to the contributor's guide on GDquest
- Note about static typing in Godot 3.1 in the README
- Note about maintainers refactoring PRs for stylization or educational purposes in the README
- Initial game concept, goal, story, mechanics (combat system), characters, aesthic choice, world information, technologies used, and prototypes to game_concept.md
