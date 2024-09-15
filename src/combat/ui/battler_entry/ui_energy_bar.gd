# Bar representing a [Battler]'s energy points. Each point is a [UIEnergyPoint].
class_name UIBattlerEnergyBar extends Node

const ENERGY_POINT_SCENE: = preload("res://src/combat/ui/battler_entry/ui_energy_point.tscn")

## The maximum number of energy points that a [Battler] may accumulate.
var max_value: = 0:
	set(new_max_value):
		max_value = new_max_value
		
		for i in max_value:
			var new_point: = ENERGY_POINT_SCENE.instantiate()
			add_child(new_point)

## The number of energy points currently available to a given [Battler].
var value: = 0:
	set(new_value):
		var old_value: = value
		value = clampi(new_value, 0, max_value)
		
		# If we have more points, we need to play the "appear" animation on the added points only.
		# That's why we generate a range of indices from `old_value` to `value`.
		if value > old_value:
			for i in range(old_value, value):
				get_child(i).appear()
		
		# Otherwise, flag which points need to "disappear".
		else:
			for i in range(old_value, value, -1):
				get_child(i - 1).disappear()

## The number of points currently selected, often shown when previewing an action.
var selected_point_count: = 0:
	set(new_value):
		var old_value := selected_point_count
		selected_point_count = clampi(new_value, 0, max_value)
		if selected_point_count > old_value:
			for i in range(old_value, selected_point_count):
				get_child(i).select()
		else:
			for i in range(old_value, selected_point_count, -1):
				get_child(i - 1).deselect()


func setup(max_energy: int, start_energy: int) -> void:
	max_value = max_energy
	value = start_energy
