class_name RangedBattlerAction extends BattlerAction

## A to-hit modifier for this attack that will be influenced by the target Battler's
## [member BattlerStats.evasion].
@export var hit_chance: = 100.0


func execute(source: Battler, targets: Array[Battler] = []) -> void:
	await source.get_tree().process_frame
	print("%s lobs a fireball at %s!!!" % [source.name, str(targets)])
