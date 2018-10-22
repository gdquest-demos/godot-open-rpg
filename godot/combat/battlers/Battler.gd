extends Position2D

class_name Battler

export var TARGET_OFFSET_DISTANCE : float = 120.0

onready var stats : CharacterStats = $Job/Stats
onready var lifebar_anchor = $InterfaceAnchor
onready var skin = $Skin
onready var actions = $Actions

var target_global_position : Vector2

var selected : bool = false setget set_selected
var selectable : bool = false

func initialize():
	var direction : Vector2 = Vector2(-1.0, 0.0) if is_in_group('party') else Vector2(1.0, 0.0)
	target_global_position = $TargetAnchor.global_position + direction * TARGET_OFFSET_DISTANCE
	
	stats.connect("health_depleted", self, "_on_health_depleted")
	self.selectable = true

func play_turn(target : Battler, action):
	yield(skin.move_forward(), "completed")
	action.execute(self, target)
	yield(skin.move_to(target), "completed")
	yield(get_tree().create_timer(1.0), "timeout")
	yield(skin.return_to_start(), "completed")

func set_selected(value):
	selected = value
	skin.blink = value

func attack(target : Battler):
	var hit = Hit.new(stats.strength)
	target.take_damage(hit)

func take_damage(hit):
	stats.take_damage(hit)
	skin.play_stagger()

func _on_health_depleted():
	selectable = false
	yield(skin.play_death(), "completed")
	queue_free()
