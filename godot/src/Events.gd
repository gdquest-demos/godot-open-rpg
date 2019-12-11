extends Node
# Events autoload script for emitting signals.
# 
# It makes life much easier when we don't have to worry about the paths to different systems/nodes
# in order to connect their signals. This also means that all nodes using it will be in direct
# interdependency with this Node. This is not much of a problem though. All Nodes and systems
# are decoupled which means that if we want to use some component in another project that doesn't
# use the same Events class, we can just remove every line with `Events.` in it and we're good.


# dialog system
signal dialog_button_proceed_pressed
signal dialog_button_cycle_pressed

# battle system
signal battle_started(msg)
signal battle_finished(msg)

# input
signal triggered(msg) # on interaction key pressed, called here `trigger` (check Input Map)

# party members
signal party_member_setup(msg)

# party
signal party_walk_started(msg)
signal party_walk_finished(msg)

# encounters
signal encounter_probed(msg) # on mouse over Encounter