class_name AttackBattlerAction extends BattlerAction

const ATTACK_DISTANCE: = 350.0

## A to-hit modifier for this attack that will be influenced by the target Battler's
## [member BattlerStats.evasion].
@export var hit_chance: = 100.0


func execute(source: Battler, targets: Array[Battler] = []) -> void:
	await source.get_tree().process_frame
	
	var origin: = source.position
	var attack_normal: float = sign(source.position.x - targets[0].position.x)
	var destination: = targets[0].position + Vector2(ATTACK_DISTANCE*attack_normal, 0)
	
	var tween: = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", destination, 0.25)
	await tween.finished
	
	await source.get_tree().create_timer(0.2).timeout
	
	tween = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", origin, 0.25)
	await tween.finished
	
	await source.get_tree().create_timer(0.1).timeout
