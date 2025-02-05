# A sample [BattlerAction] implementation that simulates a direct melee hit.
class_name HealBattlerAction extends BattlerAction

const JUMP_DISTANCE: = 250.0

@export var heal_amount: = 50


func execute(source: Battler, targets: Array[Battler] = []) -> void:
	assert(not targets.is_empty(), "An attack action requires a target.")

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

	# Wait for a short delay and then apply healing to the targets.
	await source.get_tree().create_timer(0.1).timeout
	var hit: = BattlerHit.new(-heal_amount, 100.0)
	for target in targets:
		target.take_hit(hit)
		
		# Pause slightly between heals.
		await source.get_tree().create_timer(0.1).timeout

	# Pause slightly before resuming combat.
	await source.get_tree().create_timer(0.1).timeout
