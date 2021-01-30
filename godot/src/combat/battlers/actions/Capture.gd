extends CombatAction

func execute(targets):
	assert(initialized)
	if actor.party_member and not targets:
		return false

	for target in targets:
		yield(actor.skin.move_to(target), "completed")
		if target.stats.health < 100:
			var hit = Hit.new(1000)
			#var combat_arena = target.get_parent().get_parent()
			#combat_arena.capture_reward()
			
			#target.drops.get_children().push_back({'item': 'Slime.tres', 'amount': '1'})
			var monster_collection: MonsterCollection = get_node("/root/Game/MonsterCollection")
			#This is not the most sensible place to be constructing the slime
			#Its stats should instead get figured/copied from the target that was captured
			var slime: Slime = Slime.new()
			#slime.stats = load("res://src/slimes/CherrySlime.tres")
			slime.stats = target.stats
			slime.hp = slime.stats.max_health
			slime.mp = slime.stats.max_mana
			slime.xp = 0
			monster_collection.add_slime(slime)
			
			target.take_damage(hit)
		yield(actor.get_tree().create_timer(1.0), "timeout")
		yield(return_to_start_position(), "completed")
	return true
	
#func temp() -> void:
#	var monster_collection: MonsterCollection = get_node("/root/Game/MonsterCollection")

#	#This is not the most sensible place to be constructing the slime
#	#Its stats should instead get figured from what was capture
#	print("woo")
#	var slime: Slime = Slime.new()
#	slime.stats = load("res://src/slimes/CherrySlime.tres")
#	slime.hp = slime.stats.max_health
#	slime.xp = 0
#	monster_collection.add_slime(slime)


#func _ready() -> void:
#	temp()







