@tool
class_name Door extends AreaTransition

# A locked door will block movement by placing a dummy gamepiece on the cell occupied by the door.
const GP_SCENE: = preload("res://src/field/gamepieces/gamepiece.tscn")

@export var is_locked: = false:
	set(value):
		if value != is_locked:
			is_locked = value
			
			if not is_inside_tree():
				await ready
			
			if is_locked:
				if _dummy_gp == null:
					_dummy_gp = GP_SCENE.instantiate()
					_dummy_gp.name = "CellBlocker"
					_closed_door.add_child(_dummy_gp)
			
			else:
				open()
				if _dummy_gp != null:
					_dummy_gp.queue_free()
					_dummy_gp = null

# Keep a reference to the object used to block movement through a locked door.
# Note that this gamepiece has no animation, movement, etc. It exists to occupy a board cell.
var _dummy_gp: Gamepiece = null

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
