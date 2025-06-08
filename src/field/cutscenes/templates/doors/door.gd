@tool
class_name Door extends AreaTransition

@export var is_locked: = false:
	set(value):
		if value != is_locked:
			is_locked = value
			if not is_locked:
				open()

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _closed_door: = $Area2D/ClosedDoor as Sprite2D


func _ready() -> void:
	super._ready()


func open() -> void:
	# Do not open the door if it is already open.
	if not _closed_door.visible:
		return
	
	elif is_locked:
		_anim.play("locked")
	
	else:
		_anim.play("open")
	await _anim.animation_finished


func _on_area_entered(area: Area2D) -> void:
	# Only open the door if it is closed.
	if _closed_door.visible:
		_anim.play("open")
	
	await super._on_area_entered(area)


func _on_blackout() -> void:
	super._on_blackout()
	
	#TODO: this becomes redundant when world area loading is implemented.
	_anim.play("RESET")
