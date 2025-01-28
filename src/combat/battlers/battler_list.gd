## Keeps reference to the various combat participants, including all [Battler]s and their teams.
class_name BattlerList extends RefCounted

## Emitted immediately once the player has won or lost the battle. Note that all animations (such
## as the player or AI battlers disappearing) are not yet completed.
## This is the point at which most UI elements will disappear.
signal battlers_downed

var player_battlers: Array[Battler] = []:
	set(value):
		player_battlers = value
		print("Players ", player_battlers)
		for battler in player_battlers:
			# If a party member falls in battle, check to see if the player has lost.
			battler.health_depleted.connect(
				func _on_party_member_health_depleted():
					for player in player_battlers:
						if player.stats.health > 0:
							return
					
					# All player battlers have zero health. The player lost the battle!
					print("Player lost!")
					has_player_won = false
					battlers_downed.emit()
			)

var enemies: Array[Battler] = []:
	set(value):
		enemies = value
		print(enemies)
		for battler in enemies:
			# If an enemy falls in battle, check to see if the player has won.
			battler.health_depleted.connect(
				func _on_enemy_health_depleted():
					print("Enemy hp depleted")
					for enemy in enemies:
						if enemy.stats.health > 0:
							print("enemy %s has hp" % enemy.name)
							return
					
					# All enemy battlers have zero health. The player won!
					print("Player won!")
					has_player_won = true
					battlers_downed.emit()
			)

## Tracks whether or not the player has won the combat.
var has_player_won: = false


func _init(players: Array[Battler], enemy_battlers: Array[Battler]) -> void:
	player_battlers = players
	enemies = enemy_battlers


func get_all_battlers() -> Array[Battler]:
	var all_battlers: = player_battlers.duplicate()
	all_battlers.append_array(enemies)
	return all_battlers


func get_live_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(func(battler: Battler): return battler.stats.health > 0)
