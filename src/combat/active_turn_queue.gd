class_name ActiveTurnQueue extends Node2D

var _party_members: = []
var _enemies: = []

# Allows pausing the Active Time Battle during combat intro, a cutscene, or combat end.
var is_active: = true:
	set(value):
		if value != is_active:
			is_active = value
			for battler: Battler in battlers:
				battler.is_active = is_active

# Multiplier for the global pace of battle, to slow down time while the player is making decisions.
# This is meant for accessibility and to control difficulty.
var time_scale: = 1.0:
	set(value):
		time_scale = value
		for battler: Battler in battlers:
			battler.time_scale = time_scale 

@onready var battlers: = get_children()


func _ready() -> void:
	for battler: Battler in battlers:
		battler.ready_to_act.connect(_on_battler_ready_to_act.bind(battler))
		
		if battler.is_player:
			_party_members.append(battler)
		
		else:
			_enemies.append(battler)


func _play_turn(battler: Battler) -> void:
	var action_data: ActionData
	var targets: Array[Battler] = []
	
	# The battler is getting a new turn, so increment its energy count.
	battler.stats.energy += 1
	
	# The code below makes a list of selectable targets using Battler.is_selectable
	var potential_targets: Array[Battler] = []
	var opponents: = _enemies if battler.is_player else _party_members
	for opponent: Battler in opponents:
		if opponent.is_selectable:
			potential_targets.append(opponent)
	
	if battler.is_player_controlled():
		battler.is_selected = true
		
		time_scale = 0.05
		
		# Loop until the player selects a valid set of actions and targets of said action.
		var is_selection_complete: = false
		while not is_selection_complete:
			# First of all, the player must select an action.
			action_data = await _player_select_action_async(battler)
			
			# Secondly, the player must select targets for the action.
			# If the target may be selected automatically, do so.
			if action_data.is_targeting_self:
				targets = [battler]
			else:
				targets = await _player_select_targets_async(action_data, potential_targets)
			
			# If the player selected a correct action and target, break out of the loop. Otherwise,
			# the player may reselect an action/targets.
			is_selection_complete = action_data != null and targets != []
		
		time_scale = 1.0
		battler.is_selected = false
	
	else:
		# Allow the AI to take a turn.
		if battler.actions.size():
			action_data = battler.actions[0]
			targets = [potential_targets[0]]


func _player_select_action_async(battler: Battler) -> ActionData:
	await get_tree().process_frame
	return battler.actions[0]


func _player_select_targets_async(_action: ActionData, opponents: Array[Battler]) -> Array[Battler]:
	await get_tree().process_frame
	return [opponents[0]]


func _on_battler_ready_to_act(battler: Battler) -> void:
	_play_turn(battler)
