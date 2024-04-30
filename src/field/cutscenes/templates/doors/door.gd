@tool

class_name Door extends AreaTransition

@export var is_locked: = false:
	set(value):
		is_locked = value
		
		if not Engine.is_editor_hint():
			if not is_inside_tree():
				await ready
			
			_blocking_area.get_node("CollisionShape2D").disabled = !is_locked
			
			# Wait one frame for the physics server to update before rebuilding the pathfinders.
			await get_tree().physics_frame
			FieldEvents.terrain_changed.emit()

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _blocking_area: = $Area2D/ClosedDoor/BlockingArea as Area2D
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
