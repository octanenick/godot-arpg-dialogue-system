# QuestManager.gd
extends Node

# Signals
signal quest_status_response(quest_id, status)

var all_quests = {}  # Store all the quests from the JSON here
var active_quests = []
var completed_quests = []

func load_quests():
	var file = File.new()
	if file.file_exists("res://Quests/Quests.json"):
		file.open("res://Quests/Quests.json", File.READ)
		all_quests = JSON.parse(file.get_as_text()).result
		file.close()
	else:
		print("Quests.json not found!")


func _ready():
	load_quests()
	#var dialogue_manager = get_tree().get_nodes_in_group("DialogueManager")[0]
	DialogueManager.connect("request_quest_status", self, "_on_request_quest_status")

func _on_request_quest_status(quest_id):
	var status = check_quest_status(quest_id)
	emit_signal("quest_status_response", quest_id, status)

func check_quest_status(quest_id):
	# Check if the quest is in the active quests list
	for quest in active_quests:
		if quest.quest_id == quest_id:
			return "active"

	# Check if the quest is in the completed quests list
	for quest in completed_quests:
		if quest.quest_id == quest_id:
			return "completed"

	# If the quest is not active or completed, it's considered available
	return "available"

func start_quest_by_id(quest_id: String):
	if all_quests.has(quest_id):
		var quest_data = all_quests[quest_id]
		var new_quest = Quest.new(quest_data, quest_id)
		add_child(new_quest)
		new_quest.start()
		print("started new quest")
		active_quests.append(new_quest)
		new_quest.connect("quest_status_changed", self, "_on_quest_status_changed")	
		emit_signal("quests_updated")
	else:
		print("Quest with id %s not found!" % quest_id)

func _on_quest_status_changed(new_status: int, quest: Quest): # Receive the quest instance as a parameter
	if new_status == Quest.QuestStatus.COMPLETED:
		complete_quest(quest)


# Add a new quest to the active quest list
func add_quest(quest: Quest):
	active_quests.append(quest)
	emit_signal("quests_updated")

# Mark a quest as completed and move it to the completed list
func complete_quest(quest: Quest):
	#quest.complete()
	active_quests.erase(quest)
	completed_quests.append(quest)
	emit_signal("quests_updated")

# Return a specific quest based on its name or null if not found
func get_quest_by_id(quest_id: int) -> Quest:
	for quest in active_quests:
		if quest.id == quest_id:
			return quest
	return null
