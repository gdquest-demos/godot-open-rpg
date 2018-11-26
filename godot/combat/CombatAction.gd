extends Node

class_name CombatAction

var initialized = false

var targets : Array = []
var allys : Array = []
var target : Battler = null
var skill_to_use : Skill = null

# Since Actions can be instanced by code (ie skills) these
# actions doesn't have an owner, that's why we get the owner
# from it's parent (BattlerActions.gd)
onready var actor : Battler = get_parent().get_owner()

export var icon : Texture
export var description : String = "Base combat action"

func initialize(p_targets : Array, p_allys : Array, p_actor : Battler) -> void:
	targets = p_targets
	allys = p_allys
	actor = p_actor
	initialized = true

func execute():
	assert(initialized)
	print("%s missing overwrite of the execute method" % name)
	return false

func attack_routine():
	actor.attack(target)
	yield(actor.get_tree().create_timer(1.0), "timeout")

func move_to_target_routine():
	yield(actor.skin.move_to(target), "completed")

func return_to_start_position_routine():
	yield(actor.skin.return_to_start(), "completed")

func select_target_routine():
	var interface = actor.get_tree().get_nodes_in_group("interface")[0]
	target = yield(interface.select_target(targets), "completed")
	interface.action_list.hide()
	return target

func use_skill_routine():
	if skill_to_use.success_chance == 1.0:
		actor.use_skill(target, skill_to_use)
	else:
		randomize()
		if rand_range(0, 1.0) < skill_to_use.success_chance:
			actor.use_skill(target, skill_to_use)
	yield(actor.get_tree().create_timer(1.0), "timeout")
	