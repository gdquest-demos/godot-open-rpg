""" Can't extend from StatBar (the class_name) because this won't let us export
the inherited variables from the base class """
extends "res://combat/interface/bars/StatBar.gd"

onready var preview_arrow = $Column/TextureProgress/ManaPreview
onready var texture_progress = $Column/TextureProgress
var mana_size : int 

func initialize(battler : Battler) -> void:
	_connect_value_signals(battler)
	mana_size = int(round((texture_progress.rect_size.x - 4) / self.max_value))
	
func _connect_value_signals(battler : Battler) -> void:
	var battler_stats = battler.stats
	battler_stats.connect("mana_changed", self, "_on_value_changed")
	battler_stats.connect("mana_depleted", self, "_on_value_depleted")
	
	self.max_value = battler_stats.max_mana
	self.value = battler_stats.mana

func _on_button_focused(cost) -> void:
	if cost > self.value:
		return

	preview_arrow.position.x = texture_progress.rect_position.x + ((self.value - cost) * mana_size)
	preview_arrow.visible = true

func _on_button_unfocused() -> void:
	preview_arrow.visible = false

func _on_value_changed(new_value, old_value) -> void:
	self.value = new_value
