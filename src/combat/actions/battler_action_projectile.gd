# A sample [BattlerAction] implementation that simulates a ranged attack, such as a fireball.
class_name RangedBattlerAction extends BattlerAction

@export var attack_distance: = 350.0
@export var attack_time: = 0.25
@export var return_time: = 0.25
## A to-hit modifier for this attack that will be influenced by the target Battler's
## [member BattlerStats.evasion].
@export var hit_chance: = 100.0
@export var base_damage: = 50


func execute(source: Battler, targets: Array[Battler] = []) -> void:
	assert(not targets.is_empty(), "A ranged attack action requires a target.")
	var first_target: = targets[0]

	await source.get_tree().create_timer(0.1).timeout

	# Calculate where the acting Battler will move from and to.
	var origin: = source.position
	var attack_direction: float = sign(first_target.position.x - source.position.x)
	var destination: = origin + Vector2(attack_distance*attack_direction, 0)

	# Quickly animate the attacker to the attack position, pretending to lob a fireball or smth.
	var tween: = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(source, "position", destination, attack_time)
	await tween.finished

	# No attack animations yet, so wait for a short delay and then apply damage to the target.
	# Normally we would wait for an attack animation's "triggered" signal and then spawn a
	# projectile, waiting for impact.
	await source.get_tree().create_timer(0.1).timeout
	for target in targets:
		var hit: = BattlerHit.new(base_damage, hit_chance)
		target.take_hit(hit)
		await source.get_tree().create_timer(0.1).timeout
	
	await source.get_tree().create_timer(0.4).timeout

	# Animate movement back to the attacker's original position.
	tween = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", origin, return_time)
	await tween.finished

	await source.get_tree().create_timer(0.1).timeout
