# A sample [BattlerAction] implementation that simulates a direct melee hit.
class_name AttackBattlerAction extends BattlerAction

const ATTACK_DISTANCE: = 350.0

## A to-hit modifier for this attack that will be influenced by the target Battler's
## [member BattlerStats.evasion].
@export var hit_chance: = 100.0
@export var base_damage: = 50


func execute(source: Battler, targets: Array[Battler] = []) -> void:
	assert(not targets.is_empty(), "An attack action requires a target.")
	var target: = targets[0]

	await source.get_tree().create_timer(0.1).timeout

	# Calculate where the acting Battler will move from and to.
	var origin: = source.position
	var attack_normal: float = sign(source.position.x - target.position.x)
	var destination: = target.position + Vector2(ATTACK_DISTANCE*attack_normal, 0)

	# Animate movement to attack position.
	var tween: = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", destination, 0.25)
	await tween.finished

	# No attack animations yet, so wait for a short delay and then apply damage to the target.
	# Normally we would wait for an attack animation's "triggered" signal.
	await source.get_tree().create_timer(0.1).timeout
	var hit: = BattlerHit.new(base_damage, hit_chance)
	target.take_hit(hit)
	await source.get_tree().create_timer(0.1).timeout

	# Animate movement back to the attacker's original position.
	tween = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", origin, 0.25)
	await tween.finished

	await source.get_tree().create_timer(0.1).timeout
