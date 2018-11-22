# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
 - Added a link to the contributor's guide on GDquest.
 - Added note about static typing in Godot 3.1 in the README.
 - Added a note about maintainers refactoring PRs for stylization or educational purposes in the README .
 - Added game_concept.md.
 - Added the initial game concept, goal, story, mechanics (combat system), characters, aesthic choice, world information, technologies used, and prototypes to game_concept.md.
 - Added choose_target function in Battler.gd. Enemies will have a small chance of choosing the target with the lowest health; otherwise, it will randomly choose a target.
 - Skills system added.
   - Initial stats now have mana.
   - A "combat action" for skills has been added.
   - A simple menu to select an action has been added.
   - Resource system for skills added.
   - Skills can be executed on a given probablity.
 - Added Character growth. Experience points are awarded at the end of battle to gain levels. Levels determine stat growth with defined curves for each character.
 - Mana bars added.
 - Added a "Local Map" and grid based navigation.
 - Added a signal in LocalMap that connects to its Parent Node.
 - Added Battle Formations.
 - local_map is removed when a battle begins and added when a battle ends to prevent input from changing its state.
 - Added Godette sprite
 - Added a dialogue system to LocalMap

### Changed
 - Fixed job node duplicating itself with the tool mode.
 - Refactored the initialize loop and getting battlers.
 - Fixed incorrect indentation in Battler.gd.
 - Improved Data persistence in and out of combat.

### Removed

## [0.1.0] - 2018-11-04

 - Initial Tag



