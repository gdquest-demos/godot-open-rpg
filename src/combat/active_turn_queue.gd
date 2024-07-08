class_name ActiveTurnQueue extends Node2D

## Emitted when a player-controlled battler finished playing a turn. That is, when the _play_turn()
## method returns.
signal player_turn_finished

# If true, the player is currently playing a turn (navigating menus, choosing targets, etc.).
var _is_player_playing: = false

# A stack of player-controlled battlers that have to take turns.
var _queued_player_battlers: Array[Battler] = []

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
	player_turn_finished.connect(_on_player_turn_finished)
	
	for battler: Battler in battlers:
		battler.ready_to_act.connect(_on_battler_ready_to_act.bind(battler))
		
		if battler.is_player:
			_party_members.append(battler)
		
		else:
			_enemies.append(battler)


func _play_turn(battler: Battler) -> void:
	var action: BattlerAction
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
		_is_player_playing = true
		battler.is_selected = true
		
		time_scale = 0.05
		
		# Loop until the player selects a valid set of actions and targets of said action.
		var is_selection_complete: = false
		while not is_selection_complete:
			# First of all, the player must select an action.
			action = await _player_select_action_async(battler)
			
			# Secondly, the player must select targets for the action.
			# If the target may be selected automatically, do so.
			if action.targets_self:
				targets = [battler]
			else:
				targets = await _player_select_targets_async(action, potential_targets)
			
			# If the player selected a correct action and target, break out of the loop. Otherwise,
			# the player may reselect an action/targets.
			is_selection_complete = action != null and targets != []
		
		battler.is_selected = false
	
	else:
		# Allow the AI to take a turn.
		if battler.actions.size():
			action = battler.actions[0]
			targets = [potential_targets[0]]
	
	time_scale = 0
	await battler.act(action, targets)
	time_scale = 1.0
	
	if battler.is_player_controlled():
		player_turn_finished.emit()


func _player_select_action_async(battler: Battler) -> BattlerAction:
	await get_tree().process_frame
	return battler.actions[0]


func _player_select_targets_async(_action: BattlerAction, 
		opponents: Array[Battler]) -> Array[Battler]:
	await get_tree().process_frame
	return [opponents[0]]


func _on_battler_ready_to_act(battler: Battler) -> void:
	# If the battler is controlled by the player but another player-controlled battler is in the 
	# middle of a turn, we add this one to the stack.
	if battler.is_player_controlled() and _is_player_playing:
		_queued_player_battlers.append(battler)
	
	# Otherwise, it's an AI-controlled battler or the player is waiting for a turn.
	# The battler may act immediately.
	else:
		_play_turn(battler)


func _on_player_turn_finished() -> void:
	# When a player-controlled character finishes their turn and the stack is empty, the player is
	# no longer playing.
	if _queued_player_battlers.is_empty():
		_is_player_playing = false
	
	# Otherwise, we pop the array's first value and let the corresponding battler play their turn.
	else:
		_play_turn(_queued_player_battlers.pop_front())
