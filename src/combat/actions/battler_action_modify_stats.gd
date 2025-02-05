# A sample [BattlerAction] implementation that simulates a ranged attack, such as a fireball.
class_name StatsBattlerAction extends BattlerAction

const JUMP_DISTANCE: = 250.0

## A to-hit modifier for this attack that will be influenced by the target Battler's
## [member BattlerStats.evasion].
@export var added_value: = 10


func execute(source: Battler, targets: Array[Battler] = []) -> void:
	assert(not targets.is_empty(), "A ranged attack action requires a target.")
	
	await source.get_tree().create_timer(0.1).timeout

	# Animate a little jump from the source Battler to add some movement to the action.
	var origin: = source.position

	var tween: = source.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(source, "position", origin + Vector2(0, -JUMP_DISTANCE), 0.15)
	await tween.finished
	await source.get_tree().create_timer(0.1).timeout
	tween = source.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(source, "position", origin, 0.15)
	await tween.finished

	# No attack animations yet, so wait for a short delay and then apply damage to the target.
	# Normally we would wait for an attack animation's "triggered" signal and then spawn a
	# projectile, waiting for impact.
	await source.get_tree().create_timer(0.1).timeout
	for target in targets:
		target.stats.add_modifier("attack", added_value)
		target.stats.add_modifier("hit_chance", added_value)
	
	await source.get_tree().create_timer(0.1).timeout
