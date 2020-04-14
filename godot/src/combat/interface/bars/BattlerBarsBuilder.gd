extends Node

var HookableLifebar = preload("res://src/combat/interface/bars/lifebar/HookableLifeBar.tscn")
var HookableManaBar = preload("res://src/combat/interface/bars/manabar/HookableManaBar.tscn")


func initialize(battlers: Array) -> void:
	for battler in battlers:
		create_lifebar(battler)
		if battler.stats.max_mana > 0:
			create_manabar(battler)


func create_lifebar(battler: Battler) -> void:
	var lifebar = HookableLifebar.instance()
	battler.bars.add_child(lifebar)
	lifebar.initialize(battler)


func create_manabar(battler: Battler) -> void:
	var manabar = HookableManaBar.instance()
	battler.bars.add_child(manabar)
	manabar.initialize(battler)
