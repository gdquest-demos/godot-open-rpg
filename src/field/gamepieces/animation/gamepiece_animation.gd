@tool
## Encapsulates gamepiece animation as an optional component.
##
## [br][br][b]Note:[/b] Expects a gamepiece object as parent. The animation will use gamepiece info
## that is exposed via signal.
class_name GamepieceAnimation
extends Marker2D

const BLOCK_COLOR: = Color(0.690196, 0.188235, 0.376471, .42)
const RESET_SEQUENCE_KEY: = "RESET"

const DIRECTION_SUFFIXES: = {
	Directions.Points.N: "_n",
	Directions.Points.E: "_e",
	Directions.Points.S: "_s",
	Directions.Points.W: "_w",
}

var current_sequence_id: = "":
	set = play

## Animations may optionally be direction-based. Setting the facing will use directional animations
## if they are available; otherwise non-directional animations will be used.
var facing: = Directions.Points.N:
	set = set_facing

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _collision_shape: = $Area2D/CollisionShape2D as CollisionShape2D

# At times the current 'graphics' (the visible element, at times abbreviated 'gfx') will move
# separately from the rest of the animation or gamepiece.
# For example, when travelling between cells, the gamepiece needs to move instantly so that the
# physics element of the gamepiece fully occupies it's current cell. The gfx will lag behind and
# appear to run to catch up to the cell.
@onready var _gfx: = $GFX as Marker2D


func _ready() -> void:
	if not Engine.is_editor_hint():
		var gamepiece = get_parent() as Gamepiece
		assert(gamepiece, "GamepieceAnimation expects gamepiece information exposed via signals."
			+ " Please only use GamepieceAnimation as a child of a Gamepiece for correct animation."
			+ " Current parent is named %s." % get_parent().name)
		
		gamepiece.blocks_movement_changed.connect( \
			_on_gamepiece_blocks_movement_changed.bind(gamepiece))
		_on_gamepiece_blocks_movement_changed(gamepiece)
		
		gamepiece.arrived.connect(_on_gamepiece_arrived)
		gamepiece.direction_changed.connect(_on_gamepiece_direction_changed)
		gamepiece.travel_begun.connect(_on_gamepiece_travel_begun)
		
		# Need to wait one frame in the event that the parent gamepiece is not yet ready. We cannot
		# just wait for the ready signal since there is no guarantee that it will be emitted (for
		# example we may be swapping animation objects on an existing gamepiece).
		await get_tree().process_frame
		gamepiece.gfx_anchor.remote_path = gamepiece.gfx_anchor.get_path_to(_gfx)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not get_parent() is Gamepiece:
		warnings.append("GamepieceAnimation expects gamepiece information exposed via signals. "
			+ "Please only use GamepieceAnimation as a child of a Gamepiece for correct animation.")
	
	return warnings


func play(value: String) -> void:
	if value == current_sequence_id:
		return
	
	if not is_inside_tree():
		await ready
	
	# We need to check to see if the animation is valid.
	# First of all, look for a directional equivalent - e.g. idle_n. If that fails, look for 
	# the new sequence id itself.
	var sequence_suffix: String = DIRECTION_SUFFIXES.get(facing, "")
	if _anim.has_animation(value + sequence_suffix):
		current_sequence_id = value
		_swap_animation(value + sequence_suffix, false)
	
	elif _anim.has_animation(value):
		current_sequence_id = value
		_swap_animation(value, false)


func set_facing(value: Directions.Points) -> void:
	if value == facing:
		return
	
	facing = value
	
	if not is_inside_tree():
		await ready
	
	var sequence_suffix: String = DIRECTION_SUFFIXES.get(facing, "")
	if _anim.has_animation(current_sequence_id + sequence_suffix):
		_swap_animation(current_sequence_id + sequence_suffix, true)
	
	elif _anim.has_animation(current_sequence_id):
		_swap_animation(current_sequence_id, true)


func blocks_movement() -> bool:
	return not _collision_shape.disabled


func _swap_animation(next_sequence: String, keep_position: bool) -> void:
	var next_anim = _anim.get_animation(next_sequence)
	
	if next_anim:
		# If keeping the current position, we want to do so as a ratio of the
		# position / animation length to account for animations of different length.
		var current_position_ratio = 0
		if keep_position:
			current_position_ratio = \
				_anim.current_animation_position / _anim.current_animation_length
		
		# RESET the animation immediately to its default reset state before the next sequence.
		# Take advantage of the default RESET animation to clear uncommon changes (i.e. flip_h).
		if _anim.has_animation(RESET_SEQUENCE_KEY):
			_anim.play(RESET_SEQUENCE_KEY)
			_anim.advance(0)
		
		_anim.play(next_sequence)
		_anim.advance(current_position_ratio * next_anim.length)


func _on_gamepiece_arrived() -> void:
	_gfx.position = Vector2(0, 0)
	
	play("idle")


func _on_gamepiece_direction_changed(new_direction: Vector2) -> void:
	if not new_direction.is_equal_approx(Vector2.ZERO):
		var new_facing: = Directions.angle_to_direction(new_direction.angle())
		set_facing(new_facing)


# Change the collision shape's colour depending on whether or not it blocks pathfinding.
# Please turn on 'Visible Collision Shapes' under the editor's Debug menu to see which cells are
# occupied by gamepieces.
func _on_gamepiece_blocks_movement_changed(gamepiece: Gamepiece) -> void:
	if gamepiece.blocks_movement:
		_collision_shape.debug_color = BLOCK_COLOR
		_collision_shape.disabled = false
	
	else:
		_collision_shape.disabled = true


func _on_gamepiece_travel_begun():
	play("run")
