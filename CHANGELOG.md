# Changelog

All notable changes to this project will be documented in this file

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased] v0.2.0: Better Encounters ⚔🌟

Expand the combat system and create a bite-sized, playable demo revolving around it.

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

#### Map

- Grid-based character movement
- Dialogue system

#### User Interface

- Mana bars

#### Art

- Godette sprite

### Changed

- Characters and Monsters now have mana
- Enemies now have a small chance of choosing the target with the lowest health; otherwise, they randomly choose targets
- Fixed job node duplicating itself with the tool mode
- Refactored the initialize loop and getting battlers
- Fixed incorrect indentation in Battler.gd
- Improved Data persistence in and out of combat

<!-- ### Removed -->

## v0.1.0: Combat prototype ⚔ - 2018-11-04

Base combat prototype: the characters can only attack in a turn-based fashion. Health, damage, target selection, and winning and losing the fight are all present in a basic form.

### New

- Link to the contributor's guide on GDquest
- Note about static typing in Godot 3.1 in the README
- Note about maintainers refactoring PRs for stylization or educational purposes in the README
- Initial game concept, goal, story, mechanics (combat system), characters, aesthic choice, world information, technologies used, and prototypes to game_concept.md
