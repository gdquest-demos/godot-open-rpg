extends "res://local_map/pawns/PawnInteractive.gd"
class_name QuestPawn

onready var animation_player : = $AnimationPlayer
onready var quest_bubble : = $QuestBubble
onready var actions : = $Actions

const QUEST_ACTIVE_TEXTURE = preload("res://assets/sprites/icons/npc_quest_active.png")
const QUEST_FINISHED_TEXTURE = preload("res://assets/sprites/icons/npc_quest_finished.png")

