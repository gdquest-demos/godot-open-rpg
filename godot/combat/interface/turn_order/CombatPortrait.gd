extends Control

class_name CombatPortrait

onready var animation_player : AnimationPlayer = $AnimationPlayer

onready var state = null
enum states {INITIALIZE, ACTIVE, WAITING, DISABLED} 

func initialize():

	#
	# TODO add the real battler portrait
	#

	_switch_state(INITIALIZE)

func activate():
	_switch_state(ACTIVE)

func wait():
	_switch_state(WAITING)

func disable():
	_switch_state(DISABLED)

func _switch_state(new_state):
	state = new_state
	match new_state:
		INITIALIZE:
			animation_player.play('initialize')
		ACTIVE:
			animation_player.play('activate')
		WAITING:
			animation_player.play('deactivate')
		DISABLED:
			animation_player.play('disable')
