extends Control

onready var monster_info = $Row/MonstersPanel/Column


func initialize(battlers: Array):
	for b in battlers:
		var battler = b as Battler
		if battler.party_member:
			continue

		var widget = preload("res://src/combat/interface/MonsterWidget.tscn").instance()
		widget.monster = battler
		monster_info.add_child(widget)
