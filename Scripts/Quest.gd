# Quest.gd
extends Node

class_name Quest
signal quest_status_changed(status, quest)

enum QuestStatus {NOT_STARTED, IN_PROGRESS, COMPLETED}

var quest_id: String
var title: String
var description: String
var objective = {}
var start_dialogue: String
var end_dialogue: String
var npc_name: String
var npc_id: String
var reward_experience: int
var reward_items = []
var prerequisite_quests = []
var follow_up_quests = []
var location: String
var status: int = QuestStatus.NOT_STARTED

var current_count = 0

# Here, we've modified the constructor to accept quest_id separately
func _init(data: Dictionary, quest_id: String):
	print("Initializing quest:", quest_id)
	print("Data:", data)
	self.quest_id = quest_id  # Assigning the passed quest_id
	title = data["name"]
	description = data["description"]
	objective = data["objective"]
	start_dialogue = data["start_dialogue"]
	end_dialogue = data["end_dialogue"]
	npc_name = data["npc_name"]
	npc_id = data["npc_id"]
	reward_experience = data["experience"]
	reward_items = data["prizes"]
	prerequisite_quests = data["prerequisite_quests"]
	follow_up_quests = data["follow_up_quests"]
	location = data["location"]

func start():
	status = QuestStatus.IN_PROGRESS
	emit_signal("quest_status_changed", status)
	print("Objective type:", objective.type)
	connect_to_enemies()
	
	if objective.type == "kill":
		# Connect to the signal for enemy killed
		get_tree().connect("enemy_killed", self, "_on_enemy_killed")
		print("Objective is to kill ants")

func complete():
	print("quest completed")
	status = QuestStatus.COMPLETED
	emit_signal("quest_status_changed", status, self)
	# Handle reward distribution here
	for item in reward_items:
		var item_id = item["item_id"]
		var quantity = item["quantity"]
		# Add the items to player's inventory or similar mechanics


func connect_to_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		enemy.connect("enemy_killed", self, "_on_enemy_killed")


func _on_enemy_killed(enemy_name: String):
	print(objective.target)
	if objective.target == enemy_name:
		print(enemy_name)
		current_count += 1
		if current_count >= objective.count:
			complete()
