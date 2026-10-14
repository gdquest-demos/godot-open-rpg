## A discrete chunk of game logic, initialized by the [Game].
##
## A GameState is a self-contianed unit of gameplay, such as when the player navigates the main menu
## or controls battlers in combat. While most states will rely on player state (for example, which
## area the player is visiting or which enemies they are fighting), GameStates should remain
## logically distinct from one another.
class_name GameState extends Node


## Begins the state's logic or animation.
## Deferred until a frame after the GameState is added to the SceneTree.
## [br][br][b]Note:[/b] Prefer using _ready() for initialization and start() for game logic.
func start() -> void:
	await Transition.clear(0.5)
