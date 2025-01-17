## Keeps reference to the various combat participants, including all [Battler]s and their teams.
class_name CombatTeamData extends RefCounted

## Emitted immediately once the player has won the battle. Note that all animations (such
## as the player or AI battlers disappearing) are not yet completed.
## This is the point at which most UI elements will disappear.
signal enemy_battlers_downed

## Emitted immediately once the player has lost the battle. Note that all animations (such
## as the player or AI battlers disappearing) are not yet completed.
## This is the point at which most UI elements will disappear.
signal player_battlers_downed

var player_battlers: Array[Battler] = []:
	set(value):
		player_battlers = value
		
		for battler in player_battlers:
			# If a party member falls in battle, check to see if the player has lost.
			battler.health_depleted.connect(
				func _on_party_member_health_depleted():
					for player in player_battlers:
						if player.stats.health > 0:
							return
					
					# All player battlers have zero health. The player lost the battle!
					has_player_won = false
					player_battlers_downed.emit()
			)

var enemies: Array[Battler] = []:
	set(value):
		enemies = value
		
		for battler in enemies:
			# If an enemy falls in battle, check to see if the player has won.
			battler.health_depleted.connect(
				func _on_enemy_health_depleted():
					for enemy in enemies:
						if enemy.stats.health > 0:
							return
					
					# All enemy battlers have zero health. The player won!
					has_player_won = true
					enemy_battlers_downed.emit()
			)

## Tracks whether or not the player has won the combat.
var has_player_won: = false


func get_all_battlers() -> Array[Battler]:
	var all_battlers: = player_battlers.duplicate()
	all_battlers.append_array(enemies)
	return all_battlers
