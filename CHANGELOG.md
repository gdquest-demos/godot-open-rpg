# Changelog

All notable changes to this project will be documented in this file

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [UNRELEASED] v0.3.0: Motion and Dialogues 😮💬

### New

#### Map

- Leader and followers now reflect the player's party

#### Dialogues

- Character database: you can now reference a character and an expression by name when writing dialogues
- Portrait: the dialogue box displays full-body portraits of the characters

#### Core

- Skills can now be unlocked as characters gain levels. Change the `level` property of the `Skill` to set the unlock level

### Changed

- Nicholas simplified and restructured the Battlers and Party members' code to make it more robust and easier to understand. Now the `Battler` delegates more calculations and logic to `CombatAction`
- Party Members now have a battler attached to them

### Fixes

- A skill that misses will now still reduce the battler's mana
- The link to the Code of Conduct in the readme is now correct
- Fixed a bug with life bars where if your max hp is higher than 100, the bar wouldn't be properly filled all the way

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
