# A sample [BattlerAction] implementation that simulates a direct melee hit.
class_name AttackBattlerAction extends BattlerAction

const ATTACK_DISTANCE: = 350.0

## A to-hit modifier for this attack that will be influenced by the target Battler's
## [member BattlerStats.evasion].
@export var hit_chance: = 100.0
@export var base_damage: = 50


func execute(source: Battler, targets: Array[Battler] = []) -> void:
	assert(not targets.is_empty(), "An attack action requires a target.")
	var first_target: = targets[0]

	await source.get_tree().create_timer(0.1).timeout

	# Calculate where the acting Battler will move from and to.
	var origin: = source.position
	var attack_normal: float = sign(source.position.x - first_target.position.x)
	var destination: = first_target.position + Vector2(ATTACK_DISTANCE*attack_normal, 0)

	# Animate movement to attack position.
	var tween: = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", destination, 0.25)
	await tween.finished

	# No attack animations yet, so wait for a short delay and then apply damage to the target.
	# Normally we would wait for an attack animation's "triggered" signal.
	await source.get_tree().create_timer(0.1).timeout
	for target in targets:
		
		
		# Incoporate Battler attack and a random variation (10% +- potential damage) to damage.
		var modified_damage: = base_damage + source.stats.attack
		var damage_dealt = modified_damage + (randf()-0.5)*0.2 * modified_damage
		
		# To hit is modified by a Battler's accuracy. That is, a Battler with 90 accuracy will have
		# 90% of the action's base to_hit chance.
		var to_hit: = hit_chance * (source.stats.hit_chance / 100.0)
		
		var hit: = BattlerHit.new(damage_dealt, to_hit)
		target.take_hit(hit)
		await source.get_tree().create_timer(0.1).timeout
	
	await source.get_tree().create_timer(0.1).timeout

	# Animate movement back to the attacker's original position.
	tween = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", origin, 0.25)
	await tween.finished

	await source.get_tree().create_timer(0.1).timeout
