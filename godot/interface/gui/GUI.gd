extends CanvasLayer
class_name GUI

onready var tween : = $Tween as Tween
onready var quest_journal = $Control/QuestJorunal as QuestJournal
onready var quest_button : = $Control/QuestButton as TextureButton
onready var animation_player : = $Control/AnimationPlayer as AnimationPlayer

var quests = [
	{ "title": "Active Quest", "active": true, "finished": false, "objectives": [{ "title": "Slay 15 porcupines", "finished": false }, { "title": "Speak with Godette", "finished": true }] },
	{ "title": "Active Quest", "active": true, "finished": false, "objectives": [{ "title": "Slay 15 porcupines", "finished": false }] },
	{ "title": "Finished Quest", "active": true, "finished": true,  "objectives": [{ "title": "Slay 10 porcupines", "finished": true }, { "title": "Speak with Robi", "finished": true }] },
	{ "title": "Inactive Quest", "active": false, "finished": true,  "objectives": [{ "title": "Slay 5 great porcupines", "finished": true }] },
	{ "title": "Inactive Quest", "active": false, "finished": true,  "objectives": [{ "title": "Slay 5 great porcupines", "finished": true }] },
	{ "title": "Finished Quest", "active": true, "finished": true,  "objectives": [{ "title": "Slay 10 porcupines", "finished": true }, { "title": "Speak with Robi", "finished": true }] },
	{ "title": "Finished Quest", "active": true, "finished": true,  "objectives": [{ "title": "Slay 10 porcupines", "finished": true }, { "title": "Speak with Robi", "finished": true }] },
	{ "title": "Inactive Quest", "active": false, "finished": true,  "objectives": [{ "title": "Slay 5 great porcupines", "finished": true }] },
	{ "title": "Active Quest", "active": true, "finished": false, "objectives": [{ "title": "Slay 15 porcupines", "finished": false }] },
	{ "title": "Finished Quest", "active": true, "finished": true,  "objectives": [{ "title": "Slay 10 porcupines", "finished": true }, { "title": "Speak with Robi", "finished": true }] },
	{ "title": "Active Quest", "active": true, "finished": false, "objectives": [{ "title": "Slay 15 porcupines", "finished": false }] },
	{ "title": "Inactive Quest", "active": false, "finished": true,  "objectives": [{ "title": "Slay 5 great porcupines", "finished": true }] },
]

func _ready() -> void:
	for quest in quests:
		quest_journal.add_quest(quest)

func _on_quest_started(quest) -> void:
	quest_journal.add_quest(quest)
	_wiggle_element(quest_button)

func _on_quest_finished(quest) -> void:
	quest_journal.mark_quest_as_finished(quest)
	_wiggle_element(quest_button)

func _on_quest_delivered(quest) -> void:
	quest_journal.mark_quest_as_delivered(quest)
	_wiggle_element(quest_button)

func _wiggle_element(element) -> void:
	var offset = Vector2(15, 0)
	var last_position = element.rect_position
	var wiggles = 6
	for i in range(wiggles):
		var direction = 1 if i % 2 == 0 else - 1
		tween.interpolate_property(element,
			"rect_position",
			last_position,
			element.rect_position + offset * direction,
			0.05,
			Tween.TRANS_BOUNCE, 
			Tween.EASE_IN,
			i * 0.05)
		last_position = element.rect_position + offset * direction
	tween.interpolate_property(element,
			"rect_position",
			last_position,
			element.rect_position,
			0.05,
			Tween.TRANS_BOUNCE, 
			Tween.EASE_IN,
			wiggles * 0.05)
	tween.start()

func _on_QuestButton_pressed():
	animation_player.play("slide_out_quest_journal" if quest_journal.active else "slide_in_quest_journal")
	quest_journal.active = not quest_journal.active
