extends CanvasLayer


@onready var _player_battler_list: = $PlayerBattlerList as UIPlayerBattlerList


func _ready() -> void:
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler):
			if battler.stats.health > 0:
				print("%s was selected!" % battler.name)
	)
	
