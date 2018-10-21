extends Node

var HookableLifebar = preload("res://combat/interface/lifebar/HookableLifeBar.tscn")

func initialize(battlers : Array):
	for battler in battlers:
		create_lifebar(battler)

func create_lifebar(battler : Battler):
	var lifebar = HookableLifebar.instance()
	battler.add_child(lifebar)
	lifebar.initialize(battler)
