## A playable combatant that carries out [BattlerActions] as its [member readiness] charges.
##
## Battlers are the playable characters or enemies that show up in battle. They have [BattlerStats],
## a list of [BattlerAction]s to choose from, and respond to a variety of stimuli such as status
## effects and [BattlerHit]s, which typically deal damage or heal the Battler.
##
## [br][br]Battlers have [BattlerAnim]ation children which play out the Battler's actions.
@tool
class_name Battler extends Node2D


## Emitted when the battler finished their action and arrived back at their rest position.
signal action_finished
## Forwarded from the receiving of [signal BettlerStats.health_depleted].
signal health_depleted
## Emitted when taking damage or being healed from a [BattlerHit].
## [br][br]Note the difference between this and [signal BattlerStats.health_changed]:
## 'hit_received' is always the direct result of an action, requiring graphical feedback.
signal hit_received(value: int)
## Emitted whenever a hit targeting this battler misses.
signal hit_missed
## Emitted when the battler's `_readiness` changes.
signal readiness_changed(new_value)
## Emitted when the battler is ready to take a turn.
signal ready_to_act
## Emitted when modifying `is_selected`. The user interface will react to this for
## player-controlled battlers.
signal selection_toggled(value: bool)

## A Battler must have [BattlerStats] to act and receive actions.
@export var stats: BattlerStats = null
## Each action's data stored in this array represents an action the battler can perform.
## These can be anything: attacks, healing spells, etc.
@export var actions: Array[BattlerAction]

## Each Battler is shown on the screen by a [BattlerAnim] object. The object is created dynamically
## from a PackedScene, which must yield a [BattlerAnim] object when instantiated.
@export var battler_anim_scene: PackedScene:
	set(value):
		battler_anim_scene = value
		
		if not is_inside_tree():
			await ready
		
		# Free an already existing BattlerAnim.
		if anim:
			anim.queue_free()
			anim = null
		
		# Add the new BattlerAnim class as a child and link it to this Battler instance.
		if battler_anim_scene:
			# Normally we could wrap a check for battler_anim_scene's type (should be BattlerAnim)
			# in a call to assert, but we want the following code to run in the editor and clean up
			# dynamically if the user drops an incorrect PackedScene (i.e. not a BattlerAnim) into
			# the battler_anim_scene slot.
			var new_scene: = battler_anim_scene.instantiate()
			anim = new_scene as BattlerAnim
			if not anim:
				push_warning("Battler '%s' cannot accept '%s' as " % [name, new_scene.name],
					"battler_anim_scene. '%s' is not a BattlerAnim!" % new_scene.name)
				new_scene.free()
				battler_anim_scene = null
				return
			
			add_child(anim)
			var facing: = BattlerAnim.Direction.LEFT if is_player else BattlerAnim.Direction.RIGHT
			anim.setup(self, facing)

## A CombatAI object that will determine the Battler's combat behaviour.
## If the battler has an `ai_scene`, we will instantiate it and let the AI make decisions.
## If not, the player controls this battler. The system should allow for ally AIs.
@export var ai_scene: PackedScene:
	set(value):
		ai_scene = value
		
		if ai_scene != null:
			# In the editor, check to make sure that the value set to ai_scene is actually a 
			# CombatAI bject.
			var new_instance: = ai_scene.instantiate()
			if Engine.is_editor_hint():
				if new_instance is not CombatAI:
					printerr("Cannot assign '%s' to Battler '%s'" % [new_instance.name, self.name] +
						" as ai_scene property. Assigned PackedScene is not a CombatAI type!")
					ai_scene = null
				new_instance.free()
			
			else:
				ai = new_instance
				add_child(ai)

## Player battlers are controlled by the player.
@export var is_player: = false:
	set(value):
		is_player = value
		if anim:
			var facing: = BattlerAnim.Direction.LEFT if is_player else BattlerAnim.Direction.RIGHT
			anim.direction = facing

## Reference to this Battler's child [CombatAI] node, if applicable.
var ai: CombatAI = null

## Reference to this Battler's child [BattlerAnim] node.
var anim: BattlerAnim = null

## If `false`, the battler will not be able to act.
var is_active: bool = true:
	set(value):
		is_active = value
		
		set_process(is_active)

## The turn queue will change this property when another battler is acting.
var time_scale := 1.0:
	set(value):
		time_scale = value

## If `true`, the battler is selected, which makes it move forward.
var is_selected: bool = false:
	set(value):
		if value:
			assert(is_selectable)

		is_selected = value
		selection_toggled.emit(is_selected)

## If `false`, the battler cannot be targeted by any action.
var is_selectable: bool = true:
	set(value):
		is_selectable = value
		if not is_selectable:
			is_selected = false

## When this value reaches `100.0`, the battler is ready to take their turn.
var readiness := 0.0:
	set(value):
		readiness = value
		readiness_changed.emit(readiness)

		if readiness >= 100.0:
			readiness = 100.0
			stats.energy += 1
			
			ready_to_act.emit()
			set_process(false)


func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false)
	
	else:
		assert(stats, "Battler %s does not have stats assigned!" % name)

		# Resources are NOT unique, so treat the currently assigned BattlerStats as a prototype.
		# That is, copy what it is now and use the copy, so that the original remains unaltered.
		stats = stats.duplicate()
		stats.initialize()
		stats.health_depleted.connect(func on_stats_health_depleted() -> void:
			is_active = false
			is_selectable = false
			health_depleted.emit()
		)


func _process(delta: float) -> void:
	readiness += stats.speed * delta * time_scale


func act(action: BattlerAction, targets: Array[Battler] = []) -> void:
	set_process(false)
	
	stats.energy -= action.energy_cost

	# action.execute() almost certainly is a coroutine.
	@warning_ignore("redundant_await")
	await action.execute(self, targets)
	if stats.health > 0:
		readiness = action.readiness_saved

		if is_active:
			set_process(true)

	action_finished.emit.call_deferred()


func take_hit(hit: BattlerHit) -> void:
	if hit.is_successful():
		hit_received.emit(hit.damage)
		stats.health -= hit.damage
	else:
		hit_missed.emit()


func is_ready_to_act() -> bool:
	return readiness >= 100.0
